import 'package:dispute/features/contact/application/contact_port.dart';
import 'package:dispute/features/contact/domain/contact_entity.dart';

class FetchContactByPubkeyUseCase {
  const FetchContactByPubkeyUseCase({required this.contactPort});

  final ContactPort contactPort;

  Future<List<ContactEntity>> execute(String pubkey) {
    return contactPort.fetchByPubkey(pubkey);
  }
}
