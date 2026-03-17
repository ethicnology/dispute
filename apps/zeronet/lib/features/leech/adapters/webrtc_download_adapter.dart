import 'dart:convert';

import 'package:nostr_wrapper/nostr.dart';

import '../../transfer/transfer.dart';
import '../application/download_port.dart';
import '../domain/downloaded_file.dart';
import '../domain/remote_file.dart';

class WebRtcDownloadAdapter implements DownloadPort {
  const WebRtcDownloadAdapter({
    required this.accountStorage,
  });

  final AccountStoragePort accountStorage;

  @override
  Future<DownloadedFile> download(RemoteFile file) async {
    final accounts = await accountStorage.getAll();
    if (accounts.isEmpty) throw StateError('No account found');
    final account = accounts.first;

    final relays = _parseReadRelays(account.relaysJson);
    if (relays.isEmpty) throw StateError('No relays configured');

    final filePath = await WebRtcLeecher.download(
      secretKey: account.nsec,
      seederPubkey: file.pubkey,
      sha256: file.sha256,
      fileName: file.name,
      relayUrl: relays.first,
    );

    return DownloadedFile(
      title: file.name,
      filePath: filePath,
    );
  }

  List<String> _parseReadRelays(String relaysJson) {
    final decoded = jsonDecode(relaysJson) as List;
    return decoded
        .cast<Map<String, dynamic>>()
        .where((r) => r['read'] == true)
        .map<String>((r) => r['url'] as String)
        .toList();
  }
}
