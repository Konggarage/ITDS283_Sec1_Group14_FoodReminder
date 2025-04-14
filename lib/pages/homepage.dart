import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // Import DatabaseHelper
import 'package:myapp/pages/Todaypage.dart'; // Add imports for other pages
import 'package:myapp/pages/Allpage.dart'; // Add imports for other pages
import 'package:myapp/pages/Completedpage.dart'; // Add imports for other pages
import 'package:myapp/pages/Schedulepage.dart'; // Add imports for other pages
import 'package:myapp/pages/analyze.dart'; // Add imports for other pages
import 'package:myapp/pages/settingpage.dart'; // Add setting page import
import 'package:myapp/pages/Detaillpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/pages/loginpopup.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> allReminders = []; // All reminder list
  List<Map<String, dynamic>> filteredReminders = []; // Filtered reminder list
  String searchQuery = "";
  String? phoneNumber;
  String? profileImagePath;
  String? profileName;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _fetchAllReminders();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    Future.delayed(Duration.zero, () async {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username');
      if (username == null || username.isEmpty) {
        final result = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const LoginPopup(),
        );

        if (result == true) {
          _loadProfileData();
          _fetchAllReminders();
        }
      }
    });
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final phone = prefs.getString('phone') ?? '(No Number)';
    final name = prefs.getString('username') ?? 'Guest';
    final image = prefs.getString('profileImage');
    print('📷 Loaded profileImagePath: $image');

    if (mounted) {
      setState(() {
        phoneNumber = phone;
        profileName = name;
        profileImagePath = image;
      });
      print(
        '✅ Updated UI with: $profileName / $phoneNumber / $profileImagePath',
      );
    }
  }

  // Fetch all reminders from the database
  Future<void> _fetchAllReminders() async {
    final reminders = await DatabaseHelper.instance.fetchReminders();
    setState(() {
      allReminders = reminders;
      filteredReminders = reminders; // Initially show all reminders
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
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
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color?.withOpacity(0.6),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
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
                  color: Theme.of(context).cardColor, // Updated color
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
                        style:
                            Theme.of(
                              context,
                            ).textTheme.bodyLarge, // Updated text style
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
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      leading: IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Analyze()),
          );
        },
        icon: const Icon(Icons.bar_chart),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Settingpage()),
            );
            _loadProfileData(); // โหลดข้อมูลใหม่เมื่อกลับจาก Settings
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              radius: 20,
              child: Icon(
                icon,
                color: Theme.of(context).iconTheme.color ?? color,
                size: 24,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleMedium?.color,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
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
          color: Theme.of(context).cardColor,
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
                  radius: 60,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundImage:
                      (profileImagePath != null && profileImagePath!.isNotEmpty)
                          ? FileImage(File(profileImagePath!))
                          : null,
                  child:
                      (profileImagePath == null || profileImagePath!.isEmpty)
                          ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).iconTheme.color,
                          )
                          : null,
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome Back!",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10),
                      Text(
                        profileName ?? 'Guest',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              phoneNumber ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
