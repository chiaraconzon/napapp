import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart'; // Fondamentale per il controller
import 'theme/util.dart';
import 'theme/theme.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Creiamo il controller qui: è il "cuore" dei dati per le tue coccinelle
  static final EventController _eventController = EventController();

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, "Noto Sans", "Noto Sans");
    final theme = MaterialTheme(textTheme);

    // Avvolgiamo tutto l'App con il Provider
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
