import 'package:nostr_wrapper/nostr.dart';

abstract final class Validators {
  static String? nsec(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    try {
      Keys(value);
      return null;
    } on Exception {
      return 'Invalid nsec key';
    }
  }

  static String? relayUrl(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final uri = Uri.tryParse(value);
    if (uri == null || uri.scheme != 'wss' || uri.host.isEmpty) {
      return 'Enter a valid wss:// relay URL';
    }
    return null;
  }
}
