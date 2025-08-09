import 'package:flutter/material.dart';
import '../JsonModels/signup.dart';
import 'intro/intro_page.dart';
import 'JsonModels/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const IntroPage(),
      routes: {
        '/intropage': (context) => const IntroPage(),
        '/loginpage': (context) => const LoginScreen(),
        '/signuppage': (context) => const SignUp(),
      },
    );
  }
}
