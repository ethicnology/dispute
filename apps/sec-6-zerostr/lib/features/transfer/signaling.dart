import 'dart:convert';

import 'package:nostr_wrapper/nostr.dart';

/// Ephemeral event kind for WebRTC signaling messages.
const int signalingKind = 25050;

/// Creates a signed ephemeral signaling event.
Event createSignalingEvent({
  required String secretKey,
  required String recipientPubkey,
  required Map<String, dynamic> payload,
}) {
  return Event.from(
    kind: signalingKind,
    tags: [
      ['p', recipientPubkey],
    ],
    content: jsonEncode(payload),
    secretKey: secretKey,
  );
}

/// Parses a signaling event's content.
Map<String, dynamic> parseSignalingPayload(Event event) {
  return jsonDecode(event.content) as Map<String, dynamic>;
}
