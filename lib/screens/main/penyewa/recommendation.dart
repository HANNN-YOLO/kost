// lib/user_recommendation_page.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'recommendation_saw.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../providers/kost_provider.dart';
import '../../../providers/tujuan_providers.dart';

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

  String _selectedLocation = "Pilih Tempat (Lewat Peta)";
  String _coordinateText = "Klik 2x pada peta";

  late final TextEditingController _coordinateController;

  static const String _optLokasiSekarang = "Lokasi Sekarang";
  static const String _optLokasiTujuan = "Pilih Tempat (Lewat Peta)";
  static const String _optManualKoordinat = "Masukkan Titik Koordinat";

  // -------- Icon Toggle untuk Dropdown ----------
  // 0 = Mode Manual (3 jenis inputan), 1 = Mode Tempat Supabase
  int _dropdownMode = 0;

  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  // -------- WebView (Leaflet) ----------
  late final WebViewController _mapController;
  bool _mapLoaded = false;

  bool _isLoading = false;

  final http.Client _httpClient = http.Client();

  static const int _osrmMaxDestinationsPerTableRequest = 75;

  @override
  void initState() {
    super.initState();

    _coordinateController = TextEditingController(text: _coordinateText);

    // Load data tempat dari Supabase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tujuanProvider =
          Provider.of<TujuanProviders>(context, listen: false);
      tujuanProvider.readdata();
    });

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
              _coordinateController.text = _coordinateText;
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

    if (_selectedLocation == _optLokasiTujuan) {
      await _mapController.runJavaScript("clearMyLocation();");
      await _mapController.runJavaScript("clearDestination();");
      await _mapController.runJavaScript("setMode('destination');");
      if (!mounted) return;
      setState(() {
        _coordinateText = "Klik 2x pada peta";
        _coordinateController.text = _coordinateText;
      });
    } else if (_selectedLocation == _optManualKoordinat) {
      // manual: biarkan peta bisa dilihat, tapi jangan ubah titik secara tidak sengaja
      await _mapController.runJavaScript("clearMyLocation();");
      await _mapController.runJavaScript("clearDestination();");
      await _mapController.runJavaScript("setMode('readonly');");
    } else {
      await _mapController.runJavaScript("setMode('normal');");
    }
  }

  ({double lat, double lng})? _tryParseLatLng(String input) {
    final parts = input
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90) return null;
    if (lng < -180 || lng > 180) return null;
    return (lat: lat, lng: lng);
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
        _coordinateController.text = _coordinateText;
        _selectedLocation = "Lokasi Sekarang";
      });
    } catch (e) {
      debugPrint("Error ambil lokasi: $e");
      if (!mounted) return;
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
      String str = result.toString();

      // bersihkan quotes jika dibungkus
      if (str.startsWith('"') && str.endsWith('"')) {
        str = str.substring(1, str.length - 1);
        str = str.replaceAll(r'\"', '"');
      }

      if (str == 'null' || str.trim().isEmpty) {
        if (!mounted) return;
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
          _coordinateController.text = _coordinateText;
        });
      } else {
        if (!mounted) return;
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

  // Terapkan koordinat tujuan ke peta (marker + view)
  Future<void> _applyDestinationToMap(double lat, double lng) async {
    if (!_mapLoaded) return;
    try {
      await _mapController.runJavaScript("clearMyLocation();");
      await _mapController.runJavaScript("clearDestination();");
      await _mapController.runJavaScript("setMode('readonly');");
      await _mapController.runJavaScript("setDestinationLocation($lat, $lng);");
      await _mapController.runJavaScript("setView($lat, $lng, 16);");
    } catch (_) {
      // Map hanya sebagai tampilan, abaikan error JS
    }
  }

  // ---------------- Dropdown overlay ----------------
  void _openDropdown(double Function(double) s, Color bg, Color txt) {
    final penghubung = Provider.of<TujuanProviders>(context, listen: false);

    // Tentukan item dropdown berdasarkan mode
    List<Widget> dropdownItems = [];

    if (_dropdownMode == 0) {
      // Mode Manual: 3 jenis inputan
      dropdownItems = [
        _dropdownItem(_optLokasiSekarang, s, txt, isFromSupabase: false),
        _dropdownItem(_optLokasiTujuan, s, txt, isFromSupabase: false),
        _dropdownItem(_optManualKoordinat, s, txt, isFromSupabase: false),
      ];
    } else {
      // Mode Tempat Supabase: daftar tempat dari database
      final daftarTempat = penghubung.daftarTempat;
      if (daftarTempat.isEmpty) {
        dropdownItems = [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(12)),
            child: Text(
              'Belum ada tempat tersimpan',
              style: TextStyle(
                fontSize: s(14),
                color: txt.withOpacity(0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ];
      } else {
        dropdownItems = daftarTempat
            .where((t) => t.namatujuan != null)
            .map((tempat) => _dropdownItem(
                  tempat.namatujuan!,
                  s,
                  txt,
                  isFromSupabase: true,
                  lat: tempat.garislintang,
                  lng: tempat.garisbujur,
                ))
            .toList();
      }
    }

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
                      constraints: BoxConstraints(
                        maxHeight: s(250), // Batasi tinggi dropdown
                      ),
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: dropdownItems,
                        ),
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

  Widget _dropdownItem(
    String text,
    double Function(double) s,
    Color txtColor, {
    bool isFromSupabase = false,
    double? lat,
    double? lng,
  }) {
    return InkWell(
      onTap: () async {
        setState(() => _selectedLocation = text);
        _closeDropdown();

        if (isFromSupabase) {
          // Item dari Supabase - gunakan koordinat yang sudah ada
          if (lat != null && lng != null) {
            await _mapController.runJavaScript("clearMyLocation();");
            await _mapController.runJavaScript("clearDestination();");
            await _mapController.runJavaScript("setMode('readonly');");
            await _mapController
                .runJavaScript("setDestinationLocation($lat, $lng);");
            await _mapController.runJavaScript("setView($lat, $lng, 16);");
            setState(() {
              _coordinateText = '$lat, $lng';
              _coordinateController.text = _coordinateText;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Koordinat untuk "$text" tidak tersedia')),
            );
          }
        } else if (text == _optLokasiSekarang) {
          // ubah mode peta ke normal, bersihkan marker tujuan, lalu ambil lokasi saya
          await _mapController.runJavaScript("setMode('normal');");
          await _mapController.runJavaScript("clearDestination();");
          await _goToMyLocation();
        } else if (text == _optLokasiTujuan) {
          // Pilih Tempat (Lewat Peta): bersihkan marker lokasi sekarang dan ganti mode ke destination (butuh dblclick)
          await _mapController.runJavaScript("clearMyLocation();");
          await _mapController.runJavaScript("clearDestination();");
          await _mapController.runJavaScript("setMode('destination');");
          setState(() {
            _coordinateText = "Klik 2x pada peta";
            _coordinateController.text = _coordinateText;
          });
        } else if (text == _optManualKoordinat) {
          await _mapController.runJavaScript("clearMyLocation();");
          await _mapController.runJavaScript("clearDestination();");
          await _mapController.runJavaScript("setMode('readonly');");
          // Bersihkan teks agar pengguna tidak perlu menghapus manual
          // placeholder/hint akan menjelaskan format input.
          setState(() {
            _coordinateText = '';
            _coordinateController.text = '';
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(12)),
        child: Row(
          children: [
            if (isFromSupabase)
              Padding(
                padding: EdgeInsets.only(right: s(10)),
                child: Icon(
                  Icons.place,
                  size: s(18),
                  color: txtColor.withOpacity(0.6),
                ),
              ),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: s(14),
                  color: txtColor,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
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
    _coordinateController.dispose();
    _controller.dispose();
    _httpClient.close();
    super.dispose();
  }

  Future<Map<String, dynamic>?> _getJsonWithTimeout(Uri uri) async {
    try {
      if (!mounted) return null;
      final response =
          await _httpClient.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return null;
    } catch (_) {
      return null;
    }
  }

  // =================================================
  // OSRM: Jarak routing satu arah (km)
  // Catatan:
  // - Menggunakan jarak jalan (routing) via OSRM.
  // - Arah akan ditentukan oleh caller (di halaman ini: Tujuan → Kost).
  // =================================================
  Future<double?> _osrmRouteOneWayKm({
    required double fromLat,
    required double fromLng,
    required double toLat,
    required double toLng,
  }) async {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '$fromLng,$fromLat;$toLng,$toLat?overview=false&alternatives=false&steps=false',
    );

    try {
      final data = await _getJsonWithTimeout(uri);
      if (data == null) return null;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return null;
      final distanceMeters = (routes[0]['distance'] as num?)?.toDouble();
      if (distanceMeters == null) return null;
      return distanceMeters / 1000.0;
    } catch (e) {
      debugPrint('OSRM route exception: $e');
      return null;
    }
  }

  // =================================================
  // OSRM Table batching: 1 Tujuan → banyak Kost (km)
  // Jauh lebih cepat daripada request route per-kost.
  // - Menggunakan shortest-path distance (annotations=distance).
  // - Di-chunk untuk menghindari URL terlalu panjang.
  // =================================================
  Future<Map<int, double>> _osrmTableDistancesKm({
    required double sourceLat,
    required double sourceLng,
    required List<({int id, double lat, double lng})> destinations,
  }) async {
    if (destinations.isEmpty) return <int, double>{};

    final Map<int, double> out = <int, double>{};

    for (var start = 0;
        start < destinations.length;
        start += _osrmMaxDestinationsPerTableRequest) {
      final chunk = destinations
          .skip(start)
          .take(_osrmMaxDestinationsPerTableRequest)
          .toList();

      // coordinates: [source, dest0, dest1, ...]
      final coords = <String>['$sourceLng,$sourceLat'];
      for (final d in chunk) {
        coords.add('${d.lng},${d.lat}');
      }

      final sourcesParam = '0';
      final destinationsParam = List.generate(
        chunk.length,
        (i) => '${i + 1}',
      ).join(';');

      final uri = Uri.parse(
        'https://router.project-osrm.org/table/v1/driving/${coords.join(';')}'
        '?sources=$sourcesParam&destinations=$destinationsParam&annotations=distance',
      );

      try {
        final data = await _getJsonWithTimeout(uri);
        if (data == null) continue;
        final distances = data['distances'];
        if (distances is! List || distances.isEmpty) continue;

        final row = distances[0];
        if (row is! List || row.length < chunk.length) continue;

        for (var i = 0; i < chunk.length; i++) {
          final dMeters = row[i];
          if (dMeters is num) {
            final km = dMeters.toDouble() / 1000.0;
            if (km.isFinite && km >= 0) {
              out[chunk[i].id] = km;
            }
          }
        }
      } catch (e) {
        debugPrint('OSRM table exception: $e');
      }
    }

    return out;
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
                                // ===== 2 ICON TOGGLE =====
                                Row(
                                  children: [
                                    Text(
                                      'Pilih Lokasi',
                                      style: TextStyle(
                                        fontSize: s(12),
                                        fontWeight: FontWeight.w500,
                                        color:
                                            colorTextPrimary.withOpacity(0.85),
                                      ),
                                    ),
                                    const Spacer(),
                                    // Icon 1: Mode Manual (3 jenis inputan)
                                    Tooltip(
                                      message: 'Input Manual',
                                      child: InkWell(
                                        onTap: () {
                                          if (_dropdownMode != 0) {
                                            setState(() {
                                              _dropdownMode = 0;
                                              _selectedLocation =
                                                  _optLokasiTujuan;
                                              _coordinateText =
                                                  'Klik 2x pada peta';
                                              _coordinateController.text =
                                                  _coordinateText;
                                            });
                                            _syncMapModeWithSelectedLocation();
                                          }
                                          // Buka dropdown otomatis
                                          if (!_dropdownOpen) {
                                            _openDropdown(s, colorWhite,
                                                colorTextPrimary);
                                          }
                                        },
                                        borderRadius:
                                            BorderRadius.circular(s(8)),
                                        child: Container(
                                          padding: EdgeInsets.all(s(8)),
                                          decoration: BoxDecoration(
                                            color: _dropdownMode == 0
                                                ? colorPrimary.withOpacity(0.1)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(s(8)),
                                            border: Border.all(
                                              color: _dropdownMode == 0
                                                  ? colorPrimary
                                                  : colorTextPrimary
                                                      .withOpacity(0.2),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.edit_location_alt,
                                            size: s(20),
                                            color: _dropdownMode == 0
                                                ? colorPrimary
                                                : colorTextPrimary
                                                    .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: s(10)),
                                    // Icon 2: Mode Tempat Supabase
                                    Tooltip(
                                      message: 'Tempat Tersimpan',
                                      child: InkWell(
                                        onTap: () {
                                          if (_dropdownMode != 1) {
                                            setState(() {
                                              _dropdownMode = 1;
                                              _selectedLocation =
                                                  'Pilih Tempat';
                                              _coordinateText = '';
                                              _coordinateController.text = '';
                                            });
                                          }
                                          // Buka dropdown otomatis
                                          if (!_dropdownOpen) {
                                            _openDropdown(s, colorWhite,
                                                colorTextPrimary);
                                          }
                                        },
                                        borderRadius:
                                            BorderRadius.circular(s(8)),
                                        child: Container(
                                          padding: EdgeInsets.all(s(8)),
                                          decoration: BoxDecoration(
                                            color: _dropdownMode == 1
                                                ? colorPrimary.withOpacity(0.1)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(s(8)),
                                            border: Border.all(
                                              color: _dropdownMode == 1
                                                  ? colorPrimary
                                                  : colorTextPrimary
                                                      .withOpacity(0.2),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.business,
                                            size: s(20),
                                            color: _dropdownMode == 1
                                                ? colorPrimary
                                                : colorTextPrimary
                                                    .withOpacity(0.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                          // Icon berdasarkan mode
                                          Icon(
                                            _dropdownMode == 0
                                                ? Icons.edit_location_alt
                                                : Icons.business,
                                            size: s(20),
                                            color: colorPrimary,
                                          ),
                                          SizedBox(width: s(10)),
                                          Expanded(
                                            child: Text(
                                              _selectedLocation,
                                              style: TextStyle(
                                                fontSize: s(14),
                                                color: colorTextPrimary
                                                    .withOpacity(0.6),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                                        child: TextField(
                                          controller: _coordinateController,
                                          readOnly: _selectedLocation !=
                                              _optManualKoordinat,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(
                                            signed: true,
                                            decimal: true,
                                          ),
                                          style: TextStyle(
                                            fontSize: s(14),
                                            color: colorTextPrimary
                                                .withOpacity(0.8),
                                          ),
                                          decoration: InputDecoration(
                                            isCollapsed: true,
                                            border: InputBorder.none,
                                            hintText:
                                                'Contoh: -5.147665, 119.432731',
                                            hintStyle: TextStyle(
                                              fontSize: s(14),
                                              color: colorTextPrimary
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                          onChanged: (value) {
                                            _coordinateText = value;
                                          },
                                          onSubmitted: (value) async {
                                            // Saat pengguna selesai mengetik koordinat manual,
                                            // coba parse dan langsung tampilkan di peta.
                                            final parsed =
                                                _tryParseLatLng(value.trim());
                                            if (parsed == null) {
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Format koordinat tidak valid. Contoh: -5.147665, 119.432731',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            _coordinateText =
                                                '${parsed.lat}, ${parsed.lng}';
                                            _coordinateController.text =
                                                _coordinateText;

                                            await _applyDestinationToMap(
                                                parsed.lat, parsed.lng);
                                          },
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
                                          controller: _mapController,
                                          gestureRecognizers: {
                                            Factory<
                                                OneSequenceGestureRecognizer>(
                                              () => EagerGestureRecognizer(),
                                            ),
                                          },
                                        ),
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
                                                      'Silakan isi titik koordinat tujuan (klik 2x di peta atau masukkan manual).'),
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

                                            // Update marker dan tampilan peta
                                            await _applyDestinationToMap(
                                                destLat, destLng);

                                            if (!mounted) return;

                                            setState(() {
                                              _isLoading = true;
                                            });

                                            try {
                                              if (!mounted) return;
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

                                              // Kumpulkan semua kost yang punya koordinat
                                              final destinations = <({
                                                int id,
                                                double lat,
                                                double lng
                                              })>[];
                                              for (final k in allKost) {
                                                final lat = k.garis_lintang;
                                                final lng = k.garis_bujur;
                                                final id = k.id_kost;
                                                if (id == null ||
                                                    lat == null ||
                                                    lng == null) {
                                                  continue;
                                                }
                                                destinations.add((
                                                  id: id,
                                                  lat: lat,
                                                  lng: lng
                                                ));
                                              }

                                              if (destinations.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Belum ada kost dengan koordinat lokasi.'),
                                                  ),
                                                );
                                                return;
                                              }

                                              // Hitung jarak tujuan→kost secara batching (lebih cepat)
                                              final distanceById =
                                                  await _osrmTableDistancesKm(
                                                sourceLat: destLat,
                                                sourceLng: destLng,
                                                destinations: destinations,
                                              );

                                              // Fallback: untuk yang belum dapat jarak dari table,
                                              // coba OSRM route satu-per-satu (masih akurat, cuma lebih lambat)
                                              if (distanceById.length <
                                                  destinations.length) {
                                                for (final s in destinations) {
                                                  if (distanceById.containsKey(
                                                      s.id)) continue;
                                                  final dKm =
                                                      await _osrmRouteOneWayKm(
                                                    fromLat: destLat,
                                                    fromLng: destLng,
                                                    toLat: s.lat,
                                                    toLng: s.lng,
                                                  );
                                                  if (dKm != null) {
                                                    distanceById[s.id] = dKm;
                                                  }
                                                }
                                              }

                                              // Bentuk dataKost untuk halaman SAW (skip yang tetap gagal)
                                              for (final k in allKost) {
                                                final id = k.id_kost;
                                                if (id == null) continue;
                                                final dKm = distanceById[id];
                                                if (dKm == null) {
                                                  debugPrint(
                                                      '⚠️ Skip kost ${k.nama_kost} - OSRM tidak mengembalikan jarak');
                                                  continue;
                                                }

                                                dataKost.add({
                                                  'id_kost': id,
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

                                              if (!mounted) return;

                                              if (dataKost.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Tidak ada kost yang berhasil dihitung jaraknya oleh OSRM.'),
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

                                              if (!mounted) return;

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
                                                'Harap menunggu...',
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
