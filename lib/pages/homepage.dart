import 'package:flutter/material.dart';
import 'package:myapp/pages/settingpage.dart';
import 'package:myapp/pages/Todaypage.dart';
import 'package:myapp/pages/Allpage.dart';
import 'package:myapp/pages/Completedpage.dart';
import 'package:myapp/pages/Schedulepage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomePageState();
}

class _HomePageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ ต้องใช้ children: []
            SizedBox(height: 10),
            Center(
              child: SizedBox(
                width: 300, // ปรับความกว้าง
                height: 30, // ปรับความสูง
                child: SearchBar(
                  leading: const Icon(Icons.search, color: Colors.white),
                  hintText: ('Search'),
                  hintStyle: WidgetStateProperty.all(
                    TextStyle(color: Colors.white),
                  ),
                  shadowColor: WidgetStateProperty.all(Colors.black),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  padding: WidgetStateProperty.all(
                    EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  backgroundColor: WidgetStateProperty.all(Color(0xFF1C1C1E)),
                ),
              ),
            ),
            SizedBox(height: 20),
            profilecard(),

            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GridView.count(
                shrinkWrap: true,
                physics:
                    NeverScrollableScrollPhysics(), // ป้องกันการ Scroll ซ้อนกัน
                crossAxisCount: 2, // 2 คอลัมน์
                mainAxisSpacing: 15, // ระยะห่างแนวตั้ง
                crossAxisSpacing: 15, // ระยะห่างแนวนอน
                childAspectRatio: 1.2,
                children: [
                  categoryCard(Icons.event_available, "Today", Colors.blue, () {
                    // Navigate to TodayPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TodayPage()),
                    );
                  }),
                  categoryCard(
                    Icons.calendar_today,
                    "Schedule",
                    Colors.red,
                    () {
                      // Navigate to SchedulePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SchedulePage()),
                      );
                    },
                  ),
                  categoryCard(Icons.list_alt, "All", Colors.grey, () {
                    // Navigate to AllPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Allpage()),
                    );
                  }),
                  categoryCard(
                    Icons.check_circle,
                    "Completed",
                    Colors.green,
                    () {
                      // Navigate to CompletedPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Completed()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () {
          debugPrint("Graph icon pressed");
        },
        icon: Icon(Icons.bar_chart, color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: Colors.white,
          ), // ไอคอนด้านขวา (actions)
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
      onTap: () => onPressed(), // ใช้ onPressed ในการเรียกฟังก์ชัน
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
}

class profilecard extends StatelessWidget {
  const profilecard({super.key});

  @override
  Widget build(BuildContext context) {
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
                SizedBox(width: 13), // เว้นระยะห่าง
                Column(
                  children: [
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10), // เว้นระยะห่าง
                    Text("AKE ASOKE", style: TextStyle(fontSize: 15)),
                  ],
                ),
              ],
            ),
            SizedBox(width: 10),
            SizedBox(height: 10), // เว้นระยะห่าง
            Text("(405) 555-0128", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
