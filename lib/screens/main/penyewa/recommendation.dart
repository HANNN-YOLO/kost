// lib/user_recommendation_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'recommendation_saw.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../providers/kost_provider.dart';

class UserRecommendationPage extends StatefulWidget {
  const UserRecommendationPage({Key? key}) : super(key: key);

  @override
  State<UserRecommendationPage> createState() => _UserRecommendationPageState();
}

class _UserRecommendationPageState extends State<UserRecommendationPage>
    with SingleTickerProviderStateMixin {
  // -------- dropdown floating ----------
  final LayerLink _dropdownLink = LayerLink();
  OverlayEntry? _dropdownOverlay;
  bool _dropdownOpen = false;

  final GlobalKey _fieldKey = GlobalKey();
  Size _fieldSize = Size.zero;

  String _selectedLocation = "Lokasi Tujuan";
  String _coordinateText = "12121212, 3232323";

  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  // -------- WebView (Leaflet) ----------
  late final WebViewController _mapController;
  bool _mapLoaded = false;

  @override
  void initState() {
    super.initState();

    // Buat controller WebView (webview_flutter >=4.x)
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          debugPrint("MAP PAGE LOADED: $url");
          setState(() => _mapLoaded = true);
          // Set mode sesuai dengan _selectedLocation yang aktif saat pertama kali load
          _syncMapModeWithSelectedLocation();
          // setelah peta siap, tampilkan semua titik kost
          _showAllKostOnMap();
        },
        onWebResourceError: (err) {
          debugPrint("WEBVIEW ERROR: ${err.description}");
        },
      ));

    // register JavaScript channel 'ToFlutter' untuk menerima pesan dari map.html
    _mapController.addJavaScriptChannel(
      'ToFlutter',
      onMessageReceived: (JavaScriptMessage message) {
        try {
          final payload = json.decode(message.message);
          if (payload is Map && payload['type'] == 'destination_selected') {
            final lat = payload['lat'];
            final lng = payload['lng'];
            setState(() {
              _coordinateText = '$lat, $lng';
            });
            // optional: you can also pan/marker again from Flutter (not needed)
            // _mapController.runJavaScript("setMarker($lat, $lng);");
          }
        } catch (e) {
          debugPrint('Invalid message from JS: ${message.message} — $e');
        }
      },
    );

    // load map html
    _loadMapHtmlFromAssets();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 160),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _offset =
        Tween<Offset>(begin: const Offset(0, -0.02), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // hitung ukuran field untuk dropdown overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox =
          _fieldKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        setState(() => _fieldSize = renderBox.size);
      }
    });
  }

  // =================================================
  // Kirim semua titik kost ke peta Leaflet
  Future<void> _showAllKostOnMap() async {
    if (!_mapLoaded) return;

    try {
      final kostProvider = Provider.of<KostProvider>(context, listen: false);

      // gunakan data kost untuk penyewa jika ada, jika tidak fallback ke kost umum
      final allKost = kostProvider.kostpenyewa.isNotEmpty
          ? kostProvider.kostpenyewa
          : kostProvider.kost;

      final points = allKost
          .where((k) => k.garis_lintang != null && k.garis_bujur != null)
          .map((k) => {
                'lat': k.garis_lintang,
                'lng': k.garis_bujur,
                'name': k.nama_kost ?? '',
              })
          .toList();

      if (points.isEmpty) return;

      final jsonData = jsonEncode(points);
      await _mapController.runJavaScript('showAllKostMarkers($jsonData);');
    } catch (e) {
      debugPrint('Failed to show kost markers: $e');
    }
  }

  Future<void> _loadMapHtmlFromAssets() async {
    try {
      final htmlContent = await rootBundle.loadString('assets/map/map.html');
      await _mapController.loadHtmlString(htmlContent);
      // onPageFinished nanti akan set _mapLoaded = true
    } catch (e) {
      debugPrint('Failed load map.html: $e');
      if (mounted) setState(() => _mapLoaded = false);
    }
  }

  // =================================================
  // Sinkronkan mode map dengan _selectedLocation yang aktif
  Future<void> _syncMapModeWithSelectedLocation() async {
    if (!_mapLoaded) return;

    if (_selectedLocation == "Lokasi Tujuan") {
      await _mapController.runJavaScript("setMode('destination');");
      setState(() => _coordinateText = "Klik 2x pada peta");
    } else {
      await _mapController.runJavaScript("setMode('normal');");
    }
  }

  // =================================================
  // Ambil lokasi sekarang & kirim ke JS setMyLocation(lat,lng)
  Future<void> _goToMyLocation() async {
    if (!_mapLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Map belum siap, coba lagi sebentar...')),
      );
      return;
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS belum aktif, nyalakan dulu.')),
      );
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin lokasi ditolak permanen.')),
      );
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      debugPrint("MY LOCATION: ${pos.latitude}, ${pos.longitude}");

      // set JS mode ke normal (agar single-click behavior tetap)
      await _mapController.runJavaScript("setMode('normal');");

      // set my location marker di map
      await _mapController
          .runJavaScript("setMyLocation(${pos.latitude}, ${pos.longitude});");

      setState(() {
        _coordinateText = "${pos.latitude}, ${pos.longitude}";
        _selectedLocation = "Lokasi Sekarang";
      });
    } catch (e) {
      debugPrint("Error ambil lokasi: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil lokasi: $e')),
      );
    }
  }

  // =================================================
  // Ambil koordinat klik/dblclick terakhir dari peta (manual tombol)
  Future<void> _fetchLastClickCoordinate() async {
    try {
      final result =
          await _mapController.runJavaScriptReturningResult('getLastClick()');
      String str = result == null ? 'null' : result.toString();

      // bersihkan quotes jika dibungkus
      if (str.startsWith('"') && str.endsWith('"')) {
        str = str.substring(1, str.length - 1);
        str = str.replaceAll(r'\"', '"');
      }

      if (str == 'null' || str.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Belum ada titik yang diklik di peta')),
        );
        return;
      }

      final parsed = json.decode(str);
      if (parsed is Map && parsed['lat'] != null && parsed['lng'] != null) {
        final lat = parsed['lat'];
        final lng = parsed['lng'];
        setState(() {
          _coordinateText = '$lat, $lng';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Koordinat tidak valid: $str')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil koordinat: $e')),
      );
    }
  }

  // ---------------- Dropdown overlay ----------------
  void _openDropdown(double Function(double) s, Color bg, Color txt) {
    _dropdownOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeDropdown,
            child: Container(color: Colors.transparent),
          ),
          Positioned(
            width: _fieldSize.width > 0
                ? _fieldSize.width
                : MediaQuery.of(context).size.width - s(32),
            child: CompositedTransformFollower(
              link: _dropdownLink,
              offset: Offset(0, _fieldSize.height + s(8)),
              child: FadeTransition(
                opacity: _opacity,
                child: SlideTransition(
                  position: _offset,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(s(12)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: s(14),
                            offset: Offset(0, s(6)),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _dropdownItem("Lokasi Sekarang", s, txt),
                          _dropdownItem("Lokasi Tujuan", s, txt),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_dropdownOverlay!);
    _controller.forward();
    setState(() => _dropdownOpen = true);
  }

  Widget _dropdownItem(String text, double Function(double) s, Color txtColor) {
    return InkWell(
      onTap: () async {
        setState(() => _selectedLocation = text);
        _closeDropdown();

        if (text == "Lokasi Sekarang") {
          // ubah mode peta ke normal dan ambil lokasi saya
          await _mapController.runJavaScript("setMode('normal');");
          await _goToMyLocation();
        } else {
          // Lokasi Tujuan: ganti mode ke destination (butuh dblclick)
          await _mapController.runJavaScript("setMode('destination');");
          setState(() => _coordinateText = "Klik 2x pada peta");
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(12)),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: s(14),
                color: txtColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _closeDropdown() {
    if (!_dropdownOpen) return;
    _controller.reverse().then((_) {
      _dropdownOverlay?.remove();
      _dropdownOverlay = null;
      setState(() => _dropdownOpen = false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ================= UI =============================
  @override
  Widget build(BuildContext context) {
    const double figmaWidth = 402;
    final double screenWidth = MediaQuery.of(context).size.width;
    double scale = screenWidth / figmaWidth;
    double s(double size) => size * scale;

    const Color colorBackground = Color(0xFFF5F7FB);
    const Color colorPrimary = Color(0xFF1C3B98);
    const Color colorWhite = Colors.white;
    const Color colorTextPrimary = Color(0xFF1F1F1F);
    final Color shadowColor = Color.fromRGBO(0, 0, 0, 0.06);

    return Scaffold(
      backgroundColor: colorBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: s(36),
                    height: s(36),
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(s(18)),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: s(6),
                          offset: Offset(0, s(2)),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.place,
                        size: s(18),
                        color: colorPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: s(12)),
                  Text(
                    'Tentukan Lokasi',
                    style: TextStyle(
                      fontSize: s(16),
                      fontWeight: FontWeight.w600,
                      color: colorTextPrimary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: s(16)),

              // MAIN CARD
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colorWhite,
                              borderRadius: BorderRadius.circular(s(18)),
                              boxShadow: [
                                BoxShadow(
                                  color: shadowColor,
                                  blurRadius: s(10),
                                  offset: Offset(0, s(4)),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: s(16), vertical: s(14)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Pilih Lokasi',
                                  style: TextStyle(
                                    fontSize: s(12),
                                    fontWeight: FontWeight.w500,
                                    color: colorTextPrimary.withOpacity(0.85),
                                  ),
                                ),
                                SizedBox(height: s(8)),

                                // Dropdown
                                CompositedTransformTarget(
                                  link: _dropdownLink,
                                  child: GestureDetector(
                                    key: _fieldKey,
                                    onTap: () {
                                      if (_dropdownOpen) {
                                        _closeDropdown();
                                      } else {
                                        _openDropdown(
                                          s,
                                          colorWhite,
                                          colorTextPrimary,
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: s(52),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: s(14)),
                                      decoration: BoxDecoration(
                                        color: colorBackground,
                                        borderRadius:
                                            BorderRadius.circular(s(12)),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _selectedLocation,
                                              style: TextStyle(
                                                fontSize: s(14),
                                                color: colorTextPrimary
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            _dropdownOpen
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            size: s(22),
                                            color: colorTextPrimary
                                                .withOpacity(0.6),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: s(14)),

                                Text(
                                  'Titik Koordinat',
                                  style: TextStyle(
                                    fontSize: s(12),
                                    fontWeight: FontWeight.w500,
                                    color: colorTextPrimary.withOpacity(0.85),
                                  ),
                                ),
                                SizedBox(height: s(8)),

                                Container(
                                  height: s(52),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: s(12)),
                                  decoration: BoxDecoration(
                                    color: colorBackground,
                                    borderRadius: BorderRadius.circular(s(12)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: s(20),
                                        color: colorPrimary,
                                      ),
                                      SizedBox(width: s(10)),
                                      Expanded(
                                        child: Text(
                                          _coordinateText,
                                          style: TextStyle(
                                            fontSize: s(14),
                                            color: colorTextPrimary
                                                .withOpacity(0.6),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _fetchLastClickCoordinate,
                                        icon: Icon(
                                          Icons.my_location,
                                          size: s(20),
                                          color: colorPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: s(14)),

                                // MAP (fix height agar tidak bentrok scroll)
                                SizedBox(
                                  height: s(340),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(s(14)),
                                    child: Stack(
                                      children: [
                                        WebViewWidget(
                                            controller: _mapController),
                                        if (!_mapLoaded)
                                          Positioned.fill(
                                            child: Container(
                                              color: Colors.white,
                                              child: const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: s(18)),

                                SizedBox(
                                  height: s(56),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RecommendationSawPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(s(14)),
                                      ),
                                    ),
                                    child: Text(
                                      'Tampilkan Hasil',
                                      style: TextStyle(
                                        fontSize: s(16),
                                        fontWeight: FontWeight.w600,
                                        color: colorWhite,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: s(18)),
                              ],
                            ),
                          ),
                        ),
                      ),
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
}
