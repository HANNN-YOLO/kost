import 'package:flutter/material.dart';
import '../custom/showdialog_eror.dart';
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
            padding: EdgeInsets.only(top: 250, left: 30, right: 30, bottom: 60),
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
                      onPressed: () async {
                        try {
                          await penghubung.login(email.text, pass.text);
                          setState(() {
                            mesaage = null;
                          });
                        } catch (e) {
                          // showDialog(
                          //   context: context,
                          //   builder: (context) {
                          //     return ShowdialogEror(label: "${e.toString()}");
                          //   },
                          // );
                          setState(() {
                            mesaage = e.toString();
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
                      child: Text(
                        "Masuk",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
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
