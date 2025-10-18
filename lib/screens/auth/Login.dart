import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  static const routeName = "/login";

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
      body: SingleChildScrollView(
        child: Container(
          height: tinggiLayar,
          width: lebarLayar,
          padding:
              EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul
              Text(
                "Masuk",
                style: TextStyle(
                  fontSize: fontUkuranJudul,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Tolong masukkan akun anda",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // TextField Email
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Email",
                    prefixIcon: Icon(Icons.email_outlined),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // TextField Sandi
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Sandi",
                    prefixIcon: Icon(Icons.lock_outline),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                  ),
                ),
              ),
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
                    text: "Belum Punya akun? ",
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
    );
  }
}
