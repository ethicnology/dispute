import '../domain/remote_file.dart';
import 'discovery_port.dart';

class SearchFilesUseCase {
  const SearchFilesUseCase({required this.discoveryPort});

  final DiscoveryPort discoveryPort;

  Future<List<RemoteFile>> execute({
    required String npub,
    required List<String> relayUrls,
  }) =>
      discoveryPort.searchByPubkey(npub: npub, relayUrls: relayUrls);
}
