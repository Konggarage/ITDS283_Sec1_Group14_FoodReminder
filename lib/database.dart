import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('food_reminder.db');
    return _database!;
  }

  // Initialize Database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Create Database Table
  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    await db.execute('''
    CREATE TABLE reminders (
      id $idType,
      reminder $textType,
      category $textType,
      date $textType,
      time $textType,
      imagePath $textType
    )
    ''');
  }

  // Insert new reminder
  Future<int> insertReminder(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('reminders', row);
  }

  // Fetch all reminders
  Future<List<Map<String, dynamic>>> fetchReminders() async {
    final db = await instance.database;
    return await db.query('reminders');
  }
}
