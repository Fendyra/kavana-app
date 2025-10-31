import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, {int minute = 0}) {
    final tz.Location wib = tz.getLocation('Asia/Jakarta');
    final tz.TZDateTime now = tz.TZDateTime.now(wib);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(wib, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> scheduleAllDailyReminders() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Selamat Pagi! ☀️',
      'Semangat mengawali hari! Jangan lupa buat rencana hebat hari ini.',
      _nextInstanceOfTime(8),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_morning_channel',
          'Daily Morning Reminders',
          channelDescription: 'Channel for daily morning reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Waktunya Istirahat! 🍱',
      'Sudahkah kamu istirahat dan makan siang? Jaga energimu!',
      _nextInstanceOfTime(12),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_noon_channel',
          'Daily Noon Reminders',
          channelDescription: 'Channel for daily noon reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      'Bagaimana Harimu? 🤔',
      'Yuk, luangkan waktu sejenak untuk mencatat perasaanmu di Kavana.',
      _nextInstanceOfTime(17),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_evening_channel',
          'Daily Evening Reminders',
          channelDescription: 'Channel for daily evening reminders (mood check)',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      3,
      'Selamat Tidur 🌙',
      'Jangan lupa bersyukur untuk hari ini dan selamat beristirahat.',
      _nextInstanceOfTime(21),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_night_channel',
          'Daily Night Reminders',
          channelDescription: 'Channel for daily night reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
