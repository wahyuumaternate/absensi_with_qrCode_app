import 'package:HMTI_ABSEN/screen/leaderbort_item.dart';
import 'package:HMTI_ABSEN/screen/login.dart';
import 'package:HMTI_ABSEN/screen/qr_code_scanner.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import paket intl
import 'package:http/http.dart' as http; // Import paket http
import 'dart:convert'; // Untuk menggunakan json.decode

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color primaryColor = Color(0xFF0A3981);

  String username = "";
  String email = "";
  String jabatan = "";
  String foto = "";
  int userId = 0;
  List<dynamic> attendanceData = [];

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Muat data pengguna saat widget dimulai
    _checkLoginStatus(); // Periksa status login saat pertama kali
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn =
        prefs.getBool('isLoggedIn') ?? false; // Ambil status login

    if (!isLoggedIn) {
      // Jika tidak login, arahkan ke halaman login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } else {
      // Jika sudah login, muat data pengguna dan data absensi
      await _loadUserData();
      await _fetchAttendanceData(userId);
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('userName') ?? "Username tidak tersedia";
      email = prefs.getString('userEmail') ?? "Email tidak tersedia";
      jabatan = prefs.getString('jabatan') ?? "Jabatan tidak tersedia";
      foto = prefs.getString('foto') ?? "foto tidak tersedia";
      userId = prefs.getInt('userId') ?? 0;
    });
  }

  String get formattedDate =>
      DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

  Future<void> _fetchAttendanceData(int id) async {
    if (id == 0) return; // Menghindari permintaan jika userId tidak valid

    String url = 'https://absen-web.wahyuumaternate.my.id/api/data-absen/$id';
    print('Menggunakan URL: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          attendanceData =
              json.decode(response.body); // Decode JSON dan simpan dalam list
        });
      } else {
        // Jika status kode bukan 200, lemparkan exception
        throw Exception('Gagal memuat data absensi: ${response.statusCode}');
      }
    } catch (e) {
      print("Kesalahan saat memuat data: $e");
      // Anda bisa menavigasi ke halaman error atau menampilkan snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "HMTI UNKHAIR",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: Colors.white, size: 25),
          ),
          SizedBox(width: 20),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildUserHeader(),
          _buildShiftInformation(),
          _buildAttendanceList(),
          _buildQRCodeButton()
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Container(
      padding: EdgeInsets.all(25.0),
      color: primaryColor,
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(foto),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(jabatan,
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftInformation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5)),
          ],
        ),
        child: Column(
          children: [
            Text(formattedDate,
                style: TextStyle(color: Colors.black, fontSize: 14)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttendanceContainer("Absen Masuk", "08:00 AM"),
                _buildAttendanceContainer("Absen Keluar", "17:00 PM"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceContainer(String title, String time) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 15, offset: Offset(6, 12)),
        ],
      ),
      child: Column(
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(time,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: attendanceData.isEmpty
            ? Center(child: Text('Tidak Ada Data Absen'))
            : ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final item = attendanceData[index];
                  Color statusColor =
                      _getStatusColor(item['status'].toString().toLowerCase());

                  return AttendanceItem(
                    date: item['tanggal'].toString(),
                    masuk: item['jam_masuk'].toString(),
                    keluar: item['jam_keluar'].toString(),
                    status: item['status'].toString(),
                    statusColor: statusColor,
                  );
                },
              ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'hadir':
        return Colors.green;
      case 'tidak masuk':
      case 'terlambat':
        return Colors.red;
      case 'lembur':
        return Colors.blue;
      default:
        return Colors.grey; // Warna default untuk status tidak dikenali
    }
  }

  Widget _buildQRCodeButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ScanPage()));
        },
        icon: Icon(Icons.qr_code_scanner, color: Colors.white),
        label: Text("Scan QR Code", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs
        .clear(); // Menghapus semua data dari SharedPreferences untuk logout

    // Navigasi kembali ke halaman login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
