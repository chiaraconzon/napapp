import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';
import 'theme/util.dart';
import 'theme/theme.dart';
import 'screens/home_page.dart';
import 'services/notification_service.dart';

void main() async {
  // alarm notification initialization
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // event controller for alarms
  static final EventController _eventController = EventController();

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, "Noto Sans", "Noto Sans");
    final theme = MaterialTheme(textTheme);
    // provider
    return CalendarControllerProvider(
      controller: _eventController,
      child: MaterialApp(
        title: "Nap App",
        debugShowCheckedModeBanner: false,
        theme: theme.light(),
        darkTheme: theme.dark(),
        themeMode: ThemeMode.light,
        home: const HomePage(),
        routes: {'/homepage': (context) => const HomePage()},
      ),
    );
  }
}
