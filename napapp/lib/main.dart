import 'package:flutter/material.dart';
import 'package:napapp/screens/login_page.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'theme/util.dart';
import 'theme/theme.dart';
import 'screens/home_page.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    final textTheme = createTextTheme(context, "Noto Sans", "Noto Sans");
    final theme = MaterialTheme(textTheme);

    return MaterialApp(
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeProvider.themeMode,

      home: LoginPage(),

      routes: {'/homepage': (context) => const HomePage()},
    );
  }
}
