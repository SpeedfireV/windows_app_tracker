import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart'; // For fetching the app's data directory
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:windows_apps_time_measurements_app/models/app.dart';

class DbServices {
  late final Database db;

  Future initDb() async {
    print("BEFORE DB OPENED");

    // Set up the database factory for FFI
    databaseFactory = databaseFactoryFfi;

    // Get a valid path for storing the database in a persistent directory
    Directory appDocDir = await getApplicationSupportDirectory();
    String dbPath = join(appDocDir.path,
        'apps.db'); // Path to save the database in persistent directory

    // Open the database at the given path (this will persist data between app launches)
    db = await databaseFactory.openDatabase(dbPath);
    await db.execute("PRAGMA journal_mode=WAL;");

    print("DB OPENED!");

    // Run migrations or create the database if it doesn't exist
    await _runMigrations();
  }

  Future<void> _runMigrations() async {
    // Check if the table 'Apps' exists
    if (!(await isTableExists("Apps"))) {
      // If the table does not exist, create it
      await db.execute('''
          CREATE TABLE Apps (
              id INTEGER PRIMARY KEY,
              app_name TEXT,
              app_task TEXT,
              created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
      ''');
      print("Table 'Apps' created");
    } else {
      // If 'Apps' table exists, perform any migration logic if needed.
      // Add new columns, modify schema, etc.
      // Example: if the database schema changes in a future version.
      print("Table 'Apps' already exists. Checking for migrations...");

      // You can keep track of the current schema version and apply migrations here.
      // Example: If you're on version 2 and need to add a column
      // await db.execute('ALTER TABLE Apps ADD COLUMN new_column_name TEXT');
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
