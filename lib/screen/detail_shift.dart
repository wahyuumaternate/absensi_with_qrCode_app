import 'package:flutter/material.dart';

class ShiftDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detail Shift"),
        backgroundColor: Color(0xFF0A3981),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Detail informasi shift akan ditampilkan di sini.",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
