class RelayView {
  const RelayView({
    required this.url,
    required this.read,
    required this.write,
  });

  final Uri url;
  final bool read;
  final bool write;
}
