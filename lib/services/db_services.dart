import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:windows_apps_time_measurements_app/models/app.dart';

class DbServices {
  late final Database db;

  Future initDb() async {
    print("BEFORE DB OPENED");

    // Set up the database factory for FFI
    databaseFactory = databaseFactoryFfi;

    // Get a valid path for storing the database
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'apps.db'); // Path to save the database

    // Open the database at the given path (this will persist data between app launches)
    db = await databaseFactory.openDatabase(dbPath);
    await db.execute("PRAGMA journal_mode=WAL;");

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

  Future<Iterable<App>> getRecords() async {
    if (await isTableExists("Apps")) {
      Stopwatch stopwatch = Stopwatch();

      stopwatch.start();
      final List<Map<String, Object?>> query = await db.query("Apps");
      print("Time to query: ${stopwatch.elapsedMilliseconds}");
      final Iterable<App> runnedApps =
          query.map((Map<String, Object?> object) => App.fromJson(object));
      stopwatch.stop();
      print("Time elapsed in getRecords ${stopwatch.elapsedMilliseconds}");
      return runnedApps;
    } else {
      await initDb();
      return await getRecords();
    }
  }

  Future<Iterable<App>> getLatestRecords() async {
    if (await isTableExists("Apps")) {
      final List<Map<String, Object?>> query =
          await db.query("Apps", orderBy: "id DESC", limit: 50);
      final Iterable<App> runnedApps =
          query.map((Map<String, Object?> object) => App.fromJson(object));
      return runnedApps;
    } else {
      await initDb();
      return await getLatestRecords();
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
