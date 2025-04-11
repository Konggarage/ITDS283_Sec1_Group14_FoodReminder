import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // อย่าลืม import DatabaseHelper
import 'package:intl/intl.dart';
import 'package:myapp/pages/EditReminderPage.dart'; // เพิ่มการนำเข้า EditReminderPage
import 'package:myapp/pages/Detaillpage.dart';

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
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final allReminders = await DatabaseHelper.instance.fetchReminders();

    setState(() {
      reminders =
          allReminders.where((reminder) {
            return reminder['date'] == today &&
                reminder['status'] != 'completed';
          }).toList();
    });
  }

  // ฟังก์ชันที่ใช้ในการเปลี่ยนสถานะไปที่ "completed"
  void _markAsCompleted(int id) async {
    await DatabaseHelper.instance.updateReminderStatus(id, 'completed');
    Future.delayed(const Duration(seconds: 3), () {
      _fetchTodayReminders(); // รีเฟรชข้อมูลหลังจากเปลี่ยนสถานะ
    });
  }

  // ฟังก์ชันลบ reminder
  void _deleteReminder(int id) async {
    await DatabaseHelper.instance.deleteReminder(id);
    _fetchTodayReminders(); // รีเฟรชข้อมูลในหน้า Today
  }

  void _navigateToEditReminderPage(int reminderId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReminderPage(reminderId: reminderId),
      ),
    );
    // เมื่อกลับมาจากหน้า Edit จะเช็คค่าผลลัพธ์
    if (result == true) {
      _fetchTodayReminders(); // รีเฟรชข้อมูลหลังจากการแก้ไข
    }
  }

  // ฟังก์ชันแสดง dialog เพื่อยืนยันการลบ
  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการลบ'),
          content: const Text('คุณแน่ใจว่าจะลบรายการนี้?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                _deleteReminder(id); // ลบ reminder
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetailPage(int reminderId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(reminderId: reminderId),
      ),
    );
    if (result == true) {
      _fetchTodayReminders(); // รีเฟรชข้อมูลหลังจากการดูรายละเอียด
    }
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
                  return GestureDetector(
                    onTap: () {
                      _navigateToDetailPage(
                        reminder['id'],
                      ); // เมื่อคลิกที่รายการ ไปที่หน้า DetailPage
                    },
                    child: ReminderItem(
                      id: reminder['id'],
                      title: reminder['reminder'],
                      time: reminder['time'],
                      date: reminder['date'],
                      onCheckboxChanged: (isChecked) {
                        if (isChecked) {
                          _markAsCompleted(reminder['id']);
                        }
                      },
                      onDelete: () {
                        _showDeleteConfirmationDialog(reminder['id']);
                      },
                      onEdit: () {
                        _navigateToEditReminderPage(reminder['id']);
                      },
                    ),
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
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ReminderItem({
    required this.id,
    required this.title,
    required this.time,
    required this.date,
    required this.onCheckboxChanged,
    required this.onDelete,
    required this.onEdit,
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
            ); // ส่งค่ากลับไปที่ onCheckboxChanged
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: widget.onEdit, // เรียกฟังก์ชัน Edit
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: widget.onDelete, // เรียกฟังก์ชันลบ
            ),
          ],
        ),
      ),
    );
  }
}
