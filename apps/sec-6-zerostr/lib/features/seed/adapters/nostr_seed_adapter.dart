import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:mime/mime.dart';
import 'package:nostr_wrapper/nostr.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../application/seed_port.dart';
import '../domain/seed_file.dart';

class NostrSeedAdapter implements SeedPort {
  const NostrSeedAdapter();

  @override
  Future<SeedFile> publishFile({
    required String filePath,
    required String nsec,
    required List<String> relayUrls,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final hash = sha256.convert(bytes).toString();
    final name = p.basename(filePath);
    final mime = lookupMimeType(filePath) ?? 'text/html';

    // Copy to seeding storage
    final seedDir = await _seedingDir();
    final dest = File(p.join(seedDir.path, hash, name));
    await dest.parent.create(recursive: true);
    await file.copy(dest.path);

    // Publish NIP-94 event
    final keys = Keys(nsec);
    print('[seed] pubkey: ${keys.public}');
    print('[seed] file: $name, hash: $hash, size: ${bytes.length}, mime: $mime');

    final event = FileMetadata.create(
      url: 'webrtc://${keys.public}/$name',
      mimeType: mime,
      sha256: hash,
      secretKey: keys.secret,
      content: name,
      size: bytes.length,
    );

    print('[seed] event id: ${event.id}, kind: ${event.kind}');
    print('[seed] publishing to ${relayUrls.length} relays: $relayUrls');

    for (final url in relayUrls) {
      try {
        await NostrRelay.publish(url, event);
        print('[seed] published to $url');
      } catch (e) {
        print('[seed] FAILED to publish to $url: $e');
      }
    }

    return SeedFile(
      name: name,
      sha256: hash,
      size: bytes.length,
      mimeType: mime,
      filePath: dest.path,
    );
  }

  @override
  Future<List<SeedFile>> listSeeding() async {
    final seedDir = await _seedingDir();
    if (!await seedDir.exists()) return [];

    final files = <SeedFile>[];
    await for (final hashDir in seedDir.list()) {
      if (hashDir is! Directory) continue;
      final hash = p.basename(hashDir.path);
      await for (final file in hashDir.list()) {
        if (file is! File) continue;
        final stat = await file.stat();
        files.add(SeedFile(
          name: p.basename(file.path),
          sha256: hash,
          size: stat.size,
          mimeType: lookupMimeType(file.path) ?? 'text/html',
          filePath: file.path,
        ));
      }
    }
    return files;
  }

  Future<Directory> _seedingDir() async {
    final supportDir = await getApplicationSupportDirectory();
    final dir = Directory(p.join(supportDir.path, 'seeding'));
    await dir.create(recursive: true);
    return dir;
  }
}
