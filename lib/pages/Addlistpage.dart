import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart';
// import 'package:myapp/pages/Todaypage.dart';
import 'package:myapp/main.dart';

class FoodReminderPage extends StatefulWidget {
  const FoodReminderPage({super.key});

  @override
  State<FoodReminderPage> createState() => _FoodReminderPageState();
}

class _FoodReminderPageState extends State<FoodReminderPage> {
  final TextEditingController reminderController = TextEditingController();
  String selectedCategory = 'Vegetables'; // เก็บหมวดหมู่ที่เลือก
  String selectedDate = '2025-03-30'; // เก็บวันที่ที่เลือก
  String selectedTime = '10:00 AM'; // เก็บเวลาที่เลือก
  String uploadedImage = ''; // เก็บ path ของรูปภาพที่อัปโหลด

  // ฟังก์ชันสำหรับเพิ่มข้อมูลลงในฐานข้อมูล
  void _addReminder() async {
    final reminder = reminderController.text;
    final category = selectedCategory;
    final date = selectedDate;
    final time = selectedTime;
    final imagePath = uploadedImage;

    // สร้าง Map เพื่อเก็บข้อมูลที่จะบันทึก
    Map<String, dynamic> row = {
      'reminder': reminder,
      'category': category,
      'date': date,
      'time': time,
      'imagePath': imagePath,
      'status': 'pending',
    };

    // บันทึกข้อมูลลงในฐานข้อมูล
    await DatabaseHelper.instance.insertReminder(row);

    // ก่อนที่จะเรียกใช้ context ตรวจสอบว่า widget ยังคงติดตั้งอยู่หรือไม่
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyApp(),
        ), // ไปยังหน้าที่จะแสดงรายการ
      );
    }
    // หาก widget ถูก dispose ไปแล้วจะไม่ทำอะไร

    // ไปหน้า TodayPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Food Reminder',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ), // ปรับขนาดของ title
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: TextButton(
            onPressed: () {
              reminderController.clear();
              setState(() {
                selectedCategory = 'Vegetables';
                selectedDate = '2025-03-30';
                selectedTime = '10:00 AM';
                uploadedImage = '';
              });
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero, // ทำให้ปุ่มไม่มี padding
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.red), // ขนาดข้อความที่เหมาะสม
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                _addReminder();
                print("Done pressed");
              },
              child: const Text('Done', style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reminder text field
              TextField(
                controller: reminderController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Put your food reminder',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: 'Enter your reminder',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
                items:
                    <String>[
                      'Vegetables',
                      'Fruits',
                      'Dairy',
                      'Meat',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Categories',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 65, 63, 63),
                  hintText: 'Select a category', // แสดง placeholder
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                dropdownColor: const Color.fromARGB(255, 65, 63, 63),
              ),
              const SizedBox(height: 16),

              // Date field
              TextField(
                controller: TextEditingController(text: selectedDate),
                readOnly: true,
                onTap: () async {
                  DateTime? selectedDateTime = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDateTime != null) {
                    setState(() {
                      selectedDate =
                          selectedDateTime.toLocal().toString().split(' ')[0];
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Date',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: 'Pick a date',
                  hintStyle: const TextStyle(
                    color: Colors.white,
                  ), // เปลี่ยนสีของ placeholder
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white), // กรอบสีขาว
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Time field
              TextField(
                controller: TextEditingController(text: selectedTime),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? selectedTimeOfDay = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTimeOfDay != null) {
                    setState(() {
                      selectedTime = selectedTimeOfDay.format(context);
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Time',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: selectedTime.isEmpty ? "Pick a Time" : selectedTime,
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Upload image section
              GestureDetector(
                onTap: () {
                  setState(() {
                    uploadedImage =
                        'assets/chinjang.png'; // Example path to image
                  });
                },
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[800],
                    ),
                    child:
                        uploadedImage.isEmpty
                            ? const Center(child: Text('Upload images'))
                            : Image.asset(
                              uploadedImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Add more space
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
