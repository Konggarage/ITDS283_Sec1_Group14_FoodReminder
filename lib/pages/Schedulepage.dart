import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ใช้ในการจัดการวันที่
import 'package:myapp/Fooddatabase.dart'; // อย่าลืม import DatabaseHelper

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<Map<String, dynamic>> reminders = [];
  String selectedMonth = DateFormat(
    'yyyy-MM',
  ).format(DateTime.now()); // เดือนปัจจุบัน

  @override
  void initState() {
    super.initState();
    _fetchRemindersForMonth(selectedMonth);
  }

  // ดึงข้อมูล reminders ตามเดือน
  Future<void> _fetchRemindersForMonth(String month) async {
    final allReminders = await DatabaseHelper.instance.fetchRemindersByMonth(
      month,
    );
    setState(() {
      reminders = allReminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scheduled Reminders',
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
              'Select Month:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // แทนที่ dropdown ด้วย ListView เลื่อนเดือน
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 12,
                itemBuilder: (context, index) {
                  DateTime monthDate = DateTime(DateTime.now().year, index + 1);
                  String formattedMonth = DateFormat(
                    'yyyy-MM',
                  ).format(monthDate);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMonth = formattedMonth;
                        _fetchRemindersForMonth(selectedMonth);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:
                              selectedMonth == formattedMonth
                                  ? Colors.blue
                                  : Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: 80,
                        height: 40,
                        child: Text(
                          DateFormat('MMM yyyy').format(monthDate),
                          style: TextStyle(
                            color:
                                selectedMonth == formattedMonth
                                    ? Colors.white
                                    : Colors.white60,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // แสดงข้อมูล reminders ตามวันที่เลือก
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return Card(
                    color: Colors.grey[800],
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.notifications, color: Colors.white),
                      title: Text(
                        reminder['reminder'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Due on: ${reminder['date']} at ${reminder['time']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.check,
                          color:
                              reminder['status'] == 'completed'
                                  ? Colors.green
                                  : Colors.grey,
                        ),
                        onPressed: () {
                          // อัปเดตสถานะเป็น "completed"
                          DatabaseHelper.instance.updateReminderStatus(
                            reminder['id'],
                            'completed',
                          );
                          setState(() {
                            reminder['status'] = 'completed';
                          });
                        },
                      ),
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
