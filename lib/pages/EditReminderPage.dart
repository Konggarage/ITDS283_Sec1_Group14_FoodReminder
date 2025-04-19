import 'package:flutter/material.dart';
import 'package:myapp/Fooddatabase.dart';
import 'package:myapp/service/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class EditReminderPage extends StatefulWidget {
  final int reminderId;
  const EditReminderPage({required this.reminderId, super.key});

  @override
  _EditReminderPageState createState() => _EditReminderPageState();
}

class _EditReminderPageState extends State<EditReminderPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  String _expirationDate = '';

  @override
  void initState() {
    super.initState();
    _fetchReminder();
  }

  Future<void> _fetchReminder() async {
    try {
      final reminder = await DatabaseHelper.instance.fetchReminderById(
        widget.reminderId,
      );
      _titleController.text = reminder['reminder'];
      _timeController.text = reminder['time'];
      _dateController.text = reminder['date'];
      _categoryController.text = reminder['category'];

      _expirationDate = calculateExpirationDate(
        reminder['date'],
        reminder['category'],
      );
      _expirationDateController.text = _expirationDate;
    } catch (e) {
      print("Error fetching reminder: $e");
    }
  }

  String calculateExpirationDate(String date, String category) {
    DateTime selectedDate = DateTime.parse(date);
    int daysToAdd = 0;
    if (category == 'Meat & Fish') {
      daysToAdd = 5;
    } else if (category == 'Vegetables & Fruits') {
      daysToAdd = 3;
    }
    DateTime expirationDate = selectedDate.add(Duration(days: daysToAdd));
    return DateFormat('yyyy-MM-dd').format(expirationDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Reminder",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit your reminder:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Reminder Title',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _timeController,
              readOnly: true,
              onTap: () async {
                TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (selectedTime != null) {
                  setState(() {
                    _timeController.text = selectedTime.format(context);
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Time',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: () async {
                DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  setState(() {
                    _dateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(selectedDate);
                    _expirationDate = calculateExpirationDate(
                      _dateController.text,
                      _categoryController.text,
                    );
                    _expirationDateController.text = _expirationDate;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Date',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _expirationDateController,
              readOnly: true,
              onTap: () async {
                DateTime? selectedExpirationDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (selectedExpirationDate != null) {
                  setState(() {
                    _expirationDate = DateFormat(
                      'yyyy-MM-dd',
                    ).format(selectedExpirationDate);
                    _expirationDateController.text = _expirationDate;
                  });
                }
              },
              decoration: const InputDecoration(
                labelText: 'Expiration Date',
                labelStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_expirationDateController.text.isEmpty) {
                  _expirationDate = calculateExpirationDate(
                    _dateController.text,
                    _categoryController.text,
                  );
                } else {
                  _expirationDate = _expirationDateController.text;
                }

                // ตรวจสอบว่า Expiration Date ไม่ต่ำกว่าวันนี้
                try {
                  DateTime expiration = DateTime.parse(_expirationDate);
                  if (expiration.isBefore(
                    DateTime.now().subtract(const Duration(days: 1)),
                  )) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Expiration date must be in the future or today.',
                        ),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    return;
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid Expiration Date format.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // ตรวจสอบว่า Title, Time และ Date ไม่เป็นค่าว่าง
                if (_titleController.text.isEmpty ||
                    _timeController.text.isEmpty ||
                    _dateController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields.'),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                _saveReminder();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveReminder() async {
    if (_titleController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final expiration = DateTime.parse(_expirationDate);
    if (expiration.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expiration date must be in the future or today.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updatedReminder = {
      'id': widget.reminderId,
      'reminder': _titleController.text,
      'time': _timeController.text,
      'date': _dateController.text,
      'expirationDate': _expirationDate,
    };

    try {
      await DatabaseHelper.instance.updateReminder(
        widget.reminderId,
        updatedReminder,
      );

      final prefs = await SharedPreferences.getInstance();
      final enableNoti = prefs.getBool('enableNotification') ?? true;

      if (enableNoti) {
        await NotificationService.cancelMultiple(widget.reminderId);
        await NotificationService.scheduleMultipleNotis(
          id: widget.reminderId,
          title: 'Reminder: ${_titleController.text}',
          expirationDate: DateTime.parse(_expirationDate),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      print("Error updating reminder: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update reminder'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
