import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // อย่าลืม import DatabaseHelper
// import 'package:intl/intl.dart';
import 'package:myapp/pages/EditReminderPage.dart'; // อย่าลืมนำเข้า EditReminderPage
import 'package:myapp/pages/Detaillpage.dart';

class AllPage extends StatefulWidget {
  const AllPage({super.key});

  @override
  State<AllPage> createState() => _AllPageState();
}

class _AllPageState extends State<AllPage> {
  List<Map<String, dynamic>> reminders = [];
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _fetchAllReminders();
  }

  // ฟังก์ชันดึงข้อมูลทั้งหมดจากฐานข้อมูล
  Future<void> _fetchAllReminders() async {
    final allReminders =
        await DatabaseHelper.instance
            .fetchReminders(); // ดึงข้อมูลทั้งหมดจากฐานข้อมูล

    setState(() {
      reminders =
          allReminders.where((reminder) {
            return reminder['status'] !=
                'completed'; // กรองเฉพาะ reminders ที่ไม่ได้เป็น completed
          }).toList();
    });
  }

  // ฟังก์ชันที่ใช้ในการเปลี่ยนสถานะไปที่ "completed"
  void _markAsCompleted(int id) async {
    setState(() {
      isChecked = true; // เปลี่ยนสถานะ checkbox เป็น checked
    });

    await DatabaseHelper.instance.updateReminderStatus(id, 'completed');
    await Future.delayed(const Duration(seconds: 3), () {});
    _fetchAllReminders(); // รีเฟรชข้อมูลหลังจากเปลี่ยนสถานะ
    setState(() {
      isChecked = false; // เปลี่ยนสถานะ checkbox กลับเป็น unchecked
    });
  }

  // ฟังก์ชันลบ reminder
  void _deleteReminder(int id) async {
    await DatabaseHelper.instance.deleteReminder(id);
    _fetchAllReminders(); // รีเฟรชข้อมูลทั้งหมด
  }

  // ฟังก์ชันแสดง dialog เพื่อยืนยันการลบ
  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteReminder(id); // ลบ reminder
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันที่ใช้ในการไปหน้า EditReminderPage
  void _navigateToEditReminderPage(int reminderId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReminderPage(reminderId: reminderId),
      ),
    );
    // เมื่อกลับมาจากหน้า Edit จะเช็คค่าผลลัพธ์
    if (result == true) {
      _fetchAllReminders(); // รีเฟรชข้อมูลหลังจากการแก้ไข
    }
  }

  // ฟังก์ชันที่จะไปหน้า DetailPage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Reminders',
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
              'All Reminders:',
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
                        _markAsCompleted(reminder['id']);
                      }
                    },
                    onDelete: () {
                      _showDeleteConfirmationDialog(reminder['id']);
                    },
                    onEdit: () {
                      _navigateToEditReminderPage(reminder['id']);
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
  bool isChecked = false;

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
            widget.onCheckboxChanged(isChecked);
          },
          activeColor: Colors.blue,
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
              onPressed: widget.onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: widget.onDelete,
            ),
          ],
        ),
        onTap: () {
          // เมื่อคลิกที่ ListTile จะไปที่หน้า DetailPage
          _navigateToDetailPage(widget.id); // ไปหน้า DetailPage และส่ง id
        },
      ),
    );
  }

  // ฟังก์ชันนี้จะนำทางไปหน้า DetailPage
  void _navigateToDetailPage(int reminderId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DetailPage(
              reminderId: reminderId,
            ), // ส่ง reminderId ไปที่ DetailPage
      ),
    );
  }
}
