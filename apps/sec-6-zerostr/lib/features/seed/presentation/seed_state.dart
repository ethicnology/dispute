import '../domain/seed_file.dart';

sealed class SeedState {
  const SeedState();
}

class SeedLoading extends SeedState {
  const SeedLoading();
}

class SeedIdle extends SeedState {
  const SeedIdle({required this.files});
  final List<SeedFile> files;
}

class SeedPublishing extends SeedState {
  const SeedPublishing();
}

class SeedError extends SeedState {
  const SeedError({required this.message});
  final String message;
}
