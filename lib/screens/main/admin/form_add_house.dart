import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FormAddHouse extends StatefulWidget {
  const FormAddHouse({super.key});

  @override
  State<FormAddHouse> createState() => _FormAddHouseState();
}

class _FormAddHouseState extends State<FormAddHouse> {
  final TextEditingController _namaFasilitasController =
      TextEditingController();
  File? _gambar1;
  File? _gambar2;

  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> fasilitasList = [
    {'nama': 'Kamar Mandi', 'ikon': Icons.bathtub_outlined, 'cek': false},
    {'nama': 'Tempat Tidur', 'ikon': Icons.bed, 'cek': false},
    // {'nama': 'AC', 'ikon': Icons.ac_unit, 'cek': false},
    // {'nama': 'TV', 'ikon': Icons.tv, 'cek': false},

    {'nama': 'Meja', 'ikon': Icons.desk, 'cek': false},
    {'nama': 'Listrik', 'ikon': Icons.flash_on, 'cek': false},
    {'nama': 'Air', 'ikon': Icons.water_drop, 'cek': false},
    {'nama': 'WiFi', 'ikon': Icons.wifi, 'cek': false},
    {'nama': 'Tempat Parkir', 'ikon': Icons.local_parking, 'cek': false},
    {'nama': 'Dapur Umum', 'ikon': Icons.kitchen, 'cek': false},
    {'nama': 'CCTV', 'ikon': Icons.videocam, 'cek': false},
    {'nama': 'Lemari', 'ikon': Icons.chair_alt, 'cek': false},

    // tambahan dari kamu sebelumnya
    {'nama': 'AC', 'ikon': Icons.ac_unit, 'cek': false},
    {'nama': 'TV', 'ikon': Icons.tv, 'cek': false},
  ];

  // final List<IconData> ikonPilihan = [
  //   Icons.bed,
  //   Icons.chair,
  //   Icons.tv,
  //   Icons.wifi,
  //   Icons.kitchen,
  //   Icons.ac_unit,
  //   Icons.bathtub_outlined,
  //   Icons.local_laundry_service,
  //   Icons.lock,
  //   Icons.desk,
  // ];

  IconData? ikonTerpilih;

  Future<void> _pilihGambar(int index) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (index == 1) {
          _gambar1 = File(pickedFile.path);
        } else {
          _gambar2 = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    const warnaLatar = Color(0xFFF5F7FB);
    const warnaTombol = Color(0xFF12111F);

    return Scaffold(
      backgroundColor: warnaLatar,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(tinggiLayar * 0.08),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: lebarLayar * 0.06),
          color: warnaLatar,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              Text(
                'Form Tambah Kost',
                style: TextStyle(
                  fontSize: lebarLayar * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Icon(Icons.notifications_none, color: Colors.black),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: lebarLayar * 0.06,
            vertical: tinggiLayar * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputField('Nama Pemilik', tinggiLayar, lebarLayar),
              _inputField('Nama Kost', tinggiLayar, lebarLayar),
              _inputField('Nomor Telepon', tinggiLayar, lebarLayar),
              _inputField('Harga', tinggiLayar, lebarLayar),
              _inputField('Alamat', tinggiLayar, lebarLayar),
              _inputField('Jarak', tinggiLayar, lebarLayar),
              _inputField('Luas Kamar', tinggiLayar, lebarLayar),

              // 🖼️ Input Gambar Kost
              Text(
                'Foto Kost',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: lebarLayar * 0.04,
                ),
              ),
              SizedBox(height: tinggiLayar * 0.015),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGambarPicker(
                    context,
                    'Gambar 1',
                    _gambar1,
                    () => _pilihGambar(1),
                    wajib: true,
                  ),
                  _buildGambarPicker(
                    context,
                    'Gambar 2 (Opsional)',
                    _gambar2,
                    () => _pilihGambar(2),
                  ),
                ],
              ),

              SizedBox(height: tinggiLayar * 0.04),

              // 🔹 Fasilitas
              Text(
                'Fasilitas',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: lebarLayar * 0.04,
                ),
              ),
              SizedBox(height: tinggiLayar * 0.015),

              Wrap(
                spacing: lebarLayar * 0.03,
                runSpacing: tinggiLayar * 0.015,
                children: fasilitasList.map((fasilitas) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        fasilitas['cek'] = !fasilitas['cek'];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: lebarLayar * 0.025,
                        vertical: tinggiLayar * 0.009,
                      ),
                      decoration: BoxDecoration(
                        color: fasilitas['cek']
                            ? Colors.blue.shade100
                            : Colors.white,
                        border: Border.all(
                          color: fasilitas['cek']
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            fasilitas['cek']
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: fasilitas['cek']
                                ? Colors.blue
                                : Colors.grey.shade600,
                            size: lebarLayar * 0.045,
                          ),
                          SizedBox(width: lebarLayar * 0.015),
                          Icon(
                            fasilitas['ikon'],
                            size: lebarLayar * 0.045,
                            color: Colors.grey.shade700,
                          ),
                          SizedBox(width: lebarLayar * 0.015),
                          Text(
                            fasilitas['nama'],
                            style: TextStyle(
                              fontSize: lebarLayar * 0.032,
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: tinggiLayar * 0.025),

              // GestureDetector(
              //   onTap: () => _tambahFasilitasPopup(context),
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       border: Border.all(color: Colors.blueAccent),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     padding: EdgeInsets.symmetric(
              //       horizontal: lebarLayar * 0.04,
              //       vertical: tinggiLayar * 0.014,
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         const Icon(Icons.add, color: Colors.blueAccent),
              //         SizedBox(width: lebarLayar * 0.02),
              //         const Text(
              //           "Tambah Fasilitas",
              //           style: TextStyle(
              //               color: Colors.blueAccent,
              //               fontWeight: FontWeight.w600),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              SizedBox(height: tinggiLayar * 0.05),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(lebarLayar * 0.05),
        child: SizedBox(
          height: tinggiLayar * 0.065,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: warnaTombol,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onPressed: () {
              if (_gambar1 == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text("Harap pilih minimal Gambar 1 terlebih dahulu"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
            },
            child: Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontSize: lebarLayar * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Input TextField umum
  Widget _inputField(String label, double tinggi, double lebar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: lebar * 0.035)),
        SizedBox(height: tinggi * 0.005),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: lebar * 0.04,
                vertical: tinggi * 0.018,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        SizedBox(height: tinggi * 0.025),
      ],
    );
  }

  // 🔹 Widget Pilihan Gambar Kost
  Widget _buildGambarPicker(
    BuildContext context,
    String label,
    File? file,
    VoidCallback onTap, {
    bool wajib = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: file == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image_outlined, color: Colors.grey),
                    const SizedBox(height: 6),
                    Text(
                      label + (wajib ? " *" : ""),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(file,
                      fit: BoxFit.cover, width: double.infinity),
                ),
        ),
      ),
    );
  }

  // 🔹 Popup tambah fasilitas
  // void _tambahFasilitasPopup(BuildContext context) {
  //   ikonTerpilih = null;
  //   _namaFasilitasController.clear();

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) {
  //       return Padding(
  //         padding: MediaQuery.of(context).viewInsets,
  //         child: StatefulBuilder(
  //           builder: (context, setStateBottom) {
  //             return Padding(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const Text(
  //                     "Tambah Fasilitas",
  //                     style:
  //                         TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  //                   ),
  //                   const SizedBox(height: 15),
  //                   TextField(
  //                     controller: _namaFasilitasController,
  //                     decoration: const InputDecoration(
  //                       hintText: "Nama fasilitas",
  //                       border: OutlineInputBorder(),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 15),
  //                   const Text("Pilih Ikon:"),
  //                   const SizedBox(height: 10),
  //                   Wrap(
  //                     spacing: 12,
  //                     runSpacing: 12,
  //                     children: ikonPilihan.map((ikon) {
  //                       final dipilih = ikonTerpilih == ikon;
  //                       return GestureDetector(
  //                         onTap: () {
  //                           setStateBottom(() {
  //                             ikonTerpilih = ikon;
  //                           });
  //                         },
  //                         child: Container(
  //                           decoration: BoxDecoration(
  //                             color: dipilih
  //                                 ? Colors.blueAccent.withOpacity(0.2)
  //                                 : Colors.white,
  //                             border: Border.all(
  //                               color: dipilih
  //                                   ? Colors.blueAccent
  //                                   : Colors.grey.shade300,
  //                             ),
  //                             borderRadius: BorderRadius.circular(8),
  //                           ),
  //                           padding: const EdgeInsets.all(10),
  //                           child: Icon(ikon,
  //                               color: dipilih
  //                                   ? Colors.blueAccent
  //                                   : Colors.grey.shade700),
  //                         ),
  //                       );
  //                     }).toList(),
  //                   ),
  //                   const SizedBox(height: 25),
  //                   ElevatedButton(
  //                     onPressed: () {
  //                       if (_namaFasilitasController.text.trim().isNotEmpty &&
  //                           ikonTerpilih != null) {
  //                         setState(() {
  //                           fasilitasList.add({
  //                             'nama': _namaFasilitasController.text.trim(),
  //                             'ikon': ikonTerpilih,
  //                             'cek': false,
  //                           });
  //                         });
  //                         Navigator.pop(context);
  //                       }
  //                     },
  //                     style: ElevatedButton.styleFrom(
  //                       backgroundColor: Colors.blueAccent,
  //                       minimumSize: const Size(double.infinity, 50),
  //                       shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                       ),
  //                     ),
  //                     child: const Text(
  //                       "Simpan Fasilitas",
  //                       style: TextStyle(color: Colors.white, fontSize: 16),
  //                     ),
  //                   ),
  //                   const SizedBox(height: 10),
  //                 ],
  //               ),
  //             );
  //           },
  //         ),
  //       );
  //     },
  //   );
  // }
}
