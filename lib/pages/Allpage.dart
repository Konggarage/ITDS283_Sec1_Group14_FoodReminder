import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // อย่าลืม import DatabaseHelper
import 'dart:async'; // เพิ่มการนำเข้า
import 'package:myapp/pages/EditReminderPage.dart'; // อย่าลืมนำเข้า EditReminderPage
import 'package:myapp/pages/Detaillpage.dart';
import 'package:intl/intl.dart'; // เพิ่มการนำเข้า intl

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
        await DatabaseHelper.instance.fetchAllPendingReminders();
    print('All Reminders: $allReminders'); // พิมพ์ข้อมูลที่ดึงมาเพื่อตรวจสอบ

    final today = DateTime.now();

    setState(() {
      reminders =
          allReminders
              .map((reminder) {
                // final reminderDate = DateTime.parse(reminder['date']);
                final expirationDate = DateTime.parse(
                  reminder['expirationDate'],
                );
                final isOverdue =
                    expirationDate.isBefore(today) &&
                    expirationDate.day != today.day &&
                    reminder['status'] != 'completed';

                final displayStatus =
                    isOverdue ? 'overdue' : reminder['status'];

                return {...reminder, 'status': displayStatus};
              })
              .where((reminder) => reminder['status'] != 'completed')
              .toList();
    });
  }

  // ฟังก์ชันที่ใช้ในการเปลี่ยนสถานะไปที่ "completed"
  void _markAsCompleted(int id) async {
    await DatabaseHelper.instance.updateReminderStatus(id, 'completed');
    Navigator.pop(
      context,
      true,
    ); // ส่งสัญญาณกลับไปให้ AllPage รู้ว่ามีการเปลี่ยนแปลง
    _fetchAllReminders(); // รีเฟรชข้อมูลหลังจากเปลี่ยนสถานะ
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
  void _navigateToDetailPage(int reminderId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(reminderId: reminderId),
      ),
    );

    if (result == true) {
      _fetchAllReminders(); // รีเฟรชข้อมูลเมื่อกลับมาจากหน้า detail แล้วมีการเปลี่ยนแปลง
    }
  }

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
            Text(
              'All Reminders:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                    expirationDate:
                        reminder['expirationDate'], // ส่ง expirationDate
                    status:
                        reminder['status'], // Pass the status to ReminderItem
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
                    onTap: () => _navigateToDetailPage(reminder['id']),
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
  final String expirationDate; // เพิ่ม expirationDate parameter
  final String status; // Add status parameter
  final ValueChanged<bool> onCheckboxChanged;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap; // Add onTap parameter

  const ReminderItem({
    required this.id,
    required this.title,
    required this.time,
    required this.date,
    required this.expirationDate, // รับ expirationDate
    required this.status, // Add status parameter
    required this.onCheckboxChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onTap, // Add onTap parameter
    super.key,
  });

  @override
  State<ReminderItem> createState() => _ReminderItemState();
}

class _ReminderItemState extends State<ReminderItem> {
  bool isChecked = false;
  Timer? _completionTimer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                  if (isChecked) {
                    _completionTimer = Timer(const Duration(seconds: 3), () {
                      widget.onCheckboxChanged(true);
                    });
                  } else {
                    _completionTimer?.cancel();
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: Colors.blueAccent,
                checkColor: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Expiration: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.expirationDate))}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.status == 'overdue') ...[
                          const SizedBox(width: 8),
                          const Text(
                            'Overdue',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.blueAccent,
                    ),
                    onPressed: widget.onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
  }
}
