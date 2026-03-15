import 'package:drift/drift.dart';
import '../account_storage_port.dart';
import 'nostr_database.dart';

class DriftAccountStorage implements AccountStoragePort {
  const DriftAccountStorage(this._db);

  final NostrDatabase _db;

  @override
  Future<void> save(AccountRecord account) => _db
      .into(_db.accountsTable)
      .insertOnConflictUpdate(
        AccountsTableCompanion(
          npub: Value(account.npub),
          nsec: Value(account.nsec),
          name: Value(account.name),
          relaysJson: Value(account.relaysJson),
        ),
      );

  @override
  Future<List<AccountRecord>> getAll() async {
    final rows = await _db.select(_db.accountsTable).get();
    return rows
        .map(
          (r) => AccountRecord(
            npub: r.npub,
            nsec: r.nsec,
            name: r.name,
            relaysJson: r.relaysJson,
          ),
        )
        .toList();
  }

  @override
  Future<bool> hasAny() async =>
      (await (_db.select(_db.accountsTable)..limit(1)).get()).isNotEmpty;
}
