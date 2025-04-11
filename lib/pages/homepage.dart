import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // Import DatabaseHelper
import 'package:intl/intl.dart';
import 'package:myapp/pages/Todaypage.dart'; // Add imports for other pages
import 'package:myapp/pages/Allpage.dart'; // Add imports for other pages
import 'package:myapp/pages/Completedpage.dart'; // Add imports for other pages
import 'package:myapp/pages/Schedulepage.dart'; // Add imports for other pages
import 'package:myapp/pages/analyze.dart'; // Add imports for other pages
import 'package:myapp/pages/settingpage.dart'; // Add setting page import
import 'package:myapp/pages/Detaillpage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allReminders = []; // All reminder list
  List<Map<String, dynamic>> filteredReminders = []; // Filtered reminder list
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchAllReminders();
  }

  // Fetch all reminders from the database
  Future<void> _fetchAllReminders() async {
    final reminders = await DatabaseHelper.instance.fetchReminders();
    setState(() {
      allReminders = reminders;
      filteredReminders = reminders; // Initially show all reminders
    });
  }

  // ฟังก์ชันลบ reminder
  void _deleteReminder(int id) async {
    await DatabaseHelper.instance.deleteReminder(id);
    // โหลดข้อมูลใหม่ทั้งหมดจาก database
    final reminders = await DatabaseHelper.instance.fetchReminders();

    setState(() {
      allReminders = reminders;
      // กรองข้อมูลใหม่อีกทีตาม query เดิม
      filteredReminders =
          allReminders.where((reminder) {
            final reminderTitle = reminder['reminder'].toLowerCase();
            final searchQueryLower = searchQuery.toLowerCase();
            return reminderTitle.contains(searchQueryLower);
          }).toList();
    });
  }

  // ฟังก์ชันกรองผลลัพธ์ที่แสดงใน search
  Future<void> _filterSearchResults(String query) async {
    final reminders =
        await DatabaseHelper.instance.fetchReminders(); // ดึงข้อมูลใหม่จาก DB
    final searchQueryLower = query.toLowerCase();

    setState(() {
      searchQuery = query;
      filteredReminders =
          reminders.where((reminder) {
            final reminderTitle = reminder['reminder'].toLowerCase();
            return reminderTitle.contains(searchQueryLower);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main UI elements
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // SearchBar with no space below it
                Container(
                  padding: EdgeInsets.only(
                    bottom: 0,
                  ), // Adjust padding to reduce space
                  child: TextField(
                    onChanged: (query) {
                      _filterSearchResults(query); // ใช้เวอร์ชัน async นี้แทน
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      hintText: 'Search...',
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: const Color(
                        0xFF2A2A2A,
                      ), // Dark grey background
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Profile Card
                profileCard(),
                SizedBox(height: 60),
                // Category Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                    childAspectRatio: 1.2,
                    children: [
                      categoryCard(
                        Icons.event_available,
                        "Today",
                        Colors.blue,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TodayPage(),
                            ),
                          );
                        },
                      ),
                      categoryCard(
                        Icons.calendar_today,
                        "Schedule",
                        Colors.red,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SchedulePage(),
                            ),
                          );
                        },
                      ),
                      categoryCard(Icons.list_alt, "All", Colors.grey, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AllPage()),
                        );
                      }),
                      categoryCard(
                        Icons.check_circle,
                        "Completed",
                        Colors.green,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CompletedPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // The search results dropdown
          Positioned(
            top: 70, // Adjust to position it below the search bar
            left: 20,
            right: 20,
            child: Visibility(
              visible:
                  searchQuery
                      .isNotEmpty, // Only show when search query is not empty
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(
                    0.8,
                  ), // Dark background for dropdown
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredReminders.length,
                  itemBuilder: (context, index) {
                    final reminder = filteredReminders[index];
                    return ListTile(
                      title: Text(
                        reminder['reminder'],
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {
                        final reminderId =
                            filteredReminders[index]['id']; // ดึง ID ของ reminder
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetailPage(
                                  reminderId: reminderId,
                                ), // นำทางไปยัง DetailPage
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Analyze()),
          );
        },
        icon: Icon(Icons.bar_chart, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Settingpage()),
            );
          },
        ),
      ],
    );
  }

  Widget categoryCard(
    IconData icon,
    String title,
    Color color,
    Function onPressed,
  ) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        decoration: BoxDecoration(
          color: Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 20,
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 10),
            Text(title, style: TextStyle(color: Colors.white70, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget profileCard() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.green.shade600, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/chinjang.png'),
                  radius: 60,
                ),
                SizedBox(width: 13),
                Column(
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text("AKE ASOKE", style: TextStyle(fontSize: 15)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Text("(405) 555-0128", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
