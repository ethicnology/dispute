import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'tables/account_table.dart';

part 'nostr_database.g.dart';

@DriftDatabase(tables: [AccountsTable])
class NostrDatabase extends _$NostrDatabase {
  NostrDatabase(QueryExecutor e) : super(e);

  static const _cipher = 'chacha20';

  static Future<NostrDatabase> open(String encryptionKey) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'nostr.db'));
    return NostrDatabase(
      NativeDatabase.createInBackground(
        file,
        setup: (db) {
          assert(
            _debugCheckHasCipher(db),
            'sqlite3mc is not available — check hook config in pubspec.yaml',
          );
          db.execute("PRAGMA cipher = '$_cipher';");
          db.execute("PRAGMA key = '${_escape(encryptionKey)}';");
        },
      ),
    );
  }

  static bool _debugCheckHasCipher(Database db) =>
      db.select('PRAGMA cipher;').isNotEmpty;

  static String _escape(String s) => s.replaceAll("'", "''");

  @override
  int get schemaVersion => 1;
}
