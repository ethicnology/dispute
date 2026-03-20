import '../domain/seed_file.dart';
import 'seed_port.dart';

class ListSeedingUseCase {
  const ListSeedingUseCase({required this.seedPort});

  final SeedPort seedPort;

  Future<List<SeedFile>> execute() => seedPort.listSeeding();
}
