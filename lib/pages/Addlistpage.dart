import 'package:flutter/material.dart';
// import 'package:myapp/main.dart';

class FoodReminderPage extends StatefulWidget {
  const FoodReminderPage({super.key});

  @override
  State<FoodReminderPage> createState() => _FoodReminderPageState();
}

class _FoodReminderPageState extends State<FoodReminderPage> {
  final TextEditingController reminderController = TextEditingController();
  String selectedCategory = 'Vegetables';
  String selectedDate = '2025-03-30';
  String selectedTime = '10:00 AM';
  String uploadedImage = '';

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
              style: TextStyle(
                color: Colors.red,
                // fontSize: 18,
              ), // ขนาดข้อความที่เหมาะสม
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton(
              onPressed: () {
                // Handle Done action here
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
                // controller: dateController, // ต้องตั้ง controller เพื่ออัปเดตค่า
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
                  hintText: selectedDate,
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
                  hintText: selectedTime,
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
