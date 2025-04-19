import 'package:intl/intl.dart';

String calculateExpirationDate(String date, String category) {
  final DateTime inputDate = DateTime.parse(
    date,
  ); // แปลงวันที่ที่ได้รับเป็น DateTime

  // Map ที่เก็บจำนวนวันที่จะเพิ่มตามประเภท
  final expirationMap = {
    'Meat & Fish': 5,
    'Vegetables & Fruits': 5,
    'Bread & Bakery Products': 2,
    'Rice & Pasta': 3,
    'Beverages': 5,
    'Processed Foods': 10,
    'Condiments & Sauces': 20,
  };

  // ดึงจำนวนวันที่ต้องเพิ่มจาก expirationMap ตามประเภท
  final daysToAdd =
      expirationMap[category] ?? 7; // ถ้าไม่พบประเภทให้เพิ่ม 7 วัน

  // คำนวณวันที่หมดอายุ
  final DateTime expirationDate = inputDate.add(Duration(days: daysToAdd));

  // แปลง DateTime เป็น String ในรูปแบบ 'yyyy-MM-dd'
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(expirationDate);
}

// ฟังก์ชันสำหรับเช็คว่า input ถูกกรอกครบทุกช่อง
bool isFormValid(String title, String category, String date, String time) {
  return title.isNotEmpty &&
      category.isNotEmpty &&
      date.isNotEmpty &&
      time.isNotEmpty;
}
