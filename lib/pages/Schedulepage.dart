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
  int selectedYear = DateTime.now().year;

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
    final today = DateTime.now();

    final updatedReminders =
        allReminders.map((reminder) {
          final reminderDate = DateTime.parse(reminder['date']);
          final isOverdue =
              reminder['status'] != 'completed' && reminderDate.isBefore(today);

          return {
            ...reminder,
            'status': isOverdue ? 'overdue' : reminder['status'],
          };
        }).toList();

    setState(() {
      reminders = updatedReminders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Scheduled Reminders',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Schedule',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text(
                        'Year:',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: selectedYear,
                        dropdownColor: Colors.grey[900],
                        style: const TextStyle(color: Colors.white),
                        iconEnabledColor: Colors.white,
                        items:
                            List.generate(10, (index) => 2020 + index)
                                .map(
                                  (year) => DropdownMenuItem(
                                    value: year,
                                    child: Text('$year'),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedYear = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    children: List.generate(12, (index) {
                      DateTime monthDate = DateTime(selectedYear, index + 1);
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
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                selectedMonth == formattedMonth
                                    ? Colors.blueAccent
                                    : Colors.grey[850],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            DateFormat('MMM').format(monthDate),
                            style: TextStyle(
                              color:
                                  selectedMonth == formattedMonth
                                      ? Colors.white
                                      : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // แสดงข้อมูล reminders ตามวันที่เลือก
            Expanded(
              child: ListView.builder(
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  Color statusColor;
                  IconData statusIcon;

                  if (reminder['status'] == 'completed') {
                    statusColor = Colors.green;
                    statusIcon = Icons.check;
                  } else if (reminder['status'] == 'overdue') {
                    statusColor = Colors.red;
                    statusIcon = Icons.warning;
                  } else {
                    statusColor = Colors.grey;
                    statusIcon = Icons.access_time;
                  }

                  return Card(
                    color: Colors.grey[800],
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  reminder['reminder'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Divider(color: Colors.white30),
                          const SizedBox(height: 4),
                          Text(
                            'Due on: ${reminder['date']} at ${reminder['time']}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: statusColor,
                            child: Icon(
                              statusIcon,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
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
