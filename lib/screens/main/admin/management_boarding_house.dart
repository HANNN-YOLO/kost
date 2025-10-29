import 'package:flutter/material.dart';
import 'form_add_house.dart';

class ManagementBoardingHouse extends StatelessWidget {
  const ManagementBoardingHouse({super.key});

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Daftar Kost',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Material(
                    color: Colors
                        .transparent, // supaya warna background tetap dari Container
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FormAddHouse(),
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
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.black87),
                      ),
                    ),
                  )
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: lebarLayar * 0.12,
                      height: lebarLayar * 0.12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.other_houses,
                        color: warnaIkonUtama,
                        size: lebarLayar * 0.065,
                      ),
                    ),
                    SizedBox(width: lebarLayar * 0.04),
                    const Text(
                      'Total Kost',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      '30',
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

              // 🔹 Daftar Kost
              Expanded(
                child: ListView(
                  children: [
                    KostCard(
                      gambar:
                          'https://i.pinimg.com/736x/fe/86/47/fe864738b0b4dc2e9c4281e70712e169.jpg',
                      harga: 'Rp 850.000.00',
                      nama: 'Rumah Indekos Irwan',
                      lokasi: 'Kelurahan Tamalanrea Indah',
                      tampilkanEdit: true,
                      tampilkanHapus: true,
                    ),
                    SizedBox(height: tinggiLayar * 0.02),
                    KostCard(
                      gambar:
                          'https://i.pinimg.com/736x/fe/86/47/fe864738b0b4dc2e9c4281e70712e169.jpg',
                      harga: 'Rp 850.000.00',
                      nama: 'Rumah Indekos Irwan',
                      lokasi: 'Kelurahan Tamalanrea Indah',
                      tampilkanEdit: true,
                      tampilkanHapus: true,
                    ),
                    SizedBox(height: tinggiLayar * 0.02),
                    KostCard(
                      gambar:
                          'https://i.pinimg.com/736x/fe/86/47/fe864738b0b4dc2e9c4281e70712e169.jpg',
                      harga: 'Rp 850.000.00',
                      nama: 'Rumah Indekos Irwan',
                      lokasi: 'Kelurahan Tamalanrea Indah',
                      tampilkanEdit: true,
                      tampilkanHapus: true,
                    ),
                    SizedBox(height: tinggiLayar * 0.02),
                    KostCard(
                      gambar:
                          'https://i.pinimg.com/736x/fe/86/47/fe864738b0b4dc2e9c4281e70712e169.jpg',
                      harga: 'Rp 850.000.00',
                      nama: 'Rumah Indekos Irwan',
                      lokasi: 'Kelurahan Tamalanrea Indah',
                      tampilkanEdit: true,
                      tampilkanHapus: true,
                    ),
                    SizedBox(height: tinggiLayar * 0.02),
                    KostCard(
                      gambar:
                          'https://i.pinimg.com/736x/fe/86/47/fe864738b0b4dc2e9c4281e70712e169.jpg',
                      harga: 'Rp 850.000.00',
                      nama: 'Rumah Indekos Irwan',
                      lokasi: 'Kelurahan Tamalanrea Indah',
                      tampilkanEdit: true,
                      tampilkanHapus: true,
                    ),
                    SizedBox(height: tinggiLayar * 0.02),
                    KostCard(
                      gambar:
                          'https://binabangunbangsa.com/wp-content/uploads/2020/03/tips-Manajemen-Rumah-Kost-yang-Baik-dan-Benar-.jpg',
                      harga: 'Rp 850.000.00',
                      nama: 'Rumah Indekos juragan reyhan di daerah tamalanrea',
                      lokasi: 'Kelurahan Tamalanrea Indah',
                      tampilkanEdit: true,
                      tampilkanHapus: true,
                    ),
                  ],
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
  final String harga;
  final String nama;
  final String lokasi;
  final bool tampilkanEdit;
  final bool tampilkanHapus;

  const KostCard({
    super.key,
    required this.gambar,
    required this.harga,
    required this.nama,
    required this.lokasi,
    this.tampilkanEdit = false,
    this.tampilkanHapus = false,
  });

  void _tampilkanKonfirmasiHapus(BuildContext context) {
    // POP UP KONFIRMASI HAPUS
    showGeneralDialog(
      context: context,
      barrierLabel: "Hapus Kost",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: const Color.fromARGB(
                  255, 255, 255, 255), // 🌸 Warna background lembut
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
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
              content: const Text(
                "Apakah Anda yakin ingin menghapus kost ini? Tindakan ini tidak dapat dibatalkan.",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.black26),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Batal",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.pop(context);

                    // TODO: logika hapus kost di sini
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Kost berhasil dihapus."),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  },
                  child: const Text(
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
    final double tinggiGambar = lebarLayar * 0.22;

    return Container(
      padding: EdgeInsets.all(lebarLayar * 0.03),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
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
                            harga,
                            style: TextStyle(
                              color: const Color(0xFF007BFF),
                              fontSize: lebarLayar * 0.040,
                              fontWeight: FontWeight.w900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              if (tampilkanEdit)
                                Icon(Icons.edit,
                                    color: Colors.green,
                                    size: lebarLayar * 0.060),
                              if (tampilkanHapus)
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
    );
  }
}
