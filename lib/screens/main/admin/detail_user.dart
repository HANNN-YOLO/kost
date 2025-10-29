import 'package:flutter/material.dart';

class DetailUser extends StatelessWidget {
  const DetailUser({super.key});

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    // 🎨 Warna dan gaya umum
    const warnaUtama = Color(0xFF1C3B98);
    const warnaLatar = Color(0xFFF5F7FB);
    const warnaTeksHitam = Colors.black87;
    const warnaAbu = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: warnaLatar,

      // 🔹 HEADER seperti halaman Daftar Kost / Daftar Pengguna
      appBar: AppBar(
        elevation: 0,
        backgroundColor: warnaUtama,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Detail Pengguna',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: lebarLayar * 0.05),
        child: Column(
          children: [
            SizedBox(height: tinggiLayar * 0.04),

            // 🔹 Bagian Profil
            Column(
              children: [
                Container(
                  width: lebarLayar * 0.22,
                  height: lebarLayar * 0.22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: const Icon(Icons.person, size: 50, color: Colors.grey),
                ),
                SizedBox(height: tinggiLayar * 0.015),
                const Text(
                  "Username",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: warnaTeksHitam,
                  ),
                ),
                const Text(
                  "username@gmail.com",
                  style: TextStyle(
                    fontSize: 14,
                    color: warnaAbu,
                  ),
                ),
              ],
            ),

            SizedBox(height: tinggiLayar * 0.04),

            // 🔹 Bagian Informasi Pengguna
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informasi pengguna",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: warnaTeksHitam,
                      ),
                    ),
                    SizedBox(height: tinggiLayar * 0.015),

                    // 🔹 Kartu Informasi
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: tinggiLayar * 0.02,
                        horizontal: lebarLayar * 0.04,
                      ),
                      child: Column(
                        children: [
                          infoBar("Nama", "Username"),
                          infoBar("Email", "Username@gmail.com"),
                          infoBar("Jenis Kelamin", "Laki-Laki"),
                          infoBar("No. handphone", "08123456789"),
                          infoBar("Tanggal Lahir", "18 April 2001"),
                          infoBar("Tanggal Bergabung", "18 April 2025"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Widget baris info (label & nilai)
  Widget infoBar(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14.5,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
