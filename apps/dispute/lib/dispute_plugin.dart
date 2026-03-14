import 'package:flutter/material.dart';
import 'package:plugin_interface/plugin_interface.dart';

class DisputePlugin extends AppPlugin {
  @override
  String get id => 'dispute';

  @override
  String get name => 'Dispute';

  @override
  IconData get icon => Icons.chat;

  @override
  Widget buildHome(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Dispute — Nostr Client'),
      ),
    );
  }

  @override
  Future<void> initialize() async {}
}
