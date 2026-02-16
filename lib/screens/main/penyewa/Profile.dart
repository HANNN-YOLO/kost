import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../custom/custom_UploadFoto.dart';
import '../../custom/custom_editfoto.dart';
import '../../custom/showdialog_eror.dart';
import '../../custom/custom_dropdown_search.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profil_provider.dart';
import '../../../providers/kost_provider.dart';
import '../../../services/profil_service.dart';
import '../../../services/kost_service.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  static const arah = "/profil-user";

  /// Kontrol apakah tombol "Keluar Akun" ditampilkan.
  /// Default: true (untuk profil penyewa).
  final bool showLogoutButton;

  UserProfilePage({
    Key? key,
    this.showLogoutButton = true,
  }) : super(key: key);

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int index = 0;
  String? mesaage;

  bool _isSaving = false;
  bool _hasChanges = false;

  String? _initialNoHpText;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // pantau perubahan pada field agar bisa mengaktifkan/nonaktifkan tombol simpan
    namaController.addListener(_onFormChanged);
    noHpController.addListener(_onFormChanged);
    emailController.addListener(_onFormChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final penghubung = Provider.of<AuthProvider>(context, listen: false);
      final penghubung2 = Provider.of<ProfilProvider>(context, listen: false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        namaController.text = penghubung.mydata[index].username ?? 'Default';
        emailController.text = penghubung.mydata[index].Email ?? 'Default';

        if (penghubung2.accesstoken != null) {
          await penghubung2.readdata(
            penghubung2.accesstoken!,
            penghubung2.id_auth!,
          );
        } else {
          Navigator.of(context).pop();
          throw Exception('User tidak terautentikasi.');
        }

        Navigator.of(context).pop();

        if (penghubung2.mydata.isEmpty) {
          // profil baru, nilai awal masih kosong
          _initialNoHpText = noHpController.text;
        } else {
          final kontak = penghubung2.mydata[index].kontak;
          noHpController.text =
              (kontak == null || kontak.trim().isEmpty || kontak == '0')
                  ? ''
                  : kontak;

          // simpan nilai awal saat pertama kali berhasil dibaca
          _initialNoHpText = noHpController.text;
        }

        if (mounted) {
          _recomputeHasChanges();
          setState(() {});
        }
      } catch (e) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    namaController.dispose();
    noHpController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    _recomputeHasChanges();
  }

  void _recomputeHasChanges() {
    if (!mounted) return;

    final profil = Provider.of<ProfilProvider>(context, listen: false);

    final currentNoHp = noHpController.text;

    bool changed = false;

    if (currentNoHp != (_initialNoHpText ?? '')) {
      changed = true;
    }

    // perubahan foto yang belum disimpan (memilih foto baru)
    if (profil.isinya != null) {
      changed = true;
    }

    if (changed != _hasChanges) {
      setState(() {
        _hasChanges = changed;
      });
    }
  }

  Future<void> _openPhotoOptions(
    BuildContext context,
    ProfilProvider value,
    bool hasFoto,
  ) async {
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'PhotoOptions',
      // Hilangkan overlay gelap, hanya blur halus di belakang
      barrierColor: Colors.transparent,
      transitionDuration: Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return SizedBox.shrink();
      },
      transitionBuilder: (dialogContext, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        // Animasi: blur bertambah halus bersamaan dengan modal yang fade+scale
        final double sigma = 14 * curved.value;

        return Stack(
          children: [
            // Blur halus pada seluruh layar
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: Container(color: Colors.transparent),
            ),
            // Kartu modal di tengah dengan animasi fade + scale
            Center(
              child: FadeTransition(
                opacity: curved,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 24),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Kelola Foto Profil',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pilih aksi untuk mengubah atau menghapus foto profil Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          SizedBox(height: 12),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Color(0xFFE0ECFF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.photo_camera_back_outlined,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            title: Text('Upload Foto Profil'),
                            subtitle: Text(
                              'Pilih gambar dari galeri perangkat.',
                              style: TextStyle(fontSize: 12),
                            ),
                            onTap: () async {
                              Navigator.of(context).pop();
                              await value.uploadfoto();
                              _recomputeHasChanges();
                            },
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            enabled: hasFoto,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: hasFoto
                                    ? Color(0xFFFEE2E2)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delete_outline,
                                color: hasFoto ? Colors.red : Colors.grey,
                              ),
                            ),
                            title: Text('Hapus Foto Profil'),
                            subtitle: Text(
                              'Kembalikan ke avatar default.',
                              style: TextStyle(fontSize: 12),
                            ),
                            onTap: hasFoto
                                ? () async {
                                    Navigator.of(context).pop();

                                    if (_isSaving) return;

                                    setState(() {
                                      _isSaving = true;
                                    });

                                    try {
                                      await value.hapusFotoProfil();
                                      value.bersihfoto();

                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Foto profil berhasil dihapus.',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Gagal menghapus foto profil. Silakan coba lagi.',
                                          ),
                                        ),
                                      );
                                    } finally {
                                      if (!mounted) return;
                                      setState(() {
                                        _isSaving = false;
                                      });
                                    }
                                  }
                                : null,
                          ),
                          SizedBox(height: 4),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Batal',
                              style: TextStyle(
                                color: Color(0xFF111827),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

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
                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
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
                        color: Color(0xFF1E3A8A),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Oke',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<AuthProvider>(context, listen: false);
    final penghubung2 = Provider.of<ProfilProvider>(context, listen: false);
    final penghubung3 = Provider.of<KostProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER mirip profil pemilik
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, 16),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            'Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              )
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Consumer<ProfilProvider>(
                                builder: (context, value, child) {
                                  final hasFoto = value.mydata.isNotEmpty &&
                                      value.mydata[index].foto != null &&
                                      value.mydata[index].foto!.isNotEmpty;

                                  return GestureDetector(
                                    onTap: () => _openPhotoOptions(
                                      context,
                                      value,
                                      hasFoto,
                                    ),
                                    child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        if (!hasFoto)
                                          CustomUploadfoto(
                                            tinggi: 70,
                                            panjang: 70,
                                            radius: 35,
                                            fungsi: () {
                                              _openPhotoOptions(
                                                context,
                                                value,
                                                hasFoto,
                                              );
                                            },
                                            path: value.isinya?.path,
                                          )
                                        else
                                          custom_editfoto(
                                            fungsi: () {
                                              _openPhotoOptions(
                                                context,
                                                value,
                                                hasFoto,
                                              );
                                            },
                                            path: value.isinya?.path,
                                            pathlama: value.mydata[index].foto,
                                            tinggi: 70,
                                            panjang: 70,
                                            radius: 35,
                                          ),
                                        Positioned(
                                          bottom: 2,
                                          right: 2,
                                          child: Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              color: Color(0xFF1E3A8A),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.25),
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      penghubung.mydata[index].username ?? '-',
                                      style: TextStyle(
                                        color: Color(0xFF111827),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      penghubung.mydata[index].Email ?? '-',
                                      style: TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Akun',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    _IconTextField(
                      controller: namaController,
                      label: 'Nama',
                      icon: Icons.person_outline,
                      readOnly: true,
                    ),
                    SizedBox(height: 12),
                    _IconTextField(
                      controller: noHpController,
                      label: 'No. Hp',
                      icon: Icons.phone_outlined,
                      readOnly: false,
                      keyboardType: TextInputType.phone,
                    ),
                    _IconTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    if (mesaage != null) ...[
                      SizedBox(height: 8),
                      Center(
                        child: Text(
                          mesaage!,
                          style: TextStyle(color: Colors.green),
                        ),
                      )
                    ],
                    SizedBox(height: 16),
                    if (widget.showLogoutButton)
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await penghubung.logout();
                            penghubung2.reset();
                            penghubung3.resetSession();
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            showDialog(
                              context: context,
                              builder: (context) {
                                return ShowdialogEror(
                                  label: e.toString(),
                                );
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: Icon(Icons.logout),
                        label: Text(
                          'Keluar Akun',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isSaving || !_hasChanges
                  ? null
                  : () async {
                      // Validasi fleksibel - tidak wajib semua field diisi
                      // User bisa update partial data
                      bool hasValidData = false;

                      if (noHpController.text.isNotEmpty) hasValidData = true;

                      // Profil baru: minimal isi salah satu (No HP atau Foto)
                      if (penghubung2.mydata.isEmpty &&
                          !hasValidData &&
                          penghubung2.isinya == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Minimal isi satu data untuk disimpan.',
                            ),
                          ),
                        );
                        return;
                      }

                      // Validasi & parsing nomor HP (boleh kosong)
                      final String hpText = noHpController.text.trim();
                      String? hp;
                      if (hpText.isEmpty) {
                        // Boleh kosong: simpan NULL.
                        hp = null;
                      } else {
                        // Validasi hanya angka
                        if (!RegExp(r'^\d+$').hasMatch(hpText)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Nomor HP harus berupa angka.'),
                            ),
                          );
                          return;
                        }

                        if (hpText.length < 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Nomor HP minimal 10 digit.',
                              ),
                            ),
                          );
                          return;
                        }

                        if (hpText.length > 15) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Nomor HP maksimal 15 digit.',
                              ),
                            ),
                          );
                          return;
                        }

                        // Validasi format nomor Indonesia (harus dimulai 0 atau 62)
                        if (!hpText.startsWith('0') &&
                            !hpText.startsWith('62')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Nomor HP harus dimulai dengan 0 atau 62.',
                              ),
                            ),
                          );
                          return;
                        }

                        hp = hpText;
                      }

                      try {
                        setState(() {
                          _isSaving = true;
                        });

                        if (penghubung2.mydata.isEmpty) {
                          // Mode buat profil baru
                          // Foto tidak wajib - bisa dibuat profil tanpa foto

                          final String? hpToSave = hp;

                          // Profil baru: boleh simpan tanpa upload foto
                          await penghubung2.createprofil(
                            penghubung2.isinya,
                            hpToSave,
                          );

                          setState(() {
                            noHpController.text =
                                '${penghubung2.mydata[index].kontak ?? ''}';
                            if (noHpController.text == '0' ||
                                noHpController.text == 'null') {
                              noHpController.text = '';
                            }
                            mesaage = 'Profil berhasil dibuat';
                            _initialNoHpText = noHpController.text;
                            _hasChanges = false;
                          });
                          if (mounted) {
                            // Pemilik: setelah profil diisi, update semua kost pemilik agar mengikuti no HP profil.
                            if ((penghubung.mydata[index].role ?? '') ==
                                'Pemilik') {
                              try {
                                final kostService = KostService();
                                await kostService.updateNoTelpKostPemilikSemua(
                                  penghubung2.accesstoken!,
                                  penghubung2.id_auth!,
                                  hpToSave,
                                );

                                await penghubung3.readdatapemilik(
                                  penghubung2.id_auth!,
                                  penghubung2.accesstoken!,
                                );
                              } catch (_) {
                                // non-fatal: profil tetap tersimpan
                              }
                            }

                            await _showSuccessDialog(
                              context,
                              title: 'Profil Tersimpan',
                              message:
                                  'Profil baru kamu berhasil disimpan dan siap digunakan.',
                            );
                          }
                        } else {
                          // Mode update - gunakan data lama jika field tidak diubah
                          final String? hpToSave = hp;

                          await penghubung2.updateprofil(
                            penghubung2.isinya,
                            penghubung2.mydata[index].foto,
                            hpToSave,
                          );

                          setState(() {
                            noHpController.text =
                                '${penghubung2.mydata[index].kontak ?? ''}';
                            if (noHpController.text == '0' ||
                                noHpController.text == 'null') {
                              noHpController.text = '';
                            }
                            mesaage = 'Profil berhasil diperbarui';
                            _initialNoHpText = noHpController.text;
                            _hasChanges = false;
                          });
                          if (mounted) {
                            // Pemilik: setiap perubahan no HP profil harus mengubah no HP semua kost.
                            if ((penghubung.mydata[index].role ?? '') ==
                                'Pemilik') {
                              try {
                                final kostService = KostService();
                                await kostService.updateNoTelpKostPemilikSemua(
                                  penghubung2.accesstoken!,
                                  penghubung2.id_auth!,
                                  hpToSave,
                                );

                                await penghubung3.readdatapemilik(
                                  penghubung2.id_auth!,
                                  penghubung2.accesstoken!,
                                );
                              } catch (_) {
                                // non-fatal: profil tetap tersimpan
                              }
                            }

                            await _showSuccessDialog(
                              context,
                              title: 'Perubahan Disimpan',
                              message:
                                  'Perubahan pada profil kamu sudah berhasil disimpan.',
                            );
                          }
                        }
                      } catch (e) {
                        mesaage = 'Data gagal diperbarui';
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ShowdialogEror(label: e.toString());
                          },
                        );
                      } finally {
                        if (!mounted) return;
                        setState(() {
                          _isSaving = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.save_outlined),
              label: Text(
                _isSaving ? 'Menyimpan...' : 'Simpan Perubahan Data',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class buildTextfiel extends StatelessWidget {
  final TextEditingController controllers;
  final bool keadaan;
  final String label;
  final VoidCallback? fungsi;

  buildTextfiel({
    required this.controllers,
    required this.keadaan,
    required this.label,
    this.fungsi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 25.0),
      child: TextField(
        controller: controllers,
        readOnly: keadaan,
        onTap: fungsi,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _IconTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;

  const _IconTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: const Color(0xFF6B7280),
          ),
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1.2),
          ),
        ),
      ),
    );
  }
}

// oke
