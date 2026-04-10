import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
} //main

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // root of my application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Nap App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
        ),
        textTheme: GoogleFonts.notoSansTextTheme(),
      ),
      home: const HomePage(),
    );
  } //build
} //MyApp
