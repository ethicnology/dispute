import 'dart:convert';

import 'package:dispute/features/contact/application/contact_port.dart';
import 'package:dispute/features/contact/domain/contact_entity.dart';
import 'package:dispute/shared/storage/drift_database.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:nostr_wrapper/nostr.dart';

class DriftContactAdapter implements ContactPort {
  final DisputeDatabase _db;

  const DriftContactAdapter(this._db);

  @override
  Future<void> store(ContactEntity contact) => _db
      .into(_db.contactsTable)
      .insertOnConflictUpdate(
        ContactsTableCompanion(
          npub: Value(contact.pubkey),
          name: Value(contact.name ?? ''),
          domain: Value(contact.nip05?.domain ?? ''),
          relaysJson: Value(
            jsonEncode(
              contact.relays.map((r) => {'url': r.toString()}).toList(),
            ),
          ),
        ),
      );

  @override
  Future<List<ContactEntity>> fetchAll() async {
    final records = await _db.contactsTable.select().get();
    return records.map(_fromRow).toList();
  }

  @override
  Future<List<ContactEntity>> fetchByName(String name) async {
    final rows = await (_db.select(
      _db.contactsTable,
    )..where((t) => t.name.lower().like('%${name.toLowerCase()}%'))).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<List<ContactEntity>> fetchByPubkey(String pubkey) async {
    final rows = await (_db.select(
      _db.contactsTable,
    )..where((t) => t.npub.lower().like('${pubkey.toLowerCase()}%'))).get();
    return rows.map(_fromRow).toList();
  }

  @override
  Future<ContactEntity?> search(String identifier) async {
    final url = Nip5.verificationUrl(identifier);
    final parts = identifier.split('@');
    if (parts.length != 2) return null;
    final name = parts[0];
    final domain = parts[1];

    final client = http.Client();
    try {
      final request = http.Request('GET', url)..followRedirects = false;
      final response = await client.send(request);
      if (response.statusCode != 200) return null;

      final body = await response.stream.bytesToString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final names = data['names'] as Map<String, dynamic>?;
      if (names == null) return null;

      final pubkey = names[name] as String?;
      if (pubkey == null) return null;

      final relaysMap = data['relays'] as Map<String, dynamic>?;
      final relays = relaysMap != null && relaysMap.containsKey(pubkey)
          ? (relaysMap[pubkey] as List<dynamic>)
                .map((r) => Uri.parse(r as String))
                .toList()
          : <Uri>[];

      return ContactEntity(
        pubkey: pubkey,
        name: name,
        nip05: Nip05Id(name: name, domain: domain),
        relays: relays,
      );
    } on Exception {
      return null;
    } finally {
      client.close();
    }
  }

  @override
  Future<void> trash(String pubkey) async {
    await (_db.delete(
      _db.contactsTable,
    )..where((contact) => contact.npub.equals(pubkey))).go();
  }

  ContactEntity _fromRow(ContactRow record) {
    final relayList = jsonDecode(record.relaysJson) as List<dynamic>;
    final relays = relayList.map((r) => Uri.parse(r['url'] as String)).toList();
    final nip05 = record.domain.isNotEmpty
        ? Nip05Id(name: record.name, domain: record.domain)
        : null;
    return ContactEntity(
      pubkey: record.npub,
      name: record.name.isNotEmpty ? record.name : null,
      nip05: nip05,
      relays: relays,
    );
  }
}
