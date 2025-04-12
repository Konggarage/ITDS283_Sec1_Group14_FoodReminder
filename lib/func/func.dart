import 'package:intl/intl.dart';

String calculateExpirationDate(String date, String category) {
  final DateTime inputDate = DateTime.parse(
    date,
  ); // แปลงวันที่ที่ผู้ใช้กรอกเป็น DateTime

  final expirationMap = {
    'Meat & Fish': 5,
    'Vegetables & Fruits': 3,
    'Bread & Bakery Products': 2,
    'Rice & Pasta': 3,
    'Beverages': 5,
    'Processed Foods': 10,
    'Condiments & Sauces': 20,
  };

  final daysToAdd = expirationMap[category] ?? 7;

  final DateTime expirationDate = inputDate.add(
    Duration(days: daysToAdd),
  ); // เพิ่มจำนวนวัน
  final DateFormat formatter = DateFormat('yyyy-MM-dd'); // ฟอร์แมตวันที่
  return formatter.format(expirationDate); // คืนค่าผลลัพธ์ในรูปแบบที่ต้องการ
}

// ฟังก์ชันสำหรับเช็คว่า input ถูกกรอกครบทุกช่อง
bool isFormValid(String title, String category, String date, String time) {
  return title.isNotEmpty &&
      category.isNotEmpty &&
      date.isNotEmpty &&
      time.isNotEmpty;
}
