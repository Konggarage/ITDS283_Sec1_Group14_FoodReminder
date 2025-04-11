import 'package:flutter/material.dart';
import 'package:myapp/pages/homepage.dart';
import 'package:myapp/pages/Addlistpage.dart';
import 'package:myapp/pages/FoodRecommendationPage.dart';
import 'package:myapp/pages/analyze.dart';
import 'package:myapp/pages/settingpage.dart';

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
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 0, 0),
        ),
        useMaterial3: true,
      ),
      home: const ScaffoldExample(initialIndex: 1), // หน้าเริ่มต้นเป็น HomePage
    );
  }
}

class ScaffoldExample extends StatefulWidget {
  final int initialIndex;
  const ScaffoldExample({super.key, this.initialIndex = 0});

  @override
  State<ScaffoldExample> createState() => _ScaffoldExampleState();
}

class _ScaffoldExampleState extends State<ScaffoldExample> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // หน้าในแต่ละหน้าของแอป
  static const List<Widget> _widgetOptions = <Widget>[
    FoodRecommendationPage(), // หน้าแนะนำ
    HomePage(),
    FoodReminderPage(), // หน้า Addlist
    Analyze(), // หน้า Analyze
    Settingpage(), // หน้า Settings
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.food_bank, color: Colors.white),
            label: 'Recommendation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
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

// testttttt
