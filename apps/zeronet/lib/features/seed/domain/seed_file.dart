class SeedFile {
  const SeedFile({
    required this.name,
    required this.sha256,
    required this.size,
    required this.mimeType,
    required this.filePath,
  });

  final String name;
  final String sha256; // hex-encoded
  final int size;
  final String mimeType;
  final String filePath;
}
