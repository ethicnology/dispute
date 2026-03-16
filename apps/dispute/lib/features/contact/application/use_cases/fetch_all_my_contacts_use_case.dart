import 'package:dispute/features/contact/application/contact_port.dart';
import 'package:dispute/features/contact/domain/contact_entity.dart';

class FetchAllMyContactsUseCase {
  const FetchAllMyContactsUseCase({required this.contactPort});

  final ContactPort contactPort;

  Future<List<ContactEntity>> execute() {
    return contactPort.fetchAll();
  }
}
