import 'package:flutter/material.dart';

class AttendanceItem extends StatelessWidget {
  final String date; // Tanggal absensi
  final String masuk; // Shift kerja
  final String keluar; // Shift kerja
  final String status; // Status kehadiran (Hadir, Tidak Hadir, dsb.)
  final Color statusColor; // Warna berdasarkan status

  const AttendanceItem({
    required this.date,
    required this.masuk,
    required this.keluar,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Ikon untuk aktivitas
          CircleAvatar(
            radius: 20,
            backgroundColor: statusColor,
            child: Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 16),

          // Informasi aktivitas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Masuk: $masuk",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "Keluar: $keluar",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Status Kehadiran
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
