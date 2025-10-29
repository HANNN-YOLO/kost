import 'package:flutter/material.dart';
import 'package:kost_saw/screens/main/admin/detail_user.dart';

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    const warnaLatar = Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: warnaLatar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: lebarLayar * 0.05,
            vertical: tinggiLayar * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header (judul atau search bar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_isSearching)
                    const Text(
                      "Daftar Pengguna",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    // 🔸 TextField Search
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        autofocus: true, // langsung munculkan keyboard
                        decoration: InputDecoration(
                          hintText: "Cari pengguna...",
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Colors.grey, width: 0.3),
                          ),
                        ),
                        onChanged: (value) {
                          // TODO: logika filter daftar pengguna nanti
                        },
                      ),
                    ),

                  // 🔸 Tombol kanan
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });

                      if (_isSearching) {
                        // Saat tombol search ditekan, langsung fokus & munculkan keyboard
                        Future.delayed(const Duration(milliseconds: 100), () {
                          FocusScope.of(context).requestFocus(_focusNode);
                        });
                      } else {
                        // Tutup search
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      size: 22,
                    ),
                  ),
                ],
              ),

              SizedBox(height: tinggiLayar * 0.02),

              // 🔹 Kartu Total Pengguna
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: lebarLayar * 0.04,
                  vertical: tinggiLayar * 0.018,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: lebarLayar * 0.12,
                      height: lebarLayar * 0.12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Icon(Icons.group_outlined,
                          color: Colors.black54),
                    ),
                    SizedBox(width: lebarLayar * 0.04),
                    const Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Pengguna",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "30",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tinggiLayar * 0.03),

              // 🔹 Daftar Pengguna
              Expanded(
                child: ListView(
                  children: const [
                    UserCard(
                      nama: "Irwan Syahrir",
                      email: "irwansyahrir@gmail.com",
                      alamat: "Kelurahan Tamalanrea Indah",
                      telepon: "08123456789",
                      tanggalBergabung: "2025-06-22",
                    ),
                    SizedBox(height: 16),
                    UserCard(
                      nama: "Aisyah Putri",
                      email: "aisyahputri@gmail.com",
                      alamat: "Jl. Perintis Kemerdekaan",
                      telepon: "085212345678",
                      tanggalBergabung: "2025-03-18",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Widget Kartu Pengguna
class UserCard extends StatelessWidget {
  final String nama;
  final String email;
  final String alamat;
  final String telepon;
  final String tanggalBergabung;

  const UserCard({
    super.key,
    required this.nama,
    required this.email,
    required this.alamat,
    required this.telepon,
    required this.tanggalBergabung,
  });

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    const warnaUtama = Color(0xFF1E3A8A);

    return Container(
      padding: EdgeInsets.all(lebarLayar * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Baris atas
          Row(
            children: [
              Container(
                width: lebarLayar * 0.12,
                height: lebarLayar * 0.12,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  size: 30,
                  color: warnaUtama,
                ),
              ),
              SizedBox(width: lebarLayar * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    email,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: tinggiLayar * 0.015),

          // 🔹 Info pengguna
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  alamat,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(telepon, style: const TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "Bergabung: $tanggalBergabung",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),

          SizedBox(height: tinggiLayar * 0.02),

          // 🔹 Tombol Detail
          SizedBox(
            width: double.infinity,
            height: tinggiLayar * 0.055,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 300),
                    pageBuilder: (_, __, ___) => const DetailUser(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                        child: child,
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: warnaUtama,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "Detail Pengguna",
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
