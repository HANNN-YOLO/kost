import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
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
import 'package:provider/provider.dart';
import '../../../utils/thousands_separator_input_formatter.dart';
import '../../../providers/kost_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profil_provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../custom/textfield_with_dropdown.dart';
import '../../custom/textfield_1baris_full.dart';
import 'dart:collection';

class inputanlist {
  final TextEditingController fasilitas = TextEditingController();

  void bersih() {
    fasilitas.dispose();
  }
}

class FormAddHousePemilik extends StatefulWidget {
  static const arah = "/form-house-pemilik";
  const FormAddHousePemilik({super.key});

  @override
  State<FormAddHousePemilik> createState() => _FormAddHouseState();
}

class _FormAddHouseState extends State<FormAddHousePemilik> {
  final TextEditingController _namapemilik = TextEditingController();
  final TextEditingController _namakost = TextEditingController();
  final TextEditingController _notlpn = TextEditingController();
  final TextEditingController _alamat = TextEditingController();
  final TextEditingController _harga = TextEditingController();
  // final TextEditingController _namaFasilitasController =
  //     TextEditingController();
  final TextEditingController _koordinatController = TextEditingController();
  final TextEditingController _panjang = TextEditingController();
  final TextEditingController _lebar = TextEditingController();
  bool allstatus = true;
  int index = 0;
  bool keadaan = true;
  bool _isSubmitting = false;

  List<inputanlist> _listini = [];

  final TextEditingController _facilityInputController =
      TextEditingController();
  final FocusNode _facilityFocusNode = FocusNode();
  int? _editingFacilityIndex;

  // Key untuk WebView container
  final GlobalKey _webViewKey = GlobalKey();

  // Opsi lokasi untuk titik koordinat (mirip halaman rekomendasi penyewa)
  String _selectedLocationOption = 'Lokasi Tujuan';

  static const String _optLokasiSekarang = 'Lokasi Sekarang';
  static const String _optLokasiTujuan = 'Lokasi Tujuan';
  static const String _optManualKoordinat = 'Masukkan Titik Koordinat';

  // -------- WebView (Leaflet) ----------
  late final WebViewController _mapController;
  bool _mapLoaded = false;

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
    KostProvider penghubung,
  ) {
    final optKeamanan = penghubung.keamananOptionsDynamic;
    if (optKeamanan.isNotEmpty && penghubung.jeniskeamanans != 'Pilih') {
      if (!optKeamanan.contains(penghubung.jeniskeamanans)) {
        penghubung.jeniskeamanans = 'Pilih';
      }
    }

    final optBatas = penghubung.batasJamMalamOptionsDynamic;
    if (optBatas.isNotEmpty && penghubung.batasjammalams != 'Pilih') {
      if (!optBatas.contains(penghubung.batasjammalams)) {
        penghubung.batasjammalams = 'Pilih';
      }
    }

    final optAir = penghubung.jenisAirOptionsDynamic;
    if (optAir.isNotEmpty && penghubung.jenispembayaranairs != 'Pilih') {
      if (!optAir.contains(penghubung.jenispembayaranairs)) {
        penghubung.jenispembayaranairs = 'Pilih';
      }
    }

    final optListrik = penghubung.jenisListrikOptionsDynamic;
    if (optListrik.isNotEmpty && penghubung.jenislistriks != 'Pilih') {
      if (!optListrik.contains(penghubung.jenislistriks)) {
        penghubung.jenislistriks = 'Pilih';
      }
    }
  }

  @override
  void initState() {
    super.initState();

    // Default teks untuk mode "Tujuan" saat pertama kali membuka form
    _koordinatController.text = 'Klik 2x pada peta';

    // Buat controller WebView (webview_flutter >=4.x)
    _mapController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true) // Aktifkan zoom
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) {
          if (mounted) {
            setState(() => _mapLoaded = true);
            // Sinkronkan mode peta dengan opsi lokasi yang terpilih
            _syncMapModeWithLocationOption();
          }
        },
        onWebResourceError: (err) {
          // Error handling tanpa debug print yang berat
        },
      ))
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

    // load map html
    _loadMapHtmlFromAssets();

    // Listener untuk koordinat controller
    _koordinatController.addListener(_onKoordinatChanged);

    // Listener untuk field teks agar tombol simpan bisa enable/disable dinamis
    for (final controller in [
      _namapemilik,
      _namakost,
      _notlpn,
      _alamat,
      _harga,
      _panjang,
      _lebar,
      _koordinatController,
    ]) {
      controller.addListener(_onFormFieldChanged);
    }
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

  void _onFormFieldChanged() {
    // Trigger rebuild supaya status tombol (warna & enabled) ikut berubah
    if (mounted) setState(() {});
  }

  String _facilityKey(String raw) {
    return raw.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void _startEditFacility(int index) {
    if (index < 0 || index >= _listini.length) return;
    final current = _listini[index].fasilitas.text.trim();
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
    if (index < 0 || index >= _listini.length) return;
    final removed = _listini.removeAt(index);
    removed.bersih();

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
    final existingIndex = _listini.indexWhere(
      (e) => _facilityKey(e.fasilitas.text) == normalizedKey,
    );

    setState(() {
      if (_editingFacilityIndex != null) {
        final targetIndex = _editingFacilityIndex!;
        if (existingIndex != -1 && existingIndex != targetIndex) {
          return;
        }
        _listini[targetIndex].fasilitas.text = raw;
        _editingFacilityIndex = null;
        _facilityInputController.clear();
      } else {
        if (existingIndex != -1) return;
        final item = inputanlist();
        item.fasilitas.text = raw;
        _listini.add(item);
        _facilityInputController.clear();
      }
    });

    FocusScope.of(context).requestFocus(_facilityFocusNode);
  }

  // Sinkronkan mode peta dengan opsi lokasi yang terpilih
  Future<void> _syncMapModeWithLocationOption() async {
    if (!_mapLoaded || !mounted) return;

    try {
      if (_selectedLocationOption == _optLokasiTujuan) {
        await _mapController.runJavaScript(
            "clearMyLocation(); clearDestination(); setMode('destination');");
      } else if (_selectedLocationOption == _optManualKoordinat) {
        await _mapController.runJavaScript(
            "clearMyLocation(); clearDestination(); setMode('readonly');");
      } else if (_selectedLocationOption == _optLokasiSekarang) {
        await _mapController.runJavaScript(
            "clearMyLocation(); clearDestination(); setMode('normal');");
      }
    } catch (e) {
      // Error handling ringan
    }
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

  // Minta lokasi sekarang perangkat (menggunakan Geolocator dari KostProvider)
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
      final penghubung2 = Provider.of<ProfilProvider>(context, listen: false)
          .readdata(penghubung.token!, penghubung.id_authnya!);

      final cek = Provider.of<AuthProvider>(context, listen: false)
          .mydata
          .firstWhereOrNull(
              (element) => element.id_auth == penghubung.id_authnya);

      if (penghubung2 != null) {
        print("pemisah");
        print("akhirnya kebaca");
        if (cek != null) {
          print("data aman");
          _namapemilik.text = cek.username ?? "";
          if (terima != null) {
            final pakai = Provider.of<KostProvider>(context, listen: false)
                .kostpemilik
                .firstWhereOrNull((element) => element.id_kost == terima);
            print("test berjalan kah?");

            if (pakai != null) {
              _namapemilik.text = pakai.pemilik_kost ?? "";
              _namakost.text = pakai.nama_kost ?? "";
              // Nomor telepon mengikuti profil pemilik (bukan dari data kost)
              _alamat.text = pakai.alamat_kost ?? "";
              _harga.text = ThousandsSeparatorInputFormatter.formatDigits(
                (pakai.harga_kost ?? 0).toString(),
              );
              _panjang.text = pakai.panjang.toString() ?? "00";
              _lebar.text = pakai.lebar.toString() ?? "00";
              _koordinatController.text =
                  "${pakai.garis_lintang},${pakai.garis_bujur}";
              print("test kedua");

              // penghubung.namanya = pakai.pemilik_kost ?? "Pilih";
              penghubung.jeniskosts = pakai.jenis_kost ?? "Pilih";
              penghubung.jeniskeamanans = pakai.keamanan ?? "Pilih";
              penghubung.batasjammalams = pakai.batas_jam_malam ?? "Pilih";
              penghubung.jenispembayaranairs =
                  pakai.jenis_pembayaran_air ?? "Pilih";
              penghubung.jenislistriks = pakai.jenis_listrik ?? "Pilih";
              penghubung.pernama =
                  (pakai.per == null || (pakai.per ?? '').trim().isEmpty)
                      ? 'bulan'
                      : pakai.per!;

              // Jika subkriteria terkait sudah dihapus, paksa kembali ke default.
              _coerceDeletedSubkriteriaSelections(penghubung);
              print("test ketiga");

              // fasilitas lama
              // final cekker = Provider.of<KostProvider>(context, listen: false);
              //       .fasilitaspemilik
              //       .firstWhereOrNull(
              //           (element) => element.id_fasilitas == pakai.id_fasilitas);

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
            } else {
              print("id tidak ditemukan $terima di didchangedpendencies");
            }

            // if (pakai != null) {
            //
            // }
          }
        }
      }
    }
    keadaan = false;
  }

  @override
  void dispose() {
    // Cancel semua async operations
    _debounceTimer?.cancel();

    // Remove semua listeners sebelum dispose
    _koordinatController.removeListener(_onKoordinatChanged);
    for (final controller in [
      _namapemilik,
      _namakost,
      _notlpn,
      _alamat,
      _harga,
      _panjang,
      _lebar,
      _koordinatController,
    ]) {
      controller.removeListener(_onFormFieldChanged);
    }

    // Dispose controllers
    _namakost.dispose();
    _notlpn.dispose();
    _alamat.dispose();
    _harga.dispose();
    _lebar.dispose();
    _panjang.dispose();
    _namapemilik.dispose();
    _koordinatController.dispose();

    // Dispose list controllers
    for (var item in _listini) {
      item.bersih();
    }
    _listini.clear();

    _facilityInputController.dispose();
    _facilityFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<KostProvider>(context);

    // final penghubung2 = Provider.of<ProfilProvider>(context, listen: false)
    //     .readdata(penghubung.token!, penghubung.id_authnya!);

    final penghubung3 = Provider.of<ProfilProvider>(context);

    // Nomor telepon kost selalu mengikuti nomor telepon profil pemilik.
    // Jika profil belum diisi, field ini akan kosong dan tidak bisa diedit.
    final int? profilKontak =
        penghubung3.mydata.isNotEmpty ? penghubung3.mydata.first.kontak : null;
    final String profilNoHp = (profilKontak != null && profilKontak != 0)
        ? profilKontak.toString()
        : '';
    if (_notlpn.text != profilNoHp) {
      _notlpn.text = profilNoHp;
    }

    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    const warnaLatar = Color(0xFFF5F7FB);
    const warnaTombol = Color(0xFF12111F);

    final int? terima = ModalRoute.of(context)?.settings.arguments as int?;
    KostModel? pakai;
    pakai = Provider.of<KostProvider>(context, listen: false)
        .kostpemilik
        .firstWhereOrNull((element) => element.id_kost == terima);

    if (allstatus) {
      final int? terima = ModalRoute.of(context)?.settings.arguments as int?;
      KostModel? pakai;
      if (terima != null) {
        pakai = Provider.of<KostProvider>(context, listen: false)
            .kostpemilik
            .firstWhereOrNull((element) => element.id_kost == terima);

        _listini.clear();

        if (pakai != null) {
          final String manafasilitas = (pakai.fasilitas ?? '').trim();
          if (manafasilitas.isNotEmpty) {
            final List<String> inisaja = manafasilitas
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
            for (final hanyasaja in inisaja) {
              final namanya = inputanlist();
              namanya.fasilitas.text = hanyasaja;
              _listini.add(namanya);
            }
          }
        }

        _editingFacilityIndex = null;
        _facilityInputController.clear();
        allstatus = false;
      }
    }

    int? _parseHarga() =>
        ThousandsSeparatorInputFormatter.tryParseInt(_harga.text);

    return
        // penghubung2 == null &&
        penghubung3 == null
            ? Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Scaffold(
                backgroundColor: warnaLatar,
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(tinggiLayar * 0.08),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: lebarLayar * 0.06),
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
                          child:
                              const Icon(Icons.arrow_back, color: Colors.black),
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
                        const SizedBox(
                            width: 24), // Placeholder untuk alignment
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
                        Consumer<KostProvider>(
                          builder: (context, value, child) {
                            return terima != null
                                ? _inputField("Nama Pemilik", tinggiLayar,
                                    lebarLayar, _namapemilik, true)
                                : _inputField("Nama Pemilik", tinggiLayar,
                                    lebarLayar, _namapemilik, true);
                          },
                        ),
                        SizedBox(height: tinggiLayar * 0.025),

                        Consumer<KostProvider>(
                          builder: (context, value, child) {
                            return terima != null
                                ? _inputField('Nama Kost', tinggiLayar,
                                    lebarLayar, _namakost, false)
                                : _inputField('Nama Kost', tinggiLayar,
                                    lebarLayar, _namakost, false);
                          },
                        ),

                        Consumer<KostProvider>(
                          builder: (context, value, child) {
                            return terima != null
                                ? _inputField('Nomor Telepon', tinggiLayar,
                                    lebarLayar, _notlpn, true)
                                : _inputField('Nomor Telepon', tinggiLayar,
                                    lebarLayar, _notlpn, true);
                          },
                        ),

                        Consumer<KostProvider>(
                          builder: (context, value, child) {
                            return terima != null
                                ? _inputField('Alamat', tinggiLayar, lebarLayar,
                                    _alamat, false)
                                : _inputField('Alamat', tinggiLayar, lebarLayar,
                                    _alamat, false);
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
                                    },
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
                                    manalistnya: penghubung.jeniskeamanan,
                                    label: penghubung.jeniskeamanans,
                                    pilihan: penghubung.jeniskeamanans,
                                    fungsi: (value) {
                                      penghubung.pilihkeamanan(value);
                                    },
                                  )
                                : CustomDropdownSearchv2(
                                    lebar: lebarLayar,
                                    tinggi: tinggiLayar,
                                    manalistnya: penghubung.jeniskeamanan,
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
                                              SizedBox(
                                                width: lebarLayar * 0.01,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: TextField(
                                                    controller: _panjang,
                                                    keyboardType:
                                                        TextInputType.number,
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
                                              SizedBox(
                                                  width: lebarLayar * 0.01),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: TextField(
                                                    controller: _lebar,
                                                    keyboardType:
                                                        TextInputType.number,
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
                                              SizedBox(
                                                width: lebarLayar * 0.01,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: TextField(
                                                    controller: _panjang,
                                                    keyboardType:
                                                        TextInputType.number,
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
                                              SizedBox(
                                                  width: lebarLayar * 0.01),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    border: Border.all(
                                                      color:
                                                          Colors.grey.shade300,
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  child: TextField(
                                                    controller: _lebar,
                                                    keyboardType:
                                                        TextInputType.number,
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

                        Consumer<KostProvider>(
                          builder: (context, value, child) {
                            return terima != null
                                ? _inputFieldKoordinat(
                                    tinggiLayar,
                                    lebarLayar,
                                  )
                                : _inputFieldKoordinat(
                                    tinggiLayar,
                                    lebarLayar,
                                  );
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
                                children: _listini
                                    .asMap()
                                    .entries
                                    .where((e) => e.value.fasilitas.text
                                        .trim()
                                        .isNotEmpty)
                                    .map((entry) {
                                  final idx = entry.key;
                                  final label =
                                      entry.value.fasilitas.text.trim();
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
                                      deleteIcon:
                                          const Icon(Icons.close, size: 18),
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
                    final bool isReady =
                        _isFormReadyPemilik(penghubung, isEdit: isEdit);
                    final bool canSubmit = isReady && !_isSubmitting;

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
                                onPressed: !canSubmit
                                    ? null
                                    : () async {
                                        setState(() {
                                          _isSubmitting = true;
                                        });
                                        final String? errorMessage =
                                            _validateFormPemilik(
                                          penghubung,
                                          isEdit: true,
                                          currentKostId: pakai!.id_kost,
                                        );

                                        if (errorMessage != null) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ShowdialogEror(
                                                  label: errorMessage);
                                            },
                                          );

                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                          return;
                                        }

                                        try {
                                          // await penghubung.updateddatapemilik(
                                          //   penghubung.token!,
                                          //   penghubung.id_authnya!,
                                          //   pakai!.id_fasilitas!,
                                          //   pakai.id_kost!,
                                          //   pakai.gambar_kost!,
                                          //   penghubung.foto,
                                          //   penghubung.inputan.tempat_tidur,
                                          //   penghubung
                                          //       .inputan.kamar_mandi_dalam,
                                          //   penghubung.inputan.meja,
                                          //   penghubung.inputan.tempat_parkir,
                                          //   penghubung.inputan.lemari,
                                          //   penghubung.inputan.ac,
                                          //   penghubung.inputan.tv,
                                          //   penghubung.inputan.dapur_dalam,
                                          //   penghubung.inputan.wifi,
                                          //   _namapemilik.text,
                                          //   _namakost.text,
                                          //   int.parse(_notlpn.text),
                                          //   _alamat.text,
                                          //   _parseHarga() ?? 0,
                                          //   penghubung.jeniskosts,
                                          //   penghubung.jeniskeamanans,
                                          //   int.parse(_panjang.text),
                                          //   int.parse(_lebar.text),
                                          //   penghubung.batasjammalams,
                                          //   penghubung.jenispembayaranairs,
                                          //   penghubung.jenislistriks,
                                          //   _koordinatController.text,
                                          //   penghubung.pernama,
                                          // );

                                          await penghubung
                                              .konversiupdateddatapemilik(
                                            penghubung.token!,
                                            penghubung.id_authnya!,
                                            pakai.id_kost!,
                                            pakai.gambar_kost!,
                                            penghubung.foto,
                                            _namapemilik.text,
                                            _namakost.text,
                                            int.tryParse(_notlpn.text) ?? 0,
                                            _alamat.text,
                                            ThousandsSeparatorInputFormatter
                                                    .tryParseInt(_harga.text) ??
                                                0,
                                            penghubung.jeniskosts,
                                            penghubung.jeniskeamanans,
                                            num.parse(_panjang.text),
                                            num.parse(_lebar.text),
                                            penghubung.batasjammalams,
                                            penghubung.jenispembayaranairs,
                                            penghubung.jenislistriks,
                                            _koordinatController.text,
                                            penghubung.pernama,
                                            _listini,
                                          );

                                          setState(() {
                                            penghubung.resetpilihan();
                                            penghubung.inputan.resetcheckbox();
                                          });

                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ShowdialogEror(
                                                  label: "${e.toString()}");
                                            },
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                        }
                                      },
                                child: _isSubmitting
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
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
                                onPressed: !canSubmit
                                    ? null
                                    : () async {
                                        if (!mounted) return;
                                        setState(() {
                                          _isSubmitting = true;
                                        });
                                        final String? errorMessage =
                                            _validateFormPemilik(
                                          penghubung,
                                          isEdit: false,
                                        );

                                        if (errorMessage != null) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ShowdialogEror(
                                                  label: errorMessage);
                                            },
                                          );

                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                          return;
                                        }

                                        try {
                                          // await penghubung.createdatapemilik(
                                          //   penghubung.token!,
                                          //   penghubung.foto!,
                                          //   penghubung.id_authnya!,
                                          //   penghubung.inputan.tempat_tidur,
                                          //   penghubung
                                          //       .inputan.kamar_mandi_dalam,
                                          //   penghubung.inputan.meja,
                                          //   penghubung.inputan.tempat_parkir,
                                          //   penghubung.inputan.lemari,
                                          //   penghubung.inputan.ac,
                                          //   penghubung.inputan.tv,
                                          //   penghubung.inputan.kipas,
                                          //   penghubung.inputan.dapur_dalam,
                                          //   penghubung.inputan.wifi,
                                          //   _koordinatController.text,
                                          //   _namapemilik.text,
                                          //   _namakost.text,
                                          //   _alamat.text,
                                          //   int.parse(_notlpn.text),
                                          //   _parseHarga() ?? 0,
                                          //   penghubung.jeniskosts,
                                          //   penghubung.jeniskeamanans,
                                          //   int.parse(_panjang.text),
                                          //   int.parse(_lebar.text),
                                          //   penghubung.batasjammalams,
                                          //   penghubung.jenispembayaranairs,
                                          //   penghubung.jenislistriks,
                                          //   penghubung.pernama,
                                          // );

                                          await penghubung
                                              .konversicreateddatapemilik(
                                            penghubung.token!,
                                            penghubung.foto!,
                                            penghubung.id_authnya!,
                                            _koordinatController.text,
                                            _namapemilik.text,
                                            _namakost.text,
                                            _alamat.text,
                                            int.tryParse(_notlpn.text) ?? 0,
                                            ThousandsSeparatorInputFormatter
                                                    .tryParseInt(_harga.text) ??
                                                0,
                                            penghubung.jeniskosts,
                                            penghubung.jeniskeamanans,
                                            num.parse(_panjang.text),
                                            num.parse(_lebar.text),
                                            penghubung.batasjammalams,
                                            penghubung.jenispembayaranairs,
                                            penghubung.jenislistriks,
                                            penghubung.pernama,
                                            _listini,
                                          );

                                          setState(() {
                                            penghubung.inputan.resetcheckbox();
                                            penghubung.resetpilihan();
                                          });

                                          Navigator.of(context).pop();
                                        } catch (e) {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return ShowdialogEror(
                                                  label: "${e.toString()}");
                                            },
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() {
                                              _isSubmitting = false;
                                            });
                                          }
                                        }
                                      },
                                child: _isSubmitting
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
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
                ),
              );
  }

  // 🔹 Input TextField umum
  Widget _inputField(String label, double tinggi, double lebar,
      TextEditingController isi, bool kunci) {
    final bool isNumericField = label == 'Nomor Telepon' || label == 'Harga';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: lebar * 0.035,
            )),
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
            controller: isi,
            readOnly: kunci,
            keyboardType:
                isNumericField ? TextInputType.number : TextInputType.text,
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
            ),
          ),
        ),
        SizedBox(height: tinggi * 0.025),
      ],
    );
  }

  String? _validateFormPemilik(
    KostProvider penghubung, {
    required bool isEdit,
    int? currentKostId,
  }) {
    final namaPemilik = _namapemilik.text.trim();
    final namaKost = _namakost.text.trim();
    final noTelp = _notlpn.text.trim();
    final alamat = _alamat.text.trim();
    final harga = _harga.text.trim();
    final panjang = _panjang.text.trim();
    final lebar = _lebar.text.trim();
    final koordinat = _koordinatController.text.trim();

    final bool hasAtLeastOneFasilitas =
        _listini.any((item) => item.fasilitas.text.trim().isNotEmpty);

    if (namaPemilik.isEmpty ||
        namaKost.isEmpty ||
        alamat.isEmpty ||
        harga.isEmpty ||
        panjang.isEmpty ||
        lebar.isEmpty ||
        koordinat.isEmpty) {
      return "Harap lengkapi semua kolom yang wajib diisi.";
    }

    if (penghubung.jeniskosts == "Pilih" ||
        penghubung.jeniskeamanans == "Pilih" ||
        penghubung.batasjammalams == "Pilih" ||
        penghubung.jenispembayaranairs == "Pilih" ||
        penghubung.jenislistriks == "Pilih") {
      return "Harap pilih semua opsi dropdown (jenis kost, keamanan, jam malam, pembayaran air, dan listrik).";
    }

    if (!isEdit && penghubung.foto == null) {
      return "Foto kost wajib di-upload.";
    }

    if (!hasAtLeastOneFasilitas) {
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

    // Nomor telepon mengikuti profil dan boleh kosong jika profil belum diisi.
    if (noTelp.isNotEmpty && int.tryParse(noTelp) == null) {
      return "Nomor telepon hanya boleh berisi angka.";
    }

    if (ThousandsSeparatorInputFormatter.tryParseInt(harga) == null) {
      return "Harga kost hanya boleh berisi angka.";
    }

    if (int.tryParse(panjang) == null || int.tryParse(lebar) == null) {
      return "Panjang dan lebar kamar hanya boleh berisi angka.";
    }

    final parts = koordinat.split(',');
    if (parts.length != 2) {
      return "Format titik koordinat tidak valid. Contoh: -5.147665, 119.432731";
    }

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) {
      return "Format titik koordinat tidak valid. Contoh: -5.147665, 119.432731";
    }

    final existingNamaAlamat = penghubung.kostpemilik.where((k) {
      if (currentKostId != null && k.id_kost == currentKostId) return false;
      final existingNama = (k.nama_kost ?? "").trim().toLowerCase();
      final existingAlamat = (k.alamat_kost ?? "").trim().toLowerCase();
      return existingNama == namaKost.toLowerCase() &&
          existingAlamat == alamat.toLowerCase();
    }).toList();

    if (!isEdit && existingNamaAlamat.isNotEmpty) {
      return "Kost dengan nama dan alamat tersebut sudah terdaftar.";
    }

    final existingKoordinat = penghubung.kostpemilik.where((k) {
      if (currentKostId != null && k.id_kost == currentKostId) return false;
      return k.garis_lintang == lat && k.garis_bujur == lng;
    }).toList();

    if (!isEdit && existingKoordinat.isNotEmpty) {
      return "Titik koordinat ini sudah digunakan oleh kost lain.";
    }

    return null;
  }

  bool _isFormReadyPemilik(
    KostProvider penghubung, {
    required bool isEdit,
  }) {
    final namaPemilik = _namapemilik.text.trim();
    final namaKost = _namakost.text.trim();
    final noTelp = _notlpn.text.trim();
    final alamat = _alamat.text.trim();
    final harga = _harga.text.trim();
    final panjang = _panjang.text.trim();
    final lebar = _lebar.text.trim();
    final koordinat = _koordinatController.text.trim();

    final bool hasAtLeastOneFasilitas =
        _listini.any((item) => item.fasilitas.text.trim().isNotEmpty);

    if (namaPemilik.isEmpty ||
        namaKost.isEmpty ||
        alamat.isEmpty ||
        harga.isEmpty ||
        panjang.isEmpty ||
        lebar.isEmpty ||
        koordinat.isEmpty) {
      return false;
    }

    if (penghubung.jeniskosts == "Pilih" ||
        penghubung.jeniskeamanans == "Pilih" ||
        penghubung.batasjammalams == "Pilih" ||
        penghubung.jenispembayaranairs == "Pilih" ||
        penghubung.jenislistriks == "Pilih") {
      return false;
    }

    if (!isEdit && penghubung.foto == null) {
      return false;
    }

    if (!hasAtLeastOneFasilitas) {
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
        if (_selectedLocationOption == value) return;
        setState(() => _selectedLocationOption = value);

        if (!_mapLoaded) return;

        // Set perilaku setiap opsi dan sinkronkan dengan peta
        if (value == _optManualKoordinat) {
          await _mapController.runJavaScript(
              "clearMyLocation(); clearDestination(); setMode('readonly');");
          _koordinatController.text = '';
        } else if (value == _optLokasiTujuan) {
          await _mapController.runJavaScript(
              "clearMyLocation(); clearDestination(); setMode('destination');");
          _koordinatController.text = 'Klik 2x pada peta';
        } else if (value == _optLokasiSekarang) {
          await _mapController.runJavaScript(
              "clearMyLocation(); clearDestination(); setMode('normal');");
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
            child: Icon(
              icon,
              size: lebar * 0.06,
              color: color,
            ),
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
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
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
              key: _webViewKey,
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

  // Helper Widget supaya tidak perlu menulis CheckboxListTile 10 kali
  Widget _buildCheckboxItem(
    String label,
    IconData icon,
    bool nilai,
    VoidCallback onTekan,
    double lebar,
    double tinggi,
    bool test,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: lebar * 0.025,
        vertical: tinggi * 0.009,
      ),
      decoration: BoxDecoration(
        color: test ? Colors.blue.shade100 : Colors.white,
        border: Border.all(
          color: test ? Colors.blue : Colors.grey.shade700,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Icon(
              icon,
              size: lebar * 0.045,
              color: Colors.grey.shade700,
            ),
            Text(
              label,
              style: TextStyle(
                  fontSize: lebar * 0.032,
                  color: Colors.black.withOpacity(0.8)),
            )
          ],
        ),
        // secondary: Icon(icon),
        value: nilai,
        onChanged: (value) {
          onTekan(); // Memanggil fungsi bool...() dari model
        },
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 0), // Sesuaikan padding
        dense: true, // Agar tidak terlalu renggang
      ),
    );
  }
}

// Helper Widget Baru (Desain Kotak Kecil / Tags)
Widget _buildCustomItem(
  String label,
  IconData icon,
  bool nilai,
  VoidCallback onTekan,
  double lebar,
  double tinggi,
) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTekan,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: lebar * 0.03,
          vertical: tinggi * 0.012,
        ),
        decoration: BoxDecoration(
          // Logika Warna Background: Biru muda jika aktif, Putih jika tidak
          color: nilai ? const Color(0xFFE3F2FD) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            // Logika Warna Border: Biru jika aktif, Abu jika tidak
            color: nilai ? Colors.blue : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // PENTING: Agar lebar menyesuaikan isi teks
          children: [
            // Ikon Checkbox Manual
            Icon(
              nilai ? Icons.check_box : Icons.check_box_outline_blank,
              size: lebar * 0.05,
              color: nilai ? Colors.blue : Colors.grey.shade600,
            ),
            SizedBox(width: lebar * 0.02),

            // Ikon Fasilitas
            Icon(
              icon,
              size: lebar * 0.05,
              color: nilai ? Colors.blue.shade700 : Colors.grey.shade700,
            ),
            SizedBox(width: lebar * 0.02),

            // Teks Label
            Text(
              label,
              style: TextStyle(
                fontSize: lebar * 0.032,
                fontWeight: nilai ? FontWeight.w600 : FontWeight.normal,
                color: nilai
                    ? Colors.blue.shade900
                    : Colors.black.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


// harap