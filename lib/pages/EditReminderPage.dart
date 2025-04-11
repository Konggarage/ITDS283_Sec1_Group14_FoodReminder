import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // อย่าลืม import DatabaseHelper

class EditReminderPage extends StatefulWidget {
  final int reminderId; // ใช้เพื่อรับ ID ของ reminder ที่จะถูกแก้ไข

  const EditReminderPage({required this.reminderId, super.key});

  @override
  _EditReminderPageState createState() => _EditReminderPageState();
}

class _EditReminderPageState extends State<EditReminderPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ดึงข้อมูลจาก Database เมื่อเปิดหน้า Edit
    _fetchReminder();
  }

  Future<void> _fetchReminder() async {
    try {
      // ดึงข้อมูลจากฐานข้อมูลตาม ID
      final reminder = await DatabaseHelper.instance.fetchReminderById(
        widget.reminderId,
      );

      // แสดงข้อมูลที่ดึงมาใน Console
      print('Fetched Reminder: $reminder');

      // ตั้งค่าให้กับ controller
      _titleController.text = reminder['reminder'];
      _timeController.text = reminder['time'];
      _dateController.text = reminder['date'];
    } catch (e) {
      print("Error fetching reminder: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Reminder",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit your reminder:',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: 'Time',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: 'Date',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveReminder, child: const Text('Save')),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันบันทึกข้อมูลที่แก้ไข
  void _saveReminder() async {
    final updatedReminder = {
      'id': widget.reminderId,
      'reminder': _titleController.text,
      'time': _timeController.text,
      'date': _dateController.text,
    };

    // เรียกฟังก์ชัน updateReminder ใน DatabaseHelper
    await DatabaseHelper.instance.updateReminder(
      widget.reminderId,
      updatedReminder,
    );

    // เมื่อบันทึกแล้ว กลับไปหน้า Today และรีเฟรชข้อมูล
    Navigator.pop(context, true); // ส่งค่า true เพื่อบอกว่ามีการอัปเดต
  }
}
