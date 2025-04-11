import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart';
import 'package:image_picker/image_picker.dart'; // เพิ่มการนำเข้า ImagePicker
import 'dart:io'; // สำหรับการใช้งาน File

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

  // Function to fetch the reminder data
  Future<Map<String, dynamic>> _fetchReminderData() async {
    final dbHelper = DatabaseHelper.instance;
    try {
      final data = await dbHelper.fetchReminderById(
        widget.reminderId,
      ); // Fetch data from database
      return data;
    } catch (e) {
      throw Exception('Error fetching reminder data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: reminderData, // The future that loads data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            ); // Show a loading indicator while the data is loading
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            ); // Show error message if there's any
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          } else {
            final reminder = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ตรวจสอบหากมี imagePath
                      reminder['imagePath'] != ''
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(reminder['imagePath']),
                              fit: BoxFit.cover,
                              height: 200, // ความสูงของภาพ
                              width: double.infinity, // ความกว้างเต็มหน้าจอ
                            ),
                          )
                          : SizedBox.shrink(), // หากไม่มีรูปภาพจะแสดงเป็นค่าว่าง

                      SizedBox(height: 20),

                      Text(
                        'Reminder: ${reminder['reminder']}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Divider(color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Category: ${reminder['category']}',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Date: ${reminder['date']}',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Time: ${reminder['time']}',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Status: ${reminder['status']}',
                        style: TextStyle(fontSize: 18, color: Colors.black54),
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
}
