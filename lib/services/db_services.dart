import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:windows_apps_time_measurements_app/models/app.dart';

class DbServices {
  late final Database db;

  Future initDb() async {
    print("BEFORE DB OPENED");
    databaseFactory = databaseFactoryFfi;
    db = await databaseFactory.openDatabase(inMemoryDatabasePath);
    print("DB OPENED!");
    if (!(await isTableExists("Apps"))) {
      await db.execute('''
          CREATE TABLE Apps (
              id INTEGER PRIMARY KEY,
              app_name TEXT,
              app_task TEXT,
              created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
          ''');
    }
  }

  Future addRecord(App app) async {
    if (await isTableExists("Apps")) {
      await db.insert("Apps", app.toJson());
    }
  }

  Future getRecords() async {
    if (await isTableExists("Apps")) {
      final List<Map<String, Object?>> query = await db.query("Apps");
      final Iterable<App> runnedApps =
          query.map((Map<String, Object?> object) => App.fromJson(object));
      return runnedApps;
    }
  }

  Future<bool> isTableExists(String tableName) async {
    var result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName]);

    // If the result is not empty, the table exists
    return result.isNotEmpty;
  }
}
