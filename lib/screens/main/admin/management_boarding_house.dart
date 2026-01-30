import 'package:flutter/material.dart';
import 'package:kost_saw/screens/custom/showdialog_eror.dart';
import 'form_house.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../../providers/kost_provider.dart';
import 'admin_places_page.dart';
import '../shared/formatCurrency.dart';

class ManagementBoardingHouse extends StatelessWidget {
  static const arah = "/management-board-admin";
  const ManagementBoardingHouse({super.key});

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<KostProvider>(context);
    final penghubung2 = Provider.of<KostProvider>(context);
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    // 🎨 Warna dan style umum
    const warnaLatar = Color(0xFFF5F7FB);
    const warnaKartu = Colors.white;
    const warnaIkonUtama = Color(0xFF1E3A8A);
    const warnaHarga = Color(0xFF1E3A8A);
    const warnaAbuTeks = Colors.grey;

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
              // 🔹 Bagian Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Kost',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Row(
                    children: [
                      // Tombol untuk menambahkan nama tempat + titik koordinat
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AdminPlacesPage(),
                              ),
                            );
                          },
                          child: Container(
                            width: lebarLayar * 0.09,
                            height: lebarLayar * 0.09,
                            decoration: BoxDecoration(
                              color: warnaKartu,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.add_location_alt_outlined,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: lebarLayar * 0.02),
                      // Tombol tambah kost seperti sebelumnya
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FormHouse(),
                              ),
                            );
                          },
                          child: Container(
                            width: lebarLayar * 0.09,
                            height: lebarLayar * 0.09,
                            decoration: BoxDecoration(
                              color: warnaKartu,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 3,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.add, color: Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: tinggiLayar * 0.03),

              // 🔹 Kartu Total Kost
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: lebarLayar * 0.04,
                  vertical: tinggiLayar * 0.018,
                ),
                decoration: BoxDecoration(
                  color: warnaKartu,
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
                      width: lebarLayar * 0.12,
                      height: lebarLayar * 0.12,
                      decoration: BoxDecoration(
                        color: Color(0xFFDDE6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.other_houses,
                        color: warnaIkonUtama,
                        size: lebarLayar * 0.065,
                      ),
                    ),
                    SizedBox(width: lebarLayar * 0.04),
                    Text(
                      'Total Kost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    Text(
                      "${penghubung.kost.length}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: tinggiLayar * 0.03),

              Expanded(
                child: penghubung.isLoadingAdminKost && penghubung.kost.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.separated(
                        itemCount: penghubung.kost.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: tinggiLayar * 0.02),
                        itemBuilder: (context, index) {
                          return KostCard(
                            gambar: "${penghubung.kost[index].gambar_kost}",
                            harga: penghubung.kost[index].harga_kost!,
                            nama: "${penghubung.kost[index].nama_kost}",
                            lokasi: "${penghubung.kost[index].alamat_kost}",
                            tampilkanEdit: true,
                            tampilkanHapus: true,
                            fungsihapus: () {
                              penghubung.deletedata(
                                int.parse(
                                    penghubung.kost[index].id_kost.toString()),
                              );
                            },
                            fungsitap: () {
                              final test = penghubung.kost[index];

                              final cek = Provider.of<KostProvider>(context,
                                      listen: false)
                                  .faslitas
                                  .firstWhereOrNull((element) =>
                                      element.id_fasilitas ==
                                      test.id_fasilitas);

                              if (cek == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Data fasilitas kost tidak tersedia.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              Navigator.of(context)
                                  .pushNamed("detail-kost", arguments: {
                                'data_kost': penghubung.kost[index],
                                'data_fasilitas': cek,
                              });
                            },
                            fungsiupdated: () {
                              Navigator.of(context).pushNamed(
                                "/form-house-admin",
                                arguments: penghubung.kost[index].id_kost,
                              );
                            },
                            per: "${penghubung.kost[index].per}",
                          );
                          // SizedBox(height: tinggiLayar * 0.02);
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

// 🔸 Widget KostCard — menampilkan 1 kartu kost
class KostCard extends StatelessWidget {
  final String gambar;
  final int harga;
  final String nama;
  final String lokasi;
  final bool tampilkanEdit;
  final bool tampilkanHapus;
  final VoidCallback? fungsihapus;
  final VoidCallback? fungsitap;
  final VoidCallback? fungsiupdated;
  final String per;

  KostCard({
    super.key,
    required this.gambar,
    required this.harga,
    required this.nama,
    required this.lokasi,
    this.tampilkanEdit = false,
    this.tampilkanHapus = false,
    this.fungsihapus,
    this.fungsitap,
    this.fungsiupdated,
    required this.per,
  });

  void _tampilkanKonfirmasiHapus(BuildContext context) {
    // POP UP KONFIRMASI HAPUS
    showGeneralDialog(
      context: context,
      barrierLabel: "Hapus Kost",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: Color.fromARGB(
                  255, 255, 255, 255), // 🌸 Warna background lembut
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Text(
                    "Konfirmasi Hapus",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              content: Text(
                "Apakah Anda yakin ingin menghapus kost ini? Tindakan ini tidak dapat dibatalkan.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              actionsPadding:
                  EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black26),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Batal",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    try {
                      fungsihapus?.call();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Kost berhasil dihapus."),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ShowdialogEror(label: "${e.toString()}");
                        },
                      );
                    }
                  },
                  child: Text(
                    "Hapus",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// KOMPONEN KOST CARD
  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final double tinggiGambar = lebarLayar * 0.25;

    return InkWell(
      onTap: fungsitap,
      child: Container(
        padding: EdgeInsets.all(lebarLayar * 0.03),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏠 Gambar Kost
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                gambar,
                width: lebarLayar * 0.22,
                height: tinggiGambar,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: lebarLayar * 0.04),

            // 🔤 Detail Kost
            Expanded(
              child: SizedBox(
                height: tinggiGambar,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${formatCurrency(harga)} / $per",
                              style: TextStyle(
                                color: Color(0xFF007BFF),
                                fontSize: lebarLayar * 0.0370,
                                fontWeight: FontWeight.w900,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: fungsiupdated,
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                    size: lebarLayar * 0.060,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: lebarLayar * 0.015),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _tampilkanKonfirmasiHapus(context),
                                    child: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: lebarLayar * 0.060,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: tinggiLayar * 0.005),
                        Text(
                          nama,
                          style: TextStyle(
                            fontSize: lebarLayar * 0.041,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: lebarLayar * 0.04,
                          color: Colors.grey,
                        ),
                        SizedBox(width: lebarLayar * 0.01),
                        Expanded(
                          child: Text(
                            lokasi,
                            style: TextStyle(
                              fontSize: lebarLayar * 0.032,
                              color: Colors.grey[700],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
