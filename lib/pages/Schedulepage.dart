import 'package:flutter/material.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Schedule', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text(
          "This is the Schedule Page",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
