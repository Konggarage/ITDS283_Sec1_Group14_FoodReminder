import 'package:flutter/material.dart';
import 'dart:io';
import 'package:myapp/Fooddatabase.dart';
import 'package:intl/intl.dart';

class DetailPage extends StatefulWidget {
  final int reminderId;

  DetailPage({required this.reminderId});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late Future<Map<String, dynamic>> reminderData;

  @override
  void initState() {
    super.initState();
    reminderData =
        _fetchReminderData(); // Load the data when the page is initialized
  }

  Future<Map<String, dynamic>> _fetchReminderData() async {
    final dbHelper = DatabaseHelper.instance;
    try {
      final data = await dbHelper.fetchReminderById(widget.reminderId);
      return data;
    } catch (e) {
      throw Exception('Error fetching reminder data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reminder Details',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: reminderData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final reminder = snapshot.data!;
            final dateString = '${reminder['date']} ${reminder['time']}';
            DateFormat dateFormat;

            // เช็คว่าเวลามี AM/PM หรือไม่
            if (reminder['time']?.contains('AM') ??
                false || reminder['time']?.contains('PM') ??
                false) {
              // ถ้ามี AM/PM ใช้รูปแบบ h:mm a
              dateFormat = DateFormat('yyyy-MM-dd h:mm a');
            } else {
              // ถ้าไม่มี AM/PM ใช้รูปแบบ HH:mm
              dateFormat = DateFormat('yyyy-MM-dd HH:mm');
            }

            final reminderDateTime = dateFormat.parse(
              dateString,
            ); // แปลงวันที่และเวลา
            final now = DateTime.now();

            String displayStatus = reminder['status'];

            final daysDiff = reminderDateTime.difference(now).inDays;
            // ปรับสถานะ display ตาม daysDiff
            if (reminder['status'] != 'completed') {
              if (daysDiff < 0) {
                displayStatus = 'overdue'; // ถ้าเกินวันที่กำหนด
              } else if (daysDiff == 0) {
                displayStatus = 'due'; // ถ้ายังไม่ถึง 1 วัน ให้แสดงเป็น "due"
              } else {
                displayStatus = 'upcoming'; // ถ้ายังไม่ถึงวันที่หมดอายุ
              }
            }

            final timeMessage =
                displayStatus == 'overdue'
                    ? 'Overdue by ${daysDiff.abs()} day${daysDiff.abs() == 1 ? '' : 's'}'
                    : displayStatus == 'due'
                    ? 'Due today'
                    : 'Due in $daysDiff day${daysDiff == 1 ? '' : 's'}';

            double screenWidth = MediaQuery.of(context).size.width;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    20,
                  ), // เพิ่มมุมโค้งให้มากขึ้น
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ถ้ามีรูปภาพให้แสดงรูปภาพจาก 'imagePath' หรือแสดงไอคอนเตือน
                      reminder['imagePath'] != null &&
                              reminder['imagePath'].isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // ทำให้รูปมีมุมโค้ง
                            child: Image.file(
                              File(reminder['imagePath']),
                              height:
                                  screenWidth *
                                  0.6, // ขนาดรูปเป็น 60% ของความกว้างหน้าจอ
                              width: screenWidth * 0.6,
                              fit: BoxFit.cover, // รูปจะครอบพื้นที่
                            ),
                          )
                          : Icon(
                            displayStatus == 'completed'
                                ? Icons.check_circle
                                : displayStatus == 'overdue'
                                ? Icons.warning_amber_rounded
                                : Icons.schedule,
                            color:
                                displayStatus == 'completed'
                                    ? Colors.green
                                    : displayStatus == 'overdue'
                                    ? Colors.red
                                    : Colors.orange,
                            size: 64,
                          ),
                      const SizedBox(height: 16),
                      Text(
                        reminder['reminder'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(height: 30, thickness: 1.2),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.category,
                        'Category: ${reminder['category']}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Date: ${reminder['date']}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.access_time,
                        'Time: ${reminder['time']}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.date_range,
                        'Expiration Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(reminder['expirationDate']))}', // แสดง Expiration Date แบบวัน เดือน ปี
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Status: $displayStatus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              displayStatus == 'completed'
                                  ? Colors.green
                                  : displayStatus == 'overdue'
                                  ? Colors.red
                                  : Colors.black54,
                        ),
                      ),
                      if (timeMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            timeMessage,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      if (displayStatus != 'completed')
                        Padding(
                          padding: const EdgeInsets.only(top: 24.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _markAsCompleted,
                              icon: const Icon(Icons.check),
                              label: const Text("Mark as Completed"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _markAsCompleted() async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.updateReminderStatus(widget.reminderId, 'completed');
    Navigator.pop(
      context,
      true,
    ); // ส่งสัญญาณกลับไปให้ AllPage รู้ว่ามีการเปลี่ยนแปลง
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
