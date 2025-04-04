import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart'; // อย่าลืม import DatabaseHelper

class CompletedPage extends StatefulWidget {
  const CompletedPage({super.key});
  @override
  State<CompletedPage> createState() => _CompletedPageState();
}

class _CompletedPageState extends State<CompletedPage> {
  List<Map<String, dynamic>> completedReminders = [];
  @override
  void initState() {
    super.initState();
    _fetchCompletedReminders();
  }

  Future<void> _fetchCompletedReminders() async {
    final completed = await DatabaseHelper.instance.fetchCompletedReminders();
    setState(() {
      completedReminders = completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Completed Reminders',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Completed Reminder:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: completedReminders.length,
                itemBuilder: (context, index) {
                  final reminder = completedReminders[index];
                  return CompletedReminderItem(
                    title: reminder['reminder'],
                    time: reminder['time'],
                    date: reminder['date'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompletedReminderItem extends StatelessWidget {
  final String title;
  final String time;
  final String date;

  const CompletedReminderItem({
    required this.title,
    required this.time,
    required this.date,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '$date $time',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
    );
  }
}
