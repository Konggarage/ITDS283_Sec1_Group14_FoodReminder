import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/main.dart'; // สำหรับ ScaffoldExample
import 'package:myapp/Fooddatabase.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class Settingpage extends StatefulWidget {
  const Settingpage({super.key});

  @override
  State<Settingpage> createState() => _SettingpageState();
}

class _SettingpageState extends State<Settingpage> {
  bool isReminderOn = true;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  int phoneNumber = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedName = prefs.getString('username') ?? '';
    final loadedPhone = prefs.getString('phone') ?? '';
    final reminder = prefs.getBool('expirationAlertsEnabled') ?? true;

    setState(() {
      usernameController.text = loadedName;
      phoneController.text = loadedPhone;
      isReminderOn = reminder;
    });
  }

  void handleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final username = usernameController.text;
    final phone = phoneController.text;

    await prefs.setString('username', username);
    await prefs.setString('phone', phone);

    setState(() {
      phoneNumber = int.tryParse(phone) ?? 0;
    });

    print('✅ Saved: $username / $phone');
    Navigator.pop(context, true);
  }

  void _saveProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImage', path);
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '“ Are you sure you want to delete your account? ”',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'This action is irreversible, and all your data will be permanently lost.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text(
                        "Sure",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('username');
                        await prefs.remove('phone');
                        await prefs.remove('profileImage');
                        await prefs.setBool('isLoggedIn', false);
                        await DatabaseHelper.instance
                            .deleteAllReminders(); // ลบทุก reminder ในฐานข้อมูล

                        Navigator.of(context).pop(); // ปิด dialog

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    const ScaffoldExample(initialIndex: 1),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              "Account Settings",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  final directory = await getApplicationDocumentsDirectory();
                  final name = p.basename(pickedFile.path);
                  final savedImage = await File(
                    pickedFile.path,
                  ).copy('${directory.path}/$name');

                  _saveProfileImagePath(savedImage.path);
                  setState(() {}); // รีโหลด CircleAvatar
                }
              },
              child: FutureBuilder<SharedPreferences>(
                future: SharedPreferences.getInstance(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final prefs = snapshot.data!;
                    final imagePath = prefs.getString('profileImage') ?? '';
                    return CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          imagePath.isNotEmpty && File(imagePath).existsSync()
                              ? FileImage(File(imagePath))
                              : null,
                      child:
                          imagePath.isEmpty || !File(imagePath).existsSync()
                              ? const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey,
                              )
                              : null,
                    );
                  } else {
                    return const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your username',
                hintStyle: const TextStyle(color: Colors.grey),
                labelText: "Username",
                labelStyle: const TextStyle(color: Colors.white),
                suffixIcon: const Icon(Icons.edit, color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: phoneController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: InputDecoration(
                      counterText: '', // hides character counter
                      hintText: '+66 xx-xxx-xxxx',
                      hintStyle: const TextStyle(color: Colors.grey),
                      labelText: "Phone number",
                      labelStyle: const TextStyle(color: Colors.white),
                      suffixIcon: const Icon(Icons.edit, color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    handleSave();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Enable Expiration Alerts",
                    style: TextStyle(color: Colors.white),
                  ),
                  Switch(
                    value: isReminderOn,
                    onChanged: (val) async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('expirationAlertsEnabled', val);
                      setState(() {
                        isReminderOn = val;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showDeleteConfirmation,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Delete Account"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
