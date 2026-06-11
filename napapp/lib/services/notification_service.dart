import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timeNow;
import 'package:timezone/timezone.dart' as timeNow;

class NotificationService {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    timeNow.initializeTimeZones();
    timeNow.setLocalLocation(timeNow.local);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidInit);

    await plugin.initialize(settings);
  }

  static Future<void> showNapNotification(int minutes) async {
    await plugin.show(
      0,
      "Timer avviato",
      "$minutes minuti",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }

  static Future<void> showTestNotification() async {
    await plugin.show(
      0,
      "Test",
      "Ciao",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> setAlarm(int minutes) async {
    final scheduled = DateTime.now().add(Duration(minutes: minutes));

    await plugin.zonedSchedule(
      scheduled.hashCode,
      "Sveglia",
      "Il tuo riposino è finito!",
      timeNow.TZDateTime.from(scheduled, timeNow.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarm',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
