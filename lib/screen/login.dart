import 'package:HMTI_ABSEN/screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true; // Variabel untuk mengontrol visibilitas password

  // Fungsi untuk login ke API
  Future<void> login(BuildContext context) async {
    final String apiUrl =
        'https://absen-web.wahyuumaternate.my.id/api/login'; // Ganti dengan URL API Anda

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': usernameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Mengambil token dan user dari response
        final token = data['token'];
        final user = data['user'];

        // Simpan token dan user ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('userId', user['id']);
        await prefs.setString('userName', user['name']);
        await prefs.setString('userEmail', user['email']);
        await prefs.setString('jabatan', user['jabatan']);
        await prefs.setString('foto', user['foto']);
        await prefs.setBool('isLoggedIn', true); // Menyimpan status login

        // Navigasi ke halaman Home setelah login berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } else {
        // Jika login gagal, tampilkan pesan error
        final Map<String, dynamic> errorData = json.decode(response.body);
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Login Failed'),
              content: Text(errorData['message']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Menangani error koneksi atau lainnya
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "We're glad to see you again!",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xFF1877F2),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Let's get you logged in quickly!",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 40),

              // TextField untuk Email
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle:
                      TextStyle(color: Colors.grey), // Warna default label
                  focusColor: Color(0xFF1877F2), // Warna saat fokus
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(
                          0xFF1877F2), // Ganti dengan warna biru saat fokus
                      width: 2.0, // Ketebalan border saat fokus
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey, // Warna border default
                      width: 1.0, // Ketebalan border default
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              // TextField untuk Password
              TextField(
                controller: passwordController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: "Password",
                  labelStyle:
                      TextStyle(color: Colors.grey), // Warna default label
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Color(
                          0xFF1877F2), // Ganti dengan warna biru saat fokus
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey, // Warna border default
                      width: 1.0,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText; // Toggle obsecureText
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1877F2),
                    padding:
                        EdgeInsets.symmetric(horizontal: 140, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (usernameController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      // Tampilkan snackbar atau dialog jika salah satu kosong
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            backgroundColor: Colors.redAccent,
                            content: Text(
                                'Username dan Password tidak boleh kosong')),
                      );
                    } else {
                      login(
                          context); // Panggil fungsi login saat tombol ditekan
                    }
                  },
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Anda bisa menambahkan baris untuk signup di sini jika perlu
            ],
          ),
        ),
      ),
    );
  }
}
