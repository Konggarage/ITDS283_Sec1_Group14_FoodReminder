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
            backgroundColor:
                Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : Theme.of(context).dialogBackgroundColor,
            title: Text(
              "Select Image",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: Container(
              decoration: BoxDecoration(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
                          uploadedImage = savedImage.path;
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.photo,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
                          uploadedImage = savedImage.path;
                        });
                      }
                    },
                  ),
                ],
              ),
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
          content: Text(
            'Please fill all required fields',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white),
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Food Reminder', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
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
            child: Text('Cancel', style: TextStyle(color: Colors.red)),
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
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  labelText: 'Put your food reminder',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  hintText: 'Enter your reminder',
                  hintStyle: Theme.of(context).textTheme.bodyLarge,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory.isNotEmpty ? selectedCategory : null,
                hint: Text(
                  "Select a category",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
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
                        child: Text(
                          value,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }).toList(),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  labelText: 'Categories',
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  hintText: 'Select a category',
                  hintStyle: Theme.of(context).textTheme.bodyLarge,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                dropdownColor: Theme.of(context).cardColor,
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
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  hintText: 'Pick a date',
                  hintStyle: Theme.of(context).textTheme.bodyLarge,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
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
                  labelStyle: Theme.of(context).textTheme.bodyLarge,
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  hintText: selectedTime.isEmpty ? "Pick a Time" : selectedTime,
                  hintStyle: Theme.of(context).textTheme.bodyLarge,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),

              // แสดงวันหมดอายุ
              if (expirationDate.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Expiration Date: $expirationDate',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
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
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).shadowColor.withOpacity(0.15),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child:
                        uploadedImage.isEmpty ||
                                !File(uploadedImage).existsSync()
                            ? Center(
                              child: Icon(
                                Icons.add_a_photo_outlined,
                                color: Theme.of(context).iconTheme.color,
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
