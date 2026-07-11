import 'package:flutter/material.dart';
import 'package:napapp/screens/login_page.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'theme/util.dart';
import 'theme/theme.dart';
import 'screens/home_page.dart';

void main() async {
  // Initialize system bindings (required to read async data before startup).
  WidgetsFlutterBinding.ensureInitialized();

  // Load the saved theme BEFORE drawing the UI.
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();

  // Run the app, making the ThemeProvider accessible to all screens.
  runApp(
    ChangeNotifierProvider.value(value: themeProvider, child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen for changes: if the theme is modified, the UI rebuilds automatically.
    final themeProvider = context.watch<ThemeProvider>();

    final textTheme = createTextTheme(context, "Noto Sans", "Noto Sans");
    final theme = MaterialTheme(textTheme);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Apply the generated themes and set the user's chosen mode.
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeProvider.themeMode,

      // Define the initial page and navigation routes.
      home: LoginPage(),

      routes: {'/homepage': (context) => const HomePage()},
    );
  }
}
