import 'package:flutter/material.dart';
import 'package:napapp/screens/login_page.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'theme/util.dart';
import 'theme/theme.dart';
import 'screens/home_page.dart';

void main() async {
  // Necessario perché SharedPreferences (usato da loadSavedTheme) fa
  // chiamate a piattaforma prima che runApp() abbia inizializzato i binding.
  WidgetsFlutterBinding.ensureInitialized();

  // Carica il tema salvato nella sessione precedente PRIMA di disegnare la
  // UI, così l'app parte già con il tema giusto invece di lampeggiare
  // prima su ThemeMode.system e poi passare al tema corretto.
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
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
      debugShowCheckedModeBanner: false,
      theme: theme.light(),
      darkTheme: theme.dark(),
      themeMode: themeProvider.themeMode,

      home: LoginPage(),

      routes: {'/homepage': (context) => const HomePage()},
    );
  }
}
