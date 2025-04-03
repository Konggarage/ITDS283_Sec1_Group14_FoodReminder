import 'package:flutter/material.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today\'s Reminder',
        style: TextStyle(
          color: Colors.white,
        ),),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading for Today's Reminder
            const Text(
              'Reminder for Today:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 16),

            // A simple ListView for displaying reminders
            Expanded(
              child: ListView(
                children: [
                  // Sample reminder item
                  ReminderItem(title: 'Eat Vegetables', time: '10:00 AM'),
                  ReminderItem(title: 'Drink Water', time: '12:00 PM'),
                  ReminderItem(title: 'Workout', time: '5:00 PM'),
                  // More reminder items can be added here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderItem extends StatelessWidget {
  final String title;
  final String time;

  const ReminderItem({required this.title, required this.time, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          time,
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
