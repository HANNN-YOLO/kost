import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../providers/profil_provider.dart';
import '../../../loadin_screen.dart';
import '../penyewa/Profile.dart';

class ProfilePemilikPage extends StatefulWidget {
  ProfilePemilikPage({super.key});

  static Color warnaLatar = Color(0xFFF5F7FB);
  static Color warnaKartu = Colors.white;
  static Color warnaUtama = Color(0xFF1E3A8A);
  int index = 0;
  bool keadaan = true;

  @override
  State<ProfilePemilikPage> createState() => _ProfilePemilikPageState();
}

class _ProfilePemilikPageState extends State<ProfilePemilikPage> {
  final TextEditingController _teleponController = TextEditingController();

  String? _backupTelepon;

  bool keadaan = true;

  // button done
  Future<void> _showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Success',
      barrierColor: Colors.black.withOpacity(0.25),
      transitionDuration: Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.78,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            ProfilePemilikPage.warnaUtama,
                            Color(0xFF3B82F6)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        borderRadius: BorderRadius.circular(14),
                        color: ProfilePemilikPage.warnaUtama,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Oke',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
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
      },
    );
  }

  // set up fungsi read
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (keadaan) {
      final penghubung2 = Provider.of<ProfilProvider>(context);

      if (penghubung2.mydata.isEmpty) {
        _backupTelepon = null;
        LoadinScreen();
      } else {
        _teleponController.text = penghubung2.mydata.first.kontak.toString();
        penghubung2.mydata.first.foto;

        // penghubung2.isinya.name =
        // = penghubung2.mydata.first.foto.toString();

        keadaan = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan UI & fungsi yang sama seperti profil penyewa,
    // tetapi tanpa menampilkan tombol "Keluar Akun".
    return UserProfilePage(
      showLogoutButton: false,
    );
  }
}
