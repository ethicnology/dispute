import 'package:dispute/features/contact/application/contact_port.dart';

class RemoveContactUseCase {
  const RemoveContactUseCase({required this.contactPort});

  final ContactPort contactPort;

  Future<void> execute(String pubkey) {
    return contactPort.trash(pubkey);
  }
}
