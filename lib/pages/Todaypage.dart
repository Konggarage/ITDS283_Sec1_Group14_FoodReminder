import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // อย่าลืม import DatabaseHelper
import 'package:intl/intl.dart';
import 'package:myapp/pages/EditReminderPage.dart'; // เพิ่มการนำเข้า EditReminderPage
import 'package:myapp/pages/Detaillpage.dart';
import 'package:myapp/service/notification_service.dart';
import 'dart:async';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  List<Map<String, dynamic>> reminders = [];
  List<bool> isChecked = []; // ตัวแปรเก็บสถานะของ Checkbox

  @override
  void initState() {
    super.initState();
    _fetchTodayReminders();
  }

  // ฟังก์ชันดึงข้อมูล reminders ที่มี expiration date ตรงกับวันนี้
  Future<void> _fetchTodayReminders() async {
    final today = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now()); // วันที่ปัจจุบัน
    final allReminders = await DatabaseHelper.instance.fetchReminders();

    print('All reminders: $allReminders'); // เพิ่มการพิมพ์ข้อมูล
    setState(() {
      reminders =
          allReminders.where((reminder) {
            // แปลง expirationDate ให้เป็นวันที่ที่ไม่มีเวลา (ปี-เดือน-วัน)
            final expirationDate = DateFormat(
              'yyyy-MM-dd',
            ).format(DateTime.parse(reminder['expirationDate']));
            print('Reminder expirationDate: $expirationDate'); // ดูค่าที่ดึงมา
            return expirationDate == today && reminder['status'] != 'completed';
          }).toList();
      isChecked = List.generate(
        reminders.length,
        (index) => false,
      ); // กำหนดสถานะเริ่มต้นของ Checkbox
    });

    print('Filtered reminders: $reminders'); // เพิ่มการพิมพ์ข้อมูลที่กรองแล้ว
  }

  void _deleteReminder(int id) async {
    await DatabaseHelper.instance.deleteReminder(id);
    await NotificationService.cancelMultiple(id); // ⬅️ เพิ่มเพื่อยกเลิก noti
    _fetchTodayReminders(); // รีเฟรชข้อมูลในหน้า Today
  }

  void _navigateToEditReminderPage(int reminderId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReminderPage(reminderId: reminderId),
      ),
    );
    if (result == true) {
      _fetchTodayReminders(); // รีเฟรชข้อมูลหลังจากการแก้ไข
    }
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete this reminder?',
            style: TextStyle(color: Colors.black),
          ),
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

  void _toggleReminderStatus(int id, String currentStatus) async {
    String newStatus = currentStatus == 'completed' ? 'pending' : 'completed';
    await DatabaseHelper.instance.updateReminderStatus(id, newStatus);
    _fetchTodayReminders(); // รีเฟรชข้อมูลหลังจากเปลี่ยนสถานะ
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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reminder for Today:',
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
                      expirationDate:
                          reminder['expirationDate'], // เพิ่ม expirationDate
                      status: reminder['status'],
                      isChecked: isChecked[index], // ใช้ตัวแปร isChecked
                      onCheckboxChanged: (bool? value) {
                        setState(() {
                          this.isChecked[index] = value ?? false;
                        });
                        if (value == true) {
                          Timer(const Duration(seconds: 3), () {
                            _toggleReminderStatus(
                              reminder['id'],
                              reminder['status'],
                            );
                          });
                        }
                      },
                      onEdit: () => _navigateToEditReminderPage(reminder['id']),
                      onDelete:
                          () => _showDeleteConfirmationDialog(reminder['id']),
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

class ReminderItem extends StatelessWidget {
  final int id;
  final String title;
  final String time;
  final String date;
  final String expirationDate;
  final String status;
  final bool isChecked; // เพิ่มตัวแปร isChecked
  final ValueChanged<bool?> onCheckboxChanged; // รับค่าเป็น bool?
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ReminderItem({
    required this.id,
    required this.title,
    required this.time,
    required this.date,
    required this.expirationDate,
    required this.status,
    required this.isChecked, // เพิ่มตัวแปร isChecked
    required this.onCheckboxChanged,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black54,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child:
                constraints.maxWidth < 400
                    ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCheckbox(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitle(context),
                              const SizedBox(height: 6),
                              _buildExpirationDate(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildEditDeleteButtons(),
                      ],
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCheckbox(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitle(context),
                              const SizedBox(height: 6),
                              _buildExpirationDate(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildEditDeleteButtons(),
                      ],
                    ),
          );
        },
      ),
    );
  }

  Widget _buildCheckbox() {
    return Transform.scale(
      scale: 1.2,
      child: Checkbox(
        value: isChecked, // ใช้ตัวแปร isChecked
        onChanged: (bool? value) {
          onCheckboxChanged(value); // ส่งค่า nullable bool
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        activeColor: Colors.blueAccent,
        checkColor: Colors.white,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildExpirationDate() {
    final expirationDateFormatted = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.parse(expirationDate));
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Colors.red, size: 14),
          const SizedBox(width: 6),
          Text(
            'Expiration: $expirationDateFormatted',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditDeleteButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, size: 18, color: Colors.blueAccent),
          onPressed: onEdit,
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
          onPressed: onDelete,
          tooltip: 'Delete',
        ),
      ],
    );
  }
}
