import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:kost_saw/providers/profil_provider.dart';
import '../../../providers/kost_provider.dart';
import 'package:provider/provider.dart';
import '../shared/formatCurrency.dart';
import '../../custom/showdialog_eror.dart';

class ManagementKostPemilik extends StatefulWidget {
  static const arah = "/management-board-pemilik";
  const ManagementKostPemilik({super.key});

  @override
  State<ManagementKostPemilik> createState() => _ManagementKostPemilikState();
}

class _ManagementKostPemilikState extends State<ManagementKostPemilik> {
  static Color warnaLatar = Color(0xFFF5F7FB);
  static Color warnaKartu = Colors.white;
  static Color warnaUtama = Color(0xFF1E3A8A);
  static Color aksenBiru = Color(0xFF007BFF);
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final penghubung = Provider.of<KostProvider>(context);
    final penghubung2 = Provider.of<ProfilProvider>(context, listen: false);

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
                onAdd: () {
                  if (penghubung2.mydata.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ShowdialogEror(
                            label: "Isi data Profil lebih dahulu");
                      },
                    );
                  } else {
                    Navigator.of(context, rootNavigator: true)
                        .pushNamed('/form-house-pemilik');
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
                              final cek = penghubung.fasilitaspemilik
                                  .firstWhereOrNull((element) =>
                                      element.id_fasilitas ==
                                      item.id_fasilitas);

                              if (cek == null) {
                                // Jika data fasilitas tidak ditemukan, jangan tampilkan kartu
                                return const SizedBox.shrink();
                              }

                              return _OwnerKostCard(
                                nama: penghubung.kostpemilik[index].nama_kost!,
                                gambar:
                                    penghubung.kostpemilik[index].gambar_kost!,
                                harga:
                                    penghubung.kostpemilik[index].harga_kost!,
                                lokasi:
                                    penghubung.kostpemilik[index].alamat_kost!,
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    'detail-kost',
                                    arguments: {
                                      'data_kost': item,
                                      'data_fasilitas': cek,
                                    },
                                  );
                                },
                                onEdit: () {
                                  Navigator.of(context).pushNamed(
                                    "/form-house-pemilik",
                                    arguments:
                                        penghubung.kostpemilik[index].id_kost,
                                  );
                                },
                                onDelete: () async {
                                  if (_isDeleting) return;

                                  final konfirmasi = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: const Text(
                                            'Apakah Anda yakin ingin menghapus kost ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (konfirmasi != true) return;

                                  setState(() {
                                    _isDeleting = true;
                                  });

                                  try {
                                    await penghubung.deletedatapemilik(
                                      item.id_fasilitas!,
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Gagal menghapus kost: $e',
                                        ),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isDeleting = false;
                                      });
                                    }
                                  }
                                },
                                per: penghubung.kostpemilik[index].per!,
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

  void _tombolBelumTersedia() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Fitur belum diaktifkan"),
        behavior: SnackBarBehavior.floating,
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

  String _formatRupiah(double value) {
    // Simple formatter for display only
    return "Rp " +
        value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
              (m) => "${m[1]}.",
            );
  }
}

class _OwnerKostCard extends StatelessWidget {
  // final _OwnerKost item;
  final String nama;
  final String gambar;
  final int harga;
  final String lokasi;
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
    this.onEdit,
    this.onDelete,
    this.onTap,
    required this.per,
  });

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
                            "${formatCurrency(harga)} / $per",
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
                                    lokasi,
                                    style: TextStyle(
                                      color: Colors.black54,
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

  String _formatRupiah(double value) {
    return "Rp " +
        value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
              (m) => "${m[1]}.",
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onFilter;

  _SearchBar({
    required this.controller,
    this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded(
        //   child: TextField(
        //     controller: controller,
        //     decoration: InputDecoration(
        //       hintText: "Cari kost...",
        //       prefixIcon:  Icon(Icons.search, color: Colors.black54),
        //       filled: true,
        //       fillColor: const Color(0xFFF5F7FB),
        //       contentPadding: const EdgeInsets.symmetric(vertical: 14),
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(12),
        //         borderSide: BorderSide.none,
        //       ),
        //     ),
        //   ),
        // ),
        SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onFilter,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Icon(Icons.tune, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int index;
  final ValueChanged<int>? onChanged;
  final Color warnaUtama;

  _FilterChips({
    required this.index,
    required this.onChanged,
    required this.warnaUtama,
  });

  @override
  Widget build(BuildContext context) {
    final opsi = ["Semua", "Aktif", "Nonaktif"];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final aktif = i == index;
          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onChanged?.call(i),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: aktif ? Color(0xFFDDE6FF) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: aktif ? warnaUtama : Color(0xFFE6EAF2),
                ),
                boxShadow: aktif
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                opsi[i],
                style: TextStyle(
                  color: aktif ? warnaUtama : Colors.black87,
                  fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => SizedBox(width: 10),
        itemCount: opsi.length,
      ),
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

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  _InputField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OwnerKost {
  final String nama;
  final String lokasi;
  final String harga;
  final String gambar;
  final double pemasukanBulanIni;

  _OwnerKost({
    required this.nama,
    required this.lokasi,
    required this.harga,
    required this.gambar,
    required this.pemasukanBulanIni,
  });
}
