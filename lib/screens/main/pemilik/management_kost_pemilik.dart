import 'package:flutter/material.dart';
// import 'package:collection/collection.dart';
// import 'package:kost_saw/providers/profil_provider.dart';
import '../../../providers/kost_provider.dart';
import 'package:provider/provider.dart';
import '../shared/formatCurrency.dart';
// import '../../custom/showdialog_eror.dart';

class ManagementKostPemilik extends StatefulWidget {
  static const arah = "/management-board-pemilik";
  const ManagementKostPemilik({super.key});

  @override
  State<ManagementKostPemilik> createState() => _ManagementKostPemilikState();
}

class _ManagementKostPemilikState extends State<ManagementKostPemilik> {
  static Color warnaLatar = Color(0xFFF5F7FB);
  // static Color warnaKartu = Colors.white;
  static Color warnaUtama = Color(0xFF1E3A8A);
  // static Color aksenBiru = Color(0xFF007BFF);
  // bool _isDeleting = false;
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final penghubung = Provider.of<KostProvider>(context);
    // final penghubung2 = Provider.of<ProfilProvider>(context, listen: false);

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
              // Header modern + tombol tambah
              _HeaderBar(
                title: "Daftar Kost",
                subtitle: "Kelola properti kost milik Anda",
                onAdd: _isNavigating
                    ? null
                    : () async {
                        if (_isNavigating) return;
                        setState(() => _isNavigating = true);

                        await Navigator.of(context, rootNavigator: true)
                            .pushNamed('/form-house-pemilik');

                        if (mounted) {
                          setState(() => _isNavigating = false);
                        }
                      },
                warnaUtama: warnaUtama,
              ),

              SizedBox(height: tinggiLayar * 0.02),

              // Ringkasan
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.other_houses,
                      label: "Total Kost Anda",
                      value: "${penghubung.kostpemilik.length}",
                      lebarLayar: lebarLayar,
                    ),
                  ),
                ],
              ),

              SizedBox(height: tinggiLayar * 0.02),

              // Daftar langsung tanpa filter
              SizedBox(height: tinggiLayar * 0.01),

              // Daftar kost
              Expanded(
                child: penghubung.isLoadingPemilikKost &&
                        penghubung.kostpemilik.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : penghubung.kostpemilik.isEmpty
                        ? const Center(
                            child: Text(
                              "Belum ada kost terdaftar",
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.separated(
                            itemCount: penghubung.kostpemilik.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: tinggiLayar * 0.02),
                            itemBuilder: (context, index) {
                              final item = penghubung.kostpemilik[index];
                              final bool needsFix =
                                  penghubung.kostNeedsSubkriteriaFix(item);
                              // final cek = penghubung.fasilitaspemilik
                              //     .firstWhereOrNull((element) =>
                              //         element.id_fasilitas ==
                              //         item.id_fasilitas);

                              // if (cek == null) {
                              //   // Jika data fasilitas tidak ditemukan, jangan tampilkan kartu
                              //   return const SizedBox.shrink();
                              // }

                              return _OwnerKostCard(
                                nama: penghubung.kostpemilik[index].nama_kost!,
                                gambar:
                                    penghubung.kostpemilik[index].gambar_kost!,
                                harga:
                                    penghubung.kostpemilik[index].harga_kost!,
                                lokasi:
                                    penghubung.kostpemilik[index].alamat_kost!,
                                needsFix: needsFix,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    'detail-kost',
                                    arguments: {
                                      'data_kost': item,
                                      // 'data_fasilitas': cek,
                                    },
                                  );
                                },
                                onEdit: () {
                                  Navigator.of(context).pushNamed(
                                    '/form-house-pemilik',
                                    arguments:
                                        penghubung.kostpemilik[index].id_kost,
                                    // item.id_kost,
                                  );
                                },
                                onDelete: () async {
                                  await showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (dialogContext) {
                                      bool isDeleting = false;
                                      String? dialogError;
                                      return StatefulBuilder(
                                        builder: (context, setStateDialog) {
                                          return WillPopScope(
                                            onWillPop: () async => !isDeleting,
                                            child: AlertDialog(
                                              title: const Text(
                                                'Konfirmasi Hapus',
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'Apakah Anda yakin ingin menghapus kost ini?',
                                                  ),
                                                  if (dialogError != null) ...[
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      dialogError!,
                                                      style: const TextStyle(
                                                        color: Colors.red,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: isDeleting
                                                      ? null
                                                      : () => Navigator.of(
                                                            dialogContext,
                                                          ).pop(),
                                                  child: const Text('Batal'),
                                                ),
                                                TextButton(
                                                  onPressed: isDeleting
                                                      ? null
                                                      : () async {
                                                          setStateDialog(() {
                                                            isDeleting = true;
                                                            dialogError = null;
                                                          });
                                                          try {
                                                            await penghubung
                                                                .deletedatapemilik(
                                                              penghubung
                                                                  .kostpemilik[
                                                                      index]
                                                                  .id_kost!,
                                                              penghubung
                                                                  .kostpemilik[
                                                                      index]
                                                                  .gambar_kost!,
                                                            );
                                                            if (!dialogContext
                                                                .mounted) {
                                                              return;
                                                            }
                                                            Navigator.of(
                                                              dialogContext,
                                                            ).pop();
                                                          } catch (e) {
                                                            setStateDialog(() {
                                                              isDeleting =
                                                                  false;
                                                              dialogError =
                                                                  'Gagal menghapus kost: $e';
                                                            });
                                                          }
                                                        },
                                                  child: isDeleting
                                                      ? const SizedBox(
                                                          width: 16,
                                                          height: 16,
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                          ),
                                                        )
                                                      : const Text('Hapus'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );

                                  // valiidas nya agak keluar jalur ki kah jalan ki delete nya eh malah pop gagal padahal database terhapus loh
                                  // if (konfirmasi != true) return;

                                  // setState(() {
                                  //   _isDeleting = true;
                                  // });

                                  // try {
                                  //   await penghubung.deletedatapemilik(
                                  //     item.id_fasilitas!,
                                  //     item.gambar_kost!,
                                  //   );
                                  // } catch (e) {
                                  //   ScaffoldMessenger.of(context).showSnackBar(
                                  //     SnackBar(
                                  //       content: Text(
                                  //         'Gagal menghapus kost: $e',
                                  //       ),
                                  //     ),
                                  //   );
                                  // } finally {
                                  //   if (mounted) {
                                  //     setState(() {
                                  //       _isDeleting = false;
                                  //     });
                                  //   }
                                  // }
                                },
                                per: (penghubung.kostpemilik[index].per ==
                                            null ||
                                        (penghubung.kostpemilik[index].per ??
                                                '')
                                            .trim()
                                            .isEmpty)
                                    ? 'bulan'
                                    : penghubung.kostpemilik[index].per!,
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

  // void _bukaFormTambah() {
  //   // Gunakan rootNavigator agar menggunakan routes dari MaterialApp utama
  //   final penghubung = Provider.of<ProfilProvider>(context, listen: false);

  //   if (penghubung.mydata.isEmpty) {
  //     ShowdialogEror(label: "Isi data Profil lebih dahulu");
  //   } else {
  //     Navigator.of(context, rootNavigator: true)
  //         .pushNamed('/form-house-pemilik');
  //   }
  // }
}

class _OwnerKostCard extends StatelessWidget {
  // final _OwnerKost item;
  final String nama;
  final String gambar;
  final int harga;
  final String lokasi;
  final bool needsFix;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;
  final String per;

  _OwnerKostCard({
    // required this.item,
    required this.nama,
    required this.gambar,
    required this.harga,
    required this.lokasi,
    required this.needsFix,
    this.onEdit,
    this.onDelete,
    this.onTap,
    required this.per,
  });

  static const String _needsFixLabel = 'Perbaiki Data';

  @override
  Widget build(BuildContext context) {
    final lebarLayar = MediaQuery.of(context).size.width;
    final double tinggiGambar = lebarLayar < 480 ? lebarLayar * 0.42 : 220;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner gambar
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      // item.gambar,
                      gambar,
                      width: double.infinity,
                      height: tinggiGambar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Color(0xFFE5ECFF),
                        child: Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Label harga
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFFDDE6FF).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sell_outlined,
                              size: 18, color: Color(0xFF1E3A8A)),
                          SizedBox(width: 6),
                          Text(
                            // item.harga,
                            // "${int.parse(harga.toString())}",
                            "${formatCurrency(harga)} / ${(per.trim().isEmpty ? 'bulan' : per)}",
                            style: TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Konten
            Padding(
              padding: EdgeInsets.all(lebarLayar * 0.035),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // item.nama,
                              nama,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.grey),
                                SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    // item.lokasi,
                                    needsFix ? _needsFixLabel : lokasi,
                                    style: TextStyle(
                                      color: needsFix
                                          ? Colors.red
                                          : Colors.black54,
                                      fontWeight: needsFix
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      fontSize: 13.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      // Aksi ringkas
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MiniIconBtn(
                              icon: Icons.edit_outlined,
                              label: "Edit",
                              onTap: onEdit),
                          SizedBox(width: 6),
                          _MiniIconBtn(
                              icon: Icons.delete_outline,
                              label: "Hapus",
                              onTap: onDelete,
                              danger: true),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAdd;
  final Color warnaUtama;

  _HeaderBar({
    required this.title,
    this.subtitle,
    this.onAdd,
    required this.warnaUtama,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13.5,
                  ),
                ),
              ]
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onAdd,
            child: Container(
              width: size.width * 0.12,
              height: size.width * 0.12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.add, color: warnaUtama),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  _MiniIconBtn({
    required this.icon,
    required this.label,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : const Color(0xFF1E3A8A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double lebarLayar;

  _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.lebarLayar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: lebarLayar * 0.04,
        vertical: lebarLayar * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: lebarLayar * 0.10,
            height: lebarLayar * 0.10,
            decoration: BoxDecoration(
              color: Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF1E3A8A)),
          ),
          SizedBox(width: lebarLayar * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
