import 'package:flutter/material.dart';
// 1. Importa i tuoi nuovi file
import 'theme/util.dart';
import 'theme/theme.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Usiamo la sintassi moderna super.key

  @override
  Widget build(BuildContext context) {
    // 2. Prepariamo i font (Roboto o quello che hai scelto sul sito)
    final textTheme = createTextTheme(context, "Noto Sans", "Noto Sans");

    // 3. Inizializziamo il tema Material 3 scaricato
    final theme = MaterialTheme(textTheme);

    return MaterialApp(
      title: "Nap App",
      debugShowCheckedModeBanner: false,

      // 4. Applichiamo i colori scaricati per il tema chiaro e scuro
      theme: theme.light(),
      darkTheme: theme.dark(),

      // Segue le impostazioni del telefono (chiaro o scuro)
      themeMode: ThemeMode.light,

      home: const HomePage(),
    );
  }
}
