import 'package:flutter/material.dart';
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
      title: "Wearable Project",
      home: const HomePage(title: "home"),
    );
  } //build
} //MyApp
