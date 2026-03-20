import '../domain/seed_file.dart';

abstract interface class SeedPort {
  /// Copies the file to seeding storage, hashes it, publishes NIP-94, returns the SeedFile.
  Future<SeedFile> publishFile({
    required String filePath,
    required String nsec,
    required List<String> relayUrls,
  });

  /// Lists all files currently being seeded.
  Future<List<SeedFile>> listSeeding();
}
