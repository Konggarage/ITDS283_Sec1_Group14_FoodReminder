import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // อย่าลืม import DatabaseHelper
import 'package:myapp/pages/Detaillpage.dart'; // อย่าลืม import DetailPage

class CompletedPage extends StatefulWidget {
  const CompletedPage({super.key});
  @override
  State<CompletedPage> createState() => _CompletedPageState();
}

class _CompletedPageState extends State<CompletedPage> {
  List<Map<String, dynamic>> completedReminders = [];
  List<Map<String, dynamic>> filteredReminders =
      []; // เพิ่มตัวแปรสำหรับกรองข้อมูล
  String searchQuery = ""; // เพิ่มตัวแปร searchQuery

  @override
  void initState() {
    super.initState();
    _fetchCompletedReminders();
  }

  // ฟังก์ชันดึงข้อมูล completed reminders
  Future<void> _fetchCompletedReminders() async {
    final completed = await DatabaseHelper.instance.fetchCompletedReminders();
    setState(() {
      completedReminders = completed;
      filteredReminders = completed; // แสดงข้อมูลทั้งหมดก่อน
    });
  }

  // ฟังก์ชันลบ reminder
  void _deleteReminder(int id) async {
    await DatabaseHelper.instance.deleteReminder(id); // ลบข้อมูลจากฐานข้อมูล
    _fetchCompletedReminders(); // รีเฟรชข้อมูลใน filteredReminders หลังจากลบ
    _filterSearchResults(searchQuery); // เรียกฟังก์ชันกรองข้อมูลใหม่
  }

  // ฟังก์ชันกรองข้อมูลจากการค้นหาของ user
  void _filterSearchResults(String query) {
    setState(() {
      searchQuery = query;
      filteredReminders =
          completedReminders.where((reminder) {
            final reminderTitle = reminder['reminder'].toLowerCase();
            return reminderTitle.contains(
              query.toLowerCase(),
            ); // ค้นหาตามชื่อ reminder
          }).toList();
    });
  }

  void _navigateToDetailPage(int reminderId) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailPage(reminderId: reminderId),
      ),
    );
    _fetchCompletedReminders(); // รีโหลดหลังจากกลับมา
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Completed Reminders',
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
              'Completed Reminder:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredReminders.length,
                itemBuilder: (context, index) {
                  final reminder = filteredReminders[index];
                  return CompletedReminderItem(
                    id: reminder['id'],
                    title: reminder['reminder'],
                    time: reminder['time'],
                    date: reminder['date'],
                    onDelete: () {
                      // แสดง Popup ยืนยันการลบ
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                              'Are you sure you want to delete this reminder?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // ปิด Popup
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteReminder(
                                    reminder['id'],
                                  ); // ลบ reminder
                                  Navigator.pop(context); // ปิด Popup
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );
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

class CompletedReminderItem extends StatelessWidget {
  final String title;
  final String time;
  final String date;
  final int id;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const CompletedReminderItem({
    required this.title,
    required this.time,
    required this.date,
    required this.id,
    required this.onDelete,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title.isNotEmpty ? title : '(No Title)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$date $time',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
        ),
        trailing: Icon(Icons.delete, color: Colors.red),
      ),
    );
  }
}
