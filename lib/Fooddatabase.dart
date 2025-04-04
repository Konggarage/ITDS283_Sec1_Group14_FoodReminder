import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
      DatabaseHelper._init(); // กำหนด instance ให้เรียกใช้จากที่ไหนก็ได้

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
      imagePath $textType,
      status $textType
    )
    ''');
  }

  // Insert new reminder
  Future<int> insertReminder(Map<String, dynamic> row) async {
    final db = await instance.database;
    row['status'] = row['status'] ?? 'pending';
    return await db.insert('reminders', row);
  }

  // Fetch all reminders
  Future<List<Map<String, dynamic>>> fetchReminders() async {
    final db = await instance.database;
    return await db.query('reminders');
  }

  // Update reminder status
  Future<void> updateReminderStatus(int id, String status) async {
    final db = await instance.database;
    await db.update(
      'reminders',
      {'status': status}, // อัปเดตสถานะเป็น "completed"
      where: 'id = ?',
      whereArgs: [id],
    );
  }
// only com
  Future<List<Map<String, dynamic>>> fetchCompletedReminders() async {
    final db = await instance.database;
    return await db.query(
      'reminders',
      where: 'status = ?',
      whereArgs: ['completed'],
    );
  }
  //all but no com
  Future<List<Map<String, dynamic>>> fetchAllPendingReminders() async {
  final db = await instance.database;
  return await db.query(
    'reminders',
    where: 'status != ?',
    whereArgs: ['completed'],
  );
}
  Future<List<Map<String, dynamic>>> fetchRemindersByMonth(String month) async {
    final db = await instance.database;
    return await db.query(
      'reminders',
      where:
          'strftime("%Y-%m", date) = ?', // ฟังก์ชัน strftime เพื่อกรองตามเดือน
      whereArgs: [month],
    );
  }
}
