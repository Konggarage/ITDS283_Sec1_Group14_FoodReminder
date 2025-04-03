class Reminder {
  final int? id;
  final String reminder;
  final String category;
  final String date;
  final String time;
  final String imagePath;

  Reminder({
    this.id,
    required this.reminder,
    required this.category,
    required this.date,
    required this.time,
    required this.imagePath,
  });

  // Convert a Map object to Reminder object
  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      reminder: map['reminder'],
      category: map['category'],
      date: map['date'],
      time: map['time'],
      imagePath: map['imagePath'],
    );
  }

  // Convert a Reminder object to a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminder': reminder,
      'category': category,
      'date': date,
      'time': time,
      'imagePath': imagePath,
    };
  }
}
