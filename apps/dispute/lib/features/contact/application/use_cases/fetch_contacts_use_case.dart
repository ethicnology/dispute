import 'package:dispute/features/contact/application/contact_port.dart';
import 'package:dispute/features/contact/domain/contact_entity.dart';

class FetchContactsUseCase {
  const FetchContactsUseCase({required this.contactPort});

  final ContactPort contactPort;

  Future<List<ContactEntity>> execute({String? query}) {
    final q = (query ?? '').trim();

    if (q.isEmpty) return contactPort.fetchAll();

    if (_looksLikePubkeyPrefix(q)) {
      return contactPort.fetchByPubkey(q);
    }

    return contactPort.fetchByName(q);
  }

  static bool _looksLikePubkeyPrefix(String value) {
    final text = value.trim();
    if (text.length < 8) return false;
    return RegExp(r'^[0-9a-fA-F]+$').hasMatch(text);
  }
}
