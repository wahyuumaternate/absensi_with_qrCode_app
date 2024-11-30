import 'dart:async';
import 'package:HMTI_ABSEN/screen/HomePage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Timer untuk menunggu 3 detik sebelum ke LoginScreen
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ));
    });

    return Scaffold(
      backgroundColor: Colors.white, // Warna latar belakang
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti dengan logo atau gambar aplikasi Anda
            Image.asset("assets/LOGO_HMTI.png"),
            SizedBox(height: 3),
            Text(
              'HMTI ATTENDANCE',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A3981)),
            ),
          ],
        ),
      ),
    );
  }
}
