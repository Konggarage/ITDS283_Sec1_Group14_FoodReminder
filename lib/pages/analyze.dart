import 'package:flutter/material.dart';
import 'package:myapp/pages/settingpage.dart';

class Analyze extends StatefulWidget {
  const Analyze({super.key});
  @override
  State<Analyze> createState() => _Analyze();
}

class _Analyze extends State<Analyze> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      backgroundColor: Colors.black,
      body: Column(
        
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () {
          Navigator.pushNamed(context, '/analyze');
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
}
