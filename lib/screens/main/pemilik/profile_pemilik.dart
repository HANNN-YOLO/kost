import 'package:flutter/material.dart';
import '../../custom/custom_uploadFoto_stack.dart';
import '../../custom/custom_editfoto_stack.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profil_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../../loadin_screen.dart';

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
    final size = MediaQuery.of(context).size;
    final penghubung = Provider.of<AuthProvider>(context, listen: false);
    final penghubung2 = Provider.of<ProfilProvider>(context, listen: false);

    int index = 0;
    Color warnaUtama = Color(0xFF1E3A8A);
    DateTime? waktu;

    return Scaffold(
      backgroundColor: ProfilePemilikPage.warnaLatar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: size.height * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header dengan cover gradient + avatar
              // _HeaderProfile(),
              Stack(
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
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
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
                                  // CustomUploadfotoStack(
                                  //   panjang: 50,
                                  //   tinggi: 50,
                                  //   fungsi: () {
                                  //     penghubung2.uploadfoto();
                                  //   },
                                  //   path: penghubung2.isinya?.path,
                                  //   warnautama: warnaUtama,
                                  // ),

                                  Consumer<ProfilProvider>(
                                    builder: (context, value, child) {
                                      return penghubung2.mydata.isNotEmpty
                                          ? custom_editfotostack(
                                              fungsi: () {
                                                penghubung2.uploadfoto();
                                              },
                                              path: penghubung2.isinya?.path,
                                              pathlama:
                                                  penghubung2.mydata.first.foto,
                                              tinggi: 72,
                                              panjang: 72,
                                              warnautama: warnaUtama,
                                            )
                                          : CustomUploadfotoStack(
                                              panjang: 72,
                                              tinggi: 72,
                                              fungsi: () {
                                                penghubung2.uploadfoto();
                                              },
                                              path: penghubung2.isinya?.path,
                                              warnautama: warnaUtama,
                                            );
                                      // :
                                    },
                                  ),
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
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        final konfirmasi =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title:
                                                const Text('Hapus Foto Profil'),
                                            content: const Text(
                                                'Foto profil akan dikembalikan ke default. Lanjutkan?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(true),
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (konfirmasi != true) return;

                                        setState(() {
                                          _isSaving = true;
                                        });

                                        try {
                                          await penghubung2.hapusFotoProfil();

                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Foto profil berhasil dihapus.'),
                                            ),
                                          );
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Gagal menghapus foto profil. Silakan coba lagi.'),
                                            ),
                                          );
                                        } finally {
                                          if (!mounted) return;
                                          setState(() {
                                            _isSaving = false;
                                          });
                                        }
                                      },
                                style: TextButton.styleFrom(
                                  foregroundColor: warnaUtama,
                                ),
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Hapus Foto'),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),
                      ],
                    ),
                  )
                ],
              ),

              Consumer<ProfilProvider>(
                builder: (context, value, child) {
                  return penghubung2.mydata.isNotEmpty
                      ?
                      // kondisi 1 data ada sebagai update
                      Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.015,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle('Informasi Akun'),
                              SizedBox(height: 10),
                              _InfoFieldCard(
                                icon: Icons.date_range_outlined,
                                label: 'tgl lahir',
                                controller: _tgllahir,
                                isEditing: _editgllahir,
                                onEdit: () async {
                                  // setState(() {

                                  // });
                                  final waktunya = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1000),
                                    lastDate: DateTime(9000),
                                    initialDate: DateTime.now(),
                                  );
                                  // final waktu = waktunya;
                                  _tgllahir.text =
                                      "${waktunya!.day.toString().padLeft(2, '0')}-"
                                      "${waktunya.month.toString().padLeft(2, '0')}-"
                                      "${waktunya.year.toString()}";

                                  // waktu = DateTime.parse(_tgllahir.text);
                                  waktu = DateFormat('dd-MM-yyyy')
                                      .parse(_tgllahir.text);
                                  _backuptgllahir = _tgllahir.text;

                                  _editgllahir = true;
                                },
                                onCancel: () => setState(() {
                                  _tgllahir.text = _backuptgllahir!;
                                  _editgllahir = false;
                                }),
                              ),

                              // SizedBox(height: 10),
                              _GenderFieldCard(
                                value: _jenisKelamin.text,
                                isEditing: _editJenisKelamin,
                                onEdit: () {
                                  setState(() {
                                    _backupJenisKelamin = _jenisKelamin.text;
                                    _editJenisKelamin = true;
                                  });
                                },
                                onCancel: () {
                                  setState(() {
                                    _jenisKelamin.text = _backupJenisKelamin!;
                                    _editJenisKelamin = false;
                                  });
                                },
                                onChanged: (val) {
                                  setState(() {
                                    _jenisKelamin.text = val;
                                  });
                                },
                              ),
                              SizedBox(height: 10),
                              _InfoFieldCard(
                                icon: Icons.phone_outlined,
                                label: 'Telepon',
                                controller: _teleponController,
                                isEditing: _editTelepon,
                                onEdit: () => setState(() {
                                  _backupTelepon = _teleponController.text;
                                  _editTelepon = true;
                                }),
                                onCancel: () => setState(() {
                                  _teleponController.text =
                                      _backupTelepon ?? _teleponController.text;
                                  _editTelepon = false;
                                }),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        )
                      :
                      // kondisi 2 data kosong sebagai inputan
                      Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.05,
                            vertical: size.height * 0.015,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionTitle('Informasi Akun'),
                              SizedBox(height: 10),
                              _InfoFieldCard(
                                icon: Icons.date_range_outlined,
                                label: 'tgl lahir',
                                controller: _tgllahir,
                                isEditing: _editgllahir,
                                onEdit: () async {
                                  // setState(() {

                                  // });
                                  final waktunya = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1000),
                                    lastDate: DateTime(9000),
                                    initialDate: DateTime.now(),
                                  );
                                  // final waktu = waktunya;
                                  _tgllahir.text =
                                      "${waktunya!.day.toString().padLeft(2, '0')}-"
                                      "${waktunya.month.toString().padLeft(2, '0')}-"
                                      "${waktunya.year.toString()}";

                                  // waktu = DateTime.parse(_tgllahir.text);
                                  waktu = DateFormat('dd-MM-yyyy')
                                      .parse(_tgllahir.text);
                                  _backuptgllahir = _tgllahir.text;
                                  _editgllahir = true;
                                },
                                onCancel: () => setState(() {
                                  _tgllahir.text = _backuptgllahir ?? '';
                                  _editgllahir = false;
                                }),
                              ),

                              // SizedBox(height: 10),
                              _GenderFieldCard(
                                value: _jenisKelamin.text,
                                isEditing: _editJenisKelamin,
                                onEdit: () {
                                  setState(() {
                                    _backupJenisKelamin = _jenisKelamin.text;
                                    _editJenisKelamin = true;
                                  });
                                },
                                onCancel: () {
                                  setState(() {
                                    _jenisKelamin.text = _backupJenisKelamin!;
                                    _editJenisKelamin = false;
                                  });
                                },
                                onChanged: (val) {
                                  setState(() {
                                    _jenisKelamin.text = val;
                                  });
                                },
                              ),
                              SizedBox(height: 10),
                              _InfoFieldCard(
                                icon: Icons.phone_outlined,
                                label: 'Telepon',
                                controller: _teleponController,
                                isEditing: _editTelepon,
                                onEdit: () => setState(() {
                                  _backupTelepon = _teleponController.text;
                                  _editTelepon = true;
                                }),
                                onCancel: () => setState(() {
                                  _teleponController.text =
                                      _backupTelepon ?? _teleponController.text;
                                  _editTelepon = false;
                                }),
                              ),
                              SizedBox(height: 10),
                            ],
                          ),
                        );
                },
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.015,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Preferensi'),
                    SizedBox(height: 10),
                    _SwitchCard(
                      icon: Icons.notifications_none,
                      label: 'Notifikasi',
                      value: true,
                      onChanged: (v, ctx) => _toast(
                          ctx, 'UI-only: Notifikasi ${v ? 'ON' : 'OFF'}'),
                    ),
                    SizedBox(height: 10),
                    _SwitchCard(
                      icon: Icons.dark_mode_outlined,
                      label: 'Mode Gelap',
                      value: false,
                      onChanged: (v, ctx) => _toast(
                          ctx, 'UI-only: Mode Gelap ${v ? 'ON' : 'OFF'}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.015,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: Consumer<ProfilProvider>(
              builder: (context, value, child) {
                return penghubung2.mydata.isNotEmpty
                    ? ElevatedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (_tgllahir.text.isEmpty ||
                                    _jenisKelamin.text.isEmpty ||
                                    _teleponController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Lengkapi tanggal lahir, jenis kelamin, dan telepon.'),
                                    ),
                                  );
                                  return;
                                }

                                final int? hp = int.tryParse(
                                    _teleponController.text.trim());
                                if (hp == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Nomor telepon harus berupa angka.'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isSaving = true;
                                });

                                final DateTime tgl = DateFormat('dd-MM-yyyy')
                                    .parse(_tgllahir.text);

                                try {
                                  await penghubung2.updateprofil(
                                    penghubung2.isinya,
                                    penghubung2.mydata.first.foto!,
                                    tgl,
                                    _jenisKelamin.text,
                                    hp,
                                  );

                                  if (!mounted) return;

                                  penghubung2.bersihfoto();

                                  setState(() {
                                    _editgllahir = false;
                                    _editJenisKelamin = false;
                                    _editTelepon = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Profil berhasil diperbarui.'),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Gagal memperbarui profil. Silakan coba lagi.',
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (!mounted) return;
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                              },
                        icon: _isSaving
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.save_outlined),
                        label: Text(_isSaving
                            ? 'Menyimpan...'
                            : 'Simpan Perubahan Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ProfilePemilikPage.warnaUtama,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : () async {
                                if (penghubung2.isinya == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Silakan unggah foto profil terlebih dahulu.'),
                                    ),
                                  );
                                  return;
                                }

                                if (_tgllahir.text.isEmpty ||
                                    _jenisKelamin.text.isEmpty ||
                                    _teleponController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Lengkapi tanggal lahir, jenis kelamin, dan telepon.'),
                                    ),
                                  );
                                  return;
                                }

                                final int? hp = int.tryParse(
                                    _teleponController.text.trim());
                                if (hp == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Nomor telepon harus berupa angka.'),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isSaving = true;
                                });

                                final DateTime tgl = DateFormat('dd-MM-yyyy')
                                    .parse(_tgllahir.text);

                                try {
                                  await penghubung2.createprofil(
                                    penghubung2.isinya!,
                                    tgl,
                                    _jenisKelamin.text,
                                    hp,
                                  );

                                  if (!mounted) return;

                                  penghubung2.bersihfoto();

                                  setState(() {
                                    _editgllahir = false;
                                    _editJenisKelamin = false;
                                    _editTelepon = false;
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Profil berhasil dibuat.'),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Gagal membuat profil. Silakan coba lagi.',
                                      ),
                                    ),
                                  );
                                } finally {
                                  if (!mounted) return;
                                  setState(() {
                                    _isSaving = false;
                                  });
                                }
                              },
                        icon: _isSaving
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Icon(Icons.save_outlined),
                        label: Text(_isSaving ? 'Menyimpan...' : 'Simpan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ProfilePemilikPage.warnaUtama,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
              },
            ),
          ),
        ),
      ),
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

  const _GenderFieldCard({
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


// sementara
// inputan tgl
                    // _InfoFieldCard(
                    //   icon: Icons.date_range_outlined,
                    //   label: 'tgl lahir',
                    //   controller: _tgllahir,
                    //   isEditing: _editgllahir,
                    //   onEdit: () async {
                    //     // setState(() {

                    //     // });
                    //     final waktunya = await showDatePicker(
                    //       context: context,
                    //       firstDate: DateTime(1000),
                    //       lastDate: DateTime(9000),
                    //       initialDate: DateTime.now(),
                    //     );
                    //     // final waktu = waktunya;
                    //     _tgllahir.text =
                    //         "${waktunya!.day.toString().padLeft(2, '0')}-"
                    //         "${waktunya.month.toString().padLeft(2, '0')}-"
                    //         "${waktunya.year.toString()}";

                    //     // waktu = DateTime.parse(_tgllahir.text);
                    //     waktu = DateFormat('dd-MM-yyyy').parse(_tgllahir.text);
                    //     _backuptgllahir = _tgllahir.text;
                    //     _editgllahir = true;
                    //   },
                    //   onCancel: () => setState(() {
                    //     _tgllahir.text = _backuptgllahir ?? '';
                    //     _editgllahir = false;
                    //   }),
                    // ),

// inputan jenis kelamin
                    // _InfoFieldCard(
                    //   icon: FontAwesomeIcons.venusMars,
                    //   label: 'Jenis Kelamin',
                    //   controller: _namaController,
                    //   isEditing: _editUsername,
                    //   onEdit: () => setState(() {
                    //     _backupUsername = _namaController.text;
                    //     _editUsername = true;
                    //   }),
                    //   onCancel: () => setState(() {
                    //     _namaController.text =
                    //         _backupUsername ?? _namaController.text;
                    //     _editUsername = false;
                    //   }),
                    // ),

                    // SizedBox(
                    //   height: 20,
                    // ),

                    // DropdownSearch<(IconData, String)>(
                    //   selectedItem: (
                    //     FontAwesomeIcons.venusMars,
                    //     'Jenis Kelamin'
                    //   ),
                    //   compareFn: (item1, item2) => item1.$1 == item2.$2,
                    //   items: (f, cs) => [
                    //     (Icons.male, 'Laki Laki'),
                    //     (Icons.female, 'Perempuan'),
                    //   ],
                    //   decoratorProps: DropDownDecoratorProps(
                    //     decoration: InputDecoration(
                    //       contentPadding: EdgeInsets.symmetric(vertical: 6),
                    //       filled: true,
                    //       fillColor: Colors.white,
                    //       border: OutlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.transparent),
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //       focusedBorder: OutlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.transparent),
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //       enabledBorder: OutlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.transparent),
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //   ),
                    //   dropdownBuilder: (context, selectedItem) {
                    //     return ListTile(
                    //       leading: Icon(selectedItem!.$1, color: Colors.white),
                    //       title: Text(
                    //         selectedItem.$2,
                    //         style: TextStyle(
                    //           color: Colors.black54,
                    //         ),
                    //       ),
                    //     );
                    //   },
                    //   popupProps: PopupProps.menu(
                    //     itemBuilder: (context, item, isDisabled, isSelected) {
                    //       return ListTile(
                    //         contentPadding: EdgeInsets.symmetric(
                    //             vertical: 8, horizontal: 12),
                    //         leading: Icon(item.$1, color: Colors.white),
                    //         title: Text(
                    //           item.$2,
                    //           style: TextStyle(
                    //             color: Colors.black54,
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //     fit: FlexFit.loose,
                    //     menuProps: MenuProps(
                    //       backgroundColor: Colors.transparent,
                    //       elevation: 0,
                    //       margin: EdgeInsets.only(top: 16),
                    //     ),
                    //     containerBuilder: (ctx, popupWidget) {
                    //       return Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         crossAxisAlignment: CrossAxisAlignment.end,
                    //         children: [
                    //           // Padding(
                    //           //   padding: const EdgeInsets.only(right: 12),
                    //           //   child: Image.asset(
                    //           //     'lib/assets/arrow_up.jpg',
                    //           //     color: Color(0xFF1eb98f),
                    //           //     height: 14,
                    //           //   ),
                    //           // ),
                    //           Flexible(
                    //             child: Container(
                    //               decoration: BoxDecoration(
                    //                 color: Colors.white,
                    //                 shape: BoxShape.rectangle,
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //               child: popupWidget,
                    //             ),
                    //           ),
                    //         ],
                    //       );
                    //     },
                    //   ),
                    // ),

// ini akan digunakan untuk kondisi foto
                                  // versi baru
                                  // Consumer<ProfilProvider>(
                                  //   builder: (context, value, child) {
                                  //     return penghubung2.mydata.isNotEmpty
                                  //         ? custom_editfotostack(
                                  //             fungsi: () {
                                  //               penghubung2.uploadfoto();
                                  //             },
                                  //             path: penghubung2.isinya?.path,
                                  //             pathlama:
                                  //                 penghubung2.isinya?.path,
                                  //             tinggi: 50,
                                  //             panjang: 50,
                                  //           )
                                  //         : CustomUploadfotoStack(
                                  //             panjang: 50,
                                  //             tinggi: 50,
                                  //             fungsi: () {
                                  //               penghubung2.uploadfoto();
                                  //             },
                                  //             path: penghubung2.isinya?.path,
                                  //             warnautama: warnaUtama,
                                  //           );
                                  //     // :
                                  //   },
                                  // ),