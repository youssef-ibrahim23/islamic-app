import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class DB {
  static Database? _db;

  static Future<Database?> get db async {
    if (_db == null) {
      _db = await initializeDB();
      return _db;
    } else {
      return _db;
    }
  }

  static Future<Database> initializeDB() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'School.db');

    // Open the database and assign onCreate and onUpgrade callbacks correctly
    Database schoolDB = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    return schoolDB;
  }

  // On Create, create the USERS table
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE USERS(USERNAME TEXT, EMAIL TEXT , country text);");
  }

  // On Upgrade, perform schema migration if needed
  static Future<void> _onUpgrade(
      Database db, int oldVersion, int newVersion) async {}

  // Method to execute a SELECT query
  static Future<List<Map<String, dynamic>>> select(String query) async {
    Database? DB = await db;
    var data = await DB!.rawQuery(query);
    return data;
  }

  // Method to execute an INSERT query
  static Future<int> insert(String query) async {
    Database? DB = await db;
    int insertStatus = await DB!.rawInsert(query);
    return insertStatus;
  }

  // Method to execute an UPDATE query
  static Future<int> update(String query) async {
    Database? DB = await db;
    int updateStatus = await DB!.rawUpdate(query);
    return updateStatus;
  }

  // Method to execute a DELETE query
  static Future<int> delete(String query) async {
    Database? schoolDB = await db;
    int deleteStatus = await schoolDB!.rawDelete(query);
    return deleteStatus;
  }
}
