import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  // INIZIALIZZAZIONE
  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidInit);

    await plugin.initialize(settings);
  }

  //FUNZIONE SVEGLIA
  static Future<void> setAlarm(int minutes) async {
    final scheduled = DateTime.now().add(Duration(minutes: minutes));

    await plugin.zonedSchedule(
      scheduled.hashCode, // id univoco
      "Sveglia",
      "Il tuo riposino è finito!",
      tz.TZDateTime.from(scheduled, tz.local),

      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarm',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),

      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
