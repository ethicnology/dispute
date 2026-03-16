import 'package:dispute/features/contact/application/contact_port.dart';
import 'package:dispute/features/contact/domain/contact_entity.dart';

class FetchContactByNameUseCase {
  const FetchContactByNameUseCase({required this.contactPort});

  final ContactPort contactPort;

  Future<List<ContactEntity>> execute(String name) {
    return contactPort.fetchByName(name);
  }
}
