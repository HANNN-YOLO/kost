import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/kriteria_provider.dart';
import '../shared/atribut_type.dart';

class KriteriaItem {
  final int? id_kriteria;
  final int? id_auth;
  String nama;
  AtributType atribut;
  int ranking; // Ranking untuk ROC (1 = paling penting)
  double bobotDecimal; // Bobot desimal dari database (0.0 - 1.0)
  final TextEditingController bobotController;

  KriteriaItem({
    this.id_kriteria,
    this.id_auth,
    required this.nama,
    this.atribut = AtributType.Benefit,
    this.ranking = 0,
    this.bobotDecimal = 0.0,
    String bobotAwal = "0",
  }) : bobotController = TextEditingController(text: bobotAwal);

  void dispose() {
    bobotController.dispose();
  }
}

class CriteriaManagement extends StatefulWidget {
  static const arah = "/criteria-admin";

  CriteriaManagement({super.key});

  int index = 0;

  @override
  State<CriteriaManagement> createState() => _CriteriaManagementState();
}

class _CriteriaManagementState extends State<CriteriaManagement> {
  final TextEditingController _inputBaruController = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  final List<KriteriaItem> _listKriteria = [];

  int? _editingIndex;

  bool inisiasi = false;

  late Future<void> _penghubung;

  void _perbaruidata() {
    setState(() {
      inisiasi = false;
      _penghubung =
          Provider.of<KriteriaProvider>(context, listen: false).readdata();
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inisiasi = false;
    _penghubung =
        Provider.of<KriteriaProvider>(context, listen: false).readdata();
    // _perbaruidata();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // final penghubung = Provider.of<KriteriaProvider>(context, listen: false);
  //   _perbaruidata();
  // }

  @override
  void dispose() {
    _inputBaruController.dispose();
    _editController.dispose();
    for (var item in _listKriteria) {
      item.dispose();
    }
    super.dispose();
  }

  /// Warna badge ranking berdasarkan posisi prioritas
  Color _getRankingColor(int ranking) {
    switch (ranking) {
      case 1:
        return Colors.green; // Ranking 1 = Paling penting
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final penghubung = Provider.of<KriteriaProvider>(context, listen: false);

    const warnaLatar = Color(0xFFF5F7FB);
    const warnaKartu = Color(0xFFE5ECFF);

    return FutureBuilder(
      future: _penghubung,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("kesalahan inisiaisi")),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          //
          if (!inisiasi && penghubung.mydata.isNotEmpty) {
            _listKriteria.clear();

            for (int i = 0; i < penghubung.mydata.length; i++) {
              var data = penghubung.mydata[i];
              _listKriteria.add(
                KriteriaItem(
                  id_auth: data.id_auth,
                  id_kriteria: data.id_kriteria,
                  nama: data.kategori!,
                  atribut: AtributType.fromString(data.atribut!),
                  ranking: data.ranking ??
                      (i + 1), // Gunakan ranking dari DB atau urutan
                  bobotDecimal:
                      data.bobot_decimal ?? 0.0, // Ambil bobot desimal dari DB
                  bobotAwal: data.bobot.toString(),
                ),
              );
            }
            // Urutkan berdasarkan ranking
            _listKriteria.sort((a, b) => a.ranking.compareTo(b.ranking));
            inisiasi = true;
          }

          return Scaffold(
            backgroundColor: warnaLatar,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: lebarLayar * 0.05,
                  vertical: tinggiLayar * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    penghubung.mydata.isEmpty
                        ? Text(
                            "Manajemen Kriteria Kost",
                          )
                        : Text(
                            "Updated Kriteria Kost",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                    SizedBox(height: tinggiLayar * 0.03),

                    // Bagian Input Kriteria Baru
                    Text("Masukkan Kriteria",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: tinggiLayar * 0.012),

                    // _buildInputBaru(tinggiLayar, lebarLayar),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 2)
                        ],
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: lebarLayar * 0.04),
                        child: TextField(
                          controller: _inputBaruController,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Tulis nama kriteria..."),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                // Ranking baru = posisi terakhir + 1
                                final newRanking = _listKriteria.length + 1;
                                _listKriteria.add(KriteriaItem(
                                  nama: value.trim(),
                                  ranking: newRanking,
                                ));
                                _inputBaruController.clear();

                                print(
                                    "➕ Kriteria baru: ${value.trim()} (Ranking: $newRanking)");
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: tinggiLayar * 0.03),

                    // Kartu: Daftar Kriteria dengan ROC (All-in-One)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: lebarLayar * 0.04,
                          vertical: tinggiLayar * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 3)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Icon(Icons.format_list_numbered,
                                  color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text("Daftar Kriteria (ROC)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "💡 Geser untuk mengubah urutan prioritas\n"
                            "Posisi 1 = Paling Penting (bobot tertinggi)",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Divider(height: 20),

                          // ReorderableListView untuk drag & drop
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _listKriteria.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item = _listKriteria.removeAt(oldIndex);
                                _listKriteria.insert(newIndex, item);

                                // Update ranking sesuai posisi baru
                                for (int i = 0; i < _listKriteria.length; i++) {
                                  _listKriteria[i].ranking = i + 1;
                                }

                                print("\n🔄 Urutan berubah:");
                                for (var k in _listKriteria) {
                                  print("   Ranking ${k.ranking}: ${k.nama}");
                                }
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = _listKriteria[index];
                              return Container(
                                key: ValueKey(item.nama + index.toString()),
                                margin: EdgeInsets.only(
                                    bottom: tinggiLayar * 0.012),
                                padding: EdgeInsets.symmetric(
                                    vertical: tinggiLayar * 0.012,
                                    horizontal: lebarLayar * 0.03),
                                decoration: BoxDecoration(
                                  color: warnaKartu,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getRankingColor(index + 1)
                                        .withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris 1: Ranking + Nama + Actions
                                    Row(
                                      children: [
                                        // Badge Ranking
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: _getRankingColor(index + 1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${index + 1}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),

                                        // Nama Kriteria (editable)
                                        Expanded(
                                          child: _editingIndex == index
                                              ? TextField(
                                                  controller: _editController,
                                                  autofocus: true,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14),
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                  ),
                                                  onSubmitted: (val) {
                                                    setState(() {
                                                      item.nama = val.trim();
                                                      _editingIndex = null;
                                                    });
                                                  },
                                                )
                                              : Text(
                                                  item.nama,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                        ),

                                        // Action Buttons
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Edit Button
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (_editingIndex == index) {
                                                    item.nama =
                                                        _editController.text;
                                                    _editingIndex = null;
                                                  } else {
                                                    _editingIndex = index;
                                                    _editController.text =
                                                        item.nama;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Icon(
                                                  _editingIndex == index
                                                      ? Icons.check
                                                      : Icons.edit,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            // Delete Button
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _listKriteria[index]
                                                      .dispose();
                                                  if (penghubung
                                                          .mydata.isEmpty ||
                                                      item.id_kriteria ==
                                                          null) {
                                                    _listKriteria
                                                        .removeAt(index);
                                                  } else {
                                                    penghubung.deletedata(
                                                        item.id_kriteria!);
                                                    _listKriteria
                                                        .removeAt(index);
                                                  }
                                                  // Update ranking setelah hapus
                                                  for (int i = 0;
                                                      i < _listKriteria.length;
                                                      i++) {
                                                    _listKriteria[i].ranking =
                                                        i + 1;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: Colors.red
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Icon(Icons.delete,
                                                    color: Colors.red,
                                                    size: 16),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            // Drag Handle
                                            Icon(Icons.drag_handle,
                                                color: Colors.grey[500],
                                                size: 20),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 10),

                                    // Baris 2: Bobot + Atribut
                                    Row(
                                      children: [
                                        // Bobot Desimal (Read-Only)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey[400]!),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.percent,
                                                  size: 14,
                                                  color: Colors.grey[600]),
                                              SizedBox(width: 4),
                                              Text(
                                                item.bobotDecimal
                                                    .toStringAsFixed(2),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10),

                                        // Dropdown Atribut
                                        Container(
                                          height: 32,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<AtributType>(
                                              value: item.atribut,
                                              isDense: true,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                              items: [
                                                DropdownMenuItem(
                                                    value: AtributType.Benefit,
                                                    child: Text("Benefit")),
                                                DropdownMenuItem(
                                                    value: AtributType.Cost,
                                                    child: Text("Cost")),
                                              ],
                                              onChanged: (v) => setState(
                                                  () => item.atribut = v!),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Info jika kosong
                          if (_listKriteria.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  "Belum ada kriteria.\nMasukkan kriteria baru di atas.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar:
                // _buildTombolSimpan(lebarLayar, tinggiLayar, penghubung),
                Padding(
              padding: EdgeInsets.all(lebarLayar * 0.05),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, tinggiLayar * 0.065),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: () async {
                  // cara 3
                  setState(() {
                    penghubung.mydata.isEmpty
                        ? penghubung.savemassal(_listKriteria)
                        : penghubung.updatedmassal(_listKriteria);
                    // penghubung.readdata();
                    setState(() {
                      // penghubung.readdata();
                      // _perbaruidata();
                      _penghubung =
                          Provider.of<KriteriaProvider>(context, listen: false)
                              .readdata();
                    });
                  });
                },
                child: penghubung.mydata.isEmpty
                    ? Text(
                        "Simpan",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    : Text("Simpan perubahan",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: Text("pastikan terhubung sama jaringan"),
          ),
        );
      },
    );
  }
}


  // }

// tidak terpakai
  // ==========================
  // WIDGET HELPER SECTION
  // ==========================

//   Widget _buildInputBaru(double tinggi, double lebar) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: lebar * 0.04),
//         child: TextField(
//           controller: _inputBaruController,
//           decoration: InputDecoration(
//               border: InputBorder.none, hintText: "Tulis nama kriteria..."),
//           onSubmitted: (value) {
//             if (value.trim().isNotEmpty) {
//               setState(() {
//                 _listKriteria.add(KriteriaItem(nama: value.trim()));
//                 _inputBaruController.clear();
//               });
//             }
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildKriteriaCard(double lebar, double tinggi, Color warnaKartu) {
//     return _baseCard(
//       lebar,
//       tinggi,
//       "Kriteria yang ditambahkan",
//       Column(
//         children: List.generate(_listKriteria.length, (index) {
//           final item = _listKriteria[index];
//           return Padding(
//             padding: EdgeInsets.only(bottom: tinggi * 0.015),
//             child: _buildKriteriaItem(lebar, tinggi, item, warnaKartu, index),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildKriteriaItem(double lebar, double tinggi, KriteriaItem item,
//       Color warnaKartu, int index) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//           vertical: tinggi * 0.015, horizontal: lebar * 0.04),
//       decoration: BoxDecoration(
//           color: warnaKartu, borderRadius: BorderRadius.circular(10)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: _editingIndex == index
//                 ? TextField(
//                     controller: _editController,
//                     autofocus: true,
//                     decoration: InputDecoration(
//                         isDense: true, border: InputBorder.none),
//                     onSubmitted: (val) {
//                       setState(() {
//                         item.nama = val.trim();
//                         _editingIndex = null;
//                       });
//                     },
//                   )
//                 : Text(item.nama,
//                     style: TextStyle(fontWeight: FontWeight.w500)),
//           ),
//           Row(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     if (_editingIndex == index) {
//                       item.nama = _editController.text;
//                       _editingIndex = null;
//                     } else {
//                       _editingIndex = index;
//                       _editController.text = item.nama;
//                     }
//                   });
//                 },
//                 child: Icon(_editingIndex == index ? Icons.check : Icons.edit,
//                     color: Colors.green, size: 20),
//               ),
//               SizedBox(width: 15),
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _listKriteria[index].dispose();
//                     _listKriteria.removeAt(index);
//                   });
//                 },
//                 child: Icon(Icons.delete, color: Colors.red, size: 20),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildBobotCard(double lebar, double tinggi, Color warnaKartu) {
//     return _baseCard(
//       lebar,
//       tinggi,
//       "Bobot Kriteria (isi dengan angka)",
//       Column(
//         children: _listKriteria.map((item) {
//           return Padding(
//             padding: EdgeInsets.only(bottom: tinggi * 0.015),
//             child: Row(
//               children: [
//                 Expanded(
//                     child: Text(item.nama,
//                         style: TextStyle(fontWeight: FontWeight.w500))),

//                 // Dropdown Atribut
//                 // _buildDropdown(item, warnaKartu),
//                 Container(
//                   height: 35,
//                   padding: EdgeInsets.symmetric(horizontal: 8),
//                   decoration: BoxDecoration(
//                       color: warnaKartu,
//                       borderRadius: BorderRadius.circular(8)),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<AtributType>(
//                       value: item.atribut,
//                       items: [
//                         DropdownMenuItem(
//                             value: AtributType.Benefit, child: Text("Benefit")),
//                         DropdownMenuItem(
//                             value: AtributType.Cost, child: Text("Cost")),
//                       ],
//                       onChanged: (v) => setState(() => item.atribut = v!),
//                     ),
//                   ),
//                 ),

//                 SizedBox(width: 10),

//                 /// 🎯 PENEMPATAN TEXTEDITOR
//                 /// Menggunakan controller dari model item (Pola Memori)
//                 SizedBox(
//                   width: 80,
//                   height: 35,
//                   child: TextField(
//                     controller: item.bobotController,
//                     keyboardType: TextInputType.number,
//                     textAlign: TextAlign.center,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: warnaKartu,
//                       border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide.none),
//                       contentPadding: EdgeInsets.zero,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _baseCard(double lebar, double tinggi, String judul, Widget isi) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//           horizontal: lebar * 0.04, vertical: tinggi * 0.02),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 3)
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(judul,
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
//           Divider(height: 25),
//           isi,
//         ],
//       ),
//     );
//   }

//   Widget _buildDropdown(KriteriaItem item, Color warna) {
//     return Container(
//       height: 35,
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       decoration:
//           BoxDecoration(color: warna, borderRadius: BorderRadius.circular(8)),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<AtributType>(
//           value: item.atribut,
//           items: [
//             DropdownMenuItem(
//                 value: AtributType.Benefit, child: Text("Benefit")),
//             DropdownMenuItem(value: AtributType.Cost, child: Text("Cost")),
//           ],
//           onChanged: (v) => setState(() => item.atribut = v!),
//         ),
//       ),
//     );
//   }

//   Widget _buildTombolSimpan(
//       double lebar, double tinggi, KriteriaProvider prov) {
//     return Padding(
//       padding: EdgeInsets.all(lebar * 0.05),
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.black,
//           minimumSize: Size(double.infinity, tinggi * 0.065),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
//         ),
//         onPressed: () {
//           prov.savemassal(_listKriteria);
//         },
//         child: Text("Simpan",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//       ),
//     );
//   }
// }
