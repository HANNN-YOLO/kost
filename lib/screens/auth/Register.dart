import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  static const routeName = "/register";

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    // Tentukan breakpoint
    String kategori;
    if (lebarLayar < 600) {
      kategori = "mobile";
    } else if (lebarLayar < 1200) {
      kategori = "tablet";
    } else {
      kategori = "desktop";
    }

    // Proporsi elemen tergantung ukuran layar
    double paddingHorizontal;
    double fontUkuranJudul;
    switch (kategori) {
      case "mobile":
        paddingHorizontal = 32;
        fontUkuranJudul = 32;
        break;
      case "tablet":
        paddingHorizontal = 80;
        fontUkuranJudul = 40;
        break;
      case "desktop":
        paddingHorizontal = 200;
        fontUkuranJudul = 48;
        break;
      default:
        paddingHorizontal = 32;
        fontUkuranJudul = 32;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFEFF0F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: tinggiLayar,
            width: lebarLayar,
            padding: const EdgeInsets.only(
                top: 200, left: 30, right: 30, bottom: 60),
            child: Container(
              // color: Colors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    "Daftar",
                    style: TextStyle(
                      fontSize: fontUkuranJudul,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      // fontStyle: f
                    ),
                  ),
                  // const SizedBox(height: 4),
                  const Text(
                    "Tolong masukkan akun anda",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  TextInput(hintText: "Nama", prefixIcon: Icons.person_outline),
                  const SizedBox(height: 20),
                  // TextField Email
                  TextInput(
                      hintText: "Email", prefixIcon: Icons.email_outlined),
                  const SizedBox(height: 20),
                  // TextField Sandi
                  TextInput(
                      hintText: "Sandi", prefixIcon: Icons.email_outlined),
                  const SizedBox(height: 20),
                  // TextField Konfirmasi Sandi
                  TextInput(
                      hintText: "Konfirmasi Sandi",
                      prefixIcon: Icons.lock_outline),
                  const SizedBox(height: 30),

                  // Tombol Masuk
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Teks daftar
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        text: "Sudah Punya Akun? ",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Daftar",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TextInput extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;

  const TextInput({
    super.key,
    required this.hintText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        obscureText: true,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        ),
      ),
    );
  }
}
