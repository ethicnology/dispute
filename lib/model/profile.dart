import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';

class Profile with ChangeNotifier {
  Keys keys = Keys.generate();
  String relay = "";
}
