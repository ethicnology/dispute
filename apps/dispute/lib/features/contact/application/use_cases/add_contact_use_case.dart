import 'package:dispute/features/contact/application/contact_port.dart';
import 'package:dispute/features/contact/domain/contact_entity.dart';

class AddContactUseCase {
  const AddContactUseCase({required this.contactPort});

  final ContactPort contactPort;

  Future<void> execute(ContactEntity contact) {
    return contactPort.store(contact);
  }
}
