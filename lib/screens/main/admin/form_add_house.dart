import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class FormAddHouse extends StatefulWidget {
  const FormAddHouse({super.key});

  @override
  State<FormAddHouse> createState() => _FormAddHouseState();
}

class _FormAddHouseState extends State<FormAddHouse> {
  final TextEditingController _namaFasilitasController =
      TextEditingController();
  final TextEditingController _koordinatController = TextEditingController();
  File? _gambar1;
  File? _gambar2;

  final ImagePicker _picker = ImagePicker();

  // -------- WebView (Leaflet) ----------
  late final WebViewController _mapController;
  bool _mapLoaded = false;

  // Debounce timer untuk update peta
  Timer? _debounceTimer;

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

  IconData? ikonTerpilih;

  @override
  void initState() {
    super.initState();

    // Buat controller WebView (webview_flutter >=4.x)
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true) // Aktifkan zoom
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          if (mounted) {
            setState(() => _mapLoaded = true);
          }
        },
        onWebResourceError: (err) {
          // Error handling tanpa debug print yang berat
        },
      ));

    // load map html
    _loadMapHtmlFromAssets();

    // Listener untuk koordinat controller
    _koordinatController.addListener(_onKoordinatChanged);
  }

  Future<void> _loadMapHtmlFromAssets() async {
    try {
      final htmlContent = await rootBundle.loadString('assets/map/map.html');
      await _mapController.loadHtmlString(htmlContent);
      // onPageFinished nanti akan set _mapLoaded = true
    } catch (e) {
      if (mounted) setState(() => _mapLoaded = false);
    }
  }

  // Update peta ketika koordinat diinput (dengan debounce)
  void _onKoordinatChanged() {
    final text = _koordinatController.text.trim();
    if (text.isEmpty || !_mapLoaded) return;

    // Cancel timer sebelumnya jika ada
    _debounceTimer?.cancel();

    // Debounce: tunggu 800ms setelah user berhenti mengetik
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _parseAndUpdateMap(text);
    });
  }

  // Parse koordinat dan update peta
  void _parseAndUpdateMap(String text) {
    // Parse koordinat (format: "lat, lng" atau "lat,lng")
    try {
      final parts = text.split(',').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        final lat = double.tryParse(parts[0]);
        final lng = double.tryParse(parts[1]);

        if (lat != null && lng != null) {
          // Validasi range koordinat
          if (lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
            _updateMapLocation(lat, lng);
          }
        }
      }
    } catch (e) {
      // Error handling tanpa debug print
    }
  }

  // Update lokasi peta dengan marker
  Future<void> _updateMapLocation(double lat, double lng) async {
    if (!_mapLoaded || !mounted) return;

    try {
      // Set marker dan pan ke lokasi
      await _mapController.runJavaScript(
        "setMarker($lat, $lng); setView($lat, $lng, 15);",
      );
    } catch (e) {
      // Error handling
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _koordinatController.removeListener(_onKoordinatChanged);
    _koordinatController.dispose();
    _namaFasilitasController.dispose();
    super.dispose();
  }

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
              const SizedBox(width: 24), // Placeholder untuk alignment
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
              _inputField('Alamat', tinggiLayar, lebarLayar),
              _inputField('Harga', tinggiLayar, lebarLayar),
              _inputField('Jenis Kost', tinggiLayar, lebarLayar),
              _inputField('keamanan', tinggiLayar, lebarLayar),
              _inputField('Luas Kamar', tinggiLayar, lebarLayar),
              _inputField('Batas Jam Malam', tinggiLayar, lebarLayar),
              _inputField('Lokasi Pendukung', tinggiLayar, lebarLayar),
              _inputField('Jenis Pembayaran Air', tinggiLayar, lebarLayar),
              _inputField('Jenis Listrik', tinggiLayar, lebarLayar),
              _inputFieldKoordinat(tinggiLayar, lebarLayar),

              // 🖼️ Input Gambar Kost
              RepaintBoundary(
                child: Text(
                  'Foto Kost',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: lebarLayar * 0.04,
                  ),
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
              RepaintBoundary(
                child: Text(
                  'Fasilitas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: lebarLayar * 0.04,
                  ),
                ),
              ),
              SizedBox(height: tinggiLayar * 0.015),

              Wrap(
                spacing: lebarLayar * 0.03,
                runSpacing: tinggiLayar * 0.015,
                children: fasilitasList.map((fasilitas) {
                  return RepaintBoundary(
                    child: GestureDetector(
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
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: tinggiLayar * 0.025),

              // SizedBox(height: tinggiLayar * 0.05),
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
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: TextField(
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: lebar * 0.04,
                vertical: tinggi * 0.018,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
        SizedBox(height: tinggi * 0.025),
      ],
    );
  }

  // 🔹 Input TextField khusus untuk Koordinat dengan Peta
  Widget _inputFieldKoordinat(double tinggi, double lebar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Titik Koordinat',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: lebar * 0.035,
            color: Colors.black,
          ),
        ),
        SizedBox(height: tinggi * 0.005),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: TextField(
            controller: _koordinatController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'Contoh: -5.147665, 119.432731',
              hintStyle: TextStyle(
                color: Colors.grey.shade500,
                fontSize: lebar * 0.032,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: lebar * 0.04,
                vertical: tinggi * 0.018,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: TextStyle(
              fontSize: lebar * 0.032,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: tinggi * 0.015),
        // Peta Leaflet - dengan RepaintBoundary untuk optimasi
        RepaintBoundary(
          child: SizedBox(
            height: tinggi * 0.3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    RepaintBoundary(
                      child: WebViewWidget(
                        controller: _mapController,
                        gestureRecognizers: {
                          Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer(),
                          ),
                          Factory<HorizontalDragGestureRecognizer>(
                            () => HorizontalDragGestureRecognizer(),
                          ),
                          Factory<ScaleGestureRecognizer>(
                            () => ScaleGestureRecognizer(),
                          ),
                          Factory<TapGestureRecognizer>(
                            () => TapGestureRecognizer(),
                          ),
                        },
                      ),
                    ),
                    if (!_mapLoaded)
                      Positioned.fill(
                        child: Container(
                          color: Colors.white,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
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
}
