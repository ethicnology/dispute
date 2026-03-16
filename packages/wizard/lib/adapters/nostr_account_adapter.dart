import 'dart:convert';

import 'package:nostr_wrapper/nostr.dart';

import '../application/account_port.dart';
import '../domain/account_entity.dart';

class NostrAccountAdapter implements AccountPort {
  const NostrAccountAdapter(this._storage);

  final AccountStoragePort _storage;

  @override
  Future<void> store(AccountEntity account) =>
      _storage.save(_toRecord(account));

  @override
  Future<List<AccountEntity>> fetchAll() async {
    final records = await _storage.getAll();
    return records.map(_fromRecord).toList();
  }

  @override
  Future<bool> hasAny() => _storage.hasAny();

  AccountRecord _toRecord(AccountEntity account) => AccountRecord(
    npub: account.npub,
    nsec: account.nsec,
    name: account.name,
    relaysJson: jsonEncode(
      account.relays
          .map(
            (r) => {'url': r.url.toString(), 'read': r.read, 'write': r.write},
          )
          .toList(),
    ),
  );

  AccountEntity _fromRecord(AccountRecord record) {
    final relayList = jsonDecode(record.relaysJson) as List<dynamic>;
    final relays = relayList
        .map(
          (r) => RelayEntity(
            url: Uri.parse(r['url'] as String),
            read: r['read'] as bool,
            write: r['write'] as bool,
          ),
        )
        .toList();
    return AccountEntity(
      keys: Keys(record.nsec),
      name: record.name,
      relays: relays,
    );
  }
}
