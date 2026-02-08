import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../custom/custom_uploadFoto_stack.dart';
import '../../custom/custom_editfoto_stack.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profil_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _tgllahir = TextEditingController();
  final TextEditingController _jenisKelamin = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();

  bool _editgllahir = false;
  bool _editTelepon = false;
  bool _editJenisKelamin = false;

  bool _isSaving = false;

  String? _backuptgllahir;
  String? _backupTelepon;
  String? _backupJenisKelamin;

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
        _backuptgllahir = null;
        _backupJenisKelamin = null;
        _backupTelepon = null;
        LoadinScreen();
      } else {
        _tgllahir.text = DateFormat('dd-MM-yyyy')
            .format(penghubung2.mydata.first.tgllahir!)
            .toString();
        _jenisKelamin.text = penghubung2.mydata.first.jkl.toString();
        _teleponController.text = penghubung2.mydata.first.kontak.toString();
        penghubung2.mydata.first.foto;

        // penghubung2.isinya.name =
        // = penghubung2.mydata.first.foto.toString();

        keadaan = false;
      }
    }
  }

  // tidak terpakai part 1
  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan UI & fungsi yang sama seperti profil penyewa,
    // tetapi tanpa menampilkan tombol "Keluar Akun".
    return UserProfilePage(
      showLogoutButton: false,
      showTanggalLahir: false,
      showJenisKelamin: false,
    );
  }
}

class _HeaderProfile extends StatelessWidget {
  static Color warnaUtama = Color(0xFF1E3A8A);

  _HeaderProfile();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final penghubung = Provider.of<AuthProvider>(context, listen: false);
    int index = 0;

    // return Text("halo");

    return Stack(
      children: [
        // Cover gradient
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [warnaUtama, Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Wave shape (simple decor)
        Positioned(
          right: -60,
          top: -40,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -40,
          bottom: -50,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),

        // Content
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
          child: Column(
            children: [
              SizedBox(height: 16),
              // Title only (back icon removed)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Profil Pemilik',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 14),

              // Avatar + tombol ubah foto
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Color(0xFFDDE6FF),
                          child:
                              Icon(Icons.person, color: warnaUtama, size: 36),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child:
                                  Icon(Icons.edit, size: 16, color: warnaUtama),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${penghubung.mydata[index].username}',
                            style: TextStyle(
                              color: warnaUtama,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '${penghubung.mydata[index].Email}',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('UI-only: Ubah Foto Profil')),
                        );
                      },
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.white),
                      icon: Icon(Icons.camera_alt_outlined),
                      label: Text('Ubah Foto'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        )
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _InfoFieldCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  _InfoFieldCard({
    required this.icon,
    required this.label,
    required this.controller,
    required this.isEditing,
    required this.onEdit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF1E3A8A)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.black54),
                ),
                SizedBox(height: 4),
                if (isEditing)
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFFF5F7FB),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  )
                else
                  Text(
                    controller.text,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          InkWell(
            onTap: isEditing ? onCancel : onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF1E3A8A).withOpacity(0.25)),
              ),
              child: Text(
                isEditing ? 'Batal' : 'Ubah',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final void Function(bool, BuildContext) onChanged;

  _SwitchCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF1E3A8A)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Switch(
            value: value,
            activeColor: Color(0xFF1E3A8A),
            onChanged: (v) => onChanged(v, context),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final void Function(BuildContext) onTap;

  _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Color(0xFFDDE6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF1E3A8A)),
        ),
        title: Text(label, style: TextStyle(fontWeight: FontWeight.w700)),
        trailing: Icon(Icons.chevron_right),
        onTap: () => onTap(context),
      ),
    );
  }
}

class _GenderFieldCard extends StatelessWidget {
  final String value;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final ValueChanged<String> onChanged;

  _GenderFieldCard({
    required this.value,
    required this.isEditing,
    required this.onEdit,
    required this.onCancel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              FontAwesomeIcons.venusMars,
              color: Color(0xFF1E3A8A),
              size: 18,
            ),
          ),
          SizedBox(width: 12),

          /// CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jenis Kelamin', style: TextStyle(color: Colors.black54)),
                SizedBox(height: 6),

                /// VIEW MODE
                if (!isEditing)
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  )

                /// EDIT MODE
                else
                  Wrap(
                    spacing: 8,
                    children: [
                      _genderChip(
                        icon: Icons.male,
                        label: 'Laki-Laki',
                        selected: value == 'Laki-Laki',
                        onTap: () => onChanged('Laki-Laki'),
                      ),
                      _genderChip(
                        icon: Icons.female,
                        label: 'Perempuan',
                        selected: value == 'Perempuan',
                        onTap: () => onChanged('Perempuan'),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          /// BUTTON
          InkWell(
            onTap: isEditing ? onCancel : onEdit,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFF1E3A8A).withOpacity(0.25),
                ),
              ),
              child: Text(
                isEditing ? 'Batal' : 'Ubah',
                style: TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderChip({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          SizedBox(width: 4),
          Text(label),
        ],
      ),
      selectedColor: Color(0xFF1E3A8A).withOpacity(0.15),
    );
  }
}
