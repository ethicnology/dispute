class AccountRecord {
  const AccountRecord({
    required this.npub,
    required this.nsec,
    required this.name,
    required this.relaysJson,
  });

  final String npub;
  final String nsec;
  final String name;

  /// JSON-encoded list of relay objects: [{url, read, write}]
  final String relaysJson;
}

abstract class AccountStoragePort {
  Future<void> save(AccountRecord account);
  Future<List<AccountRecord>> getAll();
  Future<bool> hasAny();
}
