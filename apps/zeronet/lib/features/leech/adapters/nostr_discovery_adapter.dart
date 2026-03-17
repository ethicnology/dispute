import 'package:nostr_wrapper/nostr.dart';

import '../application/discovery_port.dart';
import '../domain/remote_file.dart';

class NostrDiscoveryAdapter implements DiscoveryPort {
  const NostrDiscoveryAdapter();

  @override
  Future<List<RemoteFile>> searchByPubkey({
    required String npub,
    required List<String> relayUrls,
  }) async {
    print('[leech] searching for npub: $npub');
    // If input is already a 64-char hex pubkey, use directly.
    // Otherwise treat as npub1... bech32 and decode.
    final pubkeyHex = npub.startsWith('npub')
        ? Bech32Entities.decode(payload: npub).data
        : npub;

    print('[leech] resolved pubkey hex: $pubkeyHex');
    print('[leech] querying ${relayUrls.length} relays: $relayUrls');

    final filter = Filter(
      kinds: [FileMetadata.kindFileMetadata],
      authors: [pubkeyHex],
    );

    final results = <RemoteFile>[];
    for (final url in relayUrls) {
      try {
        print('[leech] querying $url ...');
        final events = await NostrRelay.query(url, filter);
        print('[leech] $url returned ${events.length} events');
        for (final event in events) {
          print(
            '[leech] event id: ${event.id}, kind: ${event.kind}, pubkey: ${event.pubkey}',
          );
          final data = FileMetadata.parse(event);
          print(
            '[leech] parsed: ${data.content}, sha256: ${data.sha256}, size: ${data.size}',
          );
          results.add(
            RemoteFile(
              name: data.content.isNotEmpty ? data.content : data.url,
              sha256: data.sha256,
              size: data.size ?? 0,
              mimeType: data.mimeType,
              pubkey: data.pubkey,
            ),
          );
        }
      } catch (e) {
        print('[leech] FAILED on $url: $e');
      }
    }

    // Deduplicate by sha256
    final seen = <String>{};
    return results.where((f) => seen.add(f.sha256)).toList();
  }
}
