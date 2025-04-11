import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:typed_data'; // เพิ่มการ import ไลบรารี

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

  // เพิ่มฟังก์ชัน deleteReminder ใน DatabaseHelper
  Future<void> deleteReminder(int id) async {
    final db = await instance.database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }

  // เพิ่มฟังก์ชันนี้เพื่อดึงข้อมูลตาม ID
  Future<Map<String, dynamic>> fetchReminderById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('Reminder with ID $id not found');
    }
  }

  // ฟังก์ชันที่ใช้ในการอัปเดตข้อมูล reminder
  Future<void> updateReminder(int id, Map<String, Object> row) async {
    final db = await instance.database;
    await db.update(
      'reminders',
      row, // ข้อมูลที่จะอัปเดต
      where: 'id = ?', // ค้นหาด้วย ID
      whereArgs: [id], // ใช้ ID ในการค้นหา
    );
  }

  Future<List<Map<String, dynamic>>> searchReminders(String query) async {
    final db = await instance.database;
    return await db.query(
      'reminders',
      where: 'reminder LIKE ?',
      whereArgs: ['%$query%'],
    );
  }

  Future<void> insertImage(Uint8List image) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('images', {'image': image});
  }

  Future<Uint8List> getImage(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('images', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty
        ? result.first['image'] as Uint8List
        : Uint8List(0);
  }

  Future<void> deleteAllReminders() async {
    final db = await database;
    await db.delete('reminders'); // ลบทุกแถวในตาราง reminders
  }
}
