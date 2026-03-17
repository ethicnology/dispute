import 'dart:async';
import 'dart:math';

import 'package:nostr/nostr.dart';
import 'package:web_socket/web_socket.dart' show TextDataReceived, WebSocket;

class NostrRelay {
  /// Opens a WebSocket to [relayUrl], sends the signed [event], and closes.
  static Future<void> publish(String relayUrl, Event event) async {
    print('[relay] publish to $relayUrl, event: ${event.id}');
    final ws = await WebSocket.connect(Uri.parse(relayUrl));
    try {
      final payload = event.serialize();
      print('[relay] sending: ${payload.substring(0, payload.length.clamp(0, 200))}...');
      ws.sendText(payload);
      final response = await ws.events.first.timeout(const Duration(seconds: 5));
      print('[relay] response: $response');
    } finally {
      await ws.close();
    }
  }

  /// Sends a REQ, collects events until EOSE, then closes.
  static Future<List<Event>> query(String relayUrl, Filter filter) async {
    print('[relay] query $relayUrl, filter: ${filter.toJson()}');
    final ws = await WebSocket.connect(Uri.parse(relayUrl));
    final subId = _randomHex(10);
    final req = Request(subscriptionId: subId, filters: [filter]);
    print('[relay] REQ: ${req.serialize()}');
    ws.sendText(req.serialize());

    final events = <Event>[];
    try {
      await for (final msg in ws.events) {
        if (msg is! TextDataReceived) continue;
        final message = Message.deserialize(msg.text);
        if (message.type == 'EVENT') {
          events.add(message.message as Event);
        } else if (message.type == 'EOSE') {
          break;
        }
      }
    } finally {
      await ws.close();
    }
    return events;
  }

  /// Subscribes to [relayUrl] with [filter] and yields events as they arrive.
  /// Also publishes events via the same connection using [send].
  /// Call [dispose] on the returned subscription to close the WebSocket.
  static Future<RelaySubscription> subscribe(
    String relayUrl,
    Filter filter,
  ) async {
    print('[relay] subscribe to $relayUrl, filter: ${filter.toJson()}');
    final ws = await WebSocket.connect(Uri.parse(relayUrl));
    final subId = _randomHex(10);
    final req = Request(subscriptionId: subId, filters: [filter]);
    ws.sendText(req.serialize());

    final controller = StreamController<Event>();

    ws.events.listen((msg) {
      if (msg is! TextDataReceived) return;
      try {
        final message = Message.deserialize(msg.text);
        if (message.type == 'EVENT') {
          print('[relay] subscription event received');
          controller.add(message.message as Event);
        }
      } catch (e) {
        print('[relay] subscription parse error: $e');
      }
    }, onDone: () {
      controller.close();
    });

    return RelaySubscription._(ws, controller);
  }

  static String _randomHex(int length) {
    final rng = Random.secure();
    return List.generate(length, (_) => rng.nextInt(16).toRadixString(16)).join();
  }
}

/// A long-lived relay subscription. Listen on [events] for incoming events.
/// Use [send] to publish events on the same connection.
class RelaySubscription {
  RelaySubscription._(this._ws, this._controller);

  final WebSocket _ws;
  final StreamController<Event> _controller;

  Stream<Event> get events => _controller.stream;

  void send(Event event) {
    print('[relay] sending event on subscription: ${event.id}');
    _ws.sendText(event.serialize());
  }

  Future<void> dispose() async {
    await _controller.close();
    await _ws.close();
  }
}
