import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import '../../../providers/tujuan_providers.dart';

class AdminPlacesPage extends StatefulWidget {
  const AdminPlacesPage({super.key});

  @override
  State<AdminPlacesPage> createState() => _AdminPlacesPageState();
}

class _AdminPlacesPageState extends State<AdminPlacesPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _coordController = TextEditingController();
  int iniangka = 0;
  bool keadaan = true;

  int _locationOptionRequestId = 0;

  // late  fungsi;

  late Future fungsi;

  perbaruidata() {
    fungsi = Provider.of<TujuanProviders>(context).readdata();
    keadaan = false;
  }

  // WebView Leaflet
  late final WebViewController _mapController;
  bool _mapLoaded = false;

  // Debounce untuk update peta saat koordinat diketik
  Timer? _debounceTimer;

  // ═══════════════════════════════════════════════════════════════════════════
  // OPSI LOKASI UNTUK TITIK KOORDINAT (seperti di form_house_pemilik.dart)
  // ═══════════════════════════════════════════════════════════════════════════
  String _selectedLocationOption = 'Lokasi Tujuan';

  static const String _optLokasiSekarang = 'Lokasi Sekarang';
  static const String _optLokasiTujuan = 'Lokasi Tujuan';
  static const String _optManualKoordinat = 'Masukkan Titik Koordinat';

  @override
  void initState() {
    super.initState();
    // perbaruidata();
    // final penghubung = Provider.of<TujuanProviders>(context, listen: false);

    // Default teks untuk mode "Tujuan" saat pertama kali membuka form
    _coordController.text = 'Klik 2x pada peta';

    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _mapLoaded = true);
              // Sinkronkan mode peta dengan opsi lokasi yang dipilih
              _syncMapModeWithLocationOption();
            }
          },
          onWebResourceError: (err) {
            // biarkan _mapLoaded tetap false jika gagal
          },
        ),
      )
      // ═══════════════════════════════════════════════════════════════════════
      // JAVASCRIPT CHANNEL untuk menerima koordinat dari peta (double-click)
      // ═══════════════════════════════════════════════════════════════════════
      ..addJavaScriptChannel(
        'ToFlutter',
        onMessageReceived: (message) {
          try {
            final data = jsonDecode(message.message);
            if (data['type'] == 'destination_selected') {
              final latNum = (data['lat'] as num?)?.toDouble();
              final lngNum = (data['lng'] as num?)?.toDouble();
              if (latNum != null && lngNum != null) {
                _coordController.text =
                    '${latNum.toStringAsFixed(6)}, ${lngNum.toStringAsFixed(6)}';
              }
            }
          } catch (e) {
            debugPrint('Error parsing JS message: $e');
          }
        },
      );

    _loadMapHtmlFromAssets();

    _coordController.addListener(_onCoordChanged);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    fungsi = Provider.of<TujuanProviders>(context).readdata();
    keadaan = false;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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

  void _onCoordChanged() {
    if (!_mapLoaded) return;
    if (_selectedLocationOption != _optManualKoordinat) return;

    final text = _coordController.text.trim();
    final parsed = _tryParseLatLng(text);
    if (parsed == null) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _updateMapManualLocation(parsed[0], parsed[1]);
    });
  }

  String? _getCoordErrorText(String rawText) {
    final text = rawText.trim();

    // Placeholder tujuan jangan dianggap error.
    if (_selectedLocationOption == _optLokasiTujuan) {
      final bool looksLikeCoordinate = text.contains(',');
      if (!looksLikeCoordinate) return null;
    }

    if (text.isEmpty) return null;
    final parsed = _tryParseLatLng(text);
    if (parsed == null) return 'Titik koordinat tidak ditemukan';
    return null;
  }

  Future<void> _updateMapManualLocation(double lat, double lng) async {
    if (!_mapLoaded) return;

    try {
      await _mapController.runJavaScript(
        'clearMyLocation(); clearDestination(); setMarker($lat, $lng);',
      );
    } catch (_) {
      // abaikan error JS ringan
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

  List<double>? _tryParseLatLng(String text) {
    final parts = text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0]);
    final lng = double.tryParse(parts[1]);
    if (lat == null || lng == null) return null;
    if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
    return [lat, lng];
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FUNGSI UNTUK SINKRONISASI MODE PETA DENGAN OPSI LOKASI
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _syncMapModeWithLocationOption() async {
    if (!_mapLoaded) return;

    try {
      if (_selectedLocationOption == _optLokasiTujuan) {
        // Mode destination: user bisa double-click untuk pilih titik
        await _mapController.runJavaScript("setMode('destination');");
      } else if (_selectedLocationOption == _optManualKoordinat) {
        // Mode normal: marker biasa
        await _mapController.runJavaScript("setMode('normal');");
      } else if (_selectedLocationOption == _optLokasiSekarang) {
        // Mode readonly: tidak bisa klik
        await _mapController.runJavaScript("setMode('readonly');");
      }
    } catch (e) {
      debugPrint('Error syncing map mode: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FUNGSI UNTUK MENDAPATKAN LOKASI SEKARANG (GPS)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _useCurrentLocation() async {
    try {
      if (_selectedLocationOption != _optLokasiSekarang) return;

      if (!_mapLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Peta belum siap, tunggu sebentar...')),
        );
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan lokasi tidak aktif.')),
        );
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

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = pos.latitude;
      final lng = pos.longitude;

      // Jika user sudah pindah opsi saat proses GPS berjalan, jangan override UI.
      if (_selectedLocationOption != _optLokasiSekarang) return;

      _coordController.text =
          '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

      await _updateMapLocation(lat, lng);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi: $e')),
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FUNGSI UNTUK MENANGANI PERUBAHAN OPSI LOKASI
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> _onLocationOptionChanged(
    String newOption, {
    void Function(VoidCallback)? modalSetState,
  }) async {
    final int requestId = ++_locationOptionRequestId;

    if (mounted) {
      setState(() {
        _selectedLocationOption = newOption;
      });
    }
    modalSetState?.call(() {});

    await _syncMapModeWithLocationOption();

    if (!mounted || requestId != _locationOptionRequestId) return;

    // Pastikan marker mode sebelumnya hilang saat pindah opsi.
    if (_mapLoaded) {
      try {
        await _mapController.runJavaScript(
          'clearMyLocation(); clearDestination();',
        );
      } catch (_) {}
    }

    if (newOption == _optLokasiTujuan) {
      // Mode tujuan: user pilih di peta dengan double-click
      _coordController.text = 'Klik 2x pada peta';
      modalSetState?.call(() {});
    } else if (newOption == _optLokasiSekarang) {
      // Mode lokasi sekarang: ambil GPS
      await _useCurrentLocation();
    } else if (newOption == _optManualKoordinat) {
      // Mode manual: user ketik koordinat
      _coordController.text = '';
      modalSetState?.call(() {});
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET IKON OPSI LOKASI (Tujuan, Sekarang, Koordinat)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLocationOptionIcon({
    required IconData icon,
    required String label,
    required String value,
    required double lebar,
    void Function(VoidCallback)? modalSetState,
  }) {
    final bool isActive = _selectedLocationOption == value;
    final Color color = isActive ? const Color(0xFF1C3B98) : Colors.grey;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // Jangan await di onTap untuk menghindari tap terasa "macet".
        // Gunakan mekanisme requestId di _onLocationOptionChanged.
        _onLocationOptionChanged(value, modalSetState: modalSetState);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: lebar * 0.14,
            height: lebar * 0.14,
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF1C3B98).withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isActive ? const Color(0xFF1C3B98) : Colors.grey.shade300,
                width: isActive ? 2 : 1,
              ),
            ),
            child: Icon(icon, color: color, size: lebar * 0.06),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: lebar * 0.028,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGET INPUT KOORDINAT DENGAN 3 OPSI (untuk digunakan di bottom sheet)
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildKoordinatInputSection(
    double tinggi,
    double lebar, {
    void Function(VoidCallback)? modalSetState,
  }) {
    final coordListenable = _coordController;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Titik Koordinat',
          style: TextStyle(
            fontSize: lebar * 0.035,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF12111F),
          ),
        ),
        SizedBox(height: tinggi * 0.01),

        // 3 Opsi Lokasi
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildLocationOptionIcon(
              icon: Icons.flag_outlined,
              label: 'Tujuan',
              value: _optLokasiTujuan,
              lebar: lebar,
              modalSetState: modalSetState,
            ),
            _buildLocationOptionIcon(
              icon: Icons.my_location,
              label: 'Sekarang',
              value: _optLokasiSekarang,
              lebar: lebar,
              modalSetState: modalSetState,
            ),
            _buildLocationOptionIcon(
              icon: Icons.edit_location_alt_outlined,
              label: 'Koordinat',
              value: _optManualKoordinat,
              lebar: lebar,
              modalSetState: modalSetState,
            ),
          ],
        ),
        SizedBox(height: tinggi * 0.015),

        // TextField + error (error dihitung dari controller)
        AnimatedBuilder(
          animation: coordListenable,
          builder: (context, _) {
            final errText = _getCoordErrorText(_coordController.text);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _coordController,
                  keyboardType: _selectedLocationOption == _optManualKoordinat
                      ? TextInputType.text
                      : TextInputType.none,
                  readOnly: _selectedLocationOption != _optManualKoordinat,
                  decoration: InputDecoration(
                    hintText: _selectedLocationOption == _optManualKoordinat
                        ? '-5.147665, 119.432731'
                        : _selectedLocationOption == _optLokasiTujuan
                            ? 'Klik 2x pada peta untuk memilih titik'
                            : 'Menunggu lokasi GPS...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    suffixIcon: _selectedLocationOption == _optLokasiSekarang
                        ? IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _useCurrentLocation,
                            tooltip: 'Refresh Lokasi',
                          )
                        : null,
                  ),
                ),
                if (errText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errText,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            );
          },
        ),

        SizedBox(height: tinggi * 0.015),

        // Peta WebView
        SizedBox(
          height: tinggi * 0.24,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                WebViewWidget(
                  controller: _mapController,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                ),
                if (!_mapLoaded)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openPlaceFormSheet({
    required TujuanProviders penghubung,
    required double tinggiLayar,
    required double lebarLayar,
    int? editId,
    String? initialName,
    String? initialCoord,
  }) async {
    final isEdit = editId != null;

    _selectedLocationOption = isEdit ? _optManualKoordinat : _optLokasiTujuan;
    _nameController.text = (initialName ?? '').trim();
    _coordController.text =
        isEdit ? (initialCoord ?? '').trim() : 'Klik 2x pada peta';

    await _syncMapModeWithLocationOption();

    if (_mapLoaded) {
      try {
        await _mapController.runJavaScript(
          'clearMyLocation(); clearDestination();',
        );
      } catch (_) {}
    }

    if (isEdit) {
      final parsed = _tryParseLatLng(_coordController.text.trim());
      if (parsed != null) {
        await _updateMapManualLocation(parsed[0], parsed[1]);
      }
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (context, modalSetState) {
            final merged = Listenable.merge([
              _nameController,
              _coordController,
            ]);

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
                        child: SingleChildScrollView(
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
                                isEdit ? 'Edit Tempat' : 'Tambah Tempat',
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
                              SizedBox(height: tinggiLayar * 0.015),
                              _buildKoordinatInputSection(
                                tinggiLayar,
                                lebarLayar,
                                modalSetState: modalSetState,
                              ),
                              SizedBox(height: tinggiLayar * 0.018),
                              SizedBox(
                                width: double.infinity,
                                height: tinggiLayar * 0.055,
                                child: AnimatedBuilder(
                                  animation: merged,
                                  builder: (context, _) {
                                    final name = _nameController.text.trim();
                                    final coord = _coordController.text.trim();
                                    final canSave = name.isNotEmpty &&
                                        _tryParseLatLng(coord) != null;

                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: canSave
                                            ? const Color(0xFF12111F)
                                            : Colors.grey.shade400,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      ),
                                      onPressed: canSave
                                          ? () {
                                              if (isEdit) {
                                                penghubung.updateddata(
                                                  editId,
                                                  name,
                                                  coord,
                                                );
                                              } else {
                                                penghubung.createdata(
                                                  name,
                                                  coord,
                                                );
                                              }

                                              _nameController.clear();
                                              _coordController.clear();
                                              Navigator.of(ctx).pop();
                                            }
                                          : null,
                                      child: Text(
                                        isEdit
                                            ? 'Simpan Perubahan'
                                            : 'Simpan Tempat',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
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
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<TujuanProviders>(context, listen: false);

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
                          '${penghubung.mydata.length}',
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
                child: penghubung.mydata.length == 0
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
                        itemCount: penghubung.mydata.length,
                        // .length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: tinggiLayar * 0.015),
                        itemBuilder: (context, index) {
                          // final place = iniangka;
                          // [index];
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
                                        // place.name,
                                        // "nama",
                                        "${penghubung.mydata[index].namatujuan}",
                                        maxLines: 2,
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
                                            final coord =
                                                '${penghubung.mydata[index].garislintang}, ${penghubung.mydata[index].garisbujur}';
                                            _openPlaceFormSheet(
                                              penghubung: penghubung,
                                              tinggiLayar: tinggiLayar,
                                              lebarLayar: lebarLayar,
                                              editId: penghubung
                                                  .mydata[index].id_tujuan!,
                                              initialName: penghubung
                                                  .mydata[index].namatujuan,
                                              initialCoord: coord,
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
                                            await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Hapus Tempat?'),
                                                  content: Text(
                                                    'Yakin ingin menghapus tempat "${penghubung.mydata[index].namatujuan}"? Tindakan ini tidak dapat dibatalkan.',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(ctx)
                                                            .pop(false);
                                                      },
                                                      child:
                                                          const Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        penghubung.deletedata(
                                                          penghubung
                                                              .mydata[index]
                                                              .id_tujuan!,
                                                        );
                                                        Navigator.of(ctx)
                                                            .pop(true);
                                                      },
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
                                        // '${place.lat}, ${place.lng}',
                                        // "titik koordinat",
                                        "${penghubung.mydata[index].garislintang},${penghubung.mydata[index].garisbujur}",
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
                    _openPlaceFormSheet(
                      penghubung: penghubung,
                      tinggiLayar: tinggiLayar,
                      lebarLayar: lebarLayar,
                    );
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
}
