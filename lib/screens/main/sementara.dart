class Sementara {
  // tidak terpakai
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
}
