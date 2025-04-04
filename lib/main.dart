import 'package:flutter/material.dart';
import 'package:myapp/pages/homepage.dart'; // อย่าลืม import หน้า Homepage
import 'package:myapp/pages/Addlistpage.dart';
// import 'package:myapp/pages/analyze.dart';
import 'package:myapp/pages/FoodRecommendationPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor:
            Colors.black, // ตั้งค่าสีพื้นหลังของ Scaffold เป็นสีดำ
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0),
        ),
        useMaterial3: true,
      ),
      home: const ScaffoldExample(), // หน้าเริ่มต้น
    );
  }
}

class ScaffoldExample extends StatefulWidget {
  const ScaffoldExample({super.key});

  @override
  State<ScaffoldExample> createState() => _ScaffoldExampleState(); // ต้องเรียก State ที่เกี่ยวข้อง
}

class _ScaffoldExampleState extends State<ScaffoldExample> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    FoodRecommendationPage(),
    Homepage(), // หน้าหลัก
    FoodReminderPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex), // แสดงหน้าแต่ละหน้า
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank, color: Colors.white),
            label: 'Recommendation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_add, color: Colors.white),
            label: 'Addlist',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
//ict555