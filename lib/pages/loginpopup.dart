import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPopup extends StatefulWidget {
  const LoginPopup({super.key});

  @override
  State<LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  String name = '';
  String phone = '';
  String imagePath = '';
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() {
        imagePath = picked.path;
      });
    }
  }

  void _saveData() async {
    if (name.isNotEmpty && phone.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('username', name);
      prefs.setString('phone', phone);
      prefs.setString('profileImage', imagePath);
      prefs.setBool('isLoggedIn', true);

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundImage:
                  imagePath.isNotEmpty ? FileImage(File(imagePath)) : null,
              child:
                  imagePath.isEmpty
                      ? const Icon(Icons.camera_alt, size: 30)
                      : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(labelText: "What's your name"),
            onChanged: (value) => name = value,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(labelText: "Phone number"),
            keyboardType: TextInputType.phone,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => phone = value,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveData,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
