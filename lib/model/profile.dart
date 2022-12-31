import 'package:dispute/main.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Profile with ChangeNotifier {
  Keychain keys = Keychain.generate();
  List<String> relays = [
    "wss://relay.nostr.info",
    "wss://nostr-pub.wellorder.net",
    "wss://nostr-pub.wellorder.net",
    "wss://nostr.openchain.fr",
    "wss://nostr.semisol.dev",
    "wss://nostr-relay.untethr.me",
    "wss://nostr.drss.io",
    "wss://nostr-pub.semisol.dev",
    "wss://nostr.ono.re",
    "wss://nostr.sandwich.farm"
  ];
  String relay = '';
  late WebSocketChannel channel;

  init() {
    relay = selectRelay(relays);
    try {
      channel = WebSocketChannel.connect(Uri.parse(relay));
      logger.i('Connected to WebSocket at $relay');
    } catch (e) {
      logger.e('Error connecting to WebSocket at $relay: $e');
    }
  }

  String selectRelay(List<String> relays) {
    String? relay;
    WebSocketChannel? channel;
    var i = 0;
    while (channel == null && i < relays.length) {
      try {
        channel = WebSocketChannel.connect(Uri.parse(relays[i]));
        relay = relays[i];
      } catch (e) {
        i++;
      }
    }
    if (relay == null) {
      throw Exception('Unable to connect to any WebSocket server');
    } else {
      return relay;
    }
  }
}
