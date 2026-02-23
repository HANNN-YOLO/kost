// import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:kost_saw/models/kost_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart'
    show rootBundle, FilteringTextInputFormatter;
import '../../custom/custom_dropdown_searh_v2.dart';
import '../../custom/label_1baris_full.dart';
import '../../custom/custom_UploadFotov2.dart';
import '../../custom/showdialog_eror.dart';
import '../../custom/custom_editfotov2.dart';
import '../../custom/textfield_with_dropdown.dart';
import 'package:provider/provider.dart';
import '../../../utils/thousands_separator_input_formatter.dart';
import '../../../providers/kost_provider.dart';
import 'package:collection/collection.dart';
import 'package:geolocator/geolocator.dart';
import '../../../providers/profil_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/nominatim_geocoding_service.dart';

class listinputan {
  final TextEditingController namaFasilitasController = TextEditingController();

  void dispose() {
    namaFasilitasController.dispose();
  }
}

class FormHouse extends StatefulWidget {
  static const arah = "/form-house-admin";
  const FormHouse({super.key});

  @override
  State<FormHouse> createState() => _FormAddHouseState();
}

class _FormAddHouseState extends State<FormHouse> {
  // final TextEditingController? _namapemilik = TextEditingController();
  final TextEditingController _namakost = TextEditingController();
  final TextEditingController _notlpn = TextEditingController();
  final TextEditingController _alamat = TextEditingController();
  final TextEditingController _harga = TextEditingController();

  final TextEditingController _koordinatController = TextEditingController();
  final TextEditingController _panjang = TextEditingController();
  final TextEditingController _lebar = TextEditingController();
  bool allstatus = false;
  int index = 0;
  bool keadaan = true;
  bool _isSubmitting = false;

  String? _initialEditSignature;

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) {
        return ShowdialogEror(label: message);
      },
    );
  }

  late final Listenable _formFieldsListenable;
  List<listinputan> _inilist = [];

  final TextEditingController _facilityInputController =
      TextEditingController();
  final FocusNode _facilityFocusNode = FocusNode();
  int? _editingFacilityIndex;

  // Key khusus untuk menjaga instance WebView tidak bentrok saat navigasi
  late final Key _mapViewKey =
      ValueKey('admin_webview_${DateTime.now().microsecondsSinceEpoch}');

  // Opsi lokasi untuk titik koordinat (mirip halaman rekomendasi penyewa)
  String _selectedLocationOption = 'Lokasi Tujuan';

  static const String _optLokasiSekarang = 'Lokasi Sekarang';
  static const String _optLokasiTujuan = 'Lokasi Tujuan';
  static const String _optManualKoordinat = 'Masukkan Titik Koordinat';

  // -------- WebView (Leaflet) ----------
  late final WebViewController _mapController;
  bool _mapLoaded = false;

  // -------- Geocoding (Alamat -> Koordinat) ----------
  bool _isGeocodingAddress = false;
  int _geocodeRequestSerial = 0;
  double? _pendingMarkerLat;
  double? _pendingMarkerLng;

  // -------- Autocomplete Alamat ----------
  List<NominatimPlace> _alamatSuggestions = [];
  bool _isLoadingAlamatSuggestions = false;
  Timer? _alamatDebounceTimer;
  final FocusNode _alamatFocusNode = FocusNode();

  // Debounce timer untuk update peta
  Timer? _debounceTimer;

  List<Map<String, dynamic>> fasilitasList = [
    {'nama': 'Tempat Tidur', 'ikon': Icons.bed, 'cek': false},
    {'nama': 'Kamar Mandi dalam', 'ikon': Icons.bathtub_outlined, 'cek': false},
    {'nama': 'Meja', 'ikon': Icons.desk, 'cek': false},
    {'nama': 'Tempat Parkir', 'ikon': Icons.local_parking, 'cek': false},
    {'nama': 'Lemari', 'ikon': Icons.chair_alt, 'cek': false},
    {'nama': 'AC', 'ikon': Icons.ac_unit, 'cek': false},
    {'nama': 'TV', 'ikon': Icons.tv, 'cek': false},
    {'nama': 'Kipas Angin', 'ikon': Icons.wind_power_outlined, 'cek': false},
    {'nama': 'Dapur dalam', 'ikon': Icons.kitchen, 'cek': false},
    {'nama': 'WiFi', 'ikon': Icons.wifi, 'cek': false},
  ];

  IconData? ikonTerpilih;

  void _coerceDeletedSubkriteriaSelections(
    KostProvider penghubung, {
    bool notify = false,
  }) {
    final optKeamanan = penghubung.keamananOptionsDynamic;
    if (optKeamanan.isNotEmpty && penghubung.jeniskeamanans != 'Pilih') {
      if (!optKeamanan.contains(penghubung.jeniskeamanans)) {
        if (notify) {
          penghubung.pilihkeamanan('Pilih');
        } else {
          penghubung.jeniskeamanans = 'Pilih';
        }
      }
    }

    final optBatas = penghubung.batasJamMalamOptionsDynamic;
    if (optBatas.isNotEmpty && penghubung.batasjammalams != 'Pilih') {
      if (!optBatas.contains(penghubung.batasjammalams)) {
        if (notify) {
          penghubung.pilihbatasjammalam('Pilih');
        } else {
          penghubung.batasjammalams = 'Pilih';
        }
      }
    }

    final optAir = penghubung.jenisAirOptionsDynamic;
    if (optAir.isNotEmpty && penghubung.jenispembayaranairs != 'Pilih') {
      if (!optAir.contains(penghubung.jenispembayaranairs)) {
        if (notify) {
          penghubung.pilihjenispembayaranair('Pilih');
        } else {
          penghubung.jenispembayaranairs = 'Pilih';
        }
      }
    }

    final optListrik = penghubung.jenisListrikOptionsDynamic;
    if (optListrik.isNotEmpty && penghubung.jenislistriks != 'Pilih') {
      if (!optListrik.contains(penghubung.jenislistriks)) {
        if (notify) {
          penghubung.pilihjenislistrik('Pilih');
        } else {
          penghubung.jenislistriks = 'Pilih';
        }
      }
    }

    final optJenisKost = penghubung.jenisKostOptionsDynamic;
    if (optJenisKost.isNotEmpty && penghubung.jeniskosts != 'Pilih') {
      if (!optJenisKost.contains(penghubung.jeniskosts)) {
        if (notify) {
          penghubung.pilihkost('Pilih');
        } else {
          penghubung.jeniskosts = 'Pilih';
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Default teks untuk mode "Tujuan" saat pertama kali membuka form
    _koordinatController.text = 'Klik 2x pada peta';

    // Default teks "Jalan " untuk field alamat agar user langsung lanjut ketik
    // (akan di-override di didChangeDependencies jika mode edit)
    _alamat.text = 'Jalan ';
    // Posisikan cursor di akhir teks
    _alamat.selection = TextSelection.fromPosition(
      TextPosition(offset: _alamat.text.length),
    );

    // 🔄 REFRESH kriteria/subkriteria + daftar user/pemilik agar dropdown selalu up-to-date
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final penghubung = Provider.of<KostProvider>(context, listen: false);

      // Dropdown "Pemilik Kost" menggunakan list user dari AuthProvider (proxy ke KostProvider).
      // ProfilProvider dipakai untuk mengambil kontak pemilik.
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final profil = Provider.of<ProfilProvider>(context, listen: false);

      try {
        await Future.wait([
          penghubung.fetchKriteria(),
          penghubung.fetchSubkriteria(),
          auth.readrole(),
          profil.readuser(),
        ]);
      } catch (_) {
        // Jangan blok halaman jika refresh gagal.
        await Future.wait([
          penghubung.fetchKriteria(),
          penghubung.fetchSubkriteria(),
        ]);
      }

      // Pastikan build terpanggil sekali setelah data user baru masuk
      // (karena beberapa provider di-build dengan listen:false).
      if (mounted) setState(() {});
    });

    // Buat controller WebView (webview_flutter >=4.x)
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true) // Aktifkan zoom
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            if (mounted) {
              setState(() => _mapLoaded = true);
              // Sinkronkan mode peta dengan opsi lokasi yang terpilih
              await _syncMapModeWithLocationOption();

              // Jika ada marker hasil geocoding sebelum map selesai load, apply sekarang
              final lat = _pendingMarkerLat;
              final lng = _pendingMarkerLng;
              if (lat != null && lng != null) {
                _pendingMarkerLat = null;
                _pendingMarkerLng = null;
                await _updateMapLocation(lat, lng);
              }
            }
          },
          onWebResourceError: (err) {
            // Error handling tanpa debug print yang berat
          },
        ),
      )
      ..addJavaScriptChannel(
        'ToFlutter',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final dynamic payload = json.decode(message.message);
            if (payload is Map && payload['type'] == 'destination_selected') {
              final double lat = (payload['lat'] as num).toDouble();
              final double lng = (payload['lng'] as num).toDouble();

              if (!mounted) return;

              // Saat user double tap di peta pada mode Tujuan,
              // isikan titik koordinat dan tampilkan marker biru.
              setState(() {
                _selectedLocationOption = _optLokasiTujuan;
                _koordinatController.text = '$lat, $lng';
              });

              await _updateMapLocation(lat, lng);
            }
          } catch (_) {
            // Abaikan pesan yang tidak valid
          }
        },
      );

    // Load map html setelah frame pertama agar WebViewWidget sudah ter-mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadMapHtmlFromAssets();
    });

    // Listener untuk koordinat controller
    _koordinatController.addListener(_onKoordinatChanged);

    // Agar tombol submit bisa update tanpa rebuild seluruh halaman
    _formFieldsListenable = Listenable.merge([
      _namakost,
      _notlpn,
      _alamat,
      _harga,
      _panjang,
      _lebar,
      _koordinatController,
    ]);
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

    // Debounce: tunggu sebentar setelah user berhenti mengetik
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _parseAndUpdateMap(text);
    });
  }

  // Parse koordinat dan update peta
  void _parseAndUpdateMap(String text) {
    if (!mounted) return;

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
      // Gunakan marker kost (biru) agar responsif dan konsisten
      await _mapController.runJavaScript(
        "clearMyLocation(); clearDestination(); setMarker($lat, $lng);",
      );
    } catch (e) {
      // Error handling
    }
  }

  // Sinkronkan mode peta dengan opsi lokasi yang terpilih
  Future<void> _syncMapModeWithLocationOption() async {
    if (!_mapLoaded || !mounted) return;

    try {
      if (_selectedLocationOption == _optLokasiTujuan) {
        await _mapController.runJavaScript(
          "clearMyLocation(); clearDestination(); setMode('destination');",
        );
      } else if (_selectedLocationOption == _optManualKoordinat) {
        await _mapController.runJavaScript(
          "clearMyLocation(); clearDestination(); setMode('readonly');",
        );
      } else if (_selectedLocationOption == _optLokasiSekarang) {
        await _mapController.runJavaScript(
          "clearMyLocation(); clearDestination(); setMode('normal');",
        );
      }
    } catch (e) {
      // Error handling ringan
    }
  }

  Future<void> _geocodeAlamatToKoordinat() async {
    final query = _alamat.text.trim();
    if (query.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat masih kosong.')),
      );
      return;
    }

    final requestId = ++_geocodeRequestSerial;
    if (mounted) setState(() => _isGeocodingAddress = true);

    try {
      final results = await NominatimGeocodingService.instance.searchAddress(
        query,
        limit: 5,
        countryCodes: 'id',
        acceptLanguage: 'id',
        userAgent: 'kost-saw/1.0 (flutter; geocoding)',
      );

      if (!mounted || requestId != _geocodeRequestSerial) return;

      if (results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alamat tidak ditemukan.')),
        );
        return;
      }

      NominatimPlace? selected;
      if (results.length == 1) {
        selected = results.first;
      } else {
        selected = await _pickNominatimResult(results);
      }

      if (!mounted || requestId != _geocodeRequestSerial) return;
      if (selected == null) return;

      await _applyLatLngToFormAndMap(selected.lat, selected.lng);
    } catch (e) {
      if (!mounted || requestId != _geocodeRequestSerial) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencari koordinat: $e')),
      );
    } finally {
      if (!mounted || requestId != _geocodeRequestSerial) return;
      setState(() => _isGeocodingAddress = false);
    }
  }

  Future<NominatimPlace?> _pickNominatimResult(
    List<NominatimPlace> results,
  ) async {
    if (!mounted) return null;

    return showModalBottomSheet<NominatimPlace>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final place = results[index];
              return ListTile(
                title: Text(
                  place.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${place.lat}, ${place.lng}'),
                onTap: () => Navigator.of(context).pop(place),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _applyLatLngToFormAndMap(double lat, double lng) async {
    if (!mounted) return;

    setState(() {
      _selectedLocationOption = _optManualKoordinat;
      _koordinatController.text = '$lat, $lng';
    });

    if (!_mapLoaded) {
      _pendingMarkerLat = lat;
      _pendingMarkerLng = lng;
      return;
    }

    await _syncMapModeWithLocationOption();
    await _updateMapLocation(lat, lng);
  }

  // -------- Autocomplete Alamat: Fetch Suggestions ----------
  void _fetchAlamatSuggestions(String query) {
    // Cancel timer sebelumnya
    _alamatDebounceTimer?.cancel();

    final trimmed = query.trim();
    if (trimmed.length < 3) {
      if (_alamatSuggestions.isNotEmpty) {
        setState(() => _alamatSuggestions = []);
      }
      return;
    }

    // Debounce 600ms agar tidak spam request
    _alamatDebounceTimer = Timer(const Duration(milliseconds: 600), () async {
      if (!mounted) return;
      setState(() => _isLoadingAlamatSuggestions = true);

      try {
        final results = await NominatimGeocodingService.instance.searchAddress(
          trimmed,
          limit: 5,
          countryCodes: 'id',
          acceptLanguage: 'id',
          userAgent: 'kost-saw/1.0 (flutter; autocomplete)',
        );

        if (!mounted) return;
        setState(() {
          _alamatSuggestions = results;
          _isLoadingAlamatSuggestions = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _alamatSuggestions = [];
          _isLoadingAlamatSuggestions = false;
        });
      }
    });
  }

  // -------- Widget Alamat dengan Autocomplete ----------
  Widget _buildAlamatAutocompleteField(double tinggi, double lebar) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alamat',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: lebar * 0.035,
          ),
        ),
        SizedBox(height: tinggi * 0.005),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _alamat,
                focusNode: _alamatFocusNode,
                textInputAction: TextInputAction.search,
                onChanged: _fetchAlamatSuggestions,
                onSubmitted: (_) => _geocodeAlamatToKoordinat(),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: lebar * 0.04,
                    vertical: tinggi * 0.018,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Ketik alamat lengkap...',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoadingAlamatSuggestions)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      IconButton(
                        tooltip: 'Cari koordinat dari alamat',
                        onPressed: _isGeocodingAddress
                            ? null
                            : _geocodeAlamatToKoordinat,
                        icon: _isGeocodingAddress
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
              ),
              // Suggestions dropdown
              if (_alamatSuggestions.isNotEmpty)
                Container(
                  constraints: BoxConstraints(maxHeight: tinggi * 0.25),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: _alamatSuggestions.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),
                    itemBuilder: (context, index) {
                      final place = _alamatSuggestions[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          place.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: lebar * 0.032),
                        ),
                        trailing: Icon(
                          Icons.north_west,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        onTap: () {
                          // Isi alamat dan apply koordinat
                          setState(() {
                            _alamat.text = place.displayName;
                            _alamatSuggestions = [];
                          });
                          _applyLatLngToFormAndMap(place.lat, place.lng);
                          // Hilangkan focus
                          _alamatFocusNode.unfocus();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: tinggi * 0.025),
      ],
    );
  }

  // Minta lokasi sekarang perangkat (menggunakan Geolocator)
  Future<void> _useCurrentLocation() async {
    try {
      if (!_mapLoaded || !mounted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Map belum siap, coba lagi sebentar...'),
            ),
          );
        }
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('GPS belum aktif, nyalakan dulu.')),
          );
          await Geolocator.openLocationSettings();
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak permanen.')),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final lat = pos.latitude;
      final lng = pos.longitude;

      _koordinatController.text = '$lat, $lng';
      await _updateMapLocation(lat, lng);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil lokasi: $e')),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (keadaan) {
      final int? terima = ModalRoute.of(context)?.settings.arguments as int?;
      final penghubung = Provider.of<KostProvider>(context, listen: false);

      // Pastikan tidak ada foto "tersisa" dari form sebelumnya.
      // Jangan notify saat didChangeDependencies (fase build) untuk menghindari
      // error: markNeedsBuild called during build.
      penghubung.clearFoto(notify: false);

      if (terima != null) {
        final pakai = Provider.of<KostProvider>(
          context,
          listen: false,
        ).kost.firstWhereOrNull((element) => element.id_kost == terima);

        if (pakai == null) {
          keadaan = false;
          return;
        }

        _namakost.text = pakai.nama_kost ?? "";
        // No tlp selalu mengikuti profil pemilik; isi awal dikosongkan dan akan di-sync di build().
        _notlpn.text = '';
        _alamat.text = pakai.alamat_kost ?? "";
        _harga.text = ThousandsSeparatorInputFormatter.formatDigits(
          (pakai.harga_kost ?? 0).toString(),
        );
        _panjang.text = pakai.panjang.toString() ?? "00";
        _lebar.text = pakai.lebar.toString() ?? "00";
        _koordinatController.text =
            "${pakai.garis_lintang}, ${pakai.garis_bujur}";

        // Set mode ke Manual Koordinat karena ini mode edit
        _selectedLocationOption = _optManualKoordinat;

        penghubung.namanya = pakai.pemilik_kost ?? "Pilih";
        penghubung.jeniskosts = pakai.jenis_kost ?? "Pilih";
        penghubung.penghunis = pakai.penghuni ?? "Pilih";
        penghubung.jeniskeamanans = pakai.keamanan ?? "Pilih";
        penghubung.batasjammalams = pakai.batas_jam_malam ?? "Pilih";
        penghubung.jenispembayaranairs = pakai.jenis_pembayaran_air ?? "Pilih";
        penghubung.jenislistriks = pakai.jenis_listrik ?? "Pilih";
        penghubung.pernama =
            (pakai.per == null || (pakai.per ?? '').trim().isEmpty)
                ? 'bulan'
                : pakai.per!;

        // Jika subkriteria terkait sudah dihapus, paksa kembali ke default.
        _coerceDeletedSubkriteriaSelections(penghubung, notify: false);

        // Isi fasilitas (jika tersedia) untuk mode edit
        _inilist.clear();
        final rawFasilitas = (pakai.fasilitas ?? '').trim();
        if (rawFasilitas.isNotEmpty) {
          final List<String> pisah = rawFasilitas
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          for (final item in pisah) {
            final jenis = listinputan();
            jenis.namaFasilitasController.text = item;
            _inilist.add(jenis);
          }
        }

        _editingFacilityIndex = null;
        _facilityInputController.clear();

        // Ambil snapshot awal untuk deteksi perubahan pada mode edit.
        _initialEditSignature = _currentEditSignatureAdmin(penghubung);

        // if (pakai != null) {
        //   final cekker = Provider.of<KostProvider>(
        //     context,
        //     listen: false,
        //   ).faslitas.firstWhereOrNull(
        //         (element) => element.id_fasilitas == pakai.id_fasilitas,
        //       );

        //   if (cekker != null) {
        //     penghubung.inputan.tempat_tidur = cekker.tempat_tidur;
        //     penghubung.inputan.kamar_mandi_dalam = cekker.kamar_mandi_dalam;
        //     penghubung.inputan.meja = cekker.meja;
        //     penghubung.inputan.tempat_parkir = cekker.tempat_parkir;
        //     penghubung.inputan.lemari = cekker.lemari;
        //     penghubung.inputan.ac = cekker.ac;
        //     penghubung.inputan.tv = cekker.tv;
        //     penghubung.inputan.kipas = cekker.kipas;
        //     penghubung.inputan.dapur_dalam = cekker.dapur_dalam;
        //     penghubung.inputan.wifi = cekker.wifi;
        //   }
        // }
      }
    }
    keadaan = false;
  }

  @override
  void dispose() {
    // final penghubung = Provider.of<KostProvider>(context);
    // penghubung.dispose();
    // penghubung.inputan.dispose();
    _namakost.dispose();
    _notlpn.dispose();
    _alamat.dispose();
    _harga.dispose();
    _lebar.dispose();
    _panjang.dispose();
    _debounceTimer?.cancel();
    _alamatDebounceTimer?.cancel();
    _alamatFocusNode.dispose();
    _koordinatController.removeListener(_onKoordinatChanged);
    _koordinatController.dispose();

    for (final item in _inilist) {
      item.dispose();
    }
    _inilist.clear();

    _facilityInputController.dispose();
    _facilityFocusNode.dispose();
    // _namaFasilitasController.dispose();
    super.dispose();
  }

  String _facilityKey(String raw) {
    return raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _normalizedCoordKey(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final parts = text.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;
    return '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
  }

  String _normalizedTextKey(String raw) {
    return raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String _facilitySignature() {
    final facilities = _inilist
        .map((e) => _facilityKey(e.namaFasilitasController.text))
        .where((e) => e.isNotEmpty)
        .toList()
      ..sort();
    return facilities.join('|');
  }

  String _currentEditSignatureAdmin(KostProvider penghubung) {
    final harga = ThousandsSeparatorInputFormatter.tryParseInt(_harga.text);
    final panjang = num.tryParse(_panjang.text.trim().replaceAll(',', '.'));
    final lebar = num.tryParse(_lebar.text.trim().replaceAll(',', '.'));
    final coordKey = _normalizedCoordKey(_koordinatController.text) ??
        _koordinatController.text.trim();

    return <String, String>{
      'namaKost': _normalizedTextKey(_namakost.text),
      'alamat': _normalizedTextKey(_alamat.text),
      'harga': (harga ?? 0).toString(),
      'panjang': (panjang ?? 0).toStringAsFixed(3),
      'lebar': (lebar ?? 0).toStringAsFixed(3),
      'koordinat': coordKey,
      'pemilik': _normalizedTextKey(penghubung.namanya ?? 'Pilih'),
      'jenisKost': _normalizedTextKey(penghubung.jeniskosts),
      'penghuni': _normalizedTextKey(penghubung.penghunis),
      'keamanan': _normalizedTextKey(penghubung.jeniskeamanans),
      'jamMalam': _normalizedTextKey(penghubung.batasjammalams),
      'air': _normalizedTextKey(penghubung.jenispembayaranairs),
      'listrik': _normalizedTextKey(penghubung.jenislistriks),
      'periode': _normalizedTextKey(penghubung.pernama),
      'fasilitas': _facilitySignature(),
      'fotoChanged': (penghubung.foto != null).toString(),
    }.entries.map((e) => '${e.key}=${e.value}').join(';');
  }

  bool _hasEditChangesAdmin(KostProvider penghubung) {
    if (_initialEditSignature == null) return true;
    return _currentEditSignatureAdmin(penghubung) != _initialEditSignature;
  }

  bool _hasAtLeastOneFacility() {
    return _inilist.any(
      (x) => x.namaFasilitasController.text.trim().isNotEmpty,
    );
  }

  void _startEditFacility(int index) {
    if (index < 0 || index >= _inilist.length) return;
    final current = _inilist[index].namaFasilitasController.text.trim();
    if (current.isEmpty) return;

    setState(() {
      _editingFacilityIndex = index;
      _facilityInputController.text = current;
      _facilityInputController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _facilityInputController.text.length,
      );
    });

    FocusScope.of(context).requestFocus(_facilityFocusNode);
  }

  void _removeFacilityAt(int index) {
    if (index < 0 || index >= _inilist.length) return;
    final removed = _inilist.removeAt(index);
    removed.dispose();

    if (_editingFacilityIndex == index) {
      _editingFacilityIndex = null;
      _facilityInputController.clear();
    } else if (_editingFacilityIndex != null &&
        _editingFacilityIndex! > index) {
      _editingFacilityIndex = _editingFacilityIndex! - 1;
    }
  }

  void _applyFacilityInput() {
    final raw = _facilityInputController.text.trim();
    if (raw.isEmpty) return;

    final normalizedKey = _facilityKey(raw);
    final existingIndex = _inilist.indexWhere(
      (e) => _facilityKey(e.namaFasilitasController.text) == normalizedKey,
    );

    setState(() {
      if (_editingFacilityIndex != null) {
        final targetIndex = _editingFacilityIndex!;
        if (existingIndex != -1 && existingIndex != targetIndex) {
          return;
        }
        _inilist[targetIndex].namaFasilitasController.text = raw;
        _editingFacilityIndex = null;
        _facilityInputController.clear();
      } else {
        if (existingIndex != -1) return;
        final item = listinputan();
        item.namaFasilitasController.text = raw;
        _inilist.add(item);
        _facilityInputController.clear();
      }
    });

    FocusScope.of(context).requestFocus(_facilityFocusNode);
  }

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<KostProvider>(context);
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    const warnaLatar = Color(0xFFF5F7FB);
    const warnaTombol = Color(0xFF12111F);

    final penghubung2 = Provider.of<AuthProvider>(context, listen: false);
    final penghubung3 = Provider.of<ProfilProvider>(context, listen: false);

    final cekked = penghubung2.hasilnya.firstWhereOrNull(
      (element) => element.username == penghubung.namanya,
    );

    final last = penghubung3.alluser.firstWhereOrNull(
      (element) => element.id_auth == cekked?.id_auth,
    );

    final String ownerKontakRaw = (last?.kontak ?? '').toString().trim();
    final String ownerKontak =
        (ownerKontakRaw.isEmpty || ownerKontakRaw == '0') ? '' : ownerKontakRaw;
    if (_notlpn.text != ownerKontak) {
      _notlpn.text = ownerKontak;
    }

    final int? terima = ModalRoute.of(context)?.settings.arguments as int?;
    final KostModel? pakai = (terima == null)
        ? null
        : Provider.of<KostProvider>(
            context,
            listen: false,
          ).kost.firstWhereOrNull((element) => element.id_kost == terima);

    if (terima != null && pakai == null) {
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
                  'Form Update Kost',
                  style: TextStyle(
                    fontSize: lebarLayar * 0.045,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 24),
              ],
            ),
          ),
        ),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Data kost yang ingin diedit tidak ditemukan.\nCoba refresh daftar kost terlebih dahulu.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return penghubung3 == null
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
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
                      onTap: () {
                        penghubung.inputan.resetcheckbox();
                        penghubung.resetpilihan();
                        Navigator.pop(context);
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    terima != null
                        ? Text(
                            'Form Update Kost',
                            style: TextStyle(
                              fontSize: lebarLayar * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          )
                        : Text(
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
                    Label1barisFull(
                      label: "Pemilik Kost",
                      lebar: lebarLayar,
                      jarak: 1,
                    ),
                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.naman,
                                label: penghubung.namanya,
                                pilihan: penghubung.namanya,
                                fungsi: (value) {
                                  penghubung.pilihpemilik(value);
                                },
                              )
                            : CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.naman,
                                label: penghubung.namanya,
                                pilihan: penghubung.namanya,
                                fungsi: (value) {
                                  penghubung.pilihpemilik(value);
                                },
                              );
                      },
                    ),
                    SizedBox(height: tinggiLayar * 0.025),

                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? _inputField(
                                'Nama Kost',
                                tinggiLayar,
                                lebarLayar,
                                _namakost,
                                false,
                              )
                            : _inputField(
                                'Nama Kost',
                                tinggiLayar,
                                lebarLayar,
                                _namakost,
                                false,
                              );
                      },
                    ),

                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? _inputField(
                                'Nomor Telepon',
                                tinggiLayar,
                                lebarLayar,
                                _notlpn,
                                false,
                              )
                            : _inputField(
                                'Nomor Telepon',
                                tinggiLayar,
                                lebarLayar,
                                _notlpn,
                                false,
                              );
                      },
                    ),

                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? TextfieldWithDropdown(
                                label: "Harga_kost",
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                isi: _harga,
                                jenis: TextInputType.number,
                                inputFormatters: const [
                                  ThousandsSeparatorInputFormatter(),
                                ],
                                manalistnya: penghubung.per,
                                label2: penghubung.pernama,
                                pilihan: penghubung.pernama,
                                fungsi: (value) {
                                  penghubung.pilihbayar(value);
                                },
                              )
                            : TextfieldWithDropdown(
                                label: "Harga Kost",
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                isi: _harga,
                                jenis: TextInputType.number,
                                inputFormatters: const [
                                  ThousandsSeparatorInputFormatter(),
                                ],
                                manalistnya: penghubung.per,
                                label2: penghubung.pernama,
                                pilihan: penghubung.pernama,
                                fungsi: (value) {
                                  penghubung.pilihbayar(value);
                                },
                              );
                      },
                    ),

                    Label1barisFull(
                      label: "Jenis Kost",
                      lebar: lebarLayar,
                      jarak: 1,
                    ),
                    SizedBox(height: tinggiLayar * 0.005),
                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jeniskost,
                                label: "Pilihlah",
                                pilihan: penghubung.jeniskosts,
                                fungsi: (value) {
                                  penghubung.pilihkost(value);
                                  // Auto-set tipe penghuni berdasarkan jenis kost
                                  if (value.toLowerCase().contains('umum')) {
                                    penghubung.pilihpenghuni('Umum');
                                  } else if (value
                                      .toLowerCase()
                                      .contains('khusus')) {
                                    if (penghubung.penghunis == 'Umum') {
                                      penghubung.pilihpenghuni('Pilih');
                                    }
                                  } else {
                                    penghubung.pilihpenghuni('Pilih');
                                  }
                                },
                              )
                            : CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jeniskost,
                                label: "Pilih",
                                pilihan: penghubung.jeniskosts,
                                fungsi: (value) {
                                  penghubung.pilihkost(value);
                                  // Auto-set tipe penghuni berdasarkan jenis kost
                                  if (value.toLowerCase().contains('umum')) {
                                    penghubung.pilihpenghuni('Umum');
                                  } else if (value
                                      .toLowerCase()
                                      .contains('khusus')) {
                                    if (penghubung.penghunis == 'Umum') {
                                      penghubung.pilihpenghuni('Pilih');
                                    }
                                  } else {
                                    penghubung.pilihpenghuni('Pilih');
                                  }
                                },
                              );
                      },
                    ),
                    SizedBox(height: tinggiLayar * 0.025),

                    Label1barisFull(
                      label: "Tipe Penghuni",
                      lebar: lebarLayar,
                      jarak: 1,
                    ),
                    SizedBox(height: tinggiLayar * 0.005),
                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        // Tentukan status enable/disable radio berdasarkan jenis kost
                        final bool isJenisKostKhusus = penghubung.jeniskosts
                            .toLowerCase()
                            .contains('khusus');
                        return Container(
                          width: lebarLayar,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    "Umum",
                                    style: TextStyle(
                                      fontSize: lebarLayar * 0.035,
                                    ),
                                  ),
                                  value: "Umum",
                                  groupValue: penghubung.penghunis == "Pilih"
                                      ? null
                                      : penghubung.penghunis,
                                  // Umum otomatis terpilih & terkunci saat jenis kost Umum
                                  onChanged: null,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    "Khusus Putra",
                                    style: TextStyle(
                                      fontSize: lebarLayar * 0.035,
                                    ),
                                  ),
                                  value: "Khusus Putra",
                                  groupValue: penghubung.penghunis == "Pilih"
                                      ? null
                                      : penghubung.penghunis,
                                  // Aktif hanya jika jenis kost mengandung "Khusus"
                                  onChanged: isJenisKostKhusus
                                      ? (val) {
                                          penghubung.pilihpenghuni(val!);
                                        }
                                      : null,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<String>(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    "Khusus Putri",
                                    style: TextStyle(
                                      fontSize: lebarLayar * 0.035,
                                    ),
                                  ),
                                  value: "Khusus Putri",
                                  groupValue: penghubung.penghunis == "Pilih"
                                      ? null
                                      : penghubung.penghunis,
                                  // Aktif hanya jika jenis kost mengandung "Khusus"
                                  onChanged: isJenisKostKhusus
                                      ? (val) {
                                          penghubung.pilihpenghuni(val!);
                                        }
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    SizedBox(height: tinggiLayar * 0.025),

                    Label1barisFull(
                      label: "Keamanan",
                      lebar: lebarLayar,
                      jarak: 1,
                    ),
                    SizedBox(height: tinggiLayar * 0.005),
                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jeniskeamananan,
                                label: penghubung.jeniskeamanans,
                                pilihan: penghubung.jeniskeamanans,
                                fungsi: (value) {
                                  penghubung.pilihkeamanan(value);
                                },
                              )
                            : CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jeniskeamananan,
                                label: penghubung.jeniskeamanans,
                                pilihan: penghubung.jeniskeamanans,
                                fungsi: (value) {
                                  penghubung.pilihkeamanan(value);
                                },
                              );
                      },
                    ),
                    SizedBox(height: tinggiLayar * 0.025),

                    Label1barisFull(
                      label: "Luas Kamar",
                      lebar: lebarLayar,
                      jarak: 1,
                    ),
                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? Container(
                                width: lebarLayar,
                                height: tinggiLayar * 0.1,
                                child: Row(
                                  children: [
                                    Container(
                                      width: lebarLayar * 0.4,
                                      child: Row(
                                        children: [
                                          Text(
                                            "Panjang",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: lebarLayar * 0.035,
                                            ),
                                          ),
                                          SizedBox(width: lebarLayar * 0.01),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  8,
                                                ),
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _panjang,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'^\d+\.?\d{0,2}'),
                                                  ),
                                                ],
                                                decoration: InputDecoration(
                                                  hintText: "00",
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal:
                                                        lebarLayar * 0.04,
                                                    vertical:
                                                        tinggiLayar * 0.018,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: lebarLayar * 0.07),
                                    Container(
                                      // color: Colors.cyan,
                                      width: lebarLayar * 0.4,
                                      child: Row(
                                        children: [
                                          Text(
                                            "Lebar",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: lebarLayar * 0.035,
                                            ),
                                          ),
                                          SizedBox(width: lebarLayar * 0.01),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  8,
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _lebar,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'^\d+\.?\d{0,2}'),
                                                  ),
                                                ],
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal:
                                                        lebarLayar * 0.04,
                                                    vertical:
                                                        tinggiLayar * 0.018,
                                                  ),
                                                  hintText: "00",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: lebarLayar,
                                height: tinggiLayar * 0.1,
                                child: Row(
                                  children: [
                                    Container(
                                      width: lebarLayar * 0.4,
                                      child: Row(
                                        children: [
                                          Text(
                                            "Panjang",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: lebarLayar * 0.035,
                                            ),
                                          ),
                                          SizedBox(width: lebarLayar * 0.01),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  8,
                                                ),
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _panjang,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'^\d+\.?\d{0,2}'),
                                                  ),
                                                ],
                                                decoration: InputDecoration(
                                                  hintText: "00",
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal:
                                                        lebarLayar * 0.04,
                                                    vertical:
                                                        tinggiLayar * 0.018,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: lebarLayar * 0.07),
                                    Container(
                                      // color: Colors.cyan,
                                      width: lebarLayar * 0.4,
                                      child: Row(
                                        children: [
                                          Text(
                                            "Lebar",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: lebarLayar * 0.035,
                                            ),
                                          ),
                                          SizedBox(width: lebarLayar * 0.01),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                  width: 1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  8,
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _lebar,
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .allow(
                                                    RegExp(r'^\d+\.?\d{0,2}'),
                                                  ),
                                                ],
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal:
                                                        lebarLayar * 0.04,
                                                    vertical:
                                                        tinggiLayar * 0.018,
                                                  ),
                                                  hintText: "00",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                      },
                    ),
                    SizedBox(height: tinggiLayar * 0.025),

                    Label1barisFull(
                      label: "Batas Jam Malam",
                      lebar: lebarLayar,
                      jarak: 1,
                    ),
                    SizedBox(height: tinggiLayar * 0.005),
                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jenisbatasjammalam,
                                label: penghubung.batasjammalams,
                                pilihan: penghubung.batasjammalams,
                                fungsi: (value) {
                                  penghubung.pilihbatasjammalam(value);
                                },
                              )
                            : CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jenisbatasjammalam,
                                label: penghubung.batasjammalams,
                                pilihan: penghubung.batasjammalams,
                                fungsi: (value) {
                                  penghubung.pilihbatasjammalam(value);
                                },
                              );
                      },
                    ),
                    SizedBox(height: tinggiLayar * 0.025),

                    Label1barisFull(
                      label: "Jenis Pembayaran Air",
                      lebar: lebarLayar,
                      jarak: 1,
                    ),
                    SizedBox(height: tinggiLayar * 0.005),
                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jenispembayaranair,
                                label: penghubung.jenispembayaranairs,
                                pilihan: penghubung.jenispembayaranairs,
                                fungsi: (value) {
                                  penghubung.pilihjenispembayaranair(value);
                                },
                              )
                            : CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jenispembayaranair,
                                label: penghubung.jenispembayaranairs,
                                pilihan: penghubung.jenispembayaranairs,
                                fungsi: (value) {
                                  penghubung.pilihjenispembayaranair(value);
                                },
                              );
                      },
                    ),
                    SizedBox(height: tinggiLayar * 0.025),

                    Label1barisFull(
                      label: "Jenis Listrik",
                      lebar: lebarLayar,
                      jarak: 1,
                    ),
                    SizedBox(height: tinggiLayar * 0.005),
                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jenislistrik,
                                label: penghubung.jenislistriks,
                                pilihan: penghubung.jenislistriks,
                                fungsi: (value) {
                                  penghubung.pilihjenislistrik(value);
                                },
                              )
                            : CustomDropdownSearchv2(
                                lebar: lebarLayar,
                                tinggi: tinggiLayar,
                                manalistnya: penghubung.jenislistrik,
                                label: penghubung.jenislistriks,
                                pilihan: penghubung.jenislistriks,
                                fungsi: (value) {
                                  penghubung.pilihjenislistrik(value);
                                },
                              );
                      },
                    ),
                    SizedBox(height: tinggiLayar * 0.025),

                    // Field Alamat dengan Autocomplete sugesti
                    _buildAlamatAutocompleteField(tinggiLayar, lebarLayar),
                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? _inputFieldKoordinat(tinggiLayar, lebarLayar)
                            : _inputFieldKoordinat(tinggiLayar, lebarLayar);
                      },
                    ),

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

                    Consumer<KostProvider>(
                      builder: (context, value, child) {
                        return terima != null
                            ? custom_editfotov2(
                                fungsi: () {
                                  penghubung.uploadfoto();
                                },
                                path: penghubung.foto?.path,
                                pathlama: pakai!.gambar_kost ?? "",
                                tinggi: tinggiLayar * 0.4,
                                panjang: lebarLayar * 2,
                              )
                            : CustomUploadfotov2(
                                tinggi: tinggiLayar * 0.4,
                                radius: 10,
                                fungsi: () {
                                  penghubung.uploadfoto();
                                },
                                path: penghubung.foto?.path,
                              );
                      },
                    ),

                    SizedBox(height: tinggiLayar * 0.015),
                    // ChangeNotifierProvider.value(
                    //   value: penghubung.inputan,
                    //   child: Consumer<KostProvider>(
                    //     builder: (context, value, child) {
                    //       return terima != null
                    //           ? Consumer<FasilitasModel>(
                    //               builder: (context, value, child) {
                    //                 return Wrap(
                    //                   spacing: lebarLayar * 0.02,
                    //                   runSpacing: tinggiLayar * 0.015,
                    //                   children: [
                    //                     _buildCustomItem(
                    //                       "Tempat Tidur",
                    //                       Icons.bed,
                    //                       value.tempat_tidur,
                    //                       () => value.booltempattidur(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Kamar Mandi Dalam",
                    //                       Icons.bathtub_outlined,
                    //                       value.kamar_mandi_dalam,
                    //                       () => value.boolkamarmandidalam(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Meja",
                    //                       Icons.desk,
                    //                       value.meja,
                    //                       () => value.boolmeja(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Tempat Parkir",
                    //                       Icons.local_parking,
                    //                       value.tempat_parkir,
                    //                       () => value.booltempatparkir(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Lemari",
                    //                       PhosphorIconsBold.gridFour,
                    //                       value.lemari,
                    //                       () => value.boollemari(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "AC",
                    //                       Icons.ac_unit,
                    //                       value.ac,
                    //                       () => value.boolac(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "TV",
                    //                       Icons.tv,
                    //                       value.tv,
                    //                       () => value.booltv(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Kipas Angin",
                    //                       Icons.wind_power,
                    //                       value.kipas,
                    //                       () => value.boolkipas(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Dapur Dalam",
                    //                       Icons.kitchen,
                    //                       value.dapur_dalam,
                    //                       () => value
                    //                           .booldapurdalam(), // Perbaikan typo pemanggilan fungsi
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "WiFi",
                    //                       Icons.wifi,
                    //                       value.wifi,
                    //                       () => value.boolwifi(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                   ],
                    //                 );
                    //               },
                    //             )
                    //           : Consumer<FasilitasModel>(
                    //               builder: (context, value, child) {
                    //                 return Wrap(
                    //                   spacing: lebarLayar * 0.02,
                    //                   runSpacing: tinggiLayar * 0.015,
                    //                   children: [
                    //                     _buildCustomItem(
                    //                       "Tempat Tidur",
                    //                       Icons.bed,
                    //                       value.tempat_tidur,
                    //                       () => value.booltempattidur(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Kamar Mandi Dalam",
                    //                       Icons.bathtub_outlined,
                    //                       value.kamar_mandi_dalam,
                    //                       () => value.boolkamarmandidalam(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Meja",
                    //                       Icons.desk,
                    //                       value.meja,
                    //                       () => value.boolmeja(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Tempat Parkir",
                    //                       Icons.local_parking,
                    //                       value.tempat_parkir,
                    //                       () => value.booltempatparkir(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Lemari",
                    //                       PhosphorIconsBold.gridFour,
                    //                       value.lemari,
                    //                       () => value.boollemari(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "AC",
                    //                       Icons.ac_unit,
                    //                       value.ac,
                    //                       () => value.boolac(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "TV",
                    //                       Icons.tv,
                    //                       value.tv,
                    //                       () => value.booltv(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Kipas Angin",
                    //                       Icons.wind_power,
                    //                       value.kipas,
                    //                       () => value.boolkipas(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "Dapur Dalam",
                    //                       Icons.kitchen,
                    //                       value.dapur_dalam,
                    //                       () => value
                    //                           .booldapurdalam(), // Perbaikan typo pemanggilan fungsi
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                     _buildCustomItem(
                    //                       "WiFi",
                    //                       Icons.wifi,
                    //                       value.wifi,
                    //                       () => value.boolwifi(),
                    //                       lebarLayar,
                    //                       tinggiLayar,
                    //                     ),
                    //                   ],
                    //                 );
                    //               },
                    //             );
                    //     },
                    //   ),
                    // ),
                    Label1barisFull(
                      label: "Fasilitas",
                      lebar: lebarLayar,
                      jarak: 1,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: EdgeInsets.all(lebarLayar * 0.03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _facilityInputController,
                            focusNode: _facilityFocusNode,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _applyFacilityInput(),
                            decoration: InputDecoration(
                              hintText: _editingFacilityIndex != null
                                  ? 'Edit fasilitas (Enter untuk simpan)'
                                  : 'Tulis nama fasilitas (Enter untuk tambah)',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          SizedBox(height: tinggiLayar * 0.015),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _inilist
                                .asMap()
                                .entries
                                .where((e) => e
                                    .value.namaFasilitasController.text
                                    .trim()
                                    .isNotEmpty)
                                .map((entry) {
                              final idx = entry.key;
                              final label = entry
                                  .value.namaFasilitasController.text
                                  .trim();
                              return GestureDetector(
                                onDoubleTap: () => _startEditFacility(idx),
                                child: Chip(
                                  label: Text(label),
                                  onDeleted: () {
                                    if (!mounted) return;
                                    setState(() {
                                      _removeFacilityAt(idx);
                                    });
                                  },
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: tinggiLayar * 0.05),
                  ],
                ),
              ),
            ),
            //
            bottomNavigationBar: Consumer<KostProvider>(
              builder: (context, value, child) {
                final bool isEdit = terima != null;
                return AnimatedBuilder(
                  animation: _formFieldsListenable,
                  builder: (context, _) {
                    final bool isReady = _isFormReadyAdmin(
                      value,
                      isEdit: isEdit,
                    );
                    final bool hasChanges =
                        !isEdit || _hasEditChangesAdmin(value);
                    final bool canSubmit =
                        isReady && !_isSubmitting && hasChanges;

                    return terima != null
                        ? Padding(
                            padding: EdgeInsets.all(lebarLayar * 0.05),
                            child: SizedBox(
                              height: tinggiLayar * 0.065,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canSubmit
                                      ? warnaTombol
                                      : Colors.grey.shade400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                onPressed: canSubmit
                                    ? () async {
                                        setState(() {
                                          _isSubmitting = true;
                                        });

                                        try {
                                          final String? errorMessage =
                                              _validateFormAdmin(
                                            value,
                                            isEdit: true,
                                            currentKostId: pakai!.id_kost,
                                          );

                                          if (errorMessage != null) {
                                            await _showErrorDialog(
                                              errorMessage,
                                            );
                                            return;
                                          }

                                          // await penghubung.updatedata(
                                          //   penghubung.foto,
                                          //   pakai!.gambar_kost!,
                                          //   pakai.id_fasilitas!,
                                          //   penghubung.inputan.tempat_tidur,
                                          //   penghubung.inputan.kamar_mandi_dalam,
                                          //   penghubung.inputan.meja,
                                          //   penghubung.inputan.tempat_parkir,
                                          //   penghubung.inputan.lemari,
                                          //   penghubung.inputan.ac,
                                          //   penghubung.inputan.tv,
                                          //   penghubung.inputan.kipas,
                                          //   penghubung.inputan.dapur_dalam,
                                          //   penghubung.inputan.wifi,
                                          //   pakai.id_kost!,
                                          //   pakai.id_auth!,
                                          //   _namakost.text,
                                          //   penghubung.namanya,
                                          //   _alamat.text,
                                          //   int.parse(_notlpn.text),
                                          //   ThousandsSeparatorInputFormatter
                                          //           .tryParseInt(
                                          //         _harga.text,
                                          //       ) ??
                                          //       0,
                                          //   penghubung.batasjammalams,
                                          //   penghubung.jenislistriks,
                                          //   penghubung.jenispembayaranairs,
                                          //   penghubung.jeniskeamanans,
                                          //   penghubung.jeniskosts,
                                          //   int.parse(_panjang.text),
                                          //   int.parse(_lebar.text),
                                          //   _koordinatController.text,
                                          //   penghubung.pernama,
                                          // );

                                          // Parse dimensions with error handling
                                          num? panjangValue;
                                          num? lebarValue;
                                          try {
                                            panjangValue = num.parse(_panjang
                                                .text
                                                .replaceAll(',', '.'));
                                            lebarValue = num.parse(_lebar.text
                                                .replaceAll(',', '.'));
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() {
                                                _isSubmitting = false;
                                              });
                                            }
                                            await _showErrorDialog(
                                              "Format angka tidak valid untuk panjang/lebar kamar.",
                                            );
                                            return;
                                          }

                                          await value.konversiupdatedata(
                                            value.foto,
                                            pakai.gambar_kost!,
                                            pakai.id_kost!,
                                            pakai.id_auth!,
                                            _namakost.text,
                                            value.namanya,
                                            _alamat.text,
                                            _notlpn.text.trim().isEmpty
                                                ? null
                                                : _notlpn.text.trim(),
                                            ThousandsSeparatorInputFormatter
                                                    .tryParseInt(_harga.text) ??
                                                0,
                                            value.batasjammalams,
                                            value.jenislistriks,
                                            value.jenispembayaranairs,
                                            value.jeniskeamanans,
                                            value.jeniskosts,
                                            value.penghunis,
                                            panjangValue,
                                            lebarValue,
                                            _koordinatController.text,
                                            value.pernama,
                                            _inilist,
                                          );
                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          await _showErrorDialog(e.toString());
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                        }
                                      }
                                    : null,
                                child: _isSubmitting
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Menyimpan...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: lebarLayar * 0.04,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Simpan Perubahan',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: lebarLayar * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.all(lebarLayar * 0.05),
                            child: SizedBox(
                              height: tinggiLayar * 0.065,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: canSubmit
                                      ? warnaTombol
                                      : Colors.grey.shade400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                onPressed: canSubmit
                                    ? () async {
                                        if (!mounted) return;
                                        setState(() {
                                          _isSubmitting = true;
                                        });

                                        try {
                                          final String? errorMessage =
                                              _validateFormAdmin(
                                            value,
                                            isEdit: false,
                                          );

                                          if (errorMessage != null) {
                                            await _showErrorDialog(
                                              errorMessage,
                                            );
                                            return;
                                          }

                                          final inilist = value.listauth;

                                          var cek = inilist.firstWhere(
                                            (element) =>
                                                element.username ==
                                                value.namanya,
                                          );

                                          // await penghubung.createdata(
                                          //   int.parse(cek.id_auth.toString()),
                                          //   penghubung.inputan.tempat_tidur,
                                          //   penghubung.inputan.kamar_mandi_dalam,
                                          //   penghubung.inputan.meja,
                                          //   penghubung.inputan.tempat_parkir,
                                          //   penghubung.inputan.lemari,
                                          //   penghubung.inputan.ac,
                                          //   penghubung.inputan.tv,
                                          //   penghubung.inputan.kipas,
                                          //   penghubung.inputan.dapur_dalam,
                                          //   penghubung.inputan.wifi,
                                          //   int.parse(_notlpn.text),
                                          //   _namakost.text,
                                          //   _alamat.text,
                                          //   penghubung.namanya,
                                          //   ThousandsSeparatorInputFormatter
                                          //           .tryParseInt(
                                          //         _harga.text,
                                          //       ) ??
                                          //       0,
                                          //   _koordinatController.text,
                                          //   penghubung.jeniskosts,
                                          //   penghubung.jeniskeamanans,
                                          //   penghubung.batasjammalams,
                                          //   penghubung.jenispembayaranairs,
                                          //   penghubung.jenislistriks,
                                          //   int.parse(_panjang.text),
                                          //   int.parse(_lebar.text),
                                          //   penghubung.foto!,
                                          //   penghubung.pernama,
                                          // );

                                          // Parse dimensions with error handling
                                          num? panjangValue;
                                          num? lebarValue;
                                          try {
                                            panjangValue = num.parse(_panjang
                                                .text
                                                .replaceAll(',', '.'));
                                            lebarValue = num.parse(_lebar.text
                                                .replaceAll(',', '.'));
                                          } catch (e) {
                                            if (mounted) {
                                              setState(() {
                                                _isSubmitting = false;
                                              });
                                            }
                                            await _showErrorDialog(
                                              "Format angka tidak valid untuk panjang/lebar kamar.",
                                            );
                                            return;
                                          }

                                          await value.konversicreatedataAdmin(
                                            int.parse(cek.id_auth.toString()),
                                            _notlpn.text.trim().isEmpty
                                                ? null
                                                : _notlpn.text.trim(),
                                            _namakost.text,
                                            _alamat.text,
                                            value.namanya,
                                            ThousandsSeparatorInputFormatter
                                                    .tryParseInt(
                                                  _harga.text,
                                                ) ??
                                                0,
                                            _koordinatController.text,
                                            value.jeniskosts,
                                            value.penghunis,
                                            value.jeniskeamanans,
                                            value.batasjammalams,
                                            value.jenispembayaranairs,
                                            value.jenislistriks,
                                            panjangValue,
                                            lebarValue,
                                            value.foto!,
                                            value.pernama,
                                            _inilist,
                                          );

                                          setState(() {
                                            value.inputan.resetcheckbox();
                                            value.resetpilihan();
                                          });

                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          await _showErrorDialog(e.toString());
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                        }
                                      }
                                    : null,
                                child: _isSubmitting
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Menyimpan...',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: lebarLayar * 0.04,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'Simpan Data',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: lebarLayar * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          );
                  },
                );
              },
            ),
          );
  }

  bool _isFormReadyAdmin(KostProvider penghubung, {required bool isEdit}) {
    // Cek semua field teks wajib terisi (no telepon opsional)
    if (_namakost.text.trim().isEmpty ||
        _alamat.text.trim().isEmpty ||
        _harga.text.trim().isEmpty ||
        _panjang.text.trim().isEmpty ||
        _lebar.text.trim().isEmpty ||
        _koordinatController.text.trim().isEmpty) {
      return false;
    }

    // Cek koordinat valid (bukan placeholder "Klik 2x pada peta")
    final koordinat = _koordinatController.text.trim();
    if (koordinat == 'Klik 2x pada peta' || koordinat.isEmpty) {
      return false;
    }
    // Validasi format koordinat
    final parts = koordinat.split(',');
    if (parts.length != 2) return false;
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return false;

    // Cek dropdown wajib sudah dipilih
    if ((penghubung.namanya == null || penghubung.namanya == "Pilih") ||
        penghubung.jeniskosts == "Pilih" ||
        penghubung.penghunis == "Pilih" ||
        penghubung.jeniskeamanans == "Pilih" ||
        penghubung.batasjammalams == "Pilih" ||
        penghubung.jenispembayaranairs == "Pilih" ||
        penghubung.jenislistriks == "Pilih") {
      return false;
    }

    // Untuk tambah data, wajib sudah memilih foto
    if (!isEdit && penghubung.foto == null) {
      return false;
    }

    if (!_hasAtLeastOneFacility()) {
      return false;
    }

    // final fasilitas = penghubung.inputan;
    // final bool hasFacility = fasilitas.tempat_tidur ||
    //     fasilitas.kamar_mandi_dalam ||
    //     fasilitas.meja ||
    //     fasilitas.tempat_parkir ||
    //     fasilitas.lemari ||
    //     fasilitas.ac ||
    //     fasilitas.tv ||
    //     fasilitas.kipas ||
    //     fasilitas.dapur_dalam ||
    //     fasilitas.wifi;

    // if (!hasFacility) {
    //   return false;
    // }

    return true;
  }

  // 🔹 Input TextField umum
  Widget _inputField(
    String label,
    double tinggi,
    double lebar,
    TextEditingController isi,
    bool keadaan,
  ) {
    final bool isPhoneField = label == 'Nomor Telepon';
    final bool isNumericField = isPhoneField || label == 'Harga';
    final bool isAlamatField = label == 'Alamat';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: lebar * 0.035,
          ),
        ),
        SizedBox(height: tinggi * 0.005),
        Container(
          decoration: BoxDecoration(
            color: isPhoneField ? Colors.grey.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: TextField(
            controller: isi,
            // Admin tidak boleh mengedit no tlp kost (sumbernya dari profil pemilik)
            // sehingga field ini selalu disabled.
            enabled: !isPhoneField,
            readOnly: isPhoneField ? true : keadaan,
            keyboardType:
                isNumericField ? TextInputType.number : TextInputType.text,
            textInputAction: isAlamatField ? TextInputAction.search : null,
            onSubmitted:
                isAlamatField ? (_) => _geocodeAlamatToKoordinat() : null,
            inputFormatters: isNumericField
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: lebar * 0.04,
                vertical: tinggi * 0.018,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: isPhoneField ? 'Otomatis dari profil pemilik' : null,
              suffixIcon: isAlamatField
                  ? IconButton(
                      tooltip: 'Cari koordinat dari alamat',
                      onPressed: _isGeocodingAddress
                          ? null
                          : _geocodeAlamatToKoordinat,
                      icon: _isGeocodingAddress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                    )
                  : null,
            ),
          ),
        ),
        SizedBox(height: tinggi * 0.025),
      ],
    );
  }

  String? _validateFormAdmin(
    KostProvider penghubung, {
    required bool isEdit,
    int? currentKostId,
  }) {
    final namaKost = _namakost.text.trim();
    final noTelp = _notlpn.text.trim();
    final alamat = _alamat.text.trim();
    final harga = _harga.text.trim();
    final panjang = _panjang.text.trim();
    final lebar = _lebar.text.trim();
    final koordinat = _koordinatController.text.trim();

    if (penghubung.namanya == "Pilih") {
      return "Harap pilih pemilik kost terlebih dahulu.";
    }

    // No telepon opsional untuk admin (karena pemilik mungkin belum lengkapi profil)
    if (namaKost.isEmpty ||
        alamat.isEmpty ||
        harga.isEmpty ||
        panjang.isEmpty ||
        lebar.isEmpty ||
        koordinat.isEmpty ||
        koordinat == 'Klik 2x pada peta') {
      return "Harap lengkapi semua kolom yang wajib diisi.";
    }

    if (penghubung.jeniskosts == "Pilih" ||
        penghubung.penghunis == "Pilih" ||
        penghubung.jeniskeamanans == "Pilih" ||
        penghubung.batasjammalams == "Pilih" ||
        penghubung.jenispembayaranairs == "Pilih" ||
        penghubung.jenislistriks == "Pilih" ||
        penghubung.pernama == "Pilih") {
      return "Harap pilih semua opsi dropdown (jenis kost, tipe penghuni, keamanan, jam malam, pembayaran air, listrik, dan periode pembayaran).";
    }

    if (!isEdit && penghubung.foto == null) {
      return "Foto kost wajib di-upload.";
    }

    if (!_hasAtLeastOneFacility()) {
      return "Harap isi minimal 1 fasilitas kost.";
    }

    // final fasilitas = penghubung.inputan;
    // final bool hasFacility = fasilitas.tempat_tidur ||
    //     fasilitas.kamar_mandi_dalam ||
    //     fasilitas.meja ||
    //     fasilitas.tempat_parkir ||
    //     fasilitas.lemari ||
    //     fasilitas.ac ||
    //     fasilitas.tv ||
    //     fasilitas.kipas ||
    //     fasilitas.dapur_dalam ||
    //     fasilitas.wifi;

    // if (!hasFacility) {
    //   return "Harap pilih minimal satu fasilitas kost.";
    // }

    // Validasi format telepon hanya jika diisi dan bukan dari profil pemilik yang sudah ada
    // Admin tidak perlu validasi ketat untuk no tlp karena itu mengikuti profil pemilik
    if (noTelp.isNotEmpty) {
      if (int.tryParse(noTelp) == null) {
        return "Nomor telepon hanya boleh berisi angka.";
      }
      // Skip validasi panjang jika dalam mode edit atau jika no tlp sudah terisi dari profil pemilik
      // Admin hanya menambah kost, bukan mengedit profil pemilik
    }

    final hargaParsed = ThousandsSeparatorInputFormatter.tryParseInt(harga);
    if (hargaParsed == null) {
      return "Harga kost hanya boleh berisi angka.";
    }
    if (hargaParsed <= 0) {
      return "Harga kost harus lebih dari 0.";
    }

    // Support both comma and dot as decimal separator
    final panjangClean = panjang.replaceAll(',', '.');
    final lebarClean = lebar.replaceAll(',', '.');

    final panjangParsed = num.tryParse(panjangClean);
    final lebarParsed = num.tryParse(lebarClean);
    if (panjangParsed == null || lebarParsed == null) {
      return "Panjang dan lebar kamar hanya boleh berisi angka (contoh: 3.5 atau 3,5).";
    }
    if (panjangParsed <= 0) {
      return "Panjang kamar harus lebih dari 0.";
    }
    if (lebarParsed <= 0) {
      return "Lebar kamar harus lebih dari 0.";
    }
    if (panjangParsed > 50) {
      return "Panjang kamar tidak realistis (maksimal 50 meter).";
    }
    if (lebarParsed > 50) {
      return "Lebar kamar tidak realistis (maksimal 50 meter).";
    }

    // Check duplicate nama kost + alamat
    final existingNamaAlamat = penghubung.kost.where((k) {
      if (currentKostId != null && k.id_kost == currentKostId) return false;
      final existingNama = (k.nama_kost ?? "").trim().toLowerCase();
      final existingAlamat = (k.alamat_kost ?? "").trim().toLowerCase();
      return existingNama == namaKost.toLowerCase() &&
          existingAlamat == alamat.toLowerCase();
    }).toList();

    if (!isEdit && existingNamaAlamat.isNotEmpty) {
      return "Kost dengan nama dan alamat tersebut sudah terdaftar.";
    }

    // Parse koordinat untuk validasi duplikat
    final koordinatParts = koordinat.split(',');
    if (koordinatParts.length != 2) {
      return "Format koordinat tidak valid. Gunakan format: latitude,longitude";
    }

    final lat = double.tryParse(koordinatParts[0].trim());
    final lng = double.tryParse(koordinatParts[1].trim());

    if (lat == null || lng == null) {
      return "Koordinat harus berisi angka yang valid.";
    }

    final existingKoordinat = penghubung.kost.where((k) {
      if (currentKostId != null && k.id_kost == currentKostId) return false;
      return k.garis_lintang == lat && k.garis_bujur == lng;
    }).toList();

    if (existingKoordinat.isNotEmpty) {
      return "Titik koordinat ini sudah digunakan oleh kost lain.";
    }

    return null;
  }

  // Tombol ikon untuk memilih sumber titik koordinat
  Widget _buildLocationOptionIcon({
    required IconData icon,
    required String label,
    required String value,
    required double lebar,
  }) {
    final bool isActive = _selectedLocationOption == value;
    final Color color = isActive ? const Color(0xFF1C3B98) : Colors.grey;

    return GestureDetector(
      onTap: () async {
        if (!mounted || _selectedLocationOption == value) return;
        setState(() => _selectedLocationOption = value);

        if (!_mapLoaded) return;

        // Set perilaku setiap opsi dan sinkronkan dengan peta
        if (value == _optManualKoordinat) {
          await _mapController.runJavaScript(
            "clearMyLocation(); clearDestination(); setMode('readonly');",
          );
          _koordinatController.text = '';
        } else if (value == _optLokasiTujuan) {
          await _mapController.runJavaScript(
            "clearMyLocation(); clearDestination(); setMode('destination');",
          );
          _koordinatController.text = 'Klik 2x pada peta';
        } else if (value == _optLokasiSekarang) {
          await _mapController.runJavaScript(
            "clearMyLocation(); clearDestination(); setMode('normal');",
          );
          await _useCurrentLocation();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(lebar * 0.02),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFE0E7FF) : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: lebar * 0.06, color: color),
          ),
          SizedBox(height: lebar * 0.01),
          Text(
            label,
            style: TextStyle(
              fontSize: lebar * 0.028,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
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
        // Tombol ikon pilihan sumber titik koordinat
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLocationOptionIcon(
              icon: Icons.flag_outlined,
              label: 'Tujuan',
              value: _optLokasiTujuan,
              lebar: lebar,
            ),
            _buildLocationOptionIcon(
              icon: Icons.my_location,
              label: 'Sekarang',
              value: _optLokasiSekarang,
              lebar: lebar,
            ),
            _buildLocationOptionIcon(
              icon: Icons.edit_location_alt_outlined,
              label: 'Koordinat',
              value: _optManualKoordinat,
              lebar: lebar,
            ),
          ],
        ),
        SizedBox(height: tinggi * 0.01),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: TextField(
            controller: _koordinatController,
            readOnly: _selectedLocationOption != _optManualKoordinat,
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
            style: TextStyle(fontSize: lebar * 0.032, color: Colors.black),
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
                        key: _mapViewKey,
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
}
