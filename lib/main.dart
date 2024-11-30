import 'package:HMTI_ABSEN/screen/splash_screen.dart';
import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFF0A3981),
      ),
      home: SplashScreen(),
    );
  }
}
