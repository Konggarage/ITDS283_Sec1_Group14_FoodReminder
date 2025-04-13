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
          // ตรวจสอบ null ก่อนการใช้งาน expirationDate
          DateTime expirationDateTime = DateTime.now();
          if (reminder['expirationDate'] != null) {
            expirationDateTime = DateTime.parse(reminder['expirationDate']);
          }

          // ตรวจสอบ null สำหรับ status
          String displayStatus = reminder['status'] ?? 'pending';

          final isOverdue =
              displayStatus != 'completed' &&
              expirationDateTime.isBefore(today);

          return {
            ...reminder,
            'status': isOverdue ? 'overdue' : displayStatus,
            // เพิ่มฟังก์ชันการคำนวณข้อความที่จะแสดงตามสถานะ
            'timeMessage':
                isOverdue
                    ? expirationDateTime.difference(today).inDays == 0
                        ? 'Expired today'
                        : 'Expired ${expirationDateTime.difference(today).inDays.abs()} day${expirationDateTime.difference(today).inDays.abs() == 1 ? '' : 's'} ago'
                    : displayStatus == 'completed'
                    ? ''
                    : displayStatus == 'due'
                    ? 'Due today'
                    : 'Due in ${expirationDateTime.difference(today).inDays} day${expirationDateTime.difference(today).inDays == 1 ? '' : 's'}',
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
        title: Text(
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                      Icon(
                        Icons.calendar_month,
                        color: Colors.indigo,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Schedule',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Year:',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<int>(
                        value: selectedYear,
                        dropdownColor: Theme.of(context).cardColor,
                        style: Theme.of(context).textTheme.bodyLarge,
                        iconEnabledColor: Theme.of(context).iconTheme.color,
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
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).cardColor,
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
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  selectedMonth == formattedMonth
                                      ? Colors.white
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.color
                                          ?.withOpacity(0.7),
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
                  String displayStatus = reminder['status'];

                  // คำนวณสถานะจาก Expiration Date
                  DateTime expirationDateTime = DateTime.now();
                  if (reminder['expirationDate'] != null) {
                    expirationDateTime = DateTime.parse(
                      reminder['expirationDate'],
                    );
                  }
                  final now = DateTime.now();

                  if (reminder['status'] != 'completed') {
                    if (expirationDateTime.isBefore(now)) {
                      displayStatus =
                          'overdue'; // ถ้า Expiration Date ก่อนวันที่ปัจจุบัน
                    } else if (expirationDateTime.year == now.year &&
                        expirationDateTime.month == now.month &&
                        expirationDateTime.day == now.day) {
                      displayStatus = 'due'; // ถ้า Expiration Date คือวันนี้
                    } else {
                      displayStatus =
                          'pending'; // ถ้า Expiration Date ยังไม่ถึง
                    }
                  }

                  // กำหนดสีและไอคอนตามสถานะ
                  Color statusColor;
                  IconData statusIcon;

                  if (displayStatus == 'completed') {
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle;
                  } else if (displayStatus == 'overdue') {
                    statusColor = Colors.red;
                    statusIcon = Icons.warning_amber_rounded;
                  } else if (displayStatus == 'due') {
                    statusColor = Colors.orange;
                    statusIcon = Icons.access_time;
                  } else {
                    statusColor = Colors.grey;
                    statusIcon = Icons.schedule;
                  }

                  return Card(
                    color: Theme.of(context).cardColor,
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.notifications,
                                    color: Colors.deepOrange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      reminder['reminder'],
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Divider(color: Theme.of(context).dividerColor),
                              const SizedBox(height: 6),

                              // 📅 Date & 🕒 Time
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    reminder['date'],
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    reminder['time'],
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),

                              // ⚠️ Expiration Date
                              if (reminder['expirationDate'] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Exp. ${DateFormat('MMM d, yyyy').format(DateTime.parse(reminder['expirationDate']))}',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // ❗ Expired Text
                              if (reminder['timeMessage'] != null &&
                                  reminder['timeMessage'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    reminder['timeMessage'],
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      color:
                                          reminder['status'] == 'overdue'
                                              ? Colors.red
                                              : null,
                                    ),
                                  ),
                                ),

                              const SizedBox(
                                height: 28,
                              ), // สำหรับเว้นที่ให้ CircleAvatar
                            ],
                          ),

                          // 🔴 Status Icon (bottom right)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: statusColor,
                              child: Icon(
                                statusIcon,
                                size: 18,
                                color: Colors.white,
                              ),
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
