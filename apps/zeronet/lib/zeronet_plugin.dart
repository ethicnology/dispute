import 'package:flutter/material.dart';
import 'package:plugin_interface/plugin_interface.dart';

class ZeronetPlugin extends AppPlugin {
  @override
  String get id => 'zeronet';

  @override
  String get name => 'ZeroNet';

  @override
  IconData get icon => Icons.language;

  @override
  Widget buildHome(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('ZeroNet — Decentralized Web on Nostr'),
      ),
    );
  }

  @override
  Future<void> initialize() async {}
}
