import '../domain/remote_file.dart';

abstract interface class DiscoveryPort {
  Future<List<RemoteFile>> searchByPubkey({
    required String npub,
    required List<String> relayUrls,
  });
}
