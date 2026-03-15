import 'package:drift/drift.dart';

@DataClassName('AccountRow')
class AccountsTable extends Table {
  TextColumn get nsec => text()();
  TextColumn get npub => text()();
  TextColumn get name => text()();
  TextColumn get relaysJson => text()();

  @override
  Set<Column> get primaryKey => {nsec};
}
