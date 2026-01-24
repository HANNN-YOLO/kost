// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../custom/custom_dropdown_searhc_v3.dart';
// import '../../../providers/kriteria_provider.dart';

// class SubcriteriaItem {
//   final int? id_subkriteria;
//   final int? id_auth;
//   final int? id_kriteria;
//   final TextEditingController kategori;
//   final TextEditingController bobot;

//   SubcriteriaItem({
//     this.id_subkriteria,
//     this.id_auth,
//     this.id_kriteria,
//     String? kategoriawal,
//     String bobotawal = "0",
//   })  : bobot = TextEditingController(text: bobotawal),
//         kategori = TextEditingController(text: kategoriawal);

//   void dispose() {
//     bobot.dispose();
//     kategori.dispose();
//   }
// }

// class SubcriteriaManagement extends StatefulWidget {
//   static const arah = "/subcriteria-admin";
//   SubcriteriaManagement({super.key});

//   @override
//   State<SubcriteriaManagement> createState() => _SubcriteriaManagementState();
// }

// class _SubcriteriaManagementState extends State<SubcriteriaManagement> {
//   final TextEditingController namacontroller = TextEditingController();
//   final TextEditingController bobotcontroller = TextEditingController();
//   bool keadaan = true;
//   int index = 0;
//   int? editinde;

//   late Future<void> _penghubung;

//   List<SubcriteriaItem> _isinya = [];

//   // Warna dan gaya mengikuti halaman lain
//   static Color _warnaLatar = Color(0xFFF5F7FB);
//   static Color _warnaKartu = Colors.white;
//   static Color _warnaUtama = Color(0xFF1E3A8A);

//   void updatedata() {
//     setState(() {
//       keadaan = false;
//       _penghubung = Provider.of<KriteriaProvider>(context, listen: false)
//           .readdatasubkriteria();
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     // TODO: implement didChangeDependencies
//     super.didChangeDependencies();
//     keadaan = false;
//     _penghubung = Provider.of<KriteriaProvider>(context, listen: false)
//         .readdatasubkriteria();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tinggiLayar = MediaQuery.of(context).size.height;
//     final lebarLayar = MediaQuery.of(context).size.width;
//     final penghubung = Provider.of<KriteriaProvider>(context, listen: false);

//     return FutureBuilder(
//       future: _penghubung,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Scaffold(
//             body: Center(
//               child: CircularProgressIndicator(),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(
//               child: Text("Error di jaringan"),
//             ),
//           );
//         } else if (snapshot.connectionState == ConnectionState.done) {
//           if (!keadaan) {
//             _isinya.clear();
//             final cek = penghubung.mydata.firstWhereOrNull(
//                 (element) => element.kategori == penghubung.nama);

//             if (cek != null) {
//               final test = penghubung.inidata
//                   .where((element) => element.id_kriteria == cek.id_kriteria);

//               if (penghubung.inidata.isNotEmpty && !keadaan) {
//                 // _isinya.clear();
//                 for (var datanya in test) {
//                   _isinya.add(
//                     SubcriteriaItem(
//                       id_auth: datanya.id_auth,
//                       id_kriteria: datanya.id_kriteria,
//                       id_subkriteria: datanya.id_subkriteria,
//                       kategoriawal: datanya.kategori,
//                       bobotawal: datanya.bobot.toString(),
//                     ),
//                   );
//                 }
//               }
//             }
//             keadaan = true;
//           }

//           return Scaffold(
//             backgroundColor: _warnaLatar,
//             body: SafeArea(
//               child: Padding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: lebarLayar * 0.05,
//                   vertical: tinggiLayar * 0.02,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header + tombol tambah
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         penghubung.inidata.isEmpty
//                             ? Text(
//                                 "Tambah Subkriteria SAW",
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w800,
//                                   color: Colors.black,
//                                 ),
//                               )
//                             : Text(
//                                 "Update Subkriteria SAW",
//                                 style: TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w800,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                         Material(
//                           color: Colors.transparent,
//                           child: InkWell(
//                             borderRadius: BorderRadius.circular(6),
//                             // onTap: _bukaFormTambah,
//                             onTap: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (_) => AlertDialog(
//                                   shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(16)),
//                                   title: Text(
//                                     "Tambah Subkriteria",
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   content: SizedBox(
//                                     width: 420,
//                                     child: Column(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         TextField(
//                                           controller: namacontroller,
//                                           decoration: InputDecoration(
//                                             labelText: "Nama Subkriteria",
//                                             filled: true,
//                                             fillColor: Color(0xFFF5F7FB),
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                           ),
//                                         ),
//                                         SizedBox(height: 12),
//                                         TextField(
//                                           controller: bobotcontroller,
//                                           keyboardType: TextInputType.number,
//                                           decoration: InputDecoration(
//                                             labelText: "Bobot (0-1)",
//                                             filled: true,
//                                             fillColor: Color(0xFFF5F7FB),
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               borderSide: BorderSide.none,
//                                             ),
//                                           ),
//                                         ),
//                                         // Atribut dihilangkan dari form sesuai permintaan
//                                       ],
//                                     ),
//                                   ),
//                                   actions: [
//                                     TextButton(
//                                       onPressed: () {
//                                         Navigator.pop(context);
//                                       },
//                                       child: Text("Batal"),
//                                     ),
//                                     TextButton(
//                                       style: TextButton.styleFrom(
//                                         // backgroundColor: _warnaUtama,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(10),
//                                         ),
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           final cek = penghubung.mydata
//                                               .firstWhereOrNull((element) =>
//                                                   element.kategori ==
//                                                   penghubung.nama);

//                                           _isinya.add(
//                                             SubcriteriaItem(
//                                               // kategori: _isinya[index].kategori,
//                                               // bobot: _isinya[index].bobot,
//                                               id_auth: penghubung.id_auth,
//                                               id_kriteria: cek?.id_kriteria,
//                                               kategoriawal: namacontroller.text,
//                                               bobotawal: bobotcontroller.text,
//                                             ),
//                                           );
//                                           namacontroller.clear();
//                                           bobotcontroller.clear();
//                                           Navigator.pop(context);
//                                         });
//                                       },
//                                       child: Text(
//                                         "Simpan",
//                                         style: TextStyle(color: _warnaUtama),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                             child: Container(
//                               width: lebarLayar * 0.09,
//                               height: lebarLayar * 0.09,
//                               decoration: BoxDecoration(
//                                 color: _warnaKartu,
//                                 borderRadius: BorderRadius.circular(6),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.black.withOpacity(0.05),
//                                     blurRadius: 3,
//                                     offset: Offset(0, 2),
//                                   ),
//                                 ],
//                               ),
//                               child: Icon(Icons.add, color: Colors.black87),
//                             ),
//                           ),
//                         )
//                       ],
//                     ),

//                     SizedBox(height: tinggiLayar * 0.03),

//                     // Ringkasan
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: lebarLayar * 0.04,
//                               vertical: lebarLayar * 0.03,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.05),
//                                   blurRadius: 3,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: lebarLayar * 0.10,
//                                   height: lebarLayar * 0.10,
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFDDE6FF),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(Icons.category_outlined,
//                                       color: Color(0xFF1E3A8A)),
//                                 ),
//                                 SizedBox(width: lebarLayar * 0.04),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Terpilih",
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         penghubung.nama!,
//                                         // _selectedKriteria,
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: lebarLayar * 0.04),
//                         Expanded(
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: lebarLayar * 0.04,
//                               vertical: lebarLayar * 0.03,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.05),
//                                   blurRadius: 3,
//                                   offset: Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: lebarLayar * 0.10,
//                                   height: lebarLayar * 0.10,
//                                   decoration: BoxDecoration(
//                                     color: Color(0xFFDDE6FF),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: Icon(Icons.list_alt_outlined,
//                                       color: Color(0xFF1E3A8A)),
//                                 ),
//                                 SizedBox(width: lebarLayar * 0.04),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         "Subkriteria",
//                                         style: TextStyle(
//                                           fontSize: 15,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         "${_isinya.length}",
//                                         // _query,
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: tinggiLayar * 0.03),

//                     // Kartu pilih kriteria
//                     // _buildPilihKriteriaCard(lebarLayar, tinggiLayar),
//                     Container(
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: _warnaKartu,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 3,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: lebarLayar * 0.04,
//                           vertical: tinggiLayar * 0.02,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               "Pilih Kriteria",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 15,
//                                 color: Colors.black,
//                               ),
//                             ),
//                             SizedBox(height: tinggiLayar * 0.012),
//                             //

//                             CustomDropdownSearchv3(
//                               manalistnya: penghubung.kategoriall,
//                               label: "PIlih",
//                               pilihan: penghubung.nama!,
//                               fungsi: (value) {
//                                 penghubung.pilihkriteria(value);
//                                 setState(() {
//                                   keadaan = false;
//                                 });
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: tinggiLayar * 0.02),

//                     // Kartu tabel subkriteria
//                     Expanded(
//                       child:
//                           // _buildTabelCard(lebarLayar, tinggiLayar, items),
//                           Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: _warnaKartu,
//                           borderRadius: BorderRadius.circular(12),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 3,
//                               offset: Offset(0, 2),
//                             ),
//                           ],
//                         ),
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: lebarLayar * 0.02,
//                             vertical: tinggiLayar * 0.015,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       "Daftar Subkriteria",
//                                       style: TextStyle(
//                                         fontWeight: FontWeight.w600,
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                     child: TextField(
//                                       decoration: InputDecoration(
//                                         hintText: "Cari subkriteria...",
//                                         isDense: true,
//                                         filled: true,
//                                         fillColor: Colors.white,
//                                         border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                           borderSide: BorderSide(
//                                               color: Colors.grey.shade300),
//                                         ),
//                                         contentPadding: EdgeInsets.symmetric(
//                                             horizontal: 10, vertical: 8),
//                                       ),
//                                       onChanged: (v) =>
//                                           setState(() => penghubung.nama = v),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: tinggiLayar * 0.015),
//                               Container(height: 1, color: Colors.grey.shade300),
//                               SizedBox(height: tinggiLayar * 0.015),
//                               Consumer<KriteriaProvider>(
//                                 builder: (context, value, child) {
//                                   final cek = penghubung.mydata
//                                       .firstWhereOrNull((element) =>
//                                           element.kategori == penghubung.nama);

//                                   final test = penghubung.inidata.where(
//                                       (element) =>
//                                           element.id_kriteria ==
//                                           cek?.id_kriteria);

//                                   return Expanded(
//                                     child: test.isEmpty
//                                         // data awal
//                                         ? ListView.separated(
//                                             itemCount: _isinya.length,
//                                             separatorBuilder:
//                                                 (context, index) => SizedBox(
//                                                     height:
//                                                         tinggiLayar * 0.012),
//                                             itemBuilder: (context, index) {
//                                               return Container(
//                                                 width: double.infinity,
//                                                 // color: Color(0xFFE9F0FF),
//                                                 padding: EdgeInsets.symmetric(
//                                                   vertical: tinggiLayar * 0.018,
//                                                   horizontal: lebarLayar * 0.04,
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   // color: _warnaKartu,
//                                                   color: Color(0xFFE9F0FF),
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.black
//                                                           .withOpacity(0.04),
//                                                       blurRadius: 4,
//                                                       offset: Offset(0, 2),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Text(
//                                                             _isinya[index]
//                                                                 .kategori
//                                                                 .text,
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.black,
//                                                               fontSize: 15,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                             ),
//                                                           ),
//                                                           SizedBox(height: 6),
//                                                           Row(
//                                                             children: [
//                                                               Container(
//                                                                 padding: EdgeInsets
//                                                                     .symmetric(
//                                                                   horizontal:
//                                                                       10,
//                                                                   vertical: 6,
//                                                                 ),
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               8),
//                                                                 ),
//                                                                 child: Text(
//                                                                   "Bobot : ${_isinya[index].bobot.text}",
//                                                                   style:
//                                                                       TextStyle(
//                                                                     color: Colors
//                                                                         .black87,
//                                                                     fontSize:
//                                                                         13.5,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w500,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     Row(
//                                                       children: [
//                                                         IconButton(
//                                                           onPressed: () {
//                                                             setState(() {
//                                                               editinde = index;
//                                                               namacontroller
//                                                                       .text =
//                                                                   "${_isinya[index].kategori.text}";
//                                                               bobotcontroller
//                                                                       .text =
//                                                                   "${_isinya[index].bobot.text}";
//                                                             });

//                                                             showDialog(
//                                                               context: context,
//                                                               builder: (_) =>
//                                                                   AlertDialog(
//                                                                 shape: RoundedRectangleBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             16)),
//                                                                 title: Text(
//                                                                   "Tambah Subkriteria",
//                                                                   style: TextStyle(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold),
//                                                                 ),
//                                                                 content:
//                                                                     SizedBox(
//                                                                   width: 420,
//                                                                   child: Column(
//                                                                     mainAxisSize:
//                                                                         MainAxisSize
//                                                                             .min,
//                                                                     children: [
//                                                                       TextField(
//                                                                         controller:
//                                                                             namacontroller,
//                                                                         decoration:
//                                                                             InputDecoration(
//                                                                           labelText:
//                                                                               "Nama Subkriteria",
//                                                                           filled:
//                                                                               true,
//                                                                           fillColor:
//                                                                               Color(0xFFF5F7FB),
//                                                                           border:
//                                                                               OutlineInputBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10),
//                                                                             borderSide:
//                                                                                 BorderSide.none,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       SizedBox(
//                                                                           height:
//                                                                               12),
//                                                                       TextField(
//                                                                         controller:
//                                                                             bobotcontroller,
//                                                                         keyboardType:
//                                                                             TextInputType.number,
//                                                                         decoration:
//                                                                             InputDecoration(
//                                                                           labelText:
//                                                                               "Bobot (0-1)",
//                                                                           filled:
//                                                                               true,
//                                                                           fillColor:
//                                                                               Color(0xFFF5F7FB),
//                                                                           border:
//                                                                               OutlineInputBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10),
//                                                                             borderSide:
//                                                                                 BorderSide.none,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       // Atribut dihilangkan dari form sesuai permintaan
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 actions: [
//                                                                   TextButton(
//                                                                     onPressed:
//                                                                         () {
//                                                                       Navigator.pop(
//                                                                           context);
//                                                                     },
//                                                                     child: Text(
//                                                                         "Batal"),
//                                                                   ),
//                                                                   TextButton(
//                                                                     style: TextButton
//                                                                         .styleFrom(
//                                                                       // backgroundColor: _warnaUtama,
//                                                                       shape:
//                                                                           RoundedRectangleBorder(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(10),
//                                                                       ),
//                                                                     ),
//                                                                     onPressed:
//                                                                         () {
//                                                                       setState(
//                                                                           () {
//                                                                         if (editinde ==
//                                                                             null) {
//                                                                           final cek = penghubung.mydata.firstWhereOrNull((element) =>
//                                                                               element.kategori ==
//                                                                               penghubung.nama);

//                                                                           _isinya
//                                                                               .add(
//                                                                             SubcriteriaItem(
//                                                                               // kategori: _isinya[index].kategori,
//                                                                               // bobot: _isinya[index].bobot,
//                                                                               id_auth: penghubung.id_auth,
//                                                                               id_kriteria: cek?.id_kriteria,
//                                                                               kategoriawal: namacontroller.text,
//                                                                               bobotawal: bobotcontroller.text,
//                                                                             ),
//                                                                           );
//                                                                         } else {
//                                                                           _isinya[editinde!]
//                                                                               .kategori
//                                                                               .text = namacontroller.text;
//                                                                           _isinya[editinde!]
//                                                                               .bobot
//                                                                               .text = bobotcontroller.text;
//                                                                         }
//                                                                         namacontroller
//                                                                             .clear();
//                                                                         bobotcontroller
//                                                                             .clear();
//                                                                         Navigator.pop(
//                                                                             context);
//                                                                       });
//                                                                     },
//                                                                     child: Text(
//                                                                       "Simpan",
//                                                                       style: TextStyle(
//                                                                           color:
//                                                                               _warnaUtama),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             );
//                                                           },
//                                                           icon: Icon(
//                                                             Icons.edit,
//                                                             color: Colors.green,
//                                                             size: lebarLayar *
//                                                                 0.060,
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             width: lebarLayar *
//                                                                 0.015),
//                                                         IconButton(
//                                                           onPressed: () async {
//                                                             setState(() {
//                                                               _isinya.removeAt(
//                                                                   index);
//                                                               penghubung
//                                                                   .readdatasubkriteria();
//                                                             });
//                                                           },
//                                                           icon: Icon(
//                                                             Icons.delete,
//                                                             color: Colors.red,
//                                                             size: lebarLayar *
//                                                                 0.060,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           )
//                                         :
//                                         // data siap di update
//                                         ListView.separated(
//                                             itemCount: _isinya.length,
//                                             separatorBuilder:
//                                                 (context, index) => SizedBox(
//                                                     height:
//                                                         tinggiLayar * 0.012),
//                                             itemBuilder: (context, index) {
//                                               return Container(
//                                                 width: double.infinity,
//                                                 // color: Color(0xFFE9F0FF),
//                                                 padding: EdgeInsets.symmetric(
//                                                   vertical: tinggiLayar * 0.018,
//                                                   horizontal: lebarLayar * 0.04,
//                                                 ),
//                                                 decoration: BoxDecoration(
//                                                   // color: _warnaKartu,
//                                                   color: Color(0xFFE9F0FF),
//                                                   borderRadius:
//                                                       BorderRadius.circular(10),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.black
//                                                           .withOpacity(0.04),
//                                                       blurRadius: 4,
//                                                       offset: Offset(0, 2),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment
//                                                           .spaceBetween,
//                                                   children: [
//                                                     Expanded(
//                                                       child: Column(
//                                                         crossAxisAlignment:
//                                                             CrossAxisAlignment
//                                                                 .start,
//                                                         children: [
//                                                           Text(
//                                                             _isinya[index]
//                                                                 .kategori
//                                                                 .text,
//                                                             style: TextStyle(
//                                                               color:
//                                                                   Colors.black,
//                                                               fontSize: 15,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w600,
//                                                             ),
//                                                           ),
//                                                           SizedBox(height: 6),
//                                                           Row(
//                                                             children: [
//                                                               Container(
//                                                                 padding: EdgeInsets
//                                                                     .symmetric(
//                                                                   horizontal:
//                                                                       10,
//                                                                   vertical: 6,
//                                                                 ),
//                                                                 decoration:
//                                                                     BoxDecoration(
//                                                                   color: Colors
//                                                                       .white,
//                                                                   borderRadius:
//                                                                       BorderRadius
//                                                                           .circular(
//                                                                               8),
//                                                                 ),
//                                                                 child: Text(
//                                                                   "Bobot : ${_isinya[index].bobot.text}",
//                                                                   style:
//                                                                       TextStyle(
//                                                                     color: Colors
//                                                                         .black87,
//                                                                     fontSize:
//                                                                         13.5,
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .w500,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ],
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                     Row(
//                                                       children: [
//                                                         IconButton(
//                                                           onPressed: () {
//                                                             namacontroller
//                                                                     .text =
//                                                                 "${_isinya[index].kategori.text}";
//                                                             bobotcontroller
//                                                                     .text =
//                                                                 "${_isinya[index].bobot.text}";
//                                                             showDialog(
//                                                               context: context,
//                                                               builder: (_) =>
//                                                                   AlertDialog(
//                                                                 shape: RoundedRectangleBorder(
//                                                                     borderRadius:
//                                                                         BorderRadius.circular(
//                                                                             16)),
//                                                                 title: Text(
//                                                                   "Update Subkriteria",
//                                                                   style: TextStyle(
//                                                                       fontWeight:
//                                                                           FontWeight
//                                                                               .bold),
//                                                                 ),
//                                                                 content:
//                                                                     SizedBox(
//                                                                   width: 420,
//                                                                   child: Column(
//                                                                     mainAxisSize:
//                                                                         MainAxisSize
//                                                                             .min,
//                                                                     children: [
//                                                                       TextField(
//                                                                         controller:
//                                                                             namacontroller,
//                                                                         decoration:
//                                                                             InputDecoration(
//                                                                           labelText:
//                                                                               "Nama Subkriteria",
//                                                                           filled:
//                                                                               true,
//                                                                           fillColor:
//                                                                               Color(0xFFF5F7FB),
//                                                                           border:
//                                                                               OutlineInputBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10),
//                                                                             borderSide:
//                                                                                 BorderSide.none,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       SizedBox(
//                                                                           height:
//                                                                               12),
//                                                                       TextField(
//                                                                         controller:
//                                                                             bobotcontroller,
//                                                                         keyboardType:
//                                                                             TextInputType.number,
//                                                                         decoration:
//                                                                             InputDecoration(
//                                                                           labelText:
//                                                                               "Bobot (0-1)",
//                                                                           filled:
//                                                                               true,
//                                                                           fillColor:
//                                                                               Color(0xFFF5F7FB),
//                                                                           border:
//                                                                               OutlineInputBorder(
//                                                                             borderRadius:
//                                                                                 BorderRadius.circular(10),
//                                                                             borderSide:
//                                                                                 BorderSide.none,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                       // Atribut dihilangkan dari form sesuai permintaan
//                                                                     ],
//                                                                   ),
//                                                                 ),
//                                                                 actions: [
//                                                                   TextButton(
//                                                                     onPressed:
//                                                                         () {
//                                                                       Navigator.pop(
//                                                                           context);
//                                                                     },
//                                                                     child: Text(
//                                                                         "Batal"),
//                                                                   ),
//                                                                   TextButton(
//                                                                     style: TextButton
//                                                                         .styleFrom(
//                                                                       // backgroundColor: _warnaUtama,
//                                                                       shape:
//                                                                           RoundedRectangleBorder(
//                                                                         borderRadius:
//                                                                             BorderRadius.circular(10),
//                                                                       ),
//                                                                     ),
//                                                                     onPressed:
//                                                                         () {
//                                                                       setState(
//                                                                           () {
//                                                                         final cek = penghubung.mydata.firstWhereOrNull((element) =>
//                                                                             element.kategori ==
//                                                                             penghubung.nama);

//                                                                         _isinya
//                                                                             .add(
//                                                                           SubcriteriaItem(
//                                                                             // kategori: _isinya[index].kategori,
//                                                                             // bobot: _isinya[index].bobot,
//                                                                             id_auth:
//                                                                                 penghubung.id_auth,
//                                                                             id_kriteria:
//                                                                                 cek?.id_kriteria,
//                                                                             kategoriawal:
//                                                                                 namacontroller.text,
//                                                                             bobotawal:
//                                                                                 bobotcontroller.text,
//                                                                           ),
//                                                                         );
//                                                                         namacontroller
//                                                                             .clear();
//                                                                         bobotcontroller
//                                                                             .clear();
//                                                                         Navigator.pop(
//                                                                             context);
//                                                                       });
//                                                                     },
//                                                                     child: Text(
//                                                                       "Simpan Perubahan",
//                                                                       style: TextStyle(
//                                                                           color:
//                                                                               _warnaUtama),
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             );
//                                                           },
//                                                           icon: Icon(
//                                                             Icons.edit,
//                                                             color: Colors.green,
//                                                             size: lebarLayar *
//                                                                 0.060,
//                                                           ),
//                                                         ),
//                                                         SizedBox(
//                                                             width: lebarLayar *
//                                                                 0.015),
//                                                         IconButton(
//                                                           onPressed: () async {
//                                                             setState(() {
//                                                               penghubung.deletedatasubkriteria(
//                                                                   penghubung
//                                                                       .inidata[
//                                                                           index]
//                                                                       .id_subkriteria!);
//                                                               _isinya.removeAt(
//                                                                   index);
//                                                             });
//                                                           },
//                                                           icon: Icon(
//                                                             Icons.delete,
//                                                             color: Colors.red,
//                                                             size: lebarLayar *
//                                                                 0.060,
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             },
//                                           ),
//                                   );
//                                 },
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             bottomNavigationBar: Padding(
//               padding: EdgeInsets.all(lebarLayar * 0.05),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     minimumSize: Size(double.infinity, tinggiLayar * 0.065),
//                     shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(50))),
//                 onPressed: () async {
//                   penghubung.inidata.isEmpty
//                       ? penghubung.savemassalsubkriteria(_isinya)
//                       : penghubung.updatedmassalsubkriteria(_isinya);
//                 },
//                 child: penghubung.inidata.isEmpty
//                     ? Text(
//                         "Simpan Data",
//                         style: TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.bold),
//                       )
//                     : Text(
//                         "Simpan Perubahan Data",
//                         style: TextStyle(
//                             color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//               ),
//             ),
//           );
//         } else {
//           return Scaffold(
//             body: Center(
//               child: Text("Kesalahan Jaringan"),
//             ),
//           );
//         }
//       },
//     );
//   }
// }

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custom/custom_dropdown_searhc_v3.dart';
import '../../../providers/kriteria_provider.dart';

class SubcriteriaItem {
  final int? id_subkriteria;
  final int? id_auth;
  final int? id_kriteria;
  final TextEditingController kategori;
  final TextEditingController bobot;

  SubcriteriaItem({
    this.id_subkriteria,
    this.id_auth,
    this.id_kriteria,
    String? kategoriawal,
    String bobotawal = "0",
  })  : bobot = TextEditingController(text: bobotawal),
        kategori = TextEditingController(text: kategoriawal);

  void dispose() {
    bobot.dispose();
    kategori.dispose();
  }
}

class SubcriteriaManagement extends StatefulWidget {
  static const arah = "/subcriteria-admin";
  SubcriteriaManagement({super.key});

  @override
  State<SubcriteriaManagement> createState() => _SubcriteriaManagementState();
}

class _SubcriteriaManagementState extends State<SubcriteriaManagement> {
  final TextEditingController namacontroller = TextEditingController();
  final TextEditingController bobotcontroller = TextEditingController();
  bool keadaan = true;
  int index = 0;
  int? editinde; // Variabel penanda: null = Tambah, angka = Edit index tersebut

  late Future<void> _penghubung;
  List<SubcriteriaItem> _isinya = [];
  bool _isInitialized = false; // Flag untuk memastikan hanya dipanggil sekali

  // Flag perubahan & loading untuk tombol simpan
  bool _hasChanges = false;
  bool _isSaving = false;

  static Color _warnaLatar = Color(0xFFF5F7FB);
  static Color _warnaKartu = Colors.white;
  static Color _warnaUtama = Color(0xFF1E3A8A);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hanya panggil sekali saat pertama kali masuk halaman
    if (!_isInitialized) {
      _isInitialized = true;
      keadaan = false;
      _penghubung = Provider.of<KriteriaProvider>(context, listen: false)
          .readdatasubkriteria();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final penghubung = Provider.of<KriteriaProvider>(context, listen: false);

    return FutureBuilder(
      future: _penghubung,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error di jaringan")),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          // --- LOGIKA SINKRONISASI DATA ( DATABASE KE LIST UI ) ---
          if (!keadaan) {
            _isinya.clear();
            // Jika belum ada kriteria terpilih, pilih otomatis kriteria pertama.
            // Gunakan post-frame callback agar tidak memanggil notifyListeners
            // (melalui pilihkriteria) langsung saat build FutureBuilder.
            if ((penghubung.nama == null || penghubung.nama!.isEmpty) &&
                penghubung.kategoriall.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                // Cek lagi untuk menghindari pemanggilan ganda jika state sudah berubah.
                if ((penghubung.nama == null || penghubung.nama!.isEmpty) &&
                    penghubung.kategoriall.isNotEmpty) {
                  penghubung.pilihkriteria(penghubung.kategoriall.first);
                }
              });
            }

            final kriteriaTerpilih = penghubung.mydata.firstWhereOrNull(
                (element) => element.kategori == penghubung.nama);

            if (kriteriaTerpilih != null) {
              final dataDbTerfilter = penghubung.inidata.where((element) =>
                  element.id_kriteria == kriteriaTerpilih.id_kriteria);

              for (var datanya in dataDbTerfilter) {
                _isinya.add(
                  SubcriteriaItem(
                    id_auth: datanya.id_auth,
                    id_kriteria: datanya.id_kriteria,
                    id_subkriteria: datanya.id_subkriteria,
                    kategoriawal: datanya.kategori,
                    bobotawal: datanya.bobot.toString(),
                  ),
                );
              }
            }
            keadaan =
                true; // Dikunci agar saat klik Simpan/Tambah, list lokal tidak dihapus
            // Setelah sinkron dari database, anggap tidak ada perubahan lokal
            _hasChanges = false;
          }

          return Scaffold(
            backgroundColor: _warnaLatar,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: lebarLayar * 0.05,
                  vertical: tinggiLayar * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          penghubung.inidata.isEmpty
                              ? "Tambah Subkriteria SAW"
                              : "Update Subkriteria SAW",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              // MODE TAMBAH
                              editinde = null;
                              namacontroller.clear();
                              bobotcontroller.clear();

                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  title: Text("Tambah Subkriteria",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: namacontroller,
                                        decoration: InputDecoration(
                                            labelText: "Nama Subkriteria",
                                            filled: true,
                                            fillColor: Color(0xFFF5F7FB),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide.none)),
                                      ),
                                      SizedBox(height: 12),
                                      TextField(
                                        controller: bobotcontroller,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                            labelText: "Bobot (0-1)",
                                            filled: true,
                                            fillColor: Color(0xFFF5F7FB),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                borderSide: BorderSide.none)),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Batal")),
                                    TextButton(
                                      onPressed: () {
                                        final namaBaru =
                                            namacontroller.text.trim();
                                        final bobotRaw =
                                            bobotcontroller.text.trim();
                                        final bobotParsed = double.tryParse(
                                            bobotRaw.replaceAll(',', '.'));

                                        if (namaBaru.isEmpty ||
                                            bobotParsed == null) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Nama dan bobot wajib diisi dengan benar.'),
                                            ),
                                          );
                                          return;
                                        }

                                        if (bobotParsed <= 0) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Bobot subkriteria tidak boleh 0 atau negatif.'),
                                            ),
                                          );
                                          return;
                                        }

                                        final sudahAdaBobotSama = _isinya.any(
                                            (item) =>
                                                double.tryParse(item.bobot.text
                                                    .trim()
                                                    .replaceAll(',', '.')) ==
                                                bobotParsed);

                                        if (sudahAdaBobotSama) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Bobot subkriteria tidak boleh ada yang sama.'),
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() {
                                          final kSekarang = penghubung.mydata
                                              .firstWhereOrNull((element) =>
                                                  element.kategori ==
                                                  penghubung.nama);

                                          _isinya.add(SubcriteriaItem(
                                            id_auth: penghubung.id_auth,
                                            id_kriteria: kSekarang?.id_kriteria,
                                            kategoriawal: namaBaru,
                                            bobotawal: bobotRaw,
                                          ));
                                          namacontroller.clear();
                                          bobotcontroller.clear();
                                          _hasChanges = true;
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: Text("Simpan",
                                          style: TextStyle(color: _warnaUtama)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: lebarLayar * 0.09,
                              height: lebarLayar * 0.09,
                              decoration: BoxDecoration(
                                  color: _warnaKartu,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: Offset(0, 2))
                                  ]),
                              child: Icon(Icons.add, color: Colors.black87),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: tinggiLayar * 0.03),
                    // Ringkasan
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 3,
                                      offset: Offset(0, 2))
                                ]),
                            child: Row(
                              children: [
                                CircleAvatar(
                                    backgroundColor: Color(0xFFDDE6FF),
                                    child: Icon(Icons.category_outlined,
                                        color: Color(0xFF1E3A8A))),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Terpilih",
                                          style: TextStyle(fontSize: 15)),
                                      Text(
                                        penghubung.nama!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: lebarLayar * 0.04),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 3,
                                      offset: Offset(0, 2))
                                ]),
                            child: Row(
                              children: [
                                CircleAvatar(
                                    backgroundColor: Color(0xFFDDE6FF),
                                    child: Icon(Icons.list_alt_outlined,
                                        color: Color(0xFF1E3A8A))),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Subkriteria",
                                        style: TextStyle(fontSize: 15)),
                                    Text("${_isinya.length}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tinggiLayar * 0.03),
                    // Card Dropdown
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(lebarLayar * 0.04),
                      decoration: BoxDecoration(
                          color: _warnaKartu,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: Offset(0, 2))
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pilih Kriteria",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: tinggiLayar * 0.012),
                          CustomDropdownSearchv3(
                            manalistnya: penghubung.kategoriall,
                            label: "Pilih",
                            pilihan: penghubung.nama!,
                            fungsi: (value) {
                              penghubung.pilihkriteria(value);
                              setState(() {
                                keadaan =
                                    false; // Buka kunci keadaan agar load data kriteria baru
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: tinggiLayar * 0.02),
                    // Tabel Daftar Subkriteria
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: _warnaKartu,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 3,
                                  offset: Offset(0, 2))
                            ]),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text("Daftar Subkriteria",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600))),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Cari...",
                                      isDense: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            Expanded(
                              child: _isinya.isEmpty
                                  ? Center(child: Text("Belum ada subkriteria"))
                                  : ListView.separated(
                                      itemCount: _isinya.length,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(height: 10),
                                      itemBuilder: (context, idx) {
                                        return Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFE9F0FF),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      _isinya[idx]
                                                          .kategori
                                                          .text,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      "Bobot : ${_isinya[idx].bobot.text}"),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                      icon: Icon(Icons.edit,
                                                          color: Colors.green),
                                                      onPressed: () {
                                                        // --- LOGIKA EDIT BERDASARKAN INDEX ---
                                                        setState(() {
                                                          editinde = idx;
                                                          namacontroller.text =
                                                              _isinya[idx]
                                                                  .kategori
                                                                  .text;
                                                          bobotcontroller.text =
                                                              _isinya[idx]
                                                                  .bobot
                                                                  .text;
                                                        });
                                                        // Tampilkan dialog yang sama
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              AlertDialog(
                                                            title: Text(
                                                                "Update Subkriteria"),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                TextField(
                                                                    controller:
                                                                        namacontroller,
                                                                    decoration: InputDecoration(
                                                                        labelText:
                                                                            "Nama")),
                                                                TextField(
                                                                    controller:
                                                                        bobotcontroller,
                                                                    decoration: InputDecoration(
                                                                        labelText:
                                                                            "Bobot")),
                                                              ],
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  child: Text(
                                                                      "Batal")),
                                                              TextButton(
                                                                onPressed: () {
                                                                  final namaBaru =
                                                                      namacontroller
                                                                          .text
                                                                          .trim();
                                                                  final bobotRaw =
                                                                      bobotcontroller
                                                                          .text
                                                                          .trim();
                                                                  final bobotParsed =
                                                                      double.tryParse(bobotRaw.replaceAll(
                                                                          ',',
                                                                          '.'));

                                                                  if (namaBaru
                                                                          .isEmpty ||
                                                                      bobotParsed ==
                                                                          null) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            Text('Nama dan bobot wajib diisi dengan benar.'),
                                                                      ),
                                                                    );
                                                                    return;
                                                                  }

                                                                  if (bobotParsed <=
                                                                      0) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Text('Bobot subkriteria tidak boleh 0 atau negatif.'),
                                                                      ),
                                                                    );
                                                                    return;
                                                                  }

                                                                  final sudahAdaBobotSama = _isinya
                                                                      .asMap()
                                                                      .entries
                                                                      .any(
                                                                          (entry) {
                                                                    if (entry
                                                                            .key ==
                                                                        editinde) {
                                                                      return false;
                                                                    }
                                                                    final v = double.tryParse(entry
                                                                        .value
                                                                        .bobot
                                                                        .text
                                                                        .trim()
                                                                        .replaceAll(
                                                                            ',',
                                                                            '.'));
                                                                    return v ==
                                                                        bobotParsed;
                                                                  });

                                                                  if (sudahAdaBobotSama) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      const SnackBar(
                                                                        content:
                                                                            Text('Bobot subkriteria tidak boleh ada yang sama.'),
                                                                      ),
                                                                    );
                                                                    return;
                                                                  }

                                                                  setState(() {
                                                                    _isinya[editinde!]
                                                                            .kategori
                                                                            .text =
                                                                        namaBaru;
                                                                    _isinya[editinde!]
                                                                            .bobot
                                                                            .text =
                                                                        bobotRaw;
                                                                    _hasChanges =
                                                                        true;
                                                                    Navigator.pop(
                                                                        context);
                                                                  });
                                                                },
                                                                child: Text(
                                                                    "Simpan Perubahan"),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                  IconButton(
                                                      icon: Icon(Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () async {
                                                        // --- LOGIKA HAPUS YANG BENAR ---
                                                        final itemDipilih =
                                                            _isinya[idx];
                                                        if (itemDipilih
                                                                .id_subkriteria !=
                                                            null) {
                                                          await penghubung
                                                              .deletedatasubkriteria(
                                                                  itemDipilih
                                                                      .id_subkriteria!);
                                                        }
                                                        setState(() {
                                                          _isinya.removeAt(idx);
                                                          _hasChanges = true;
                                                        });
                                                      }),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.all(lebarLayar * 0.05),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: Size(double.infinity, tinggiLayar * 0.065),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                onPressed: (!_hasChanges || _isSaving)
                    ? null
                    : () async {
                        setState(() {
                          _isSaving = true;
                        });

                        try {
                          // Jika data di database (inidata) kosong untuk kriteria ini, panggil savemassal
                          final kSekarang = penghubung.mydata.firstWhereOrNull(
                              (e) => e.kategori == penghubung.nama);
                          final dataDb = penghubung.inidata.where(
                              (e) => e.id_kriteria == kSekarang?.id_kriteria);

                          if (dataDb.isEmpty) {
                            await penghubung.savemassalsubkriteria(_isinya);
                          } else {
                            await penghubung.updatedmassalsubkriteria(_isinya);
                          }

                          // Refresh UI setelah simpan database
                          if (!mounted) return;
                          setState(() {
                            keadaan = false;
                            _isSaving = false;
                          });
                        } catch (e) {
                          if (!mounted) return;
                          setState(() {
                            _isSaving = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Gagal menyimpan subkriteria: ${e.toString()}'),
                            ),
                          );
                        }
                      },
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Menyimpan...',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Text(
                        // Cek apakah ada data di database untuk kriteria terpilih ini
                        penghubung.inidata.any((element) {
                          final kTerpilih = penghubung.mydata.firstWhereOrNull(
                              (e) => e.kategori == penghubung.nama);
                          return element.id_kriteria == kTerpilih?.id_kriteria;
                        })
                            ? "Simpan Perubahan Data"
                            : "Simpan Data",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          );
        }
        return Scaffold(body: Center(child: Text("Error")));
      },
    );
  }
}

// tidak terpakai
//   Widget _buildPilihKriteriaCard(double lebarLayar, double tinggiLayar) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: _warnaKartu,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 3,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: lebarLayar * 0.04,
//           vertical: tinggiLayar * 0.02,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Pilih Kriteria",
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//                 color: Colors.black,
//               ),
//             ),
//             SizedBox(height: tinggiLayar * 0.012),
//             DropdownButtonFormField<String>(
//               value: _selectedKriteria,
//               items: _kriteriaList
//                   .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                   .toList(),
//               onChanged: (val) {
//                 if (val != null) setState(() => _selectedKriteria = val);
//               },
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Color(0xFFE5ECFF),
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 12,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabelCard(
//     double lebarLayar,
//     double tinggiLayar,
//     List<SubcriteriaItem> items,
//   ) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: _warnaKartu,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 3,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.symmetric(
//           horizontal: lebarLayar * 0.02,
//           vertical: tinggiLayar * 0.015,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     "Daftar Subkriteria",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 15,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Cari subkriteria...",
//                       isDense: true,
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       contentPadding:
//                           EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                     ),
//                     onChanged: (v) => setState(() => _query = v),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: tinggiLayar * 0.015),
//             Container(height: 1, color: Colors.grey.shade300),
//             SizedBox(height: tinggiLayar * 0.015),
//             Expanded(
//               child: items.isEmpty
//                   ? Center(
//                       child: Text(
//                         "Belum ada subkriteria",
//                         style: TextStyle(color: Colors.black54),
//                       ),
//                     )
//                   : ListView.separated(
//                       itemCount: items.length,
//                       separatorBuilder: (context, index) =>
//                           SizedBox(height: tinggiLayar * 0.012),
//                       itemBuilder: (context, index) {
//                         return _buildSubItem(
//                           lebarLayar,
//                           tinggiLayar,
//                           items[index],
//                         );
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  // void _tombolBelumTersedia() {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text("Fitur CRUD belum diaktifkan"),
  //       behavior: SnackBarBehavior.floating,
  //     ),
  //   );
  // }

//   Widget _buildSubItem(
//     double lebarLayar,
//     double tinggiLayar,
//     SubcriteriaItem item,
//   ) {
//     Color warnaItem = Color(0xFFE5ECFF);
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(
//         vertical: tinggiLayar * 0.018,
//         horizontal: lebarLayar * 0.04,
//       ),
//       decoration: BoxDecoration(
//         color: warnaItem,
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.nama,
//                   style: TextStyle(
//                     color: Colors.black,
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         "Bobot: ${item.bobot.toStringAsFixed(2)}",
//                         style: TextStyle(
//                           color: Colors.black87,
//                           fontSize: 13.5,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Row(
//             children: [
//               IconButton(
//                 tooltip: "Ubah (simulasi)",
//                 onPressed: _tombolBelumTersedia,
//                 icon: Icon(
//                   Icons.edit,
//                   color: Colors.green,
//                   size: lebarLayar * 0.060,
//                 ),
//               ),
//               SizedBox(width: lebarLayar * 0.015),
//               IconButton(
//                 tooltip: "Hapus (simulasi)",
//                 onPressed: _tombolBelumTersedia,
//                 icon: Icon(
//                   Icons.delete,
//                   color: Colors.red,
//                   size: lebarLayar * 0.060,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   void _bukaFormTambah() {
//     final namaController = TextEditingController();
//     final bobotController = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text(
//           "Tambah Subkriteria",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         content: SizedBox(
//           width: 420,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: namaController,
//                 decoration: InputDecoration(
//                   labelText: "Nama Subkriteria",
//                   filled: true,
//                   fillColor: Color(0xFFF5F7FB),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               SizedBox(height: 12),
//               TextField(
//                 controller: bobotController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: "Bobot (0-1)",
//                   filled: true,
//                   fillColor: Color(0xFFF5F7FB),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               // Atribut dihilangkan dari form sesuai permintaan
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("Batal"),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(
//               // backgroundColor: _warnaUtama,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(
//                   content: Text("Simulasi: Subkriteria belum disimpan"),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             },
//             child: Text(
//               "Simpan",
//               style: TextStyle(color: _warnaUtama),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final double lebarLayar;

//   _InfoCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.lebarLayar,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: lebarLayar * 0.04,
//         vertical: lebarLayar * 0.03,
//       ),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 3,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: lebarLayar * 0.10,
//             height: lebarLayar * 0.10,
//             decoration: BoxDecoration(
//               color: Color(0xFFDDE6FF),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Color(0xFF1E3A8A)),
//           ),
//           SizedBox(width: lebarLayar * 0.04),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
