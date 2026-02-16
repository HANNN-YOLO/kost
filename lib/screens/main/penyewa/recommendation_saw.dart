import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math' as math;

import 'process_saw.dart';
import 'package:provider/provider.dart';

import '../../../providers/kost_provider.dart';
import '../../../algoritma/simple_additive_weighting.dart';
import '../shared/formatCurrency.dart';

class RecommendationSawPage extends StatefulWidget {
  final double? destinationLat;
  final double? destinationLng;
  final List<Map<String, dynamic>>? kostData;

  const RecommendationSawPage({
    super.key,
    this.destinationLat,
    this.destinationLng,
    this.kostData,
  });

  @override
  State<RecommendationSawPage> createState() => _RecommendationSawPageState();
}

int? _parseIdrToInt(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return int.tryParse(digits);
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static String _format(String digits) {
    if (digits.isEmpty) return '';
    final rev = digits.split('').reversed.toList();
    final parts = <String>[];
    for (int i = 0; i < rev.length; i += 3) {
      parts.add(rev.sublist(i, (i + 3).clamp(0, rev.length)).join());
    }
    return parts.join('.').split('').reversed.join();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final formatted = _format(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _RecommendationSawPageState extends State<RecommendationSawPage> {
  final TextEditingController _hargaMaxC = TextEditingController();
  final TextEditingController _luasMaxC = TextEditingController();

  late final KostProvider _kostProvider;
  bool _sawAutoStarted = false;
  bool _showSkippedWarning = true; // State untuk show/hide warning banner

  String _jenisKostFilter = 'Semua';
  String _keamananFilter = 'Semua';
  String _batasJamMalamFilter = 'Semua';
  String _jenisListrikFilter = 'Semua';
  String _jenisPembayaranAirFilter = 'Semua';
  double? _jarakMaxKm;

  final Set<String> _fasilitasWajib = <String>{};

  static const List<String> _opsiJenisKost = <String>[
    'Semua',
    'Umum',
    'Khusus Putri',
    'Khusus Putra',
  ];

  static const List<double> _opsiJarakKm = <double>[1, 3, 5, 10];

  static const List<String> _opsiFasilitas = <String>[
    'Tempat Tidur',
    'Kamar Mandi Dalam',
    'Meja',
    'Tempat Parkir',
    'Lemari',
    'AC',
    'TV',
    'Kipas Angin',
    'Dapur Dalam',
    'WiFi',
  ];

  static String _facilityKey(String raw) {
    final cleaned =
        raw.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '').trim();
    return cleaned;
  }

  static String _canonicalFacilityLabel(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final key = _facilityKey(trimmed);

    // Bathroom inside: WC Dalam / KM Dalam / Kamar Mandi Dalam
    if (key == 'wcdalam' ||
        key == 'wc' ||
        key == 'kmdalam' ||
        key == 'kamarmandidalam' ||
        key == 'kamarmandiddlm' ||
        key == 'kmmandidalam') {
      return 'Kamar Mandi Dalam';
    }

    if (key == 'dapurdalam' || key == 'dapur') return 'Dapur Dalam';
    if (key == 'kipasangin' || key == 'kipas') return 'Kipas Angin';
    if (key == 'wifi' || key == 'wi-fi' || key == 'wi_fi') return 'WiFi';
    if (key == 'tempatparkir' || key == 'parkir') return 'Tempat Parkir';
    if (key == 'tempattidur' || key == 'kasur' || key == 'ranjang') {
      return 'Tempat Tidur';
    }

    // Default: keep original label (but trimmed)
    return trimmed;
  }

  @override
  void dispose() {
    _hargaMaxC.dispose();
    _luasMaxC.dispose();
    super.dispose();
  }

  void _resetFilter() {
    setState(() {
      _hargaMaxC.clear();
      _luasMaxC.clear();
      _jenisKostFilter = 'Semua';
      _keamananFilter = 'Semua';
      _batasJamMalamFilter = 'Semua';
      _jenisListrikFilter = 'Semua';
      _jenisPembayaranAirFilter = 'Semua';
      _jarakMaxKm = null;
      _fasilitasWajib.clear();
    });
  }

  List<String> _getSubkriteriaOptions(
    KostProvider provider,
    bool Function(String lowerNamaKriteria) match,
  ) {
    final listKriteria = provider.listKriteria;
    final listSubkriteria = provider.listSubkriteria;
    if (listKriteria.isEmpty || listSubkriteria.isEmpty) return [];

    final matchedIds = listKriteria
        .where((k) {
          final nama = (k.kategori ?? '').toLowerCase();
          return match(nama);
        })
        .map((k) => k.id_kriteria)
        .whereType<int>()
        .toSet();

    if (matchedIds.isEmpty) return [];

    final Map<String, String> unique = <String, String>{};
    for (final s in listSubkriteria) {
      final id = s.id_kriteria;
      if (id == null || !matchedIds.contains(id)) continue;
      final raw = (s.kategori ?? '').trim();
      if (raw.isEmpty) continue;
      unique.putIfAbsent(raw.toLowerCase(), () => raw);
    }

    final hasil = unique.values.toList();
    hasil.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return hasil;
  }

  Future<void> _openFilterSheet({
    required double Function(double) s,
    required Color colorPrimary,
    required Color colorTextPrimary,
    required Color colorWhite,
    required Color shadowColor,
    required List<String> keamananOptions,
    required List<String> batasJamMalamOptions,
    required List<String> jenisListrikOptions,
    required List<String> jenisPembayaranAirOptions,
    required List<String> fasilitasOptions,
    required int totalRankings,
    required int filteredRankings,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(s(18))),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        return _SawFilterSheet(
          s: s,
          colorPrimary: colorPrimary,
          colorTextPrimary: colorTextPrimary,
          colorWhite: colorWhite,
          shadowColor: shadowColor,
          keamananOptions: keamananOptions,
          batasJamMalamOptions: batasJamMalamOptions,
          jenisListrikOptions: jenisListrikOptions,
          jenisPembayaranAirOptions: jenisPembayaranAirOptions,
          fasilitasOptions: fasilitasOptions,
          totalRankings: totalRankings,
          filteredRankings: filteredRankings,
          initialHargaMax: _hargaMaxC.text,
          initialLuasMax: _luasMaxC.text,
          initialJenisKost: _jenisKostFilter,
          initialKeamanan: _keamananFilter,
          initialBatasJamMalam: _batasJamMalamFilter,
          initialJenisListrik: _jenisListrikFilter,
          initialJenisPembayaranAir: _jenisPembayaranAirFilter,
          initialJarakMaxKm: _jarakMaxKm,
          initialFasilitasWajib: _fasilitasWajib,
          onResetAll: () => _resetFilter(),
          onApply: (
            hargaMax,
            luasMax,
            jenisKost,
            keamanan,
            batasJamMalam,
            jenisListrik,
            jenisPembayaranAir,
            jarakMaxKm,
            fasilitasWajib,
          ) {
            setState(() {
              _hargaMaxC.text = hargaMax;
              _luasMaxC.text = luasMax;
              _jenisKostFilter = jenisKost;
              _keamananFilter = keamanan;
              _batasJamMalamFilter = batasJamMalam;
              _jenisListrikFilter = jenisListrik;
              _jenisPembayaranAirFilter = jenisPembayaranAir;
              _jarakMaxKm = jarakMaxKm;
              _fasilitasWajib
                ..clear()
                ..addAll(fasilitasWajib);
            });
          },
        );
      },
    );
  }

  double? _getDistanceKmFromArgs(int idKost) {
    if (widget.kostData == null) return null;
    for (final m in widget.kostData!) {
      if (m['id_kost'] == idKost) {
        final v = m['distanceKm'];
        if (v is num) return v.toDouble();
        return null;
      }
    }
    return null;
  }

  double _deg2rad(double deg) => deg * (3.141592653589793 / 180.0);

  double? _haversineKm({
    required double? lat1,
    required double? lng1,
    required double? lat2,
    required double? lng2,
  }) {
    if (lat1 == null || lng1 == null || lat2 == null || lng2 == null) {
      return null;
    }
    const double R = 6371.0;
    final double dLat = _deg2rad(lat2 - lat1);
    final double dLng = _deg2rad(lng2 - lng1);
    final double a = (math.sin(dLat / 2) * math.sin(dLat / 2)) +
        (math.cos(_deg2rad(lat1)) *
            math.cos(_deg2rad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2));
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  void _showSkippedDetail(
    BuildContext context,
    List<KostTerskipSAW> skipped,
    double Function(double) s,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(s(18))),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return Padding(
              padding: EdgeInsets.fromLTRB(s(16), s(12), s(16), s(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: s(44),
                      height: s(5),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(s(999)),
                      ),
                    ),
                  ),
                  SizedBox(height: s(12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kost Tidak Diproses',
                              style: TextStyle(
                                fontSize: s(16),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: s(6)),
                            Text(
                              'Berikut kost yang tidak masuk perangkingan karena ada kriteria yang tidak cocok dengan subkriteria.',
                              style: TextStyle(
                                fontSize: s(12),
                                color: const Color(0xFF1F1F1F).withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: s(8)),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, size: s(24)),
                        tooltip: 'Tutup',
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey.shade100,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(s(8)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s(12)),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemCount: skipped.length,
                      separatorBuilder: (_, __) => SizedBox(height: s(10)),
                      itemBuilder: (context, index) {
                        final item = skipped[index];
                        return Container(
                          padding: EdgeInsets.all(s(12)),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7FB),
                            borderRadius: BorderRadius.circular(s(14)),
                            border: Border.all(
                              color: const Color(0xFF1C3B98).withOpacity(0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: s(18),
                                    color: const Color(0xFF1C3B98),
                                  ),
                                  SizedBox(width: s(8)),
                                  Expanded(
                                    child: Text(
                                      item.namaKost,
                                      style: TextStyle(
                                        fontSize: s(14),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1F1F1F),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: s(8)),
                              ...item.alasan.map(
                                (a) => Padding(
                                  padding: EdgeInsets.only(bottom: s(6)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('• ',
                                          style: TextStyle(
                                              fontSize: s(12), height: 1.35)),
                                      Expanded(
                                        child: Text(
                                          a,
                                          style: TextStyle(
                                            fontSize: s(12),
                                            height: 1.35,
                                            color: const Color(0xFF1F1F1F)
                                                .withOpacity(0.85),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Ambil provider sekali saat widget masih mounted.
    _kostProvider = context.read<KostProvider>();

    // Jalankan perhitungan SAW saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_sawAutoStarted) return;
      _sawAutoStarted = true;

      _kostProvider.hitungSAW(
        userLat: widget.destinationLat,
        userLng: widget.destinationLng,
      );
    });
  }

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
    final Color shadowColor = const Color.fromRGBO(0, 0, 0, 0.06);

    return Scaffold(
      backgroundColor: colorBackground,
      appBar: AppBar(
        backgroundColor: colorBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: colorPrimary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Hasil Rekomendasi (SAW)',
          style:
              TextStyle(color: colorTextPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Lihat Perhitungan SAW',
            icon: const Icon(Icons.table_chart_outlined, color: colorPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProcessSawPage(
                    userLat: widget.destinationLat,
                    userLng: widget.destinationLng,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: s(4)),
        ],
      ),
      body: Consumer<KostProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoadingSAW) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: s(16)),
                  Text(
                    'Harap menunggu...',
                    style: TextStyle(
                      fontSize: s(14),
                      color: colorTextPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Error state
          if (provider.errorSAW != null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(s(24)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: s(64),
                      color: Colors.red,
                    ),
                    SizedBox(height: s(16)),
                    Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: s(18),
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: s(8)),
                    Text(
                      provider.errorSAW!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: s(14),
                        color: colorTextPrimary,
                      ),
                    ),
                    SizedBox(height: s(24)),
                    ElevatedButton.icon(
                      onPressed: () => provider.hitungSAW(
                        userLat: widget.destinationLat,
                        userLng: widget.destinationLng,
                      ),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba Lagi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorPrimary,
                        foregroundColor: colorWhite,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Tidak ada hasil
          if (provider.hasilSAW == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: s(64),
                    color: colorPrimary.withOpacity(0.5),
                  ),
                  SizedBox(height: s(16)),
                  Text(
                    'Belum ada hasil rekomendasi',
                    style: TextStyle(
                      fontSize: s(16),
                      color: colorTextPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Ambil hasil ranking dari SAW
          final hasilSAW = provider.hasilSAW!;
          final rankings = hasilSAW.hasilRanking;
          final skipped = hasilSAW.kostTerskip;

          // Build list of kost items from ranking
          final kostList = provider.kostpenyewa.isNotEmpty
              ? provider.kostpenyewa
              : provider.kost;

          final Map<int, dynamic> kostById = <int, dynamic>{};
          for (final k in kostList) {
            final id = k.id_kost;
            if (id is int) kostById[id] = k;
          }

          // Opsi dropdown diambil dari subkriteria (fallback ke data kost kalau subkriteria kosong)
          List<String> _fallbackFromKost(String? Function(dynamic k) pick) {
            final Set<String> values = <String>{};
            for (final k in kostList) {
              final v = (pick(k) ?? '').trim();
              if (v.isNotEmpty && v.toLowerCase() != 'pilih') values.add(v);
            }
            final list = values.toList()..sort();
            return list;
          }

          final subKeamanan = _getSubkriteriaOptions(
            provider,
            (nama) => nama.contains('keamanan'),
          );
          final subJamMalam = _getSubkriteriaOptions(
            provider,
            (nama) => nama.contains('batas') || nama.contains('jam malam'),
          );
          final subListrik = _getSubkriteriaOptions(
            provider,
            (nama) => nama.contains('listrik'),
          );
          final subAir = _getSubkriteriaOptions(
            provider,
            (nama) => nama.contains('air') || nama.contains('pembayaran'),
          );

          final List<String> keamananOptions = <String>[
            'Semua',
            ...((subKeamanan.isNotEmpty)
                ? subKeamanan
                : _fallbackFromKost((k) => (k.keamanan ?? '').toString())),
          ];
          final List<String> batasJamMalamOptions = <String>[
            'Semua',
            ...((subJamMalam.isNotEmpty)
                ? subJamMalam
                : _fallbackFromKost(
                    (k) => (k.batas_jam_malam ?? '').toString(),
                  )),
          ];
          final List<String> jenisListrikOptions = <String>[
            'Semua',
            ...((subListrik.isNotEmpty)
                ? subListrik
                : _fallbackFromKost((k) => (k.jenis_listrik ?? '').toString())),
          ];
          final List<String> jenisPembayaranAirOptions = <String>[
            'Semua',
            ...((subAir.isNotEmpty)
                ? subAir
                : _fallbackFromKost(
                    (k) => (k.jenis_pembayaran_air ?? '').toString(),
                  )),
          ];

          // Opsi fasilitas diambil dari fasilitas yang ada pada data kost (comma-separated)
          final Map<String, String> fasilitasUnique = <String, String>{};
          for (final k in kostList) {
            final raw = (k.fasilitas ?? '').toString();
            if (raw.trim().isEmpty) continue;
            for (final part in raw.split(',')) {
              final item = part.trim();
              if (item.isEmpty) continue;
              final canonical = _canonicalFacilityLabel(item);
              if (canonical.isEmpty) continue;
              final key = _facilityKey(canonical);
              if (key.isEmpty) continue;
              fasilitasUnique.putIfAbsent(key, () => canonical);
            }
          }
          final List<String> fasilitasOptions = (fasilitasUnique.isNotEmpty)
              ? (fasilitasUnique.values.toList()
                ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())))
              : _opsiFasilitas;

          bool passesFilter(dynamic kost, HasilRanking ranking) {
            final int harga = (kost.harga_kost ?? 0) as int;
            final int? hargaMax = _parseIdrToInt(_hargaMaxC.text.trim());
            if (hargaMax != null && harga > hargaMax) return false;

            if (_jenisKostFilter != 'Semua') {
              final jenis = (kost.jenis_kost ?? '').toString();
              if (jenis != _jenisKostFilter) return false;
            }

            if (_keamananFilter != 'Semua') {
              final keamanan = (kost.keamanan ?? '').toString();
              if (keamanan != _keamananFilter) return false;
            }

            if (_batasJamMalamFilter != 'Semua') {
              final v = (kost.batas_jam_malam ?? '').toString();
              if (v != _batasJamMalamFilter) return false;
            }

            if (_jenisListrikFilter != 'Semua') {
              final v = (kost.jenis_listrik ?? '').toString();
              if (v != _jenisListrikFilter) return false;
            }

            if (_jenisPembayaranAirFilter != 'Semua') {
              final v = (kost.jenis_pembayaran_air ?? '').toString();
              if (v != _jenisPembayaranAirFilter) return false;
            }

            final num? luasMax = num.tryParse(_luasMaxC.text.trim());
            if (luasMax != null) {
              final num? panjang = kost.panjang;
              final num? lebar = kost.lebar;
              if (panjang == null || lebar == null) return false;
              final num luas = panjang * lebar;
              if (luas > luasMax) return false;
            }

            if (_jarakMaxKm != null) {
              double? d = _getDistanceKmFromArgs(ranking.idKost);
              d ??= _haversineKm(
                lat1: widget.destinationLat,
                lng1: widget.destinationLng,
                lat2: kost.garis_lintang,
                lng2: kost.garis_bujur,
              );
              if (d == null) return false;
              if (d > _jarakMaxKm!) return false;
            }

            if (_fasilitasWajib.isNotEmpty) {
              final raw = (kost.fasilitas ?? '').toString();
              final Set<String> fasilitasKostKeys = raw
                  .split(',')
                  .map((e) => _facilityKey(_canonicalFacilityLabel(e)))
                  .where((e) => e.isNotEmpty)
                  .toSet();
              for (final f in _fasilitasWajib) {
                if (!fasilitasKostKeys.contains(_facilityKey(f))) {
                  return false;
                }
              }
            }

            return true;
          }

          // Filter setelah perangkingan SAW (sesuai pilihan)
          final List<HasilRanking> filteredRankings = <HasilRanking>[];
          for (final r in rankings) {
            final found = kostById[r.idKost];
            if (found == null) continue;
            if (passesFilter(found, r)) {
              filteredRankings.add(r);
            }
          }

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (skipped.isNotEmpty && _showSkippedWarning) ...[
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(s(12)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(s(14)),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withOpacity(0.35),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: const Color(0xFFF59E0B),
                            size: s(20),
                          ),
                          SizedBox(width: s(10)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${skipped.length} kost tidak diproses',
                                  style: TextStyle(
                                    fontSize: s(13),
                                    fontWeight: FontWeight.w700,
                                    color: colorTextPrimary,
                                  ),
                                ),
                                SizedBox(height: s(4)),
                                Text(
                                  'Ada kriteria yang tidak cocok dengan subkriteria. Kost ini tidak dimasukkan ke perangkingan.',
                                  style: TextStyle(
                                    fontSize: s(12),
                                    color: colorTextPrimary.withOpacity(0.75),
                                    height: 1.25,
                                  ),
                                ),
                                SizedBox(height: s(8)),
                                SizedBox(
                                  height: s(34),
                                  child: OutlinedButton(
                                    onPressed: () => _showSkippedDetail(
                                      context,
                                      skipped,
                                      s,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFB45309),
                                      side: BorderSide(
                                        color: const Color(0xFFF59E0B)
                                            .withOpacity(0.6),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(s(10)),
                                      ),
                                    ),
                                    child: Text(
                                      'Lihat alasan',
                                      style: TextStyle(
                                        fontSize: s(12),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _showSkippedWarning = false;
                              });
                            },
                            icon: Icon(Icons.close, size: s(20)),
                            tooltip: 'Tutup peringatan',
                            constraints: BoxConstraints(),
                            padding: EdgeInsets.all(s(4)),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFF59E0B).withOpacity(0.15),
                              shape: CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: s(12)),
                  ],
                  // Tombol untuk menampilkan kembali warning jika sudah disembunyikan
                  if (skipped.isNotEmpty && !_showSkippedWarning) ...[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(s(10)),
                        border: Border.all(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _showSkippedWarning = true;
                          });
                        },
                        borderRadius: BorderRadius.circular(s(10)),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: s(12),
                            vertical: s(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: s(18),
                                color: const Color(0xFFF59E0B),
                              ),
                              SizedBox(width: s(8)),
                              Text(
                                'Lihat ${skipped.length} kost yang tidak diproses',
                                style: TextStyle(
                                  fontSize: s(12),
                                  color: const Color(0xFFB45309),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: s(12)),
                  ],
                  Row(
                    children: [
                      Container(
                        width: s(36),
                        height: s(36),
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: BorderRadius.circular(s(12)),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: s(8),
                              offset: Offset(0, s(3)),
                            ),
                          ],
                        ),
                        child: Icon(Icons.emoji_events_rounded,
                            color: Colors.amber, size: s(20)),
                      ),
                      SizedBox(width: s(10)),
                      Text(
                        'Peringkat Kost (SAW)',
                        style: TextStyle(
                          fontSize: s(16),
                          fontWeight: FontWeight.w600,
                          color: colorTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s(10)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Menampilkan ${filteredRankings.length} dari ${rankings.length}',
                          style: TextStyle(
                            fontSize: s(12),
                            fontWeight: FontWeight.w700,
                            color: colorTextPrimary.withOpacity(0.75),
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _openFilterSheet(
                          s: s,
                          colorPrimary: colorPrimary,
                          colorTextPrimary: colorTextPrimary,
                          colorWhite: colorWhite,
                          shadowColor: shadowColor,
                          keamananOptions: keamananOptions,
                          batasJamMalamOptions: batasJamMalamOptions,
                          jenisListrikOptions: jenisListrikOptions,
                          jenisPembayaranAirOptions: jenisPembayaranAirOptions,
                          fasilitasOptions: fasilitasOptions,
                          totalRankings: rankings.length,
                          filteredRankings: filteredRankings.length,
                        ),
                        icon: const Icon(Icons.filter_alt_rounded),
                        label: const Text('Filter'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorPrimary,
                          side:
                              BorderSide(color: colorPrimary.withOpacity(0.35)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(s(12)),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: s(12),
                            vertical: s(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s(12)),
                  Expanded(
                    child: filteredRankings.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(s(24)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.filter_alt_off_rounded,
                                    size: s(64),
                                    color: colorPrimary.withOpacity(0.55),
                                  ),
                                  SizedBox(height: s(14)),
                                  Text(
                                    'Tidak ada kost yang memenuhi penilaian',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: s(15),
                                      fontWeight: FontWeight.w700,
                                      color: colorTextPrimary,
                                    ),
                                  ),
                                  SizedBox(height: s(8)),
                                  Text(
                                    'Periksa subkriteria (range) yang tersedia atau lihat alasan kost yang dilewati.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: s(12),
                                      color: colorTextPrimary.withOpacity(0.7),
                                      height: 1.3,
                                    ),
                                  ),
                                  if (skipped.isNotEmpty) ...[
                                    SizedBox(height: s(14)),
                                    ElevatedButton.icon(
                                      onPressed: () => _showSkippedDetail(
                                        context,
                                        skipped,
                                        s,
                                      ),
                                      icon: const Icon(
                                          Icons.info_outline_rounded),
                                      label: const Text('Lihat alasan'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colorPrimary,
                                        foregroundColor: colorWhite,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredRankings.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: s(12)),
                            itemBuilder: (context, index) {
                              final ranking = filteredRankings[index];

                              // Cari data kost berdasarkan idKost dari ranking
                              dynamic kost;
                              for (final k in kostList) {
                                if (k.id_kost == ranking.idKost) {
                                  kost = k;
                                  break;
                                }
                              }

                              if (kost == null) {
                                return const SizedBox.shrink();
                              }

                              // Cari jarak dari kostData jika tersedia
                              double? distanceKm;
                              distanceKm =
                                  _getDistanceKmFromArgs(ranking.idKost);
                              distanceKm ??= _haversineKm(
                                lat1: widget.destinationLat,
                                lng1: widget.destinationLng,
                                lat2: kost.garis_lintang,
                                lng2: kost.garis_bujur,
                              );

                              return _RankingCard(
                                rank: ranking.peringkat,
                                namaKost: ranking.namaKost,
                                skor: ranking.skor,
                                harga: kost.harga_kost ?? 0,
                                distanceKm: distanceKm,
                                luasKamar:
                                    (kost.panjang ?? 0) * (kost.lebar ?? 0),
                                panjang: kost.panjang ?? 0,
                                lebar: kost.lebar ?? 0,
                                imageUrl: kost.gambar_kost,
                                idKost: ranking.idKost,
                                s: s,
                                colorPrimary: colorPrimary,
                                colorTextPrimary: colorTextPrimary,
                                colorBackground: colorBackground,
                                colorWhite: colorWhite,
                                shadowColor: shadowColor,
                                destinationLat: widget.destinationLat,
                                destinationLng: widget.destinationLng,
                                per: (kost.per == null ||
                                        (kost.per ?? '').trim().isEmpty)
                                    ? 'bulan'
                                    : kost.per!,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _filterTextField({
  required TextEditingController controller,
  required String hintText,
  required double Function(double) s,
  required Color colorPrimary,
  List<TextInputFormatter>? inputFormatters,
}) {
  return TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: inputFormatters,
    decoration: InputDecoration(
      hintText: hintText,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(
        horizontal: s(12),
        vertical: s(12),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(s(12)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(s(12)),
        borderSide: BorderSide(color: colorPrimary.withOpacity(0.18)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(s(12)),
        borderSide: BorderSide(color: colorPrimary.withOpacity(0.45)),
      ),
    ),
  );
}

Widget _filterDropdown({
  required String label,
  required String value,
  required List<String> items,
  required double Function(double) s,
  required Color colorPrimary,
  required ValueChanged<String?> onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: s(12),
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: s(8)),
      Container(
        padding: EdgeInsets.symmetric(horizontal: s(12)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(s(12)),
          border: Border.all(color: colorPrimary.withOpacity(0.18)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            items: items
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(
                        fontSize: s(12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}

Widget _choiceChip({
  required String label,
  required bool selected,
  required double Function(double) s,
  required Color colorPrimary,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: s(12), vertical: s(8)),
      decoration: BoxDecoration(
        color: selected ? colorPrimary : colorPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(s(999)),
        border: Border.all(color: colorPrimary.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: s(11),
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : colorPrimary,
        ),
      ),
    ),
  );
}

class _SawFilterSheet extends StatefulWidget {
  final double Function(double) s;
  final Color colorPrimary;
  final Color colorTextPrimary;
  final Color colorWhite;
  final Color shadowColor;

  final List<String> keamananOptions;
  final List<String> batasJamMalamOptions;
  final List<String> jenisListrikOptions;
  final List<String> jenisPembayaranAirOptions;
  final List<String> fasilitasOptions;

  final int totalRankings;
  final int filteredRankings;

  final String initialHargaMax;
  final String initialLuasMax;
  final String initialJenisKost;
  final String initialKeamanan;
  final String initialBatasJamMalam;
  final String initialJenisListrik;
  final String initialJenisPembayaranAir;
  final double? initialJarakMaxKm;
  final Set<String> initialFasilitasWajib;

  final VoidCallback onResetAll;

  final void Function(
    String hargaMax,
    String luasMax,
    String jenisKost,
    String keamanan,
    String batasJamMalam,
    String jenisListrik,
    String jenisPembayaranAir,
    double? jarakMaxKm,
    Set<String> fasilitasWajib,
  ) onApply;

  const _SawFilterSheet({
    required this.s,
    required this.colorPrimary,
    required this.colorTextPrimary,
    required this.colorWhite,
    required this.shadowColor,
    required this.keamananOptions,
    required this.batasJamMalamOptions,
    required this.jenisListrikOptions,
    required this.jenisPembayaranAirOptions,
    required this.fasilitasOptions,
    required this.totalRankings,
    required this.filteredRankings,
    required this.initialHargaMax,
    required this.initialLuasMax,
    required this.initialJenisKost,
    required this.initialKeamanan,
    required this.initialBatasJamMalam,
    required this.initialJenisListrik,
    required this.initialJenisPembayaranAir,
    required this.initialJarakMaxKm,
    required this.initialFasilitasWajib,
    required this.onResetAll,
    required this.onApply,
  });

  @override
  State<_SawFilterSheet> createState() => _SawFilterSheetState();
}

class _SawFilterSheetState extends State<_SawFilterSheet> {
  late final TextEditingController _hargaMax;
  late final TextEditingController _luasMax;

  late String _jenisKost;
  late String _keamanan;
  late String _batasJamMalam;
  late String _jenisListrik;
  late String _jenisPembayaranAir;
  double? _jarakMaxKm;
  late final Set<String> _fasilitasWajib;

  @override
  void initState() {
    super.initState();
    _hargaMax = TextEditingController(text: widget.initialHargaMax);
    _luasMax = TextEditingController(text: widget.initialLuasMax);
    _jenisKost = widget.initialJenisKost;
    _keamanan = widget.initialKeamanan;
    _batasJamMalam = widget.initialBatasJamMalam;
    _jenisListrik = widget.initialJenisListrik;
    _jenisPembayaranAir = widget.initialJenisPembayaranAir;
    _jarakMaxKm = widget.initialJarakMaxKm;
    _fasilitasWajib = <String>{...widget.initialFasilitasWajib};
  }

  @override
  void dispose() {
    _hargaMax.dispose();
    _luasMax.dispose();
    super.dispose();
  }

  void _resetLocal() {
    setState(() {
      _hargaMax.clear();
      _luasMax.clear();
      _jenisKost = 'Semua';
      _keamanan = 'Semua';
      _batasJamMalam = 'Semua';
      _jenisListrik = 'Semua';
      _jenisPembayaranAir = 'Semua';
      _jarakMaxKm = null;
      _fasilitasWajib.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final colorPrimary = widget.colorPrimary;
    final colorTextPrimary = widget.colorTextPrimary;
    final colorWhite = widget.colorWhite;

    final keamananValue =
        widget.keamananOptions.contains(_keamanan) ? _keamanan : 'Semua';
    final jamMalamValue = widget.batasJamMalamOptions.contains(_batasJamMalam)
        ? _batasJamMalam
        : 'Semua';
    final listrikValue = widget.jenisListrikOptions.contains(_jenisListrik)
        ? _jenisListrik
        : 'Semua';
    final airValue =
        widget.jenisPembayaranAirOptions.contains(_jenisPembayaranAir)
            ? _jenisPembayaranAir
            : 'Semua';

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(s(16), s(12), s(16), s(16)),
              children: [
                Center(
                  child: Container(
                    width: s(44),
                    height: s(5),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(s(999)),
                    ),
                  ),
                ),
                SizedBox(height: s(10)),
                Row(
                  children: [
                    Icon(Icons.filter_alt_rounded,
                        color: colorPrimary, size: s(18)),
                    SizedBox(width: s(8)),
                    Expanded(
                      child: Text(
                        'Filter',
                        style: TextStyle(
                          fontSize: s(14),
                          fontWeight: FontWeight.w800,
                          color: colorTextPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.filteredRankings}/${widget.totalRankings}',
                      style: TextStyle(
                        fontSize: s(12),
                        fontWeight: FontWeight.w800,
                        color: colorPrimary,
                      ),
                    ),
                    SizedBox(width: s(8)),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: colorPrimary,
                      tooltip: 'Tutup',
                    ),
                  ],
                ),
                SizedBox(height: s(12)),
                Text(
                  'Harga Maksimum (Rp)',
                  style: TextStyle(
                    fontSize: s(12),
                    fontWeight: FontWeight.w700,
                    color: colorTextPrimary,
                  ),
                ),
                SizedBox(height: s(8)),
                _filterTextField(
                  controller: _hargaMax,
                  hintText: 'Contoh: 1500000',
                  s: s,
                  colorPrimary: colorPrimary,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ThousandsSeparatorInputFormatter(),
                  ],
                ),
                SizedBox(height: s(12)),
                Row(
                  children: [
                    Expanded(
                      child: _filterDropdown(
                        label: 'Jenis Kost',
                        value: _jenisKost,
                        items: _RecommendationSawPageState._opsiJenisKost,
                        s: s,
                        colorPrimary: colorPrimary,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _jenisKost = v);
                        },
                      ),
                    ),
                    SizedBox(width: s(10)),
                    Expanded(
                      child: _filterDropdown(
                        label: 'Keamanan',
                        value: keamananValue,
                        items: widget.keamananOptions,
                        s: s,
                        colorPrimary: colorPrimary,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _keamanan = v);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s(12)),
                Row(
                  children: [
                    Expanded(
                      child: _filterDropdown(
                        label: 'Batas Jam Malam',
                        value: jamMalamValue,
                        items: widget.batasJamMalamOptions,
                        s: s,
                        colorPrimary: colorPrimary,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _batasJamMalam = v);
                        },
                      ),
                    ),
                    SizedBox(width: s(10)),
                    Expanded(
                      child: _filterDropdown(
                        label: 'Jenis Listrik',
                        value: listrikValue,
                        items: widget.jenisListrikOptions,
                        s: s,
                        colorPrimary: colorPrimary,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _jenisListrik = v);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s(12)),
                _filterDropdown(
                  label: 'Pembayaran Air',
                  value: airValue,
                  items: widget.jenisPembayaranAirOptions,
                  s: s,
                  colorPrimary: colorPrimary,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _jenisPembayaranAir = v);
                  },
                ),
                SizedBox(height: s(12)),
                Text(
                  'Jarak Maksimum',
                  style: TextStyle(
                    fontSize: s(12),
                    fontWeight: FontWeight.w700,
                    color: colorTextPrimary,
                  ),
                ),
                SizedBox(height: s(8)),
                Wrap(
                  spacing: s(8),
                  runSpacing: s(8),
                  children: [
                    _choiceChip(
                      label: 'Semua',
                      selected: _jarakMaxKm == null,
                      s: s,
                      colorPrimary: colorPrimary,
                      onTap: () => setState(() => _jarakMaxKm = null),
                    ),
                    ..._RecommendationSawPageState._opsiJarakKm.map(
                      (km) => _choiceChip(
                        label: '${km.toStringAsFixed(0)} km',
                        selected: _jarakMaxKm == km,
                        s: s,
                        colorPrimary: colorPrimary,
                        onTap: () => setState(() => _jarakMaxKm = km),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s(12)),
                Text(
                  'Luas Kamar Maksimum (m²)',
                  style: TextStyle(
                    fontSize: s(12),
                    fontWeight: FontWeight.w700,
                    color: colorTextPrimary,
                  ),
                ),
                SizedBox(height: s(8)),
                _filterTextField(
                  controller: _luasMax,
                  hintText: 'Contoh: 14',
                  s: s,
                  colorPrimary: colorPrimary,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                SizedBox(height: s(12)),
                Text(
                  'Fasilitas Wajib',
                  style: TextStyle(
                    fontSize: s(12),
                    fontWeight: FontWeight.w700,
                    color: colorTextPrimary,
                  ),
                ),
                SizedBox(height: s(8)),
                Wrap(
                  spacing: s(8),
                  runSpacing: s(8),
                  children: widget.fasilitasOptions.map((f) {
                    final selectedKeys = _fasilitasWajib
                        .map(_RecommendationSawPageState._facilityKey)
                        .toSet();
                    final bool selected = selectedKeys
                        .contains(_RecommendationSawPageState._facilityKey(f));
                    return FilterChip(
                      label: Text(
                        f,
                        style: TextStyle(
                          fontSize: s(11),
                          fontWeight: FontWeight.w700,
                          color: selected ? colorWhite : colorPrimary,
                        ),
                      ),
                      selected: selected,
                      selectedColor: colorPrimary,
                      backgroundColor: colorPrimary.withOpacity(0.08),
                      side: BorderSide(
                        color: colorPrimary.withOpacity(0.20),
                      ),
                      onSelected: (v) {
                        setState(() {
                          final k = _RecommendationSawPageState._facilityKey(f);
                          final existing = _fasilitasWajib.firstWhere(
                            (x) =>
                                _RecommendationSawPageState._facilityKey(x) ==
                                k,
                            orElse: () => '',
                          );
                          if (v) {
                            if (existing.isEmpty) _fasilitasWajib.add(f);
                          } else {
                            if (existing.isNotEmpty)
                              _fasilitasWajib.remove(existing);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: s(14)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          widget.onResetAll();
                          _resetLocal();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorPrimary,
                          side:
                              BorderSide(color: colorPrimary.withOpacity(0.35)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(s(12)),
                          ),
                          padding: EdgeInsets.symmetric(vertical: s(12)),
                        ),
                      ),
                    ),
                    SizedBox(width: s(10)),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.onApply(
                            _hargaMax.text,
                            _luasMax.text,
                            _jenisKost,
                            _keamanan,
                            _batasJamMalam,
                            _jenisListrik,
                            _jenisPembayaranAir,
                            _jarakMaxKm,
                            _fasilitasWajib,
                          );
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Terapkan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorPrimary,
                          foregroundColor: colorWhite,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(s(12)),
                          ),
                          padding: EdgeInsets.symmetric(vertical: s(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s(4)),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Widget Card untuk menampilkan ranking kost
class _RankingCard extends StatelessWidget {
  final int rank;
  final String namaKost;
  final double skor;
  final int harga;
  final double? distanceKm;
  final num luasKamar;
  final num panjang;
  final num lebar;
  final String? imageUrl;
  final int idKost;
  final double Function(double) s;
  final Color colorPrimary;
  final Color colorTextPrimary;
  final Color colorBackground;
  final Color colorWhite;
  final Color shadowColor;
  final double? destinationLat;
  final double? destinationLng;
  final String per;

  const _RankingCard({
    required this.rank,
    required this.namaKost,
    required this.skor,
    required this.harga,
    required this.distanceKm,
    required this.luasKamar,
    required this.panjang,
    required this.lebar,
    required this.imageUrl,
    required this.idKost,
    required this.s,
    required this.colorPrimary,
    required this.colorTextPrimary,
    required this.colorBackground,
    required this.colorWhite,
    required this.shadowColor,
    required this.destinationLat,
    required this.destinationLng,
    required this.per,
  });

  @override
  Widget build(BuildContext context) {
    // Warna badge berdasarkan peringkat
    Color rankColor;
    Color rankBgColor;
    IconData rankIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      rankBgColor = const Color(0xFFFFF8E1);
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      rankBgColor = const Color(0xFFF5F5F5);
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankBgColor = const Color(0xFFFBE9E7);
      rankIcon = Icons.emoji_events_rounded;
    } else {
      rankColor = colorPrimary;
      rankBgColor = const Color(0xFFE3F2FD);
      rankIcon = Icons.tag;
    }

    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(s(16)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: s(10),
            offset: Offset(0, s(4)),
          ),
        ],
        border: rank == 1
            ? Border.all(color: const Color(0xFFFFD700), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image banner dengan badge peringkat
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(s(14))),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl == null || imageUrl!.isEmpty
                      ? Container(
                          color: const Color(0xFFE5ECFF),
                          child: Center(
                            child: Icon(
                              Icons.home_rounded,
                              color: Colors.grey,
                              size: s(48),
                            ),
                          ),
                        )
                      : Image.network(
                          imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: const Color(0xFFE5ECFF),
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: s(48),
                              ),
                            ),
                          ),
                        ),
                ),
                // Badge Peringkat (kiri atas)
                Positioned(
                  left: s(12),
                  top: s(12),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: s(12), vertical: s(8)),
                    decoration: BoxDecoration(
                      color: rankBgColor,
                      borderRadius: BorderRadius.circular(s(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: s(4),
                          offset: Offset(0, s(2)),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(rankIcon, size: s(18), color: rankColor),
                        SizedBox(width: s(4)),
                        Text(
                          '#$rank',
                          style: TextStyle(
                            fontSize: s(14),
                            fontWeight: FontWeight.w800,
                            color: rank <= 3 ? rankColor : colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Badge Harga (kanan atas)
                Positioned(
                  right: s(12),
                  top: s(12),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: s(10), vertical: s(6)),
                    decoration: BoxDecoration(
                      color: colorPrimary.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(s(10)),
                    ),
                    child: Text(
                      "${formatCurrency(harga)}",
                      style: TextStyle(
                        color: colorWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: s(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(s(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Kost
                Text(
                  namaKost,
                  style: TextStyle(
                    fontSize: s(16),
                    fontWeight: FontWeight.w700,
                    color: colorTextPrimary,
                  ),
                ),
                SizedBox(height: s(12)),

                // Info Grid: Skor, Jarak, Luas
                Row(
                  children: [
                    // Skor SAW
                    Expanded(
                      child: _infoChip(
                        icon: Icons.analytics_rounded,
                        label: 'Skor',
                        value: skor.toStringAsFixed(2),
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    SizedBox(width: s(8)),
                    // Jarak
                    Expanded(
                      child: _infoChip(
                        icon: Icons.route_rounded,
                        label: '',
                        value: distanceKm != null
                            ? '${distanceKm!.toStringAsFixed(2)} km'
                            : '-',
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(width: s(8)),
                    // Luas Kamar
                    Expanded(
                      child: _infoChip(
                        icon: Icons.square_foot_rounded,
                        label: 'Luas',
                        value: '${panjang}x${lebar} m²',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: s(12)),

                // Button Lihat Detail
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToDetail(context),
                    icon: Icon(Icons.visibility_rounded, size: s(18)),
                    label: Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: s(13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: colorWhite,
                      padding: EdgeInsets.symmetric(vertical: s(12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(s(10)),
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
  }

  Widget _infoChip({
    IconData? icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: s(10), horizontal: s(8)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(s(10)),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, size: s(20), color: color),
            SizedBox(height: s(4)),
          ],
          if (label.trim().isNotEmpty) ...[
            Text(
              label,
              style: TextStyle(
                fontSize: s(10),
                color: colorTextPrimary.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: s(2)),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: s(12),
              color: colorTextPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    final kostProvider = Provider.of<KostProvider>(context, listen: false);

    final List kostList = kostProvider.kostpenyewa.isNotEmpty
        ? kostProvider.kostpenyewa
        : kostProvider.kost;

    dynamic selectedKost;
    for (final k in kostList) {
      if (k.id_kost == idKost) {
        selectedKost = k;
        break;
      }
    }

    if (selectedKost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kost tidak ditemukan.')),
      );
      return;
    }

    Navigator.of(context).pushNamed(
      'detail-kost',
      arguments: {
        'data_kost': selectedKost,
        if (destinationLat != null) 'destinationLat': destinationLat,
        if (destinationLng != null) 'destinationLng': destinationLng,
        if (distanceKm != null) 'distanceKm': distanceKm,
      },
    );
  }

  String _formatCurrency(int value) {
    final str = value.toString();
    final rev = str.split('').reversed.toList();
    final parts = <String>[];
    for (int i = 0; i < rev.length; i += 3) {
      parts.add(rev.sublist(i, (i + 3).clamp(0, rev.length)).join());
    }
    final grouped = parts.join('.').split('').reversed.join();
    return 'Rp $grouped';
  }
}
