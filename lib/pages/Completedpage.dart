import 'package:flutter/material.dart';


class Completed extends StatelessWidget {
  const Completed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Completed', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Text(
          "This is the Completed Page",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
