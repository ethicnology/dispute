class RemoteFile {
  const RemoteFile({
    required this.name,
    required this.sha256,
    required this.size,
    required this.mimeType,
    required this.pubkey,
  });

  final String name;
  final String sha256;
  final int size;
  final String mimeType;
  final String pubkey;
}
