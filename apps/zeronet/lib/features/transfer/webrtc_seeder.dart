import 'dart:async';
import 'dart:io';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nostr_wrapper/nostr.dart';

import 'signaling.dart';

/// Listens for incoming WebRTC connection requests on a relay and serves files.
class WebRtcSeeder {
  WebRtcSeeder({
    required this.secretKey,
    required this.relayUrl,
  });

  final String secretKey;
  final String relayUrl;
  RelaySubscription? _sub;
  final _peerConnections = <String, RTCPeerConnection>{};

  /// Files available for serving, keyed by sha256.
  final Map<String, String> filesBySha256 = {};

  /// Starts listening for signaling events addressed to our pubkey.
  Future<void> start() async {
    final keys = Keys(secretKey);
    print('[seeder] starting, pubkey: ${keys.public}');

    _sub = await NostrRelay.subscribe(
      relayUrl,
      Filter(kinds: [signalingKind], pTags: [keys.public]),
    );

    _sub!.events.listen((event) => _handleSignaling(event, keys));
  }

  Future<void> _handleSignaling(Event event, Keys keys) async {
    final payload = parseSignalingPayload(event);
    final type = payload['type'] as String;
    final senderPubkey = event.pubkey;

    print('[seeder] received signaling: type=$type from=$senderPubkey');

    switch (type) {
      case 'offer':
        await _handleOffer(payload, senderPubkey, keys);
      case 'ice':
        await _handleIce(payload, senderPubkey);
    }
  }

  Future<void> _handleOffer(
    Map<String, dynamic> payload,
    String senderPubkey,
    Keys keys,
  ) async {
    final pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });
    _peerConnections[senderPubkey] = pc;

    // Handle ICE candidates
    pc.onIceCandidate = (candidate) {
      print('[seeder] sending ICE candidate to $senderPubkey');
      final event = createSignalingEvent(
        secretKey: keys.secret,
        recipientPubkey: senderPubkey,
        payload: {
          'type': 'ice',
          'candidate': candidate.toMap(),
        },
      );
      _sub?.send(event);
    };

    // Handle incoming data channel from leecher
    pc.onDataChannel = (channel) {
      print('[seeder] data channel opened: ${channel.label}');
      channel.onMessage = (msg) async {
        final request = msg.text;
        print('[seeder] received request: $request');
        if (request.startsWith('request:')) {
          final sha256 = request.substring(8);
          await _serveFile(channel, sha256);
        }
      };
    };

    // Set remote description (the offer)
    final sdp = payload['sdp'] as String;
    await pc.setRemoteDescription(
      RTCSessionDescription(sdp, 'offer'),
    );

    // Create and send answer
    final answer = await pc.createAnswer();
    await pc.setLocalDescription(answer);

    print('[seeder] sending answer to $senderPubkey');
    final answerEvent = createSignalingEvent(
      secretKey: keys.secret,
      recipientPubkey: senderPubkey,
      payload: {
        'type': 'answer',
        'sdp': answer.sdp,
      },
    );
    _sub?.send(answerEvent);
  }

  Future<void> _handleIce(
    Map<String, dynamic> payload,
    String senderPubkey,
  ) async {
    final pc = _peerConnections[senderPubkey];
    if (pc == null) return;

    final candidateMap = payload['candidate'] as Map<String, dynamic>;
    await pc.addCandidate(RTCIceCandidate(
      candidateMap['candidate'] as String?,
      candidateMap['sdpMid'] as String?,
      candidateMap['sdpMLineIndex'] as int?,
    ));
  }

  Future<void> _serveFile(RTCDataChannel channel, String sha256) async {
    final filePath = filesBySha256[sha256];
    if (filePath == null) {
      print('[seeder] file not found: $sha256');
      channel.send(RTCDataChannelMessage('error:not_found'));
      return;
    }

    print('[seeder] serving file: $filePath');
    final bytes = await File(filePath).readAsBytes();

    // Send file size first
    channel.send(RTCDataChannelMessage('size:${bytes.length}'));

    // Send in chunks (16KB)
    const chunkSize = 16384;
    for (var offset = 0; offset < bytes.length; offset += chunkSize) {
      final end = (offset + chunkSize).clamp(0, bytes.length);
      channel.send(RTCDataChannelMessage.fromBinary(
        bytes.sublist(offset, end),
      ));
    }

    // Signal completion
    channel.send(RTCDataChannelMessage('done'));
    print('[seeder] file transfer complete');
  }

  Future<void> stop() async {
    for (final pc in _peerConnections.values) {
      await pc.close();
    }
    _peerConnections.clear();
    await _sub?.dispose();
    _sub = null;
  }
}
