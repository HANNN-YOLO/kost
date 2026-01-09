import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:kost_saw/models/fasilitas_model.dart';
import 'package:kost_saw/models/kost_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../custom/custom_dropdown_searh_v2.dart';
import '../../custom/label_1baris_full.dart';
import '../../custom/custom_UploadFotov2.dart';
import '../../custom/showdialog_eror.dart';
import '../../custom/custom_editfotov2.dart';
import 'package:provider/provider.dart';
import '../../../providers/kost_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profil_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:collection/collection.dart';

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
  final TextEditingController _namaFasilitasController =
      TextEditingController();
  final TextEditingController _koordinatController = TextEditingController();
  final TextEditingController _panjang = TextEditingController();
  final TextEditingController _lebar = TextEditingController();
  bool allstatus = false;
  int index = 0;
  bool keadaan = true;

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (keadaan) {
      final int? terima = ModalRoute.of(context)?.settings.arguments as int?;
      final penghubung = Provider.of<KostProvider>(context, listen: false);
      final penghubung2 = Provider.of<ProfilProvider>(context, listen: false)
          .readdata(penghubung.token!, penghubung.id_authnya!);

      final cek = Provider.of<AuthProvider>(context, listen: false)
          .mydata
          .firstWhere((element) => element.id_auth == penghubung.id_authnya);

      if (penghubung2 != null) {
        print("akhirnya kebaca");
        if (cek != null) {
          print("data aman");
          _namapemilik.text = cek.username ?? "";
          if (terima != null) {
            final pakai = Provider.of<KostProvider>(context, listen: false)
                .kostpemilik
                .firstWhere((element) => element.id_kost == terima);

            _namapemilik.text = pakai.pemilik_kost ?? "";
            _namakost.text = pakai.nama_kost ?? "";
            _notlpn.text = pakai.notlp_kost.toString() ?? "";
            _alamat.text = pakai.alamat_kost ?? "";
            _harga.text = pakai.harga_kost.toString() ?? "";
            _panjang.text = pakai.panjang.toString() ?? "00";
            _lebar.text = pakai.lebar.toString() ?? "00";
            _koordinatController.text =
                "${pakai.garis_lintang},${pakai.garis_bujur}";

            // penghubung.namanya = pakai.pemilik_kost ?? "Pilih";
            penghubung.jeniskosts = pakai.jenis_kost ?? "Pilih";
            penghubung.jeniskeamanans = pakai.keamanan ?? "Pilih";
            penghubung.batasjammalams = pakai.batas_jam_malam ?? "PIlih";
            penghubung.jenispembayaranairs =
                pakai.jenis_pembayaran_air ?? "Pilih";
            penghubung.jenislistriks = pakai.jenis_listrik ?? "Pilih";

            if (pakai != null) {
              final cekker = Provider.of<KostProvider>(context, listen: false)
                  .fasilitaspemilik
                  .firstWhereOrNull(
                      (element) => element.id_fasilitas == pakai.id_fasilitas);

              if (cekker != null) {
                penghubung.inputan.tempat_tidur = cekker.tempat_tidur;
                penghubung.inputan.kamar_mandi_dalam = cekker.kamar_mandi_dalam;
                penghubung.inputan.meja = cekker.meja;
                penghubung.inputan.tempat_parkir = cekker.tempat_parkir;
                penghubung.inputan.lemari = cekker.lemari;
                penghubung.inputan.ac = cekker.ac;
                penghubung.inputan.tv = cekker.tv;
                penghubung.inputan.kipas = cekker.kipas;
                penghubung.inputan.dapur_dalam = cekker.dapur_dalam;
                penghubung.inputan.wifi = cekker.wifi;
              }
            }
          }
        }
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
    _koordinatController.removeListener(_onKoordinatChanged);
    _koordinatController.dispose();
    _namaFasilitasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<KostProvider>(context);

    // final penghubung2 = Provider.of<ProfilProvider>(context, listen: false)
    //     .readdata(penghubung.token!, penghubung.id_authnya!);

    final penghubung3 = Provider.of<ProfilProvider>(context);

    // Jika profil sudah ada, isi otomatis nomor telepon sekali saja
    if (penghubung3.mydata.isNotEmpty && _notlpn.text.isEmpty) {
      _notlpn.text = penghubung3.mydata.first.kontak.toString();
    }

    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    const warnaLatar = Color(0xFFF5F7FB);
    const warnaTombol = Color(0xFF12111F);

    final int? terima = ModalRoute.of(context)?.settings.arguments as int?;
    KostModel? pakai;

    if (terima != null) {
      pakai = Provider.of<KostProvider>(context, listen: false)
          .kostpemilik
          .firstWhere((element) => element.id_kost == terima);
    }

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
                                ? _inputField('Harga', tinggiLayar, lebarLayar,
                                    _harga, false)
                                : _inputField('Harga', tinggiLayar, lebarLayar,
                                    _harga, false);
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
                                    pathlama: pakai?.gambar_kost,
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
                        ChangeNotifierProvider.value(
                          value: penghubung.inputan,
                          child: Consumer<KostProvider>(
                            builder: (context, value, child) {
                              return terima != null
                                  ? Consumer<FasilitasModel>(
                                      builder: (context, value, child) {
                                        return Wrap(
                                          spacing: lebarLayar * 0.02,
                                          runSpacing: tinggiLayar * 0.015,
                                          children: [
                                            _buildCustomItem(
                                              "Tempat Tidur",
                                              Icons.bed,
                                              value.tempat_tidur,
                                              () => value.booltempattidur(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Kamar Mandi Dalam",
                                              Icons.bathtub_outlined,
                                              value.kamar_mandi_dalam,
                                              () => value.boolkamarmandidalam(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Meja",
                                              Icons.desk,
                                              value.meja,
                                              () => value.boolmeja(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Tempat Parkir",
                                              Icons.local_parking,
                                              value.tempat_parkir,
                                              () => value.booltempatparkir(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Lemari",
                                              PhosphorIconsBold.gridFour,
                                              value.lemari,
                                              () => value.boollemari(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "AC",
                                              Icons.ac_unit,
                                              value.ac,
                                              () => value.boolac(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "TV",
                                              Icons.tv,
                                              value.tv,
                                              () => value.booltv(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Kipas Angin",
                                              Icons.wind_power,
                                              value.kipas,
                                              () => value.boolkipas(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Dapur Dalam",
                                              Icons.kitchen,
                                              value.dapur_dalam,
                                              () => value
                                                  .booldapurdalam(), // Perbaikan typo pemanggilan fungsi
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "WiFi",
                                              Icons.wifi,
                                              value.wifi,
                                              () => value.boolwifi(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                          ],
                                        );
                                      },
                                    )
                                  : Consumer<FasilitasModel>(
                                      builder: (context, value, child) {
                                        return Wrap(
                                          spacing: lebarLayar * 0.02,
                                          runSpacing: tinggiLayar * 0.015,
                                          children: [
                                            _buildCustomItem(
                                              "Tempat Tidur",
                                              Icons.bed,
                                              value.tempat_tidur,
                                              () => value.booltempattidur(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Kamar Mandi Dalam",
                                              Icons.bathtub_outlined,
                                              value.kamar_mandi_dalam,
                                              () => value.boolkamarmandidalam(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Meja",
                                              Icons.desk,
                                              value.meja,
                                              () => value.boolmeja(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Tempat Parkir",
                                              Icons.local_parking,
                                              value.tempat_parkir,
                                              () => value.booltempatparkir(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Lemari",
                                              PhosphorIconsBold.gridFour,
                                              value.lemari,
                                              () => value.boollemari(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "AC",
                                              Icons.ac_unit,
                                              value.ac,
                                              () => value.boolac(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "TV",
                                              Icons.tv,
                                              value.tv,
                                              () => value.booltv(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Kipas Angin",
                                              Icons.wind_power,
                                              value.kipas,
                                              () => value.boolkipas(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "Dapur Dalam",
                                              Icons.kitchen,
                                              value.dapur_dalam,
                                              () => value
                                                  .booldapurdalam(), // Perbaikan typo pemanggilan fungsi
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                            _buildCustomItem(
                                              "WiFi",
                                              Icons.wifi,
                                              value.wifi,
                                              () => value.boolwifi(),
                                              lebarLayar,
                                              tinggiLayar,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                            },
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
                    return terima != null
                        ? Padding(
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
                                onPressed: () async {
                                  try {
                                    await penghubung.updateddatapemilik(
                                      penghubung.token!,
                                      penghubung.id_authnya!,
                                      pakai!.id_fasilitas!,
                                      pakai.id_kost!,
                                      pakai.gambar_kost!,
                                      penghubung.foto,
                                      penghubung.inputan.tempat_tidur,
                                      penghubung.inputan.kamar_mandi_dalam,
                                      penghubung.inputan.meja,
                                      penghubung.inputan.tempat_parkir,
                                      penghubung.inputan.lemari,
                                      penghubung.inputan.ac,
                                      penghubung.inputan.tv,
                                      penghubung.inputan.dapur_dalam,
                                      penghubung.inputan.wifi,
                                      _namapemilik.text,
                                      _namakost.text,
                                      int.parse(_notlpn.text),
                                      _alamat.text,
                                      int.parse(_harga.text),
                                      penghubung.jeniskosts,
                                      penghubung.jeniskeamanans,
                                      int.parse(_panjang.text),
                                      int.parse(_lebar.text),
                                      penghubung.batasjammalams,
                                      penghubung.jenispembayaranairs,
                                      penghubung.jenislistriks,
                                      _koordinatController.text,
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
                                  }
                                },
                                child: Text(
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
                                  backgroundColor: warnaTombol,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    await penghubung.createdatapemilik(
                                      penghubung.token!,
                                      penghubung.foto!,
                                      penghubung.id_authnya!,
                                      penghubung.inputan.tempat_tidur,
                                      penghubung.inputan.kamar_mandi_dalam,
                                      penghubung.inputan.meja,
                                      penghubung.inputan.tempat_parkir,
                                      penghubung.inputan.lemari,
                                      penghubung.inputan.ac,
                                      penghubung.inputan.tv,
                                      penghubung.inputan.kipas,
                                      penghubung.inputan.dapur_dalam,
                                      penghubung.inputan.wifi,
                                      _koordinatController.text,
                                      _namapemilik.text,
                                      _namakost.text,
                                      _alamat.text,
                                      int.parse(_notlpn.text),
                                      int.parse(_harga.text),
                                      penghubung.jeniskosts,
                                      penghubung.jeniskeamanans,
                                      int.parse(_panjang.text),
                                      int.parse(_lebar.text),
                                      penghubung.batasjammalams,
                                      penghubung.jenispembayaranairs,
                                      penghubung.jenislistriks,
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
                                  }
                                },
                                child: Text(
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
