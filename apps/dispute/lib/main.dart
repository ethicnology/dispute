import 'package:dispute/dispute_plugin.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final plugin = DisputePlugin();
  await plugin.initialize();
  runApp(MaterialApp(home: Builder(builder: plugin.buildHome)));
}
