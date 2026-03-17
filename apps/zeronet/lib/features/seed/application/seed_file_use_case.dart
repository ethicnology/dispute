import '../domain/seed_file.dart';
import 'seed_port.dart';

class SeedFileUseCase {
  const SeedFileUseCase({required this.seedPort});

  final SeedPort seedPort;

  Future<SeedFile> execute({
    required String filePath,
    required String nsec,
    required List<String> relayUrls,
  }) =>
      seedPort.publishFile(
        filePath: filePath,
        nsec: nsec,
        relayUrls: relayUrls,
      );
}
