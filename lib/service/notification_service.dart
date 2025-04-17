import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pillmate_channel',
          'PillMate Notifications',
          channelDescription: 'Pill reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> scheduleMultipleNotis({
    required int id,
    required String title,
    required DateTime expirationDate,
  }) async {
    // เตือนล่วงหน้าวันก่อนหมดอายุ
    final DateTime dayBefore = expirationDate.subtract(const Duration(days: 1));
    final DateTime now = DateTime.now();
    final DateTime testTime = DateTime(
      now.year,
      now.month,
      now.day,
      0,
      28,
    ); // 00:25 วันนี้

    final List<DateTime> scheduleTimes = [
      testTime,
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 9),
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 12),
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 15),
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 18),
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 21),
      DateTime(dayBefore.year, dayBefore.month, dayBefore.day, 23, 59),
    ];

    final List<String> messages = [
      '🧪 [Test] Noti "$title" ',
      '🕘 เหลืออีก 1 วัน! "$title" จะหมดอายุเร็ว ๆ นี้',
      '🍽️ เที่ยงนี้อย่าลืมใช้ "$title" ก่อนหมดอายุ!',
      '⏰ ใกล้หมดอายุ! "$title" จะหมดภายใน 1 วัน',
      '🔥 บ่ายเย็นแล้ว รีบเช็ค "$title" ก่อนหมดอายุ!',
      '⚠️ อีกไม่กี่ชม. "$title" ใกล้หมดอายุ',
      '⏳ ดึกนี้ "$title" จะหมดอายุแล้ว!',
    ];

    for (int i = 0; i < scheduleTimes.length; i++) {
      final DateTime scheduledTime = scheduleTimes[i];
      if (scheduledTime.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: id * 10 + i,
          title: 'ใกล้หมดอายุแล้ว! 🧊',
          body: messages[i],
          scheduledTime: scheduledTime,
        );
        print('🔔 Scheduled Noti: ${id * 10 + i} at $scheduledTime');
      }
    }
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelMultiple(int id) async {
    final pendingNotis =
        await _notificationsPlugin.pendingNotificationRequests();
    for (int i = 0; i < 6; i++) {
      int notiId = id * 10 + i;
      if (pendingNotis.any((noti) => noti.id == notiId)) {
        await _notificationsPlugin.cancel(notiId);
        print('❌ Cancelled noti id: $notiId');
      }
    }
  }

  static Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pillmate_channel',
          'PillMate Notifications',
          channelDescription: 'Pill reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}

void testNoti() {
  NotificationService.showImmediateNotification(
    id: 999,
    title: 'แจ้งเตือนทันที!',
    body: 'แจ้งเตือนทดสอบแบบเด้งทันทีแม้อยู่ในแอป',
  );
}
