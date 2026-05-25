import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as timeNow;
import 'package:timezone/timezone.dart' as timeNow;

class NotificationService {
  static final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  // initialization:
  static Future<void> init() async {
    // it is a function that we can recall without creating an object
    timeNow.initializeTimeZones();
    // it tells us how the notification on the phone appears (it tells me that it will uses my app icon)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    // it creates a package with my configurations (as the app icon)
    const settings = InitializationSettings(android: androidInit);
    // initialize the notification plugin(runs everything)
    await plugin.initialize(settings);
  }

  // alarm function:
  static Future<void> setAlarm(int minutes) async {
    // given the rigth now time, it adds the minutes
    final scheduled = DateTime.now().add(Duration(minutes: minutes));

    // it tells us that we want the notification in the future
    await plugin.zonedSchedule(
      scheduled.hashCode, // univoc ID of my alarm
      "Sveglia",
      "Il tuo riposino è finito!",
      // the date and time is transformed in a specific time and date type
      timeNow.TZDateTime.from(scheduled, timeNow.local),

      // here I configure how the notification appears
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel', // mandatory
          'Alarm', // name of the channel
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      // permits the alarm to ring ALSO if the phone is in stand-by
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // time is interpreted as absolute, it assocciate "30 minuti" to a SPECIFIC moment
    );
  }
}
