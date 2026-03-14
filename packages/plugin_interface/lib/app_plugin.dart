import 'package:flutter/widgets.dart';

abstract class AppPlugin {
  String get id;
  String get name;
  IconData get icon;
  Widget buildHome(BuildContext context);
  Future<void> initialize();
}
