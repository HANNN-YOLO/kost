import 'package:flutter/material.dart';
import 'package:kost_saw/screens/main/admin/detail_user.dart';
import 'package:provider/provider.dart';
import '../../../providers/profil_provider.dart';
import '../../../providers/kost_provider.dart';
import '../../../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class UserManagement extends StatefulWidget {
  static const arah = "/user-management-admin";
  UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  bool _isSearching = false;
  bool hanyasekali = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((vakue) {
      if (hanyasekali) {
        final penghubung2 = Provider.of<ProfilProvider>(context, listen: false);

        if (penghubung2.alluser.isEmpty && penghubung2.accesstoken != null) {
          penghubung2.readuser();
        }
        if (penghubung2.listauth.isEmpty && penghubung2.accesstoken != null) {
          penghubung2.listauth;
        }
        hanyasekali = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<ProfilProvider>(context, listen: false);
    final penghubung2 = Provider.of<AuthProvider>(context);
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    const warnaLatar = Color(0xFFF5F7FB);

    // hitung hanya pengguna non-admin
    final totalNonAdmin = penghubung.listauth
        .where((a) => (a.role ?? '').toLowerCase() != 'admin')
        .length;

    return Scaffold(
      backgroundColor: warnaLatar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: lebarLayar * 0.05,
            vertical: tinggiLayar * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header (judul atau search bar)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!_isSearching)
                    Text(
                      "Daftar Pengguna",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    // 🔸 TextField Search
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        autofocus: true, // langsung munculkan keyboard
                        decoration: InputDecoration(
                          hintText: "Cari pengguna...",
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 0.3,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          // TODO: logika filter daftar pengguna nanti
                        },
                      ),
                    ),

                  // 🔸 Tombol kanan
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isSearching = !_isSearching;
                      });

                      if (_isSearching) {
                        // Saat tombol search ditekan, langsung fokus & munculkan keyboard
                        Future.delayed(Duration(milliseconds: 100), () {
                          FocusScope.of(context).requestFocus(_focusNode);
                        });
                      } else {
                        // Tutup search
                        _searchController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
                    icon: Icon(
                      _isSearching ? Icons.close : Icons.search,
                      size: 22,
                    ),
                  ),
                ],
              ),

              SizedBox(height: tinggiLayar * 0.02),

              // 🔹 Kartu Total Pengguna
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: lebarLayar * 0.04,
                  vertical: tinggiLayar * 0.018,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: lebarLayar * 0.12,
                      height: lebarLayar * 0.12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Icon(Icons.group_outlined, color: Colors.black54),
                    ),
                    SizedBox(width: lebarLayar * 0.04),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Pengguna",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            // "$totalNonAdmin",
                            "${penghubung.alluser.length}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: tinggiLayar * 0.03),

              // 🔹 Daftar Pengguna
              Expanded(
                child: Consumer<ProfilProvider>(
                  builder: (context, value, child) {
                    // gunakan data auth (semua akun non-admin) sebagai sumber utama
                    final semuaAuth = value.listauth
                        .where(
                          (a) => (a.role ?? '').toLowerCase() != 'admin',
                        )
                        .toList();

                    // perhitungan dari sisi auth
                    // return semuaAuth.isEmpty
                    //     ? Center(child: CircularProgressIndicator())
                    //     :
                    //     ListView.separated(
                    //         itemCount: semuaAuth.length,
                    //         separatorBuilder: (context, index) =>
                    //             const SizedBox(height: 12),
                    //         itemBuilder: (context, index) {
                    //           final authuser = semuaAuth[index];

                    //           // cari profil jika sudah pernah mengisi
                    //           final profiluser = value.alluser.firstWhereOrNull(
                    //             (p) => p.id_auth == authuser.id_auth,
                    //           );

                    //           final user = authuser.username ?? "Tidak ada";
                    //           final email = authuser.Email ?? "Tidak ada";
                    //           final uid = authuser.UID ?? "";

                    //           final telepon = profiluser == null
                    //               ? "Belum mengisi profil"
                    //               : (profiluser.kontak == 0
                    //                   ? "Tidak di publish"
                    //                   : "${profiluser.kontak}");

                    //           final foto = profiluser?.foto ?? "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSG55Nj1bMrY-HE5O8dWGAnkPKqRGQ2AnDmGA&s.jpg";
                    //           final idAuth = authuser.id_auth ?? -1;

                    //           return UserCard(
                    //             nama: user,
                    //             email: email,
                    //             telepon: telepon,
                    //             tanggalBergabung:
                    //                 profiluser?.createdAt,
                    //             foto: foto,
                    //             id: idAuth,
                    //             hasProfil: profiluser != null,
                    //             fungsihapus: profiluser == null
                    //                 ? null
                    //                 : () async {
                    //                     await penghubung2.deletedata(
                    //                       profiluser.id_auth!,
                    //                       uid,
                    //                     );

                    //                     if (profiluser.foto != null &&
                    //                         profiluser.foto!.isNotEmpty) {
                    //                       await penghubung.deletegambaradmin(
                    //                         profiluser.foto!,
                    //                       );
                    //                     }
                    //                   },
                    //           );
                    //         },
                    //       );

                    // perhitungan dari yang sudah daftar data profil
                    return penghubung.alluser.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : ListView.separated(
                            itemCount: penghubung.alluser.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final authuser = semuaAuth[index];

                              // cari profil jika sudah pernah mengisi
                              final profiluser = value.alluser.firstWhereOrNull(
                                (p) => p.id_auth == authuser.id_auth,
                              );

                              final user = authuser.username ?? "Tidak ada";
                              final email = authuser.Email ?? "Tidak ada";
                              final uid = authuser.UID ?? "";

                              final telepon = profiluser == null
                                  ? "Belum mengisi profil"
                                  : (profiluser.kontak == 0
                                      ? "Tidak di publish"
                                      : "${profiluser.kontak}");

                              final foto = profiluser?.foto ?? "";
                              final idAuth = authuser.id_auth ?? -1;

                              return UserCard(
                                nama: user,
                                email: email,
                                telepon: telepon,
                                tanggalBergabung: profiluser?.createdAt,
                                foto: foto,
                                id: idAuth,
                                hasProfil: profiluser != null,
                                fungsihapus: profiluser == null
                                    ? null
                                    : () async {
                                        await penghubung2.deletedata(
                                          profiluser.id_auth!,
                                          uid,
                                        );

                                        if (profiluser.foto != null &&
                                            profiluser.foto!.isNotEmpty) {
                                          await penghubung.deletegambaradmin(
                                            profiluser.foto!,
                                          );
                                        }
                                      },
                              );
                            },
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 🔹 Widget Kartu Pengguna
class UserCard extends StatelessWidget {
  final String nama;
  final String email;
  // final String alamat;
  final String telepon;
  final DateTime? tanggalBergabung;
  final String? foto;
  final int id;
  final VoidCallback? fungsihapus;
  final bool hasProfil;

  UserCard({
    super.key,
    required this.nama,
    required this.email,
    // required this.alamat,
    required this.telepon,
    this.tanggalBergabung,
    this.foto,
    required this.id,
    this.fungsihapus,
    this.hasProfil = true,
  });

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    const warnaUtama = Color(0xFF1E3A8A);

    return Container(
      padding: EdgeInsets.all(lebarLayar * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Baris atas
          Row(
            children: [
              Container(
                width: lebarLayar * 0.12,
                height: lebarLayar * 0.12,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: const Color(0xFFDDE6FF),
                  borderRadius: BorderRadius.circular(8),
                  image: foto != null
                      ? DecorationImage(
                          image: NetworkImage(foto!),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        )
                      : DecorationImage(
                          image: NetworkImage(
                              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSG55Nj1bMrY-HE5O8dWGAnkPKqRGQ2AnDmGA&s.jpg"),
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                ),
                child: foto == null
                    ? Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSG55Nj1bMrY-HE5O8dWGAnkPKqRGQ2AnDmGA&s.jpg")
                    : null,
              ),
              SizedBox(width: lebarLayar * 0.04),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    email,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: tinggiLayar * 0.015),
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(telepon, style: TextStyle(fontSize: 14)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.date_range, size: 16, color: Colors.grey),
              SizedBox(width: 4),
              Text(
                // tanggalBergabung!.toIso8601String(),
                DateFormat('dd-MM-yyyy').format(tanggalBergabung!),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: tinggiLayar * 0.02),

          // 🔹 Tombol Aksi: Detail & Hapus
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: tinggiLayar * 0.055,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          transitionDuration: Duration(milliseconds: 300),
                          pageBuilder: (_, __, ___) => DetailUser(),
                          transitionsBuilder: (
                            context,
                            animation,
                            secondaryAnimation,
                            child,
                          ) {
                            return FadeTransition(
                              opacity: CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeInOut,
                              ),
                              child: child,
                            );
                          },
                          settings: RouteSettings(arguments: id),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: warnaUtama,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      "Detail",
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: tinggiLayar * 0.055,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (!hasProfil) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Pengguna belum mengisi profil, tidak ada data profil untuk dihapus.',
                            ),
                          ),
                        );
                        return;
                      }
                      final profilProvider = Provider.of<ProfilProvider>(
                        context,
                        listen: false,
                      );
                      final kostProvider = Provider.of<KostProvider>(
                        context,
                        listen: false,
                      );

                      // Cari data profil untuk mendapatkan id_auth pemilik
                      final profil = profilProvider.alluser.firstWhere(
                        (p) => p.id_auth == id,
                        orElse: () => profilProvider.alluser.first,
                      );

                      final int? ownerAuthId = profil.id_auth;
                      int jumlahKost = 0;
                      List kostPemilik = [];

                      if (ownerAuthId != null) {
                        // Pastikan data kost terbaru
                        try {
                          await kostProvider.readdata();
                        } catch (_) {}

                        kostPemilik = kostProvider.kost
                            .where((k) => k.id_auth == ownerAuthId)
                            .toList();
                        jumlahKost = kostPemilik.length;
                      }

                      final konfirmasi = await showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: Text('Hapus Pengguna'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Yakin ingin menghapus pengguna "$nama"? Tindakan ini tidak dapat dibatalkan.',
                                ),
                                if (jumlahKost > 0) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    'Pengguna ini memiliki $jumlahKost kost yang terdaftar dalam sistem. Jika pengguna dihapus, seluruh kost tersebut juga akan terhapus.',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: Text('Batal'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  fungsihapus?.call();
                                  Navigator.of(ctx).pop(true);
                                },
                                child: Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );

                      if (konfirmasi != true) return;

                      try {
                        // Hapus semua kost milik pengguna ini (jika ada)
                        for (final k in kostPemilik) {
                          if (k.id_kost != null) {
                            await kostProvider.deletedata(k.id_kost as int);
                          }
                        }

                        final provider = Provider.of<ProfilProvider>(
                          context,
                          listen: false,
                        );
                        // await provider.deleteUserByProfilId(id);
                        fungsihapus?.call();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                jumlahKost > 0
                                    ? 'Pengguna dan $jumlahKost kost terkait berhasil dihapus dari sistem.'
                                    : 'Pengguna berhasil dihapus dari sistem.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal menghapus pengguna: $e'),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.delete_outline, color: Colors.red),
                    label: Text('Hapus', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
