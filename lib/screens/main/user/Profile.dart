import 'package:flutter/material.dart';
import '../../custom/showdialog_eror.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<AuthProvider>(context);
    final TextEditingController namaController = TextEditingController();
    final TextEditingController tglLahirController = TextEditingController();
    final TextEditingController jenisKelaminController =
        TextEditingController();
    final TextEditingController noHpController = TextEditingController();
    final TextEditingController emailController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () => Navigator.pop(context),
        // ),
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Detail",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField("Nama", namaController),
            _buildTextField("Tanggal Lahir", tglLahirController),
            _buildTextField("Jenis Kelamin", jenisKelaminController),
            _buildTextField("No. Hp", noHpController),
            _buildTextField("Email", emailController),
            // const SizedBox(height: 50),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await penghubung.logout();
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ShowdialogEror(label: "${e.toString()}");
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: const Text(
                  "Keluar",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: const Color(0xFFF7F9FC),
        child: ElevatedButton(
          onPressed: () {
            // aksi simpan di sini
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            "Simpan",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
