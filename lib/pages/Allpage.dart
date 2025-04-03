import 'package:flutter/material.dart';

class Allpage extends StatelessWidget {
  const Allpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Allpage', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text(
          "This is the Allpage Page",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
