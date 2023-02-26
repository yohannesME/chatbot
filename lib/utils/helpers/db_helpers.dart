import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'chatbot.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE messages (id TEXT PRIMARY KEY, text TEXT, isImage BOOL, isBot BOOL)'
            );
      },
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DBHelper.database();
    await db.insert(
      table,
      data,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<void> clear() async {
    // Get a location using getDatabasesPath
    var databasesPath = await sql.getDatabasesPath();
    String thepath = path.join(databasesPath, 'chatbot.db');

    // Delete the database
    await sql.deleteDatabase(thepath);
  }
}
