class Sementara {
  //
  // tidak terpakai di bagian admin place
  // void _openAddPlaceSheet(
  //   TujuanProviders penghubung,
  //   double tinggiLayar,
  //   double lebarLayar,
  // ) {
  //   // reset pesan error namun biarkan isi terakhir jika ada
  //   setState(() {
  //     _errorText = null;
  //     _nameController.clear();
  //     _coordController.clear();
  //     _isNameFilled = false;
  //     _isCoordValid = false;
  //   });

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (ctx) {
  //       final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
  //       return GestureDetector(
  //         onTap: () => FocusScope.of(ctx).unfocus(),
  //         child: BackdropFilter(
  //           filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
  //           child: Container(
  //             color: Colors.black26,
  //             padding: EdgeInsets.only(bottom: bottomInset),
  //             child: Align(
  //               alignment: Alignment.bottomCenter,
  //               child: Container(
  //                 width: double.infinity,
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: lebarLayar * 0.06,
  //                   vertical: tinggiLayar * 0.02,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: const BorderRadius.vertical(
  //                     top: Radius.circular(20),
  //                   ),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black.withOpacity(0.15),
  //                       blurRadius: 10,
  //                       offset: const Offset(0, -2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: SafeArea(
  //                   top: false,
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Center(
  //                         child: Container(
  //                           width: lebarLayar * 0.12,
  //                           height: 4,
  //                           margin: const EdgeInsets.only(bottom: 12),
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey.shade300,
  //                             borderRadius: BorderRadius.circular(50),
  //                           ),
  //                         ),
  //                       ),
  //                       Text(
  //                         'Tambah Tempat',
  //                         style: TextStyle(
  //                           fontSize: lebarLayar * 0.040,
  //                           fontWeight: FontWeight.w700,
  //                         ),
  //                       ),
  //                       SizedBox(height: tinggiLayar * 0.012),
  //                       TextField(
  //                         controller: _nameController,
  //                         decoration: const InputDecoration(
  //                           labelText: 'Nama Tempat',
  //                         ),
  //                       ),
  //                       const SizedBox(height: 12),
  //                       TextField(
  //                         controller: _coordController,
  //                         keyboardType: TextInputType.text,
  //                         decoration: const InputDecoration(
  //                           labelText: 'Titik Koordinat',
  //                           hintText: '-5.147665, 119.432731',
  //                         ),
  //                       ),
  //                       if (_errorText != null) ...[
  //                         const SizedBox(height: 8),
  //                         Text(
  //                           _errorText!,
  //                           style: const TextStyle(
  //                             color: Colors.red,
  //                             fontSize: 12,
  //                           ),
  //                         ),
  //                       ],
  //                       SizedBox(height: tinggiLayar * 0.015),
  //                       SizedBox(
  //                         height: tinggiLayar * 0.24,
  //                         child: ClipRRect(
  //                           borderRadius: BorderRadius.circular(8),
  //                           child: Stack(
  //                             children: [
  //                               WebViewWidget(controller: _mapController),
  //                               if (!_mapLoaded)
  //                                 const Center(
  //                                   child: CircularProgressIndicator(),
  //                                 ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(height: tinggiLayar * 0.018),
  //                       SizedBox(
  //                         width: double.infinity,
  //                         height: tinggiLayar * 0.055,
  //                         child: ElevatedButton(
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: _isNameFilled && _isCoordValid
  //                                 ? const Color(0xFF12111F)
  //                                 : Colors.grey.shade400,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(50),
  //                             ),
  //                           ),
  //                           onPressed: _isNameFilled && _isCoordValid
  //                               ? () {
  //                                   _onSavePlace(penghubung);
  //                                   Navigator.of(ctx).pop();
  //                                 }
  //                               : null,
  //                           child: const Text(
  //                             'Simpan Tempat',
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.w600,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _openEditPlaceSheet(
  //   TujuanProviders penghubung,
  //   double tinggiLayar,
  //   double lebarLayar,
  //   int index,
  //   // AdminPlace place,
  // ) {
  //   setState(() {
  //     // _nameController.text = place.name;
  //     // _coordController.text = '${place.lat}, ${place.lng}';
  //     _errorText = null;
  //     _isNameFilled = true;
  //     _isCoordValid = true;
  //   });

  //   if (_mapLoaded) {
  //     // _updateMapLocation(place.lat, place.lng);
  //   }

  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (ctx) {
  //       final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
  //       return GestureDetector(
  //         onTap: () => FocusScope.of(ctx).unfocus(),
  //         child: BackdropFilter(
  //           filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
  //           child: Container(
  //             color: Colors.black26,
  //             padding: EdgeInsets.only(bottom: bottomInset),
  //             child: Align(
  //               alignment: Alignment.bottomCenter,
  //               child: Container(
  //                 width: double.infinity,
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: lebarLayar * 0.06,
  //                   vertical: tinggiLayar * 0.02,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white,
  //                   borderRadius: const BorderRadius.vertical(
  //                     top: Radius.circular(20),
  //                   ),
  //                   boxShadow: [
  //                     BoxShadow(
  //                       color: Colors.black.withOpacity(0.15),
  //                       blurRadius: 10,
  //                       offset: const Offset(0, -2),
  //                     ),
  //                   ],
  //                 ),
  //                 child: SafeArea(
  //                   top: false,
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Center(
  //                         child: Container(
  //                           width: lebarLayar * 0.12,
  //                           height: 4,
  //                           margin: const EdgeInsets.only(bottom: 12),
  //                           decoration: BoxDecoration(
  //                             color: Colors.grey.shade300,
  //                             borderRadius: BorderRadius.circular(50),
  //                           ),
  //                         ),
  //                       ),
  //                       Text(
  //                         'Edit Tempat',
  //                         style: TextStyle(
  //                           fontSize: lebarLayar * 0.040,
  //                           fontWeight: FontWeight.w700,
  //                         ),
  //                       ),
  //                       SizedBox(height: tinggiLayar * 0.012),
  //                       TextField(
  //                         controller: _nameController,
  //                         decoration: const InputDecoration(
  //                           labelText: 'Nama Tempat',
  //                         ),
  //                       ),
  //                       const SizedBox(height: 12),
  //                       TextField(
  //                         controller: _coordController,
  //                         keyboardType: TextInputType.text,
  //                         decoration: const InputDecoration(
  //                           labelText: 'Titik Koordinat',
  //                           hintText: '-5.147665, 119.432731',
  //                         ),
  //                       ),
  //                       if (_errorText != null) ...[
  //                         const SizedBox(height: 8),
  //                         Text(
  //                           _errorText!,
  //                           style: const TextStyle(
  //                             color: Colors.red,
  //                             fontSize: 12,
  //                           ),
  //                         ),
  //                       ],
  //                       SizedBox(height: tinggiLayar * 0.015),
  //                       SizedBox(
  //                         height: tinggiLayar * 0.24,
  //                         child: ClipRRect(
  //                           borderRadius: BorderRadius.circular(8),
  //                           child: Stack(
  //                             children: [
  //                               WebViewWidget(controller: _mapController),
  //                               if (!_mapLoaded)
  //                                 const Center(
  //                                   child: CircularProgressIndicator(),
  //                                 ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                       SizedBox(height: tinggiLayar * 0.018),
  //                       SizedBox(
  //                         width: double.infinity,
  //                         height: tinggiLayar * 0.055,
  //                         child: ElevatedButton(
  //                           style: ElevatedButton.styleFrom(
  //                             backgroundColor: _isNameFilled && _isCoordValid
  //                                 ? const Color(0xFF12111F)
  //                                 : Colors.grey.shade400,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(50),
  //                             ),
  //                           ),
  //                           onPressed: _isNameFilled && _isCoordValid
  //                               ? () {
  //                                   _onSavePlace(
  //                                     penghubung,
  //                                     index: index,
  //                                   );
  //                                   Navigator.of(ctx).pop();
  //                                 }
  //                               : null,
  //                           child: const Text(
  //                             'Simpan Perubahan',
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontWeight: FontWeight.w600,
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // void _onSavePlace(TujuanProviders penghubung, {int? index}) {
  //   final name = _nameController.text.trim();
  //   final coord = _coordController.text.trim();

  //   final parts = coord
  //       .split(',')
  //       .map((e) => e.trim())
  //       .where((e) => e.isNotEmpty)
  //       .toList();

  //   double? lat;
  //   double? lng;

  //   if (parts.length == 2) {
  //     lat = double.tryParse(parts[0]);
  //     lng = double.tryParse(parts[1]);
  //   }

  //   if (name.isEmpty || lat == null || lng == null) {
  //     setState(() {
  //       _errorText = 'Titik koordinat tidak ditemukan';
  //     });
  //     return;
  //   }

  //   if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
  //     setState(() {
  //       _errorText = 'Titik koordinat tidak ditemukan';
  //     });
  //     return;
  //   }

  //   setState(() {
  //     _errorText = null;
  //   });

  //   _nameController.clear();
  //   _coordController.clear();
  // }

  // dibagian criteria management
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

// dibagian form house admin

  // 🔹 Widget Pilihan Gambar Kost
  // Widget _buildGambarPicker(
  //   BuildContext context,
  //   String label,
  //   File? file,
  //   VoidCallback onTap, {
  //   bool wajib = false,
  // }) {
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: onTap,
  //       child: Container(
  //         height: 120,
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           border: Border.all(color: Colors.grey.shade300, width: 1.5),
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: file == null
  //             ? Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   const Icon(Icons.image_outlined, color: Colors.grey),
  //                   const SizedBox(height: 6),
  //                   Text(
  //                     label + (wajib ? " *" : ""),
  //                     style: TextStyle(
  //                       color: Colors.grey.shade700,
  //                       fontSize: 13,
  //                     ),
  //                   ),
  //                 ],
  //               )
  //             : ClipRRect(
  //                 borderRadius: BorderRadius.circular(8),
  //                 child: Image.file(
  //                   file,
  //                   fit: BoxFit.cover,
  //                   width: double.infinity,
  //                 ),
  //               ),
  //       ),
  //     ),
  //   );
  // }

  // Helper Widget supaya tidak perlu menulis CheckboxListTile 10 kali
  // Widget _buildCheckboxItem(
  //   String label,
  //   IconData icon,
  //   bool nilai,
  //   VoidCallback onTekan,
  //   double lebar,
  //   double tinggi,
  //   bool test,
  // ) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: lebar * 0.025,
  //       vertical: tinggi * 0.009,
  //     ),
  //     decoration: BoxDecoration(
  //       color: test ? Colors.blue.shade100 : Colors.white,
  //       border: Border.all(color: test ? Colors.blue : Colors.grey.shade700),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: CheckboxListTile(
  //       title: Row(
  //         children: [
  //           Icon(icon, size: lebar * 0.045, color: Colors.grey.shade700),
  //           Text(
  //             label,
  //             style: TextStyle(
  //               fontSize: lebar * 0.032,
  //               color: Colors.black.withOpacity(0.8),
  //             ),
  //           ),
  //         ],
  //       ),
  //       // secondary: Icon(icon),
  //       value: nilai,
  //       onChanged: (value) {
  //         onTekan(); // Memanggil fungsi bool...() dari model
  //       },
  //       controlAffinity: ListTileControlAffinity.leading,
  //       contentPadding: const EdgeInsets.symmetric(
  //         horizontal: 0,
  //       ), // Sesuaikan padding
  //       dense: true, // Agar tidak terlalu renggang
  //     ),
  //   );
  // }

// Helper Widget Baru (Desain Kotak Kecil / Tags)
  // Widget _buildCustomItem(
  //   String label,
  //   IconData icon,
  //   bool nilai,
  //   VoidCallback onTekan,
  //   double lebar,
  //   double tinggi,
  // ) {
  //   return Material(
  //     color: Colors.transparent,
  //     child: InkWell(
  //       onTap: onTekan,
  //       borderRadius: BorderRadius.circular(8),
  //       child: AnimatedContainer(
  //         duration: const Duration(milliseconds: 200),
  //         padding: EdgeInsets.symmetric(
  //           horizontal: lebar * 0.03,
  //           vertical: tinggi * 0.012,
  //         ),
  //         decoration: BoxDecoration(
  //           // Logika Warna Background: Biru muda jika aktif, Putih jika tidak
  //           color: nilai ? const Color(0xFFE3F2FD) : Colors.white,
  //           borderRadius: BorderRadius.circular(8),
  //           border: Border.all(
  //             // Logika Warna Border: Biru jika aktif, Abu jika tidak
  //             color: nilai ? Colors.blue : Colors.grey.shade300,
  //             width: 1.5,
  //           ),
  //         ),
  //         child: Row(
  //           mainAxisSize:
  //               MainAxisSize.min, // PENTING: Agar lebar menyesuaikan isi teks
  //           children: [
  //             // Ikon Checkbox Manual
  //             Icon(
  //               nilai ? Icons.check_box : Icons.check_box_outline_blank,
  //               size: lebar * 0.05,
  //               color: nilai ? Colors.blue : Colors.grey.shade600,
  //             ),
  //             SizedBox(width: lebar * 0.02),

  //             // Ikon Fasilitas
  //             Icon(
  //               icon,
  //               size: lebar * 0.05,
  //               color: nilai ? Colors.blue.shade700 : Colors.grey.shade700,
  //             ),
  //             SizedBox(width: lebar * 0.02),

  //             // Teks Label
  //             Text(
  //               label,
  //               style: TextStyle(
  //                 fontSize: lebar * 0.032,
  //                 fontWeight: nilai ? FontWeight.w600 : FontWeight.normal,
  //                 color: nilai
  //                     ? Colors.blue.shade900
  //                     : Colors.black.withOpacity(0.7),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // dibagian form house pemilik
  // Widget _buildCheckboxItem(
  //   String label,
  //   IconData icon,
  //   bool nilai,
  //   VoidCallback onTekan,
  //   double lebar,
  //   double tinggi,
  //   bool test,
  // ) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: lebar * 0.025,
  //       vertical: tinggi * 0.009,
  //     ),
  //     decoration: BoxDecoration(
  //       color: test ? Colors.blue.shade100 : Colors.white,
  //       border: Border.all(
  //         color: test ? Colors.blue : Colors.grey.shade700,
  //       ),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: CheckboxListTile(
  //       title: Row(
  //         children: [
  //           Icon(
  //             icon,
  //             size: lebar * 0.045,
  //             color: Colors.grey.shade700,
  //           ),
  //           Text(
  //             label,
  //             style: TextStyle(
  //                 fontSize: lebar * 0.032,
  //                 color: Colors.black.withOpacity(0.8)),
  //           )
  //         ],
  //       ),
  //       // secondary: Icon(icon),
  //       value: nilai,
  //       onChanged: (value) {
  //         onTekan(); // Memanggil fungsi bool...() dari model
  //       },
  //       controlAffinity: ListTileControlAffinity.leading,
  //       contentPadding:
  //           const EdgeInsets.symmetric(horizontal: 0), // Sesuaikan padding
  //       dense: true, // Agar tidak terlalu renggang
  //     ),
  //   );
  // }

  // Helper Widget Baru (Desain Kotak Kecil / Tags)
  // Widget _buildCustomItem(
  //   String label,
  //   IconData icon,
  //   bool nilai,
  //   VoidCallback onTekan,
  //   double lebar,
  //   double tinggi,
  // ) {
  //   return Material(
  //     color: Colors.transparent,
  //     child: InkWell(
  //       onTap: onTekan,
  //       borderRadius: BorderRadius.circular(8),
  //       child: AnimatedContainer(
  //         duration: const Duration(milliseconds: 200),
  //         padding: EdgeInsets.symmetric(
  //           horizontal: lebar * 0.03,
  //           vertical: tinggi * 0.012,
  //         ),
  //         decoration: BoxDecoration(
  //           // Logika Warna Background: Biru muda jika aktif, Putih jika tidak
  //           color: nilai ? const Color(0xFFE3F2FD) : Colors.white,
  //           borderRadius: BorderRadius.circular(8),
  //           border: Border.all(
  //             // Logika Warna Border: Biru jika aktif, Abu jika tidak
  //             color: nilai ? Colors.blue : Colors.grey.shade300,
  //             width: 1.5,
  //           ),
  //         ),
  //         child: Row(
  //           mainAxisSize:
  //               MainAxisSize.min, // PENTING: Agar lebar menyesuaikan isi teks
  //           children: [
  //             // Ikon Checkbox Manual
  //             Icon(
  //               nilai ? Icons.check_box : Icons.check_box_outline_blank,
  //               size: lebar * 0.05,
  //               color: nilai ? Colors.blue : Colors.grey.shade600,
  //             ),
  //             SizedBox(width: lebar * 0.02),

  //             // Ikon Fasilitas
  //             Icon(
  //               icon,
  //               size: lebar * 0.05,
  //               color: nilai ? Colors.blue.shade700 : Colors.grey.shade700,
  //             ),
  //             SizedBox(width: lebar * 0.02),

  //             // Teks Label
  //             Text(
  //               label,
  //               style: TextStyle(
  //                 fontSize: lebar * 0.032,
  //                 fontWeight: nilai ? FontWeight.w600 : FontWeight.normal,
  //                 color: nilai
  //                     ? Colors.blue.shade900
  //                     : Colors.black.withOpacity(0.7),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // dibagian subkriteri management
  //   bool _operatorToInclusive(String? operator, bool isMin) {
  //   if (operator == null) return true; // Default inclusive
  //   if (isMin) {
  //     return operator == '>=' || operator == '≥';
  //   } else {
  //     return operator == '<=' || operator == '≤';
  //   }
  // }

  //   int? _tryParseIntFlexible(String raw) {
  //   // Tetap dipakai untuk angka bulat (misal harga) yang boleh ada pemisah.
  //   final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  //   if (digits.isEmpty) return null;
  //   return int.tryParse(digits);
  // }

  //   bool _rawAlreadyContainsUnit(String raw, String unit) {
  //   final u = unit.trim().toLowerCase();
  //   if (u.isEmpty) return false;
  //   final r = raw.toLowerCase();
  //   return r.contains(u);
  // }

  //   bool _looksLikeNumericRuleLabel(String raw) {
  //   final s = raw.trim().toLowerCase();
  //   if (s.isEmpty) return true;
  //   if (RegExp(r'^(<=|>=|<|>|≤|≥)').hasMatch(s)) return true;
  //   // Angka / range / angka + unit sederhana
  //   if (RegExp(r'^[0-9\s\.,\-]+(km)?$').hasMatch(s)) return true;
  //   return false;
  // }

  //   bool _isDuplicateKategori(String kandidat, {int? ignoreIndex}) {
  //   final cand = _normalizeKategoriForCompare(kandidat);
  //   if (cand.isEmpty) return false;
  //   for (final entry in _isinya.asMap().entries) {
  //     if (ignoreIndex != null && entry.key == ignoreIndex) continue;
  //     final existing = _normalizeKategoriForCompare(entry.value.kategori.text);
  //     if (existing == cand) return true;
  //   }
  //   return false;
  // }

  //   String _normalizeKategoriForCompare(String raw) {
  //   var s = raw.trim().toLowerCase();
  //   if (s.isEmpty) return '';

  //   // Samakan simbol unicode ke operator ASCII
  //   s = s.replaceAll('≤', '<=').replaceAll('≥', '>=');

  //   // Range lengkap: >= a-b
  //   final matchRange =
  //       RegExp(r'^(>=)\s*([0-9\.,\s]+)\s*-\s*([0-9\.,\s]+)\s*$').firstMatch(s);
  //   if (matchRange != null) {
  //     final a = _tryParseNumFlexible(matchRange.group(2) ?? '');
  //     final b = _tryParseNumFlexible(matchRange.group(3) ?? '');
  //     if (a != null && b != null)
  //       return '>=${_formatNumPlain(a)}-${_formatNumPlain(b)}';
  //   }

  //   // Satu sisi: <= x
  //   final matchLe = RegExp(r'^(<=)\s*([0-9\.,\s]+)\s*$').firstMatch(s);
  //   if (matchLe != null) {
  //     final x = _tryParseNumFlexible(matchLe.group(2) ?? '');
  //     if (x != null) return '<=${_formatNumPlain(x)}';
  //   }

  //   // Satu sisi: >= x
  //   final matchGe = RegExp(r'^(>=)\s*([0-9\.,\s]+)\s*$').firstMatch(s);
  //   if (matchGe != null) {
  //     final x = _tryParseNumFlexible(matchGe.group(2) ?? '');
  //     if (x != null) return '>=${_formatNumPlain(x)}';
  //   }

  //   // Angka saja
  //   final onlyNumber = RegExp(r'^\s*([0-9\.,\s]+)\s*$').firstMatch(s);
  //   if (onlyNumber != null) {
  //     final x = _tryParseNumFlexible(onlyNumber.group(1) ?? '');
  //     if (x != null) return _formatNumPlain(x);
  //   }

  //   // Fallback: rapikan spasi
  //   return s.replaceAll(RegExp(r'\s+'), ' ');
  // }

  // form house pemilik
//   class _InputField extends StatelessWidget {
//   final String label;
//   final TextEditingController controller;

//   _InputField({required this.label, required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         filled: true,
//         fillColor: const Color(0xFFF5F7FB),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }

// class _OwnerKost {
//   final String nama;
//   final String lokasi;
//   final String harga;
//   final String gambar;
//   final double pemasukanBulanIni;

//   _OwnerKost({
//     required this.nama,
//     required this.lokasi,
//     required this.harga,
//     required this.gambar,
//     required this.pemasukanBulanIni,
//   });
// }

  // 🔹 Widget Pilihan Gambar Kost
  // Widget _buildGambarPicker(
  //   BuildContext context,
  //   String label,
  //   File? file,
  //   VoidCallback onTap, {
  //   bool wajib = false,
  // }) {
  //   return Expanded(
  //     child: GestureDetector(
  //       onTap: onTap,
  //       child: Container(
  //         height: 120,
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           border: Border.all(
  //             color: Colors.grey.shade300,
  //             width: 1.5,
  //           ),
  //           borderRadius: BorderRadius.circular(10),
  //         ),
  //         child: file == null
  //             ? Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   const Icon(Icons.image_outlined, color: Colors.grey),
  //                   const SizedBox(height: 6),
  //                   Text(
  //                     label + (wajib ? " *" : ""),
  //                     style: TextStyle(
  //                       color: Colors.grey.shade700,
  //                       fontSize: 13,
  //                     ),
  //                   ),
  //                 ],
  //               )
  //             : ClipRRect(
  //                 borderRadius: BorderRadius.circular(8),
  //                 child: Image.file(file,
  //                     fit: BoxFit.cover, width: double.infinity),
  //               ),
  //       ),
  //     ),
  //   );
  // }

  //   String _formatRupiah(double value) {
  //   // Simple formatter for display only
  //   return "Rp " +
  //       value.toStringAsFixed(0).replaceAllMapped(
  //             RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
  //             (m) => "${m[1]}.",
  //           );
  // }

  // dibagian management kost pemilik

  //   void _tombolBelumTersedia() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text("Fitur belum diaktifkan"),
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

  //   String _formatRupiah(double value) {
  //   // Simple formatter for display only
  //   return "Rp " +
  //       value.toStringAsFixed(0).replaceAllMapped(
  //             RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
  //             (m) => "${m[1]}.",
  //           );
  // }

//   class _SearchBar extends StatelessWidget {
//   final TextEditingController controller;
//   final VoidCallback? onFilter;

//   _SearchBar({
//     required this.controller,
//     this.onFilter,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(width: 10),
//         Material(
//           color: Colors.transparent,
//           child: InkWell(
//             borderRadius: BorderRadius.circular(12),
//             onTap: onFilter,
//             child: Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.06),
//                     blurRadius: 6,
//                     offset: Offset(0, 3),
//                   )
//                 ],
//               ),
//               child: Icon(Icons.tune, color: Colors.black87),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _FilterChips extends StatelessWidget {
//   final int index;
//   final ValueChanged<int>? onChanged;
//   final Color warnaUtama;

//   _FilterChips({
//     required this.index,
//     required this.onChanged,
//     required this.warnaUtama,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final opsi = ["Semua", "Aktif", "Nonaktif"];
//     return SizedBox(
//       height: 36,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemBuilder: (context, i) {
//           final aktif = i == index;
//           return InkWell(
//             borderRadius: BorderRadius.circular(24),
//             onTap: () => onChanged?.call(i),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 14),
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 color: aktif ? Color(0xFFDDE6FF) : Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: aktif ? warnaUtama : Color(0xFFE6EAF2),
//                 ),
//                 boxShadow: aktif
//                     ? [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.04),
//                           blurRadius: 6,
//                           offset: Offset(0, 3),
//                         )
//                       ]
//                     : [],
//               ),
//               child: Text(
//                 opsi[i],
//                 style: TextStyle(
//                   color: aktif ? warnaUtama : Colors.black87,
//                   fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
//                 ),
//               ),
//             ),
//           );
//         },
//         separatorBuilder: (_, __) => SizedBox(width: 10),
//         itemCount: opsi.length,
//       ),
//     );
//   }
// }

// dibagian profil pemilik

  // void _toast(BuildContext context, String msg) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(msg),
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

//   class _HeaderProfile extends StatelessWidget {
//   static Color warnaUtama = Color(0xFF1E3A8A);

//   _HeaderProfile();

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final penghubung = Provider.of<AuthProvider>(context, listen: false);
//     int index = 0;

//     // return Text("halo");

//     return Stack(
//       children: [
//         // Cover gradient
//         Container(
//           height: 180,
//           width: double.infinity,
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [warnaUtama, Color(0xFF3B82F6)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         // Wave shape (simple decor)
//         Positioned(
//           right: -60,
//           top: -40,
//           child: Container(
//             width: 160,
//             height: 160,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.08),
//               shape: BoxShape.circle,
//             ),
//           ),
//         ),
//         Positioned(
//           left: -40,
//           bottom: -50,
//           child: Container(
//             width: 140,
//             height: 140,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.06),
//               shape: BoxShape.circle,
//             ),
//           ),
//         ),

//         // Content
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
//           child: Column(
//             children: [
//               SizedBox(height: 16),
//               // Title only (back icon removed)
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Profil Pemilik',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w800,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 14),

//               // Avatar + tombol ubah foto
//               Container(
//                 padding: EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       blurRadius: 10,
//                       offset: Offset(0, 6),
//                     )
//                   ],
//                 ),
//                 child: Row(
//                   children: [
//                     Stack(
//                       children: [
//                         CircleAvatar(
//                           radius: 34,
//                           backgroundColor: Color(0xFFDDE6FF),
//                           child:
//                               Icon(Icons.person, color: warnaUtama, size: 36),
//                         ),
//                         Positioned(
//                           right: 0,
//                           bottom: 0,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Container(
//                               width: 28,
//                               height: 28,
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 shape: BoxShape.circle,
//                               ),
//                               child:
//                                   Icon(Icons.edit, size: 16, color: warnaUtama),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                     SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             '${penghubung.mydata[index].username}',
//                             style: TextStyle(
//                               color: warnaUtama,
//                               fontWeight: FontWeight.w800,
//                               fontSize: 16,
//                             ),
//                           ),
//                           SizedBox(height: 6),
//                           Text(
//                             '${penghubung.mydata[index].Email}',
//                             style: TextStyle(color: Colors.black87),
//                           ),
//                         ],
//                       ),
//                     ),
//                     TextButton.icon(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('UI-only: Ubah Foto Profil')),
//                         );
//                       },
//                       style:
//                           TextButton.styleFrom(foregroundColor: Colors.white),
//                       icon: Icon(Icons.camera_alt_outlined),
//                       label: Text('Ubah Foto'),
//                     ),
//                   ],
//                 ),
//               ),

//               SizedBox(height: 16),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }

// class _SectionTitle extends StatelessWidget {
//   final String text;
//   _SectionTitle(this.text);
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style: TextStyle(
//         fontSize: 16,
//         fontWeight: FontWeight.w800,
//       ),
//     );
//   }
// }

// class _InfoFieldCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final TextEditingController controller;
//   final bool isEditing;
//   final VoidCallback onEdit;
//   final VoidCallback onCancel;

//   _InfoFieldCard({
//     required this.icon,
//     required this.label,
//     required this.controller,
//     required this.isEditing,
//     required this.onEdit,
//     required this.onCancel,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: Color(0xFFDDE6FF),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Color(0xFF1E3A8A)),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(color: Colors.black54),
//                 ),
//                 SizedBox(height: 4),
//                 if (isEditing)
//                   TextField(
//                     controller: controller,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Color(0xFFF5F7FB),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 10,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   )
//                 else
//                   Text(
//                     controller.text,
//                     style: TextStyle(
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           InkWell(
//             onTap: isEditing ? onCancel : onEdit,
//             borderRadius: BorderRadius.circular(8),
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Color(0xFF1E3A8A).withOpacity(0.25)),
//               ),
//               child: Text(
//                 isEditing ? 'Batal' : 'Ubah',
//                 style: TextStyle(
//                   color: Color(0xFF1E3A8A),
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _SwitchCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool value;
//   final void Function(bool, BuildContext) onChanged;

//   _SwitchCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 42,
//             height: 42,
//             decoration: BoxDecoration(
//               color: Color(0xFFDDE6FF),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Color(0xFF1E3A8A)),
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(fontWeight: FontWeight.w700),
//             ),
//           ),
//           Switch(
//             value: value,
//             activeColor: Color(0xFF1E3A8A),
//             onChanged: (v) => onChanged(v, context),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ActionTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final void Function(BuildContext) onTap;

//   _ActionTile({
//     required this.icon,
//     required this.label,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: Container(
//           width: 42,
//           height: 42,
//           decoration: BoxDecoration(
//             color: Color(0xFFDDE6FF),
//             shape: BoxShape.circle,
//           ),
//           child: Icon(icon, color: Color(0xFF1E3A8A)),
//         ),
//         title: Text(label, style: TextStyle(fontWeight: FontWeight.w700)),
//         trailing: Icon(Icons.chevron_right),
//         onTap: () => onTap(context),
//       ),
//     );
//   }
// }

// dibagian income pemilik
// class _SummaryCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String value;

//   const _SummaryCard({
//     required this.icon,
//     required this.title,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 46,
//             height: 46,
//             decoration: const BoxDecoration(
//               color: Color(0xFFDDE6FF),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Color(0xFF1E3A8A)),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w800,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _IncomeItemCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final Color warnaUtama;

//   const _IncomeItemCard({
//     required this.title,
//     required this.value,
//     required this.warnaUtama,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: const [
//                     Icon(Icons.payments_outlined, size: 16, color: Colors.grey),
//                     SizedBox(width: 6),
//                     Text(
//                       "Pendapatan",
//                       style: TextStyle(color: Colors.black54, fontSize: 13.5),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: const Color(0xFFDDE6FF),
//               borderRadius: BorderRadius.circular(10),
//               border: Border.all(color: warnaUtama.withOpacity(0.25)),
//             ),
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: warnaUtama,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// dibagian rekomendasi_saw
  // String _formatCurrency(int value) {
  //   final str = value.toString();
  //   final rev = str.split('').reversed.toList();
  //   final parts = <String>[];
  //   for (int i = 0; i < rev.length; i += 3) {
  //     parts.add(rev.sublist(i, (i + 3).clamp(0, rev.length)).join());
  //   }
  //   final grouped = parts.join('.').split('').reversed.join();
  //   return 'Rp $grouped';
  // }

  // dibagian rekomendasi
  //   Future<void> _promptManualCoordinate() async {
  //   final initial =
  //       _tryParseLatLng(_coordinateText) != null ? _coordinateText : '';
  //   final controller = TextEditingController(text: initial);

  //   final result = await showDialog<String>(
  //     context: context,
  //     builder: (ctx) {
  //       String? errorText;
  //       return StatefulBuilder(
  //         builder: (ctx, setState) {
  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(14),
  //             ),
  //             title: const Text('Masukkan Titik Koordinat'),
  //             content: TextField(
  //               controller: controller,
  //               keyboardType: const TextInputType.numberWithOptions(
  //                 signed: true,
  //                 decimal: true,
  //               ),
  //               decoration: InputDecoration(
  //                 hintText: 'Contoh: -5.147665, 119.432731',
  //                 errorText: errorText,
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.of(ctx).pop(),
  //                 child: const Text('Batal'),
  //               ),
  //               TextButton(
  //                 onPressed: () {
  //                   final parsed = _tryParseLatLng(controller.text.trim());
  //                   if (parsed == null) {
  //                     setState(() {
  //                       errorText =
  //                           'Format harus "lat, lng" dan nilainya valid.';
  //                     });
  //                     return;
  //                   }
  //                   Navigator.of(ctx).pop(controller.text.trim());
  //                 },
  //                 child: const Text('Simpan'),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );

  //   if (result == null) return;
  //   final parsed = _tryParseLatLng(result);
  //   if (parsed == null) return;

  //   if (!mounted) return;
  //   setState(() {
  //     _selectedLocation = _optManualKoordinat;
  //     _coordinateText = '${parsed.lat}, ${parsed.lng}';
  //   });

  //   if (_mapLoaded) {
  //     try {
  //       await _mapController.runJavaScript("clearMyLocation();");
  //       await _mapController.runJavaScript("clearDestination();");
  //       await _mapController.runJavaScript("setMode('readonly');");
  //       await _mapController.runJavaScript(
  //           "setDestinationLocation(${parsed.lat}, ${parsed.lng});");
  //       await _mapController
  //           .runJavaScript("setView(${parsed.lat}, ${parsed.lng}, 16);");
  //     } catch (_) {
  //       // ignore: map hanya sebagai tampilan
  //     }
  //   }
  // }
}
