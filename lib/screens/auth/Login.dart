import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  static const routeName = "/login";

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();

  String? mesaage;
  bool _isLoading = false;

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<AuthProvider>(context, listen: false);

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
      backgroundColor: Color(0xFFEFF0F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: tinggiLayar,
            width: lebarLayar,
            padding: EdgeInsets.only(
              top: 250,
              left: paddingHorizontal,
              right: paddingHorizontal,
              bottom: 60,
            ),
            child: Container(
              // color: Colors.red,
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
                      // fontStyle: f
                    ),
                  ),
                  //  SizedBox(height: 4),
                  Text(
                    "Tolong masukkan akun anda",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  SizedBox(height: 20),

                  // TextField Email
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // TextField Sandi
                  Consumer<AuthProvider>(
                    builder: (context, value, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          keyboardType: TextInputType.visiblePassword,
                          textCapitalization: TextCapitalization.none,
                          controller: pass,
                          obscureText: value.kelihatan,
                          onTap: () {
                            value.keadaan();
                          },
                          decoration: InputDecoration(
                            hintText: "Sandi",
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: value.kelihatan
                                ? Icon(Icons.visibility_off)
                                : Icon(Icons.visibility),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 18, horizontal: 10),
                          ),
                        ),
                      );
                    },
                  ),

                  if (mesaage != null) ...[
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        mesaage!,
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  ],
                  SizedBox(height: 30),

                  // Tombol Masuk
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              // Validasi client-side
                              if (email.text.trim().isEmpty ||
                                  pass.text.isEmpty) {
                                setState(() {
                                  mesaage =
                                      "Email dan password tidak boleh kosong.";
                                });
                                return;
                              }

                              // Validasi format email
                              if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$')
                                  .hasMatch(email.text.trim())) {
                                setState(() {
                                  mesaage = "Format email tidak valid.";
                                });
                                return;
                              }

                              setState(() {
                                mesaage = null;
                                _isLoading = true;
                              });

                              try {
                                await penghubung.login(
                                  email.text.trim(),
                                  pass.text,
                                );
                              } catch (e) {
                                if (!mounted) return;
                                setState(() {
                                  mesaage = e.toString();
                                });
                              } finally {
                                if (!mounted) return;
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Masuk...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              "Masuk",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  Spacer(),

                  // Teks daftar
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed("/register");
                      },
                      child: RichText(
                        text: TextSpan(
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
