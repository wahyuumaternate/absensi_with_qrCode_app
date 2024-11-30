import 'package:HMTI_ABSEN/screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // Import Timer
import 'package:shared_preferences/shared_preferences.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false; // Untuk mendeteksi proses validasi
  String? lastDetectedQrCode; // Menyimpan QR Code terakhir yang terdeteksi
  Timer? _requestTimer; // Timer untuk mencegah request berulang

  // Fungsi untuk mengirim data QR Code ke server
  Future<void> sendData(String qrCode) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      // Handle case where userId is missing (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User ID tidak ditemukan'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // Membuat objek Map
    Map<String, dynamic> data = {
      'qr_code': qrCode,
      'user_id': userId,
    };

    await _validateQrCode(data); // Nebak fungsi validasi
  }

  // Fungsi untuk memvalidasi QR Code dengan API
  Future<void> _validateQrCode(Map<String, dynamic> data) async {
    const String apiUrl =
        "https://absen-web.wahyuumaternate.my.id/api/validate-qr-code"; // Ganti sesuai kebutuhan

    if (isProcessing) return; // Jangan lakukan lagi jika sedang memproses
    isProcessing = true; // Set bahwa kita sedang memproses

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('berhasil validasi');
        // Jika valid, arahkan ke HomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil Absen'),
            backgroundColor: Colors.greenAccent,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false, // Menghapus semua rute sebelumnya
        );
      } else {
        print('gagal validasi');
        // Menampilkan pesan kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseData['message'] ?? 'Gagal validasi'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (route) => false, // Menghapus semua rute sebelumnya
        );
      }
    } catch (e) {
      print('error validasi: $e');
      // Menampilkan kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat validasi QR Code'),
          backgroundColor: Colors.redAccent,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
        (route) => false, // Menghapus semua rute sebelumnya
      );
    } finally {
      isProcessing = false; // Reset flag memproses
      // Reset dan set timer untuk request selanjutnya
      _requestTimer?.cancel(); // Pastikan timer sebelumnya dibatalkan
      _requestTimer = Timer(Duration(seconds: 2), () {
        setState(() {
          isProcessing = false; // Mengizinkan request baru setelah 2 detik
        });
      });
    }
  }

  // Fungsi untuk menampilkan hasil scan QR dan memvalidasinya
  void _onQrCodeDetected(Barcode barcode) {
    final qrCode = barcode.rawValue;

    if (qrCode != null && qrCode != lastDetectedQrCode && !isProcessing) {
      lastDetectedQrCode = qrCode; // Simpan QR code terakhir yang terdeteksi
      sendData(qrCode); // Mengirim data QR Code untuk validasi
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0A3981),
        foregroundColor: Colors.white,
        title: Text('Scan QR Code'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Tampilan Scanner
          MobileScanner(
            controller: cameraController,
            onDetect: (BarcodeCapture barcodeCapture) {
              final barcode = barcodeCapture.barcodes.first;
              _onQrCodeDetected(barcode);
            },
          ),

          // Overlay dengan kotak tengah transparan
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Stack(
              children: [
                // Area kotak transparan
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                  ),
                ),

                // Teks "Scan QR Code for attendance"
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 280),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Scan QR Code Untuk Absen',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tombol Cancel di bawah
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0A3981), // Warna biru gelap
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose(); // Properly dispose the scanner controller
    _requestTimer?.cancel(); // Pastikan timer dibatalkan saat dispose
    super.dispose();
  }
}
