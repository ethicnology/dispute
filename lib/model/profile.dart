import 'package:dispute/main.dart';
import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Profile with ChangeNotifier {
  Keychain keys = Keychain.generate();
  String relay = "wss://relay.dispute.systems";
  late WebSocketChannel channel;

  init() {
    try {
      channel = WebSocketChannel.connect(Uri.parse(relay));
      logger.i('Connected to WebSocket at $relay');
    } catch (e) {
      logger.e('Error connecting to WebSocket at $relay: $e');
    }
  }
}
