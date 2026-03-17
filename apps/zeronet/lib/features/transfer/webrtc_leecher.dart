import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'signaling.dart';

/// Downloads a file from a seeder via WebRTC DataChannel.
class WebRtcLeecher {
  /// Initiates a WebRTC connection to the seeder and downloads a file.
  ///
  /// Returns the local file path where the downloaded file was saved.
  static Future<String> download({
    required String secretKey,
    required String seederPubkey,
    required String sha256,
    required String fileName,
    required String relayUrl,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final keys = Keys(secretKey);
    print('[leecher] starting download from $seederPubkey, file: $sha256');

    // Subscribe for signaling responses
    final sub = await NostrRelay.subscribe(
      relayUrl,
      Filter(kinds: [signalingKind], pTags: [keys.public]),
    );

    final pc = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    // Handle ICE candidates — send to seeder
    pc.onIceCandidate = (candidate) {
      print('[leecher] sending ICE candidate');
      final event = createSignalingEvent(
        secretKey: keys.secret,
        recipientPubkey: seederPubkey,
        payload: {
          'type': 'ice',
          'candidate': candidate.toMap(),
        },
      );
      sub.send(event);
    };

    // Listen for signaling responses (answer + ICE)
    sub.events.listen((event) async {
      if (event.pubkey != seederPubkey) return;
      final payload = parseSignalingPayload(event);
      final type = payload['type'] as String;
      print('[leecher] received signaling: type=$type');

      switch (type) {
        case 'answer':
          final sdp = payload['sdp'] as String;
          await pc.setRemoteDescription(
            RTCSessionDescription(sdp, 'answer'),
          );
        case 'ice':
          final candidateMap = payload['candidate'] as Map<String, dynamic>;
          await pc.addCandidate(RTCIceCandidate(
            candidateMap['candidate'] as String?,
            candidateMap['sdpMid'] as String?,
            candidateMap['sdpMLineIndex'] as int?,
          ));
      }
    });

    // Create data channel
    final channel = await pc.createDataChannel(
      'file-transfer',
      RTCDataChannelInit()..ordered = true,
    );

    // Create and send offer
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);

    print('[leecher] sending offer to $seederPubkey');
    final offerEvent = createSignalingEvent(
      secretKey: keys.secret,
      recipientPubkey: seederPubkey,
      payload: {
        'type': 'offer',
        'sdp': offer.sdp,
      },
    );
    sub.send(offerEvent);

    // Wait for file transfer over data channel
    final completer = Completer<String>();
    final chunks = <Uint8List>[];
    var expectedSize = 0;

    channel.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        print('[leecher] data channel open, requesting file');
        channel.send(RTCDataChannelMessage('request:$sha256'));
      }
    };

    channel.onMessage = (msg) {
      if (msg.isBinary) {
        chunks.add(msg.binary);
        final received = chunks.fold<int>(0, (sum, c) => sum + c.length);
        print('[leecher] received chunk, total: $received/$expectedSize');
      } else {
        final text = msg.text;
        if (text.startsWith('size:')) {
          expectedSize = int.parse(text.substring(5));
          print('[leecher] expecting $expectedSize bytes');
        } else if (text == 'done') {
          print('[leecher] transfer complete');
          _saveFile(sha256, fileName, chunks).then(completer.complete);
        } else if (text.startsWith('error:')) {
          completer.completeError(Exception('Seeder error: $text'));
        }
      }
    };

    try {
      final path = await completer.future.timeout(timeout);
      return path;
    } finally {
      await channel.close();
      await pc.close();
      await sub.dispose();
    }
  }

  static Future<String> _saveFile(
    String sha256,
    String fileName,
    List<Uint8List> chunks,
  ) async {
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(supportDir.path, 'websites', sha256));
    await dir.create(recursive: true);
    final file = File(p.join(dir.path, fileName));

    final sink = file.openWrite();
    for (final chunk in chunks) {
      sink.add(chunk);
    }
    await sink.close();

    print('[leecher] saved to ${file.path}');
    return file.path;
  }
}
