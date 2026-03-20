sealed class SeedEvent {
  const SeedEvent();
}

class SeedListRequested extends SeedEvent {
  const SeedListRequested();
}

class SeedFileRequested extends SeedEvent {
  const SeedFileRequested({required this.filePath});
  final String filePath;
}
