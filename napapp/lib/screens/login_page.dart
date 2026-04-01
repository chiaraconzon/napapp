import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  static const routename = 'LoginPage';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text('To the home'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  } //build
} //ProfilePage
