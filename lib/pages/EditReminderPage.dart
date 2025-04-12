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
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController(); // เพิ่มตัวควบคุมสำหรับ Expiration Date
  String _expirationDate =
      ''; // เปลี่ยนเป็น String และกำหนดให้เป็นค่าว่างหากไม่มีข้อมูล

  @override
  void initState() {
    super.initState();
    _fetchReminder();
  }

  Future<void> _fetchReminder() async {
    try {
      final reminder = await DatabaseHelper.instance.fetchReminderById(
        widget.reminderId,
      );

      _titleController.text = reminder['reminder'];
      _timeController.text = reminder['time'];
      _dateController.text = reminder['date'];
      _categoryController.text = reminder['category'];

      // คำนวณ Expiration Date ตามวันที่และหมวดหมู่ที่บันทึกไว้
      _expirationDate = calculateExpirationDate(
        reminder['date'],
        reminder['category'],
      );
      _expirationDateController.text =
          _expirationDate; // กรอกค่า Expiration Date ที่คำนวณแล้ว
    } catch (e) {
      print("Error fetching reminder: $e");
    }
  }

  String calculateExpirationDate(String date, String category) {
    DateTime selectedDate = DateTime.parse(date);
    int daysToAdd = 0;

    if (category == 'Meat & Fish') {
      daysToAdd = 5;
    } else if (category == 'Vegetables & Fruits') {
      daysToAdd = 3;
    }

    DateTime expirationDate = selectedDate.add(Duration(days: daysToAdd));
    return expirationDate.toString().split(
      ' ',
    )[0]; // แสดงวันที่ในรูปแบบ 'yyyy-MM-dd'
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
              readOnly: true,
              onTap: () async {
                TimeOfDay? selectedTimeOfDay = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (selectedTimeOfDay != null) {
                  setState(() {
                    _timeController.text = selectedTimeOfDay.format(context);
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Time',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            // ให้ผู้ใช้เลือกวันที่ใน DatePicker
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () async {
                DateTime? selectedDateTime = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDateTime != null) {
                  setState(() {
                    _dateController.text =
                        selectedDateTime.toLocal().toString().split(' ')[0];
                    // คำนวณ Expiration Date ใหม่เมื่อวันที่ถูกเลือก
                    _expirationDate = calculateExpirationDate(
                      _dateController.text,
                      _categoryController.text,
                    );
                    _expirationDateController.text =
                        _expirationDate; // อัปเดต Expiration Date ที่คำนวณใหม่
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Date', // เปลี่ยนจาก Date เป็น Expiration Date
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            // เพิ่มให้ผู้ใช้กรอก Expiration Date หรือใช้การคำนวณ
            TextField(
              controller:
                  _expirationDateController, // ให้ผู้ใช้กรอกค่า Expiration Date เอง
              decoration: const InputDecoration(
                labelText: 'Expiration Date',
                labelStyle: TextStyle(color: Colors.grey),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // ตรวจสอบว่า user กรอกค่า Expiration Date เองหรือไม่
                if (_expirationDateController.text.isEmpty) {
                  _expirationDate = calculateExpirationDate(
                    _dateController.text,
                    _categoryController.text,
                  );
                } else {
                  _expirationDate = _expirationDateController.text;
                }

                _saveReminder();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveReminder() async {
    final updatedReminder = {
      'id': widget.reminderId,
      'reminder': _titleController.text,
      'time': _timeController.text,
      'date': _dateController.text,
    };

    updatedReminder['expirationDate'] = _expirationDate;

    try {
      await DatabaseHelper.instance.updateReminder(
        widget.reminderId,
        updatedReminder,
      );
      Navigator.pop(context, true); // ส่งค่า true เพื่อบอกว่ามีการอัปเดต
    } catch (e) {
      print("Error updating reminder: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update reminder'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
