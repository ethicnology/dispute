import 'package:drift/drift.dart';

@DataClassName('ContactRow')
class ContactsTable extends Table {
  TextColumn get npub => text()();
  TextColumn get name => text()();
  TextColumn get domain => text()();
  TextColumn get relaysJson => text()();

  @override
  Set<Column> get primaryKey => {npub};
}
