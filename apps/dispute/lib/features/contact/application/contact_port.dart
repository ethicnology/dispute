import 'package:dispute/features/contact/domain/contact_entity.dart';

abstract class ContactPort {
  Future<void> store(ContactEntity contact);
  Future<void> trash(String pubkey);

  Future<List<ContactEntity>> fetchByName(String name);
  Future<List<ContactEntity>> fetchByPubkey(String pubkey);
  Future<List<ContactEntity>> fetchAll();

  Future<ContactEntity?> search(String identifier);
}

class ContactRecord {
  const ContactRecord({
    required this.npub,
    required this.name,
    required this.relaysJson,
  });

  final String npub;
  final String name;
  final String relaysJson;
}
