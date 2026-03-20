import 'package:flutter/material.dart';
import 'package:zeronet/zeronet_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final plugin = ZeronetPlugin();
  await plugin.initialize();
  runApp(MaterialApp(home: Builder(builder: plugin.buildHome)));
}
