import 'package:flutter/material.dart';
import 'package:nostr/nostr.dart';

class Profile with ChangeNotifier {
  Keychain keys = Keychain.generate();
  String relay = "";
}
