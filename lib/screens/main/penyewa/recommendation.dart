// lib/user_recommendation_page.dart
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'recommendation_saw.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
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

  bool _isLoading = false;

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
          if (!mounted) return;
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
            if (!mounted) return;
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
      if (!mounted) return;
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

      if (!mounted) return;
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
        if (!mounted) return;
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
          // ubah mode peta ke normal, bersihkan marker tujuan, lalu ambil lokasi saya
          await _mapController.runJavaScript("setMode('normal');");
          await _mapController.runJavaScript("clearDestination();");
          await _goToMyLocation();
        } else {
          // Lokasi Tujuan: bersihkan marker lokasi sekarang dan ganti mode ke destination (butuh dblclick)
          await _mapController.runJavaScript("clearMyLocation();");
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
      if (!mounted) return;
      _dropdownOverlay?.remove();
      _dropdownOverlay = null;
      setState(() => _dropdownOpen = false);
    });
  }

  @override
  void dispose() {
    // pastikan overlay dibersihkan agar tidak menahan referensi State
    _dropdownOverlay?.remove();
    _dropdownOverlay = null;
    _controller.dispose();
    super.dispose();
  }

  // =================================================
  // FUNGSI DASAR: Haversine - Jarak garis lurus dalam kilometer
  // =================================================
  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371.0; // radius bumi km
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLon = _deg2rad(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _deg2rad(double deg) => deg * (math.pi / 180.0);

  // =================================================
  // FUNGSI HELPER: Request OSRM untuk satu arah
  // =================================================
  Future<double?> _osrmOneWay(
      double fromLat, double fromLng, double toLat, double toLng) async {
    final uri = Uri.parse('https://router.project-osrm.org/route/v1/driving/'
        '$fromLng,$fromLat;$toLng,$toLat?overview=false&alternatives=false&steps=false');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final distanceMeters = (routes[0]['distance'] as num?)?.toDouble();
          if (distanceMeters != null) {
            return distanceMeters / 1000.0;
          }
        }
      }
    } catch (e) {
      debugPrint('OSRM request exception: $e');
    }
    return null;
  }

  // =================================================
  // ╔═══════════════════════════════════════════════╗
  // ║     PILIH SALAH SATU OPSI DI BAWAH INI!       ║
  // ║  Uncomment opsi yang ingin digunakan,         ║
  // ║  Comment opsi lainnya.                        ║
  // ╚═══════════════════════════════════════════════╝
  // =================================================

  // ███████████████████████████████████████████████████████████████████████████
  // █ OPSI 1: HITUNG DUA ARAH, AMBIL TERPENDEK (AKTIF - DEFAULT)              █
  // █ Kelebihan: Mengatasi masalah jalan satu arah yang salah tercatat        █
  // █ Kekurangan: Request API 2x lipat (lebih lambat)                         █
  // ███████████████████████████████████████████████████████████████████████████
  Future<double> _getDistanceForSAW(
      double pointLat, double pointLng, double kostLat, double kostLng) async {
    debugPrint('📍 OPSI 1: Menghitung dua arah...');

    // Hitung arah 1: Titik Tujuan → Kost
    final dist1 = await _osrmOneWay(pointLat, pointLng, kostLat, kostLng);
    debugPrint('   → Titik→Kost: ${dist1?.toStringAsFixed(2) ?? "gagal"} km');

    // Hitung arah 2: Kost → Titik Tujuan
    final dist2 = await _osrmOneWay(kostLat, kostLng, pointLat, pointLng);
    debugPrint('   ← Kost→Titik: ${dist2?.toStringAsFixed(2) ?? "gagal"} km');

    // Ambil yang terpendek, fallback ke Haversine jika keduanya gagal
    if (dist1 != null && dist2 != null) {
      final shortest = dist1 < dist2 ? dist1 : dist2;
      debugPrint('   ✅ Ambil terpendek: ${shortest.toStringAsFixed(2)} km');
      return shortest;
    } else if (dist1 != null) {
      return dist1;
    } else if (dist2 != null) {
      return dist2;
    } else {
      final haversine = _distanceKm(pointLat, pointLng, kostLat, kostLng);
      debugPrint(
          '   ⚠️ Fallback Haversine: ${haversine.toStringAsFixed(2)} km');
      return haversine;
    }
  }

  /*
  // ███████████████████████████████████████████████████████████████████████████
  // █ OPSI 2: HAVERSINE SAJA (GARIS LURUS)                                    █
  // █ Kelebihan: Konsisten, cepat, tidak tergantung data OSM                  █
  // █ Kekurangan: Tidak realistis untuk navigasi sebenarnya                   █
  // ███████████████████████████████████████████████████████████████████████████
  Future<double> _getDistanceForSAW(
      double pointLat, double pointLng, double kostLat, double kostLng) async {
    debugPrint('📍 OPSI 2: Menggunakan Haversine (garis lurus)...');
    final haversine = _distanceKm(pointLat, pointLng, kostLat, kostLng);
    debugPrint('   ✅ Jarak: ${haversine.toStringAsFixed(2)} km');
    return haversine;
  }
  */

  /*
  // ███████████████████████████████████████████████████████████████████████████
  // █ OPSI 3: OSRM SATU ARAH SAJA (FUNGSI LAMA/ORIGINAL)                      █
  // █ Kelebihan: Realistis untuk navigasi                                     █
  // █ Kekurangan: Tergantung akurasi data OSM, bisa salah jika one-way salah  █
  // ███████████████████████████████████████████████████████████████████████████
  Future<double> _getDistanceForSAW(
      double pointLat, double pointLng, double kostLat, double kostLng) async {
    debugPrint('📍 OPSI 3: Menggunakan OSRM satu arah...');
    final dist = await _osrmOneWay(pointLat, pointLng, kostLat, kostLng);
    if (dist != null) {
      debugPrint('   ✅ Jarak OSRM: ${dist.toStringAsFixed(2)} km');
      return dist;
    }
    final haversine = _distanceKm(pointLat, pointLng, kostLat, kostLng);
    debugPrint('   ⚠️ Fallback Haversine: ${haversine.toStringAsFixed(2)} km');
    return haversine;
  }
  */

  /*
  // ███████████████████████████████████████████████████████████████████████████
  // █ OPSI 4: HYBRID - DUA ARAH + DETEKSI ANOMALI                             █
  // █ Kelebihan: Paling robust, mendeteksi jika data OSM bermasalah           █
  // █ Kekurangan: Paling kompleks, request API 2x lipat                       █
  // █ Logika: Jika jarak OSRM > 2x Haversine, anggap anomali → pakai Haversine█
  // ███████████████████████████████████████████████████████████████████████████
  Future<double> _getDistanceForSAW(
      double pointLat, double pointLng, double kostLat, double kostLng) async {
    debugPrint('📍 OPSI 4: Hybrid dengan deteksi anomali...');

    final haversine = _distanceKm(pointLat, pointLng, kostLat, kostLng);
    debugPrint('   📐 Haversine: ${haversine.toStringAsFixed(2)} km');

    // Hitung arah 1: Titik Tujuan → Kost
    final dist1 = await _osrmOneWay(pointLat, pointLng, kostLat, kostLng);
    debugPrint('   → Titik→Kost: ${dist1?.toStringAsFixed(2) ?? "gagal"} km');

    // Hitung arah 2: Kost → Titik Tujuan
    final dist2 = await _osrmOneWay(kostLat, kostLng, pointLat, pointLng);
    debugPrint('   ← Kost→Titik: ${dist2?.toStringAsFixed(2) ?? "gagal"} km');

    // Ambil yang terpendek dari OSRM
    double? osrmShortest;
    if (dist1 != null && dist2 != null) {
      osrmShortest = dist1 < dist2 ? dist1 : dist2;
    } else if (dist1 != null) {
      osrmShortest = dist1;
    } else if (dist2 != null) {
      osrmShortest = dist2;
    }

    // Deteksi anomali: jika OSRM > 2x Haversine, data OSM bermasalah
    if (osrmShortest != null) {
      final ratio = osrmShortest / haversine;
      debugPrint('   📊 Rasio OSRM/Haversine: ${ratio.toStringAsFixed(2)}');

      if (ratio > 2.0) {
        debugPrint('   ⚠️ ANOMALI TERDETEKSI! Menggunakan Haversine.');
        return haversine;
      } else {
        debugPrint('   ✅ Normal, menggunakan OSRM: ${osrmShortest.toStringAsFixed(2)} km');
        return osrmShortest;
      }
    }

    debugPrint('   ⚠️ OSRM gagal, fallback Haversine: ${haversine.toStringAsFixed(2)} km');
    return haversine;
  }
  */

  // =================================================
  // FUNGSI LAMA (DIKOMENTARI - UNTUK REFERENSI)
  // =================================================
  /*
  // Fungsi lama sebelum ada opsi - hanya satu arah
  Future<double> _roadDistanceKm(
      double fromLat, double fromLng, double toLat, double toLng) async {
    final uri = Uri.parse('https://router.project-osrm.org/route/v1/driving/'
        '$fromLng,$fromLat;$toLng,$toLat?overview=false&alternatives=false&steps=false');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final distanceMeters = (routes[0]['distance'] as num?)?.toDouble();
          if (distanceMeters != null) {
            return distanceMeters / 1000.0;
          }
        }
      } else {
        debugPrint('OSRM route error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('OSRM route exception: $e');
    }

    // fallback jika gagal
    return _distanceKm(fromLat, fromLng, toLat, toLng);
  }
  */

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
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            // Parse koordinat tujuan
                                            final parts = _coordinateText
                                                .split(',')
                                                .map((e) => e.trim())
                                                .toList();

                                            if (parts.length != 2) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Silakan pilih titik lokasi tujuan di peta dulu.'),
                                                ),
                                              );
                                              return;
                                            }

                                            final double? destLat =
                                                double.tryParse(parts[0]);
                                            final double? destLng =
                                                double.tryParse(parts[1]);

                                            if (destLat == null ||
                                                destLng == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Format koordinat tidak valid. Silakan pilih ulang di peta.'),
                                                ),
                                              );
                                              return;
                                            }

                                            setState(() {
                                              _isLoading = true;
                                            });

                                            try {
                                              final kostProvider =
                                                  Provider.of<KostProvider>(
                                                context,
                                                listen: false,
                                              );

                                              final allKost = kostProvider
                                                      .kostpenyewa.isNotEmpty
                                                  ? kostProvider.kostpenyewa
                                                  : kostProvider.kost;

                                              final List<Map<String, dynamic>>
                                                  dataKost = [];

                                              for (final k in allKost) {
                                                final lat = k.garis_lintang;
                                                final lng = k.garis_bujur;
                                                if (lat == null || lng == null)
                                                  continue;

                                                // ═══════════════════════════════════════════════
                                                // GUNAKAN FUNGSI _getDistanceForSAW
                                                // yang sudah dikonfigurasi di atas (Opsi 1-4)
                                                // ═══════════════════════════════════════════════
                                                final dKm =
                                                    await _getDistanceForSAW(
                                                        destLat,
                                                        destLng,
                                                        lat,
                                                        lng);

                                                dataKost.add({
                                                  'id_kost': k.id_kost,
                                                  'id_fasilitas':
                                                      k.id_fasilitas,
                                                  'name': k.nama_kost ?? 'Kost',
                                                  'address':
                                                      k.alamat_kost ?? '',
                                                  'pricePerMonth':
                                                      k.harga_kost ?? 0,
                                                  'distanceKm': dKm,
                                                  'imageUrl':
                                                      k.gambar_kost ?? '',
                                                });
                                              }

                                              if (dataKost.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Belum ada kost dengan koordinat lokasi.'),
                                                  ),
                                                );
                                                return;
                                              }

                                              // urutkan berdasarkan jarak terdekat
                                              dataKost.sort((a, b) =>
                                                  (a['distanceKm'] as double)
                                                      .compareTo(b['distanceKm']
                                                          as double));

                                              // Simpan jarakKostMap ke provider untuk digunakan di SAW
                                              final jarakMap = <int, double>{};
                                              for (final k in dataKost) {
                                                jarakMap[k['id_kost'] as int] =
                                                    k['distanceKm'] as double;
                                              }
                                              kostProvider
                                                  .setJarakKostMap(jarakMap);

                                              await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      RecommendationSawPage(
                                                    destinationLat: destLat,
                                                    destinationLng: destLng,
                                                    kostData: dataKost,
                                                  ),
                                                ),
                                              );
                                            } finally {
                                              if (!mounted) return;
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colorPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(s(14)),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: s(20),
                                                height: s(20),
                                                child:
                                                    const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              ),
                                              SizedBox(width: s(10)),
                                              Text(
                                                'Menghitung SAW...',
                                                style: TextStyle(
                                                  fontSize: s(16),
                                                  fontWeight: FontWeight.w600,
                                                  color: colorWhite,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
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
