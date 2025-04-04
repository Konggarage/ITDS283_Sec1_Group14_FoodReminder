import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // อย่าลืม import DatabaseHelper
import 'package:intl/intl.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    _fetchTodayReminders();
  }

  // ฟังก์ชันดึงข้อมูล reminders ที่หมดอายุวันนี้
  Future<void> _fetchTodayReminders() async {
    final today = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now()); // ดึงวันที่ปัจจุบัน
    final allReminders =
        await DatabaseHelper.instance
            .fetchReminders(); // ดึงข้อมูลทั้งหมดจากฐานข้อมูล

    setState(() {
      reminders =
          allReminders.where((reminder) {
            return reminder['date'] ==
                today; // เลือกแค่ reminders ที่ตรงกับวันที่วันนี้
          }).toList();
    });
  }

  // ฟังก์ชันที่ใช้ในการเปลี่ยนสถานะไปที่ "completed"
  void _markAsCompleted(int id) async {
    // อัปเดตสถานะในฐานข้อมูลให้เป็น completed
    await DatabaseHelper.instance.updateReminderStatus(id, 'completed');
    // รีเฟรชข้อมูลหลังจากเปลี่ยนสถานะ
    _fetchTodayReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Today\'s Reminder',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminder for Today:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return ReminderItem(
                    id: reminder['id'],
                    title: reminder['reminder'],
                    time: reminder['time'],
                    date: reminder['date'],
                    onCheckboxChanged: (isChecked) {
                      if (isChecked) {
                        // ถ้าเลือกแล้ว เปลี่ยนสถานะเป็น completed
                        _markAsCompleted(reminder['id']);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderItem extends StatefulWidget {
  final int id;
  final String title;
  final String time;
  final String date;
  final ValueChanged<bool> onCheckboxChanged;

  const ReminderItem({
    required this.id,
    required this.title,
    required this.time,
    required this.date,
    required this.onCheckboxChanged,
    super.key,
  });

  @override
  State<ReminderItem> createState() => _ReminderItemState();
}

class _ReminderItemState extends State<ReminderItem> {
  bool isChecked = false; // ใช้ตัวแปรนี้ในการเก็บสถานะของ checkbox

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: isChecked, // ใช้ isChecked ในการบอกสถานะของ checkbox
          onChanged: (bool? value) {
            setState(() {
              isChecked = value ?? false;
            });
            widget.onCheckboxChanged(
              isChecked,
            ); // ส่งค่าไปที่ฟังก์ชันที่เรียกใช้
          },
          activeColor: Colors.blue, // ปรับสีเมื่อเลือก
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${widget.date} ${widget.time}',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
