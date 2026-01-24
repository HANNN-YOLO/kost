import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../../providers/kost_provider.dart';

class AdminPlacesPage extends StatefulWidget {
  const AdminPlacesPage({super.key});

  @override
  State<AdminPlacesPage> createState() => _AdminPlacesPageState();
}

class _AdminPlacesPageState extends State<AdminPlacesPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _coordController = TextEditingController();
  String? _errorText;

  // WebView Leaflet
  late final WebViewController _mapController;
  bool _mapLoaded = false;

  // Debounce untuk update peta saat koordinat diketik
  Timer? _debounceTimer;

  bool _isNameFilled = false;
  bool _isCoordValid = false;

  @override
  void initState() {
    super.initState();

    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _mapLoaded = true);
            }
          },
          onWebResourceError: (err) {
            // biarkan _mapLoaded tetap false jika gagal
          },
        ),
      );

    _loadMapHtmlFromAssets();

    // Dengarkan perubahan field agar bisa mengaktifkan/nonaktifkan tombol simpan
    _nameController.addListener(_onNameChanged);
    _coordController.addListener(_onCoordChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.removeListener(_onNameChanged);
    _coordController.removeListener(_onCoordChanged);
    _nameController.dispose();
    _coordController.dispose();
    super.dispose();
  }

  Future<void> _loadMapHtmlFromAssets() async {
    try {
      final htmlContent = await rootBundle.loadString('assets/map/map.html');
      await _mapController.loadHtmlString(htmlContent);
    } catch (e) {
      if (mounted) setState(() => _mapLoaded = false);
    }
  }

  void _onNameChanged() {
    final filled = _nameController.text.trim().isNotEmpty;
    if (filled != _isNameFilled) {
      setState(() {
        _isNameFilled = filled;
      });
    }
  }

  void _onCoordChanged() {
    final text = _coordController.text.trim();
    if (text.isEmpty) {
      _debounceTimer?.cancel();
      if (_isCoordValid || _errorText != null) {
        setState(() {
          _isCoordValid = false;
          _errorText = null;
        });
      }
      return;
    }

    // Validasi koordinat langsung untuk mengatur status tombol simpan
    bool valid = false;
    try {
      final parts = text.split(',').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);
        if (lat != null && lng != null) {
          valid = lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
        }
      }
    } catch (_) {
      valid = false;
    }

    setState(() {
      _isCoordValid = valid;
      _errorText = valid ? null : 'Titik koordinat tidak ditemukan';
    });

    if (!valid || !_mapLoaded) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _parseAndUpdateMap(text);
    });
  }

  void _parseAndUpdateMap(String text) {
    try {
      final parts = text.split(',').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);

        if (lat != null && lng != null) {
          if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
            _updateMapLocation(lat, lng);
          }
        }
      }
    } catch (_) {
      // abaikan jika parsing gagal
    }
  }

  Future<void> _updateMapLocation(double lat, double lng) async {
    if (!_mapLoaded) return;

    try {
      await _mapController.runJavaScript(
        'clearMyLocation(); clearDestination(); setMyLocation($lat, $lng);',
      );
    } catch (_) {
      // abaikan error JS ringan
    }
  }

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<KostProvider>(context);
    final places = penghubung.adminPlaces;

    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    const warnaLatar = Color(0xFFF5F7FB);
    const warnaKartu = Colors.white;

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
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: lebarLayar * 0.01),
                  Text(
                    'Daftar Tempat',
                    style: TextStyle(
                      fontSize: lebarLayar * 0.045,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: tinggiLayar * 0.02),

              // Kartu total tempat
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: lebarLayar * 0.05,
                  vertical: tinggiLayar * 0.02,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Tempat',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: tinggiLayar * 0.005),
                        Text(
                          '${places.length}',
                          style: TextStyle(
                            fontSize: lebarLayar * 0.050,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.location_city_rounded,
                      color: Color(0xFF12111F),
                      size: 36,
                    ),
                  ],
                ),
              ),

              SizedBox(height: tinggiLayar * 0.02),

              // Daftar tempat
              Expanded(
                child: places.isEmpty
                    ? Center(
                        child: Text(
                          'Belum ada tempat yang ditambahkan.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: lebarLayar * 0.035,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: places.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: tinggiLayar * 0.015),
                        itemBuilder: (context, index) {
                          final place = places[index];
                          return Container(
                            padding: EdgeInsets.all(lebarLayar * 0.035),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        place.name,
                                        style: TextStyle(
                                          fontSize: lebarLayar * 0.040,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.edit_outlined,
                                            size: lebarLayar * 0.055,
                                            color: Colors.grey.shade700,
                                          ),
                                          onPressed: () {
                                            _openEditPlaceSheet(
                                              penghubung,
                                              tinggiLayar,
                                              lebarLayar,
                                              index,
                                              place,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            size: lebarLayar * 0.055,
                                            color: Colors.red.shade400,
                                          ),
                                          onPressed: () async {
                                            final confirm =
                                                await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Hapus Tempat?'),
                                                  content: Text(
                                                    'Yakin ingin menghapus tempat "${place.name}"? Tindakan ini tidak dapat dibatalkan.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(false),
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(true),
                                                      child: const Text(
                                                        'Hapus',
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirm == true) {
                                              penghubung
                                                  .removeAdminPlaceAt(index);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Tempat "${place.name}" telah dihapus',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: lebarLayar * 0.040,
                                      color: Colors.grey.shade600,
                                    ),
                                    SizedBox(width: lebarLayar * 0.01),
                                    Expanded(
                                      child: Text(
                                        '${place.lat}, ${place.lng}',
                                        style: TextStyle(
                                          fontSize: lebarLayar * 0.032,
                                          color: Colors.grey.shade700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              SizedBox(height: tinggiLayar * 0.02),

              // Tombol untuk membuka form tambah tempat (dalam bottom sheet)
              SizedBox(
                width: double.infinity,
                height: tinggiLayar * 0.055,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12111F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  onPressed: () {
                    _openAddPlaceSheet(penghubung, tinggiLayar, lebarLayar);
                  },
                  icon: const Icon(
                    Icons.add_location_alt_outlined,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Tambahkan Tempat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddPlaceSheet(
    KostProvider penghubung,
    double tinggiLayar,
    double lebarLayar,
  ) {
    // reset pesan error namun biarkan isi terakhir jika ada
    setState(() {
      _errorText = null;
      _nameController.clear();
      _coordController.clear();
      _isNameFilled = false;
      _isCoordValid = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return GestureDetector(
          onTap: () => FocusScope.of(ctx).unfocus(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black26,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: lebarLayar * 0.06,
                    vertical: tinggiLayar * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: lebarLayar * 0.12,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        Text(
                          'Tambah Tempat',
                          style: TextStyle(
                            fontSize: lebarLayar * 0.040,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: tinggiLayar * 0.012),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Tempat',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _coordController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Titik Koordinat',
                            hintText: '-5.147665, 119.432731',
                          ),
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        SizedBox(height: tinggiLayar * 0.015),
                        SizedBox(
                          height: tinggiLayar * 0.24,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                WebViewWidget(controller: _mapController),
                                if (!_mapLoaded)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: tinggiLayar * 0.018),
                        SizedBox(
                          width: double.infinity,
                          height: tinggiLayar * 0.055,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isNameFilled && _isCoordValid
                                  ? const Color(0xFF12111F)
                                  : Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: _isNameFilled && _isCoordValid
                                ? () {
                                    _onSavePlace(penghubung);
                                    Navigator.of(ctx).pop();
                                  }
                                : null,
                            child: const Text(
                              'Simpan Tempat',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openEditPlaceSheet(
    KostProvider penghubung,
    double tinggiLayar,
    double lebarLayar,
    int index,
    AdminPlace place,
  ) {
    setState(() {
      _nameController.text = place.name;
      _coordController.text = '${place.lat}, ${place.lng}';
      _errorText = null;
      _isNameFilled = true;
      _isCoordValid = true;
    });

    if (_mapLoaded) {
      _updateMapLocation(place.lat, place.lng);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return GestureDetector(
          onTap: () => FocusScope.of(ctx).unfocus(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              color: Colors.black26,
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: lebarLayar * 0.06,
                    vertical: tinggiLayar * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: lebarLayar * 0.12,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                        Text(
                          'Edit Tempat',
                          style: TextStyle(
                            fontSize: lebarLayar * 0.040,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: tinggiLayar * 0.012),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Tempat',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _coordController,
                          keyboardType: TextInputType.text,
                          decoration: const InputDecoration(
                            labelText: 'Titik Koordinat',
                            hintText: '-5.147665, 119.432731',
                          ),
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _errorText!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        SizedBox(height: tinggiLayar * 0.015),
                        SizedBox(
                          height: tinggiLayar * 0.24,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                WebViewWidget(controller: _mapController),
                                if (!_mapLoaded)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: tinggiLayar * 0.018),
                        SizedBox(
                          width: double.infinity,
                          height: tinggiLayar * 0.055,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isNameFilled && _isCoordValid
                                  ? const Color(0xFF12111F)
                                  : Colors.grey.shade400,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: _isNameFilled && _isCoordValid
                                ? () {
                                    _onSavePlace(
                                      penghubung,
                                      index: index,
                                    );
                                    Navigator.of(ctx).pop();
                                  }
                                : null,
                            child: const Text(
                              'Simpan Perubahan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSavePlace(KostProvider penghubung, {int? index}) {
    final name = _nameController.text.trim();
    final coord = _coordController.text.trim();

    final parts = coord
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    double? lat;
    double? lng;

    if (parts.length == 2) {
      lat = double.tryParse(parts[0]);
      lng = double.tryParse(parts[1]);
    }

    if (name.isEmpty || lat == null || lng == null) {
      setState(() {
        _errorText = 'Titik koordinat tidak ditemukan';
      });
      return;
    }

    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
      setState(() {
        _errorText = 'Titik koordinat tidak ditemukan';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    final newPlace = AdminPlace(name: name, lat: lat, lng: lng);

    if (index == null) {
      penghubung.addAdminPlace(newPlace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tempat "$name" tersimpan dengan koordinat $lat, $lng',
          ),
        ),
      );
    } else {
      penghubung.updateAdminPlace(index, newPlace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tempat "$name" berhasil diperbarui',
          ),
        ),
      );
    }

    _nameController.clear();
    _coordController.clear();
  }
}
