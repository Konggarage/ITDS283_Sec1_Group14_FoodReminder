import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // นำเข้า image_picker
import 'dart:io'; // สำหรับจัดการกับไฟล์รูป
import 'package:myapp/Fooddatabase.dart'; // เชื่อมต่อฐานข้อมูล
import 'package:myapp/func/func.dart'; // นำเข้า func.dart ที่คำนวณวันหมดอายุ
import 'package:intl/intl.dart'; // นำเข้า intl สำหรับการจัดการวันที่
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FoodReminderPage extends StatefulWidget {
  const FoodReminderPage({super.key});

  @override
  State<FoodReminderPage> createState() => _FoodReminderPageState();
}

class _FoodReminderPageState extends State<FoodReminderPage> {
  final TextEditingController reminderController = TextEditingController();
  String selectedCategory = '';
  String selectedDate = '';
  String selectedTime = '';
  String uploadedImage = ''; // เก็บ path ของรูปภาพที่อัปโหลด
  String expirationDate = ''; // เพิ่มตัวแปรเก็บวันหมดอายุที่คำนวณ

  final ImagePicker _picker = ImagePicker(); // เพิ่มตัวแปร ImagePicker

  // ฟังก์ชันเลือกภาพจากกล้องหรือแกลเลอรี
  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF2E3047),
            title: const Text(
              "Select Image",
              style: TextStyle(color: Colors.white),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  onPressed: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (picked != null && mounted) {
                      final directory =
                          await getApplicationDocumentsDirectory();
                      final name = p.basename(picked.path);
                      final savedImage = await File(
                        picked.path,
                      ).copy('${directory.path}/$name');

                      setState(() {
                        uploadedImage =
                            savedImage.path; // เก็บ path ของรูปภาพที่ถ่าย
                      });
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.white),
                  onPressed: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null && mounted) {
                      final directory =
                          await getApplicationDocumentsDirectory();
                      final name = p.basename(picked.path);
                      final savedImage = await File(
                        picked.path,
                      ).copy('${directory.path}/$name');

                      setState(() {
                        uploadedImage =
                            savedImage.path; // เก็บ path ของรูปภาพที่เลือก
                      });
                    }
                  },
                ),
              ],
            ),
          ),
    );
  }

  // ฟังก์ชันสำหรับเพิ่มข้อมูลลงในฐานข้อมูล
  void _addReminder() async {
    final reminder = reminderController.text;
    final category = selectedCategory;
    final date = selectedDate;
    final time = selectedTime;

    if (reminder.isEmpty || category.isEmpty || date.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please fill all required fields',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // คำนวณวันหมดอายุ
    String expirationDateCalculated = calculateExpirationDate(date, category);

    // เก็บวันหมดอายุที่คำนวณแล้ว
    setState(() {
      expirationDate = expirationDateCalculated;
    });

    Map<String, dynamic> row = {
      'reminder': reminder,
      'category': category,
      'date': date,
      'time': time,
      'imagePath': uploadedImage,
      'status': 'pending',
      'expirationDate': expirationDate, // บันทึกวันหมดอายุ
    };

    // ตรวจสอบว่า DatabaseHelper ทำงานได้ไหม
    try {
      await DatabaseHelper.instance.insertReminder(
        row,
      ); // บันทึกข้อมูลลงฐานข้อมูล
      print('Saved reminder: $row'); // พิมพ์ข้อมูลใน terminal เพื่อตรวจสอบ

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Reminder saved successfully!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // รีเซ็ตฟอร์มหลังจากบันทึก
      setState(() {
        reminderController.clear();
        selectedCategory = '';
        selectedDate = '';
        selectedTime = '';
        uploadedImage = '';
        expirationDate = ''; // รีเซ็ตวันหมดอายุ
      });
    } catch (e) {
      print('Error saving reminder: $e'); // พิมพ์ข้อผิดพลาดใน terminal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save reminder'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Food Reminder',
          style: TextStyle(color: Colors.white),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: TextButton(
            onPressed: () {
              reminderController.clear();
              setState(() {
                selectedCategory = '';
                selectedDate = '';
                selectedTime = '';
                uploadedImage = '';
                expirationDate = ''; // รีเซ็ตวันหมดอายุ
              });
            },
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                _addReminder();
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
              TextFormField(
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
                value: selectedCategory.isNotEmpty ? selectedCategory : null,
                hint: Text("Select a category"),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                    if (selectedDate.isNotEmpty) {
                      expirationDate = calculateExpirationDate(
                        selectedDate,
                        selectedCategory,
                      );
                    }
                  });
                },
                items:
                    <String>[
                      'Vegetables & Fruits',
                      'Meat & Fish',
                      'Bread & Bakery Products',
                      'Rice & Pasta',
                      'Beverages',
                      'Processed Foods',
                      'Condiments & Sauces',
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
                  hintText: 'Select a category',
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
                controller: TextEditingController(
                  text: selectedDate.isNotEmpty ? selectedDate : '',
                ),
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
                      if (selectedCategory.isNotEmpty) {
                        expirationDate = calculateExpirationDate(
                          selectedDate,
                          selectedCategory,
                        );
                      }
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Date',
                  labelStyle: const TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Colors.grey[800],
                  hintText: 'Pick a date',
                  hintStyle: const TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),

              // Time field
              TextField(
                controller: TextEditingController(
                  text: selectedTime.isNotEmpty ? selectedTime : '',
                ),
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

              // แสดงวันหมดอายุ
              if (expirationDate.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Expiration Date: $expirationDate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

              // ฟังก์ชันอัปโหลดรูป
              GestureDetector(
                onTap:
                    _showImagePickerDialog, // ใช้ฟังก์ชันเปิด dialog เลือกภาพ
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
                        uploadedImage.isEmpty ||
                                !File(uploadedImage).existsSync()
                            ? const Center(
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                color: Colors.white,
                                size: 40, // ขนาดของไอคอน
                              ),
                            )
                            : Image.file(
                              File(uploadedImage),
                              fit: BoxFit.cover,
                              width: double.infinity,
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
}
