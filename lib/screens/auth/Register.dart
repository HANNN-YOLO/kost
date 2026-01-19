import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../custom/custom_dropdown_search.dart';
import '../../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = "/register";

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController user = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController pas1 = TextEditingController();
  final TextEditingController pas2 = TextEditingController();

  String? message;
  bool _isLoading = false;

  @override
  void dispose() {
    user.dispose();
    email.dispose();
    pas1.dispose();
    pas2.dispose();
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
            width: lebarLayar,
            padding: EdgeInsets.only(top: 200, left: 30, right: 30, bottom: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                //  SizedBox(height: 4),
                Text(
                  "Tolong Isikan data anda",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),

                SizedBox(
                  height: 20,
                ),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomDropdownSearch(
                    manalistnya: penghubung.roles,
                    label: penghubung.role,
                    pilihan: penghubung.role,
                    fungsi: (value) {
                      penghubung.pilihrole(value);
                    },
                  ),
                ),

                SizedBox(height: 20),
                TextInput(
                  hintText: "Nama",
                  prefixIcon: Icons.person_outline,
                  isinya: user,
                  kelihatan: false,
                ),
                SizedBox(height: 20),
                // TextField Email
                TextInput(
                  hintText: "Email",
                  prefixIcon: Icons.email_outlined,
                  isinya: email,
                  kelihatan: false,
                ),
                SizedBox(height: 20),
                // TextField Sandi
                Consumer<AuthProvider>(
                  builder: (context, value, child) {
                    return TextInput(
                      hintText: "Sandi",
                      prefixIcon: Icons.lock_outline,
                      isinya: pas1,
                      kelihatan: value.kelihatan,
                      custom: value.kelihatan
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                      fungsi: () {
                        value.keadaan();
                      },
                    );
                  },
                ),
                SizedBox(height: 20),
                // TextField Konfirmasi Sandi
                Consumer<AuthProvider>(
                  builder: (context, value, child) {
                    return TextInput(
                      hintText: "Konfirmasi Sandi",
                      prefixIcon: Icons.lock_outline,
                      isinya: pas2,
                      kelihatan: value.lihat,
                      custom: value.lihat
                          ? Icon(Icons.visibility_off)
                          : Icon(Icons.visibility),
                      fungsi: () {
                        value.konfirmasi();
                      },
                    );
                  },
                ),

                if (message != null) ...[
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      message!,
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
                            // validasi dasar di sisi UI agar tidak memanggil server jika ada field kosong
                            if (penghubung.role == "Pilih" ||
                                user.text.trim().isEmpty ||
                                email.text.trim().isEmpty ||
                                pas1.text.isEmpty ||
                                pas2.text.isEmpty) {
                              setState(() {
                                message =
                                    "Harap isi semua field dan pilih role terlebih dahulu.";
                              });
                              return;
                            }

                            setState(() {
                              message = null;
                              _isLoading = true;
                            });

                            try {
                              await penghubung.register(
                                user.text.trim(),
                                email.text.trim(),
                                pas1.text,
                                pas2.text,
                                penghubung.role,
                                context,
                              );
                            } catch (e) {
                              if (!mounted) return;
                              setState(() {
                                message = e.toString();
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
                                "Mendaftar...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            "Daftar",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Teks daftar
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed("/login");
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Sudah Punya Akun? ",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: "Login",
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
    );
  }
}

class TextInput extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final bool? kelihatan;
  final TextEditingController isinya;
  final Icon? custom;
  final VoidCallback? fungsi;

  const TextInput({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.kelihatan,
    required this.isinya,
    this.custom,
    this.fungsi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: isinya,
        obscureText: kelihatan!,
        onTap: fungsi,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(prefixIcon),
          suffixIcon: custom,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        ),
      ),
    );
  }
}
