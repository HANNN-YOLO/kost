import 'package:flutter/material.dart';
import '../shared/formatCurrency.dart';
import 'package:provider/provider.dart';
import '../../../providers/kost_provider.dart';
import 'package:flutter/services.dart';

class KostHomePage extends StatefulWidget {
  static const routeName = '/kost_home';

  const KostHomePage({Key? key}) : super(key: key);

  @override
  State<KostHomePage> createState() => _KostHomePageState();
}

class _KostHomePageState extends State<KostHomePage>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _hargaMaxController = TextEditingController();
  final TextEditingController _luasMaxController = TextEditingController();

  bool _isAutoRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoRefreshIfNeeded();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _autoRefreshIfNeeded();
    }
  }

  Future<void> _autoRefreshIfNeeded() async {
    if (!mounted) return;
    if (_isAutoRefreshing) return;
    _isAutoRefreshing = true;
    try {
      await _refreshData();
    } catch (_) {
      // Abaikan error auto-refresh.
    } finally {
      _isAutoRefreshing = false;
    }
  }

  String _searchQuery = '';
  String _selectedJenis = 'Semua';

  String _keamananFilter = 'Semua';
  String _batasJamMalamFilter = 'Semua';
  String _jenisListrikFilter = 'Semua';
  String _jenisPembayaranAirFilter = 'Semua';

  Set<String> _fasilitasWajib = <String>{};

  static const List<String> _opsiJenisKostFallback = <String>[
    'Semua',
    'Umum',
    'Khusus Putri',
    'Khusus Putra',
  ];

  static const List<String> _opsiFasilitasFallback = <String>[
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

  static String _norm(String s) => s.trim().toLowerCase();

  static String _canonicalJenis(String raw) {
    final lower = _norm(raw);
    if (lower.isEmpty) return '';
    if (lower.contains('putri') || lower.contains('wanita'))
      return 'khusus putri';
    if (lower.contains('putra') || lower.contains('pria'))
      return 'khusus putra';
    if (lower.contains('umum') || lower.contains('campur')) return 'umum';
    return lower;
  }

  static int? _parseIdrToInt(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  static String _facilityKey(String input) {
    final s = _norm(input);
    if (s.isEmpty) return '';
    return s.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  static String _canonicalFacilityLabel(String raw) {
    final lower = _norm(raw);
    if (lower.isEmpty) return '';

    if (lower.contains('wifi')) return 'WiFi';
    if (lower.contains('ac') || lower.contains('a/c')) return 'AC';
    if (lower.contains('parkir')) return 'Parkir';
    if (lower.contains('kamar mandi') && lower.contains('dalam')) {
      return 'Kamar Mandi Dalam';
    }
    if (lower.contains('kamar mandi') && lower.contains('luar')) {
      return 'Kamar Mandi Luar';
    }
    if (lower.contains('lemari')) return 'Lemari';
    if (lower.contains('kasur') || lower.contains('ranjang')) return 'Kasur';
    if (lower.contains('meja')) return 'Meja';
    if (lower.contains('kursi')) return 'Kursi';
    if (lower.contains('dapur')) return 'Dapur';
    if (lower.contains('laundry') || lower.contains('cuci')) return 'Laundry';

    // fallback: title-case sederhana
    final parts = lower.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    return parts
        .map((w) => w.length <= 1
            ? w.toUpperCase()
            : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  static bool _looksLikeNumericSubcriteria(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return true;
    // contoh yang tidak diinginkan: "4", "4-6", "4 - 6"
    if (RegExp(r'^\d+$').hasMatch(s)) return true;
    if (RegExp(r'^\d+\s*-\s*\d+$').hasMatch(s)) return true;
    return false;
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

  List<String> _fallbackFromKost(
    List<dynamic> kostList,
    String? Function(dynamic k) pick,
  ) {
    final Set<String> values = <String>{};
    for (final k in kostList) {
      final v = (pick(k) ?? '').trim();
      if (v.isEmpty) continue;
      if (v.toLowerCase() == 'pilih') continue;
      values.add(v);
    }
    final list = values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  Future<void> _openFilterSheet({
    required double Function(double) s,
    required Color colorPrimary,
    required Color colorTextPrimary,
    required Color colorWhite,
    required List<String> jenisKostOptions,
    required List<String> keamananOptions,
    required List<String> batasJamMalamOptions,
    required List<String> jenisListrikOptions,
    required List<String> jenisPembayaranAirOptions,
    required List<String> fasilitasOptions,
    required int totalKost,
    required int filteredKost,
  }) async {
    final result = await showModalBottomSheet<_HomeFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(s(18))),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) {
        return _HomeFilterSheet(
          s: s,
          colorPrimary: colorPrimary,
          colorTextPrimary: colorTextPrimary,
          colorWhite: colorWhite,
          jenisKostOptions: jenisKostOptions,
          keamananOptions: keamananOptions,
          batasJamMalamOptions: batasJamMalamOptions,
          jenisListrikOptions: jenisListrikOptions,
          jenisPembayaranAirOptions: jenisPembayaranAirOptions,
          fasilitasOptions: fasilitasOptions,
          totalKost: totalKost,
          filteredKost: filteredKost,
          initialJenisKost: _selectedJenis,
          initialKeamanan: _keamananFilter,
          initialBatasJamMalam: _batasJamMalamFilter,
          initialJenisListrik: _jenisListrikFilter,
          initialJenisPembayaranAir: _jenisPembayaranAirFilter,
          initialHargaMax: _hargaMaxController.text,
          initialLuasMax: _luasMaxController.text,
          initialFasilitasWajib: _fasilitasWajib,
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() {
      _selectedJenis = result.jenisKost;
      _keamananFilter = result.keamanan;
      _batasJamMalamFilter = result.batasJamMalam;
      _jenisListrikFilter = result.jenisListrik;
      _jenisPembayaranAirFilter = result.jenisPembayaranAir;
      _hargaMaxController.text = result.hargaMax;
      _luasMaxController.text = result.luasMax;
      _fasilitasWajib = result.fasilitasWajib.toSet();
    });
  }

  @override

  /// Fungsi untuk refresh data kost (pull-to-refresh)
  Future<void> _refreshData() async {
    final penghubung = Provider.of<KostProvider>(context, listen: false);
    if (penghubung.token != null) {
      await penghubung.fetchKriteria();
      await penghubung.fetchSubkriteria();
      await penghubung.readdatapenyewa(penghubung.token!);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _hargaMaxController.dispose();
    _luasMaxController.dispose();
    super.dispose();
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedJenis == label;
    return _FilterChipItem(
      label: label,
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedJenis = label;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final penghubung = Provider.of<KostProvider>(context);
    const Color colorPrimary = Color(0xFF1C3B98);
    const Color colorTextPrimary = Color(0xFF111827);
    const Color colorWhite = Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;
    const double figmaWidth = 402;
    double scale = screenWidth / figmaWidth;
    double s(double size) => size * scale;

    // AppBar custom dengan gaya lebih minimalis & modern
    final AppBar appBar = AppBar(
      elevation: 0,
      toolbarHeight: 90,
      backgroundColor: const Color(0xFFF5F7FB),
      foregroundColor: Colors.black,
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Cari kost terbaik',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Temukan kost idealmu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: () async {
                final kostList = penghubung.kostpenyewa;

                final subKeamanan = _getSubkriteriaOptions(
                  penghubung,
                  (nama) => nama.contains('keamanan'),
                );
                final subJamMalam = _getSubkriteriaOptions(
                  penghubung,
                  (nama) =>
                      nama.contains('batas') || nama.contains('jam malam'),
                );
                final subListrik = _getSubkriteriaOptions(
                  penghubung,
                  (nama) => nama.contains('listrik'),
                );
                final subAir = _getSubkriteriaOptions(
                  penghubung,
                  (nama) => nama.contains('air') || nama.contains('pembayaran'),
                );

                final keamananOptions = <String>[
                  'Semua',
                  ...((subKeamanan.isNotEmpty)
                      ? subKeamanan
                      : _fallbackFromKost(
                          kostList, (k) => (k.keamanan ?? '').toString())),
                ];
                final batasJamMalamOptions = <String>[
                  'Semua',
                  ...((subJamMalam.isNotEmpty)
                      ? subJamMalam
                      : _fallbackFromKost(kostList,
                          (k) => (k.batas_jam_malam ?? '').toString())),
                ];
                final jenisListrikOptions = <String>[
                  'Semua',
                  ...((subListrik.isNotEmpty)
                      ? subListrik
                      : _fallbackFromKost(
                          kostList, (k) => (k.jenis_listrik ?? '').toString())),
                ];
                final jenisPembayaranAirOptions = <String>[
                  'Semua',
                  ...((subAir.isNotEmpty)
                      ? subAir
                      : _fallbackFromKost(kostList,
                          (k) => (k.jenis_pembayaran_air ?? '').toString())),
                ];

                // Opsi fasilitas: ambil dari fasilitas yang ada pada data kost
                // (jangan ambil dari subkriteria karena bisa berupa angka seperti 4-6)
                final Map<String, String> fasilitasUnique = <String, String>{};

                for (final k in kostList) {
                  final raw = (k.fasilitas ?? '').toString();
                  if (raw.trim().isEmpty) continue;
                  for (final part in raw.split(RegExp(r'[|,;]'))) {
                    final item = part.trim();
                    if (item.isEmpty) continue;
                    if (_looksLikeNumericSubcriteria(item)) continue;
                    final canonical = _canonicalFacilityLabel(item);
                    if (canonical.isEmpty) continue;
                    if (_looksLikeNumericSubcriteria(canonical)) continue;
                    final key = _facilityKey(canonical);
                    if (key.isEmpty) continue;
                    fasilitasUnique.putIfAbsent(key, () => canonical);
                  }
                }

                // Jika kosong, pakai fallback seperti halaman rekomendasi
                if (fasilitasUnique.isEmpty) {
                  for (final raw in _opsiFasilitasFallback) {
                    final canonical = _canonicalFacilityLabel(raw);
                    if (canonical.isEmpty) continue;
                    final key = _facilityKey(canonical);
                    if (key.isEmpty) continue;
                    fasilitasUnique.putIfAbsent(key, () => canonical);
                  }
                }

                final fasilitasOptions = fasilitasUnique.values.toList()
                  ..removeWhere((e) => e.trim().isEmpty)
                  ..sort(
                    (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
                  );

                // hitung jumlah kost terfilter saat ini untuk ditampilkan di header filter
                final totalKost = kostList.length;
                final filteredNow = kostList.where((k) {
                  final nama = (k.nama_kost ?? '').toLowerCase();
                  final alamat = (k.alamat_kost ?? '').toLowerCase();
                  final jenis = (k.penghuni ?? '').toLowerCase();

                  bool matchesSearch = true;
                  if (_searchQuery.isNotEmpty) {
                    matchesSearch = nama.contains(_searchQuery) ||
                        alamat.contains(_searchQuery) ||
                        jenis.contains(_searchQuery);
                  }

                  bool matchesJenis = true;
                  if (_selectedJenis != 'Semua') {
                    final raw = (k.penghuni ?? '').toString();
                    matchesJenis =
                        _canonicalJenis(raw) == _canonicalJenis(_selectedJenis);
                  }

                  bool matchesHarga = true;
                  final int? hargaMax =
                      _parseIdrToInt(_hargaMaxController.text.trim());
                  if (hargaMax != null) {
                    final int harga = (k.harga_kost ?? 0) as int;
                    if (harga > hargaMax) matchesHarga = false;
                  }

                  bool matchesLuas = true;
                  final num? luasMax = num.tryParse(
                    _luasMaxController.text.trim().replaceAll(',', '.'),
                  );
                  if (luasMax != null) {
                    final num? panjang = k.panjang;
                    final num? lebar = k.lebar;
                    if (panjang == null || lebar == null) {
                      matchesLuas = false;
                    } else {
                      final num luas = panjang * lebar;
                      if (luas > luasMax) matchesLuas = false;
                    }
                  }

                  bool matchesKeamanan = true;
                  if (_norm(_keamananFilter) != _norm('Semua')) {
                    matchesKeamanan = _norm((k.keamanan ?? '').toString()) ==
                        _norm(_keamananFilter);
                  }

                  bool matchesJamMalam = true;
                  if (_norm(_batasJamMalamFilter) != _norm('Semua')) {
                    matchesJamMalam =
                        _norm((k.batas_jam_malam ?? '').toString()) ==
                            _norm(_batasJamMalamFilter);
                  }

                  bool matchesListrik = true;
                  if (_norm(_jenisListrikFilter) != _norm('Semua')) {
                    matchesListrik =
                        _norm((k.jenis_listrik ?? '').toString()) ==
                            _norm(_jenisListrikFilter);
                  }

                  bool matchesAir = true;
                  if (_norm(_jenisPembayaranAirFilter) != _norm('Semua')) {
                    matchesAir =
                        _norm((k.jenis_pembayaran_air ?? '').toString()) ==
                            _norm(_jenisPembayaranAirFilter);
                  }

                  bool matchesFasilitas = true;
                  if (_fasilitasWajib.isNotEmpty) {
                    final raw = (k.fasilitas ?? '').toString();
                    final Set<String> fasilitasKostKeys = raw
                        .split(RegExp(r'[|,;]'))
                        .map((e) => _facilityKey(_canonicalFacilityLabel(e)))
                        .where((e) => e.isNotEmpty)
                        .toSet();
                    for (final f in _fasilitasWajib) {
                      if (!fasilitasKostKeys.contains(_facilityKey(f))) {
                        matchesFasilitas = false;
                        break;
                      }
                    }
                  }

                  return matchesSearch &&
                      matchesJenis &&
                      matchesHarga &&
                      matchesLuas &&
                      matchesKeamanan &&
                      matchesJamMalam &&
                      matchesListrik &&
                      matchesAir &&
                      matchesFasilitas;
                }).length;

                await _openFilterSheet(
                  s: s,
                  colorPrimary: colorPrimary,
                  colorTextPrimary: colorTextPrimary,
                  colorWhite: colorWhite,
                  jenisKostOptions: _opsiJenisKostFallback,
                  keamananOptions: keamananOptions,
                  batasJamMalamOptions: batasJamMalamOptions,
                  jenisListrikOptions: jenisListrikOptions,
                  jenisPembayaranAirOptions: jenisPembayaranAirOptions,
                  fasilitasOptions: fasilitasOptions,
                  totalKost: totalKost,
                  filteredKost: filteredNow,
                );
              },
              icon: const Icon(Icons.filter_alt_rounded),
              tooltip: 'Filter',
            ),
          ],
        ),
      ),
    );

    final tinggiBody = tinggiLayar - appBar.preferredSize.height - topPadding;

    // Breakpoints (adaptive)
    String kategori;
    if (lebarLayar < 600) {
      kategori = "mobile";
    } else if (lebarLayar < 1200) {
      kategori = "tablet";
    } else {
      kategori = "desktop";
    }

    // Styling adaptif berdasarkan kategori
    double cardRadius;
    double imageHeight;
    double titleFont;
    double priceFont;
    switch (kategori) {
      case "mobile":
        cardRadius = 14;
        imageHeight = tinggiBody * 0.32;
        titleFont = 16;
        priceFont = 16;
        break;
      case "tablet":
        cardRadius = 16;
        imageHeight = tinggiBody * 0.28;
        titleFont = 18;
        priceFont = 18;
        break;
      default: // desktop
        cardRadius = 18;
        imageHeight = tinggiBody * 0.22;
        titleFont = 20;
        priceFont = 20;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: PreferredSize(
        preferredSize: appBar.preferredSize,
        child: SafeArea(child: appBar),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Search field
            Material(
              elevation: 0,
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Cari kost',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const SizedBox(height: 4),

            // List kost terfilter
            Expanded(
              child: Builder(
                builder: (context) {
                  if (penghubung.isLoadingPenyewaKost &&
                      penghubung.kostpenyewa.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final semuaKost = penghubung.kostpenyewa;

                  final filtered = semuaKost.where((k) {
                    final nama = (k.nama_kost ?? '').toLowerCase();
                    final alamat = (k.alamat_kost ?? '').toLowerCase();
                    final jenis = (k.penghuni ?? '').toLowerCase();

                    bool matchesSearch = true;
                    if (_searchQuery.isNotEmpty) {
                      matchesSearch = nama.contains(_searchQuery) ||
                          alamat.contains(_searchQuery) ||
                          jenis.contains(_searchQuery);
                    }

                    bool matchesJenis = true;
                    if (_selectedJenis != 'Semua') {
                      final raw = (k.penghuni ?? '').toString();
                      matchesJenis = _canonicalJenis(raw) ==
                          _canonicalJenis(_selectedJenis);
                    }

                    bool matchesHarga = true;
                    final int? hargaMax =
                        _parseIdrToInt(_hargaMaxController.text.trim());
                    if (hargaMax != null) {
                      final int harga = (k.harga_kost ?? 0) as int;
                      if (harga > hargaMax) matchesHarga = false;
                    }

                    bool matchesLuas = true;
                    final num? luasMax = num.tryParse(
                        _luasMaxController.text.trim().replaceAll(',', '.'));
                    if (luasMax != null) {
                      final num? panjang = k.panjang;
                      final num? lebar = k.lebar;
                      if (panjang == null || lebar == null) {
                        matchesLuas = false;
                      } else {
                        final num luas = panjang * lebar;
                        if (luas > luasMax) matchesLuas = false;
                      }
                    }

                    bool matchesKeamanan = true;
                    if (_norm(_keamananFilter) != _norm('Semua')) {
                      matchesKeamanan = _norm((k.keamanan ?? '').toString()) ==
                          _norm(_keamananFilter);
                    }

                    bool matchesJamMalam = true;
                    if (_norm(_batasJamMalamFilter) != _norm('Semua')) {
                      matchesJamMalam =
                          _norm((k.batas_jam_malam ?? '').toString()) ==
                              _norm(_batasJamMalamFilter);
                    }

                    bool matchesListrik = true;
                    if (_norm(_jenisListrikFilter) != _norm('Semua')) {
                      matchesListrik =
                          _norm((k.jenis_listrik ?? '').toString()) ==
                              _norm(_jenisListrikFilter);
                    }

                    bool matchesAir = true;
                    if (_norm(_jenisPembayaranAirFilter) != _norm('Semua')) {
                      matchesAir =
                          _norm((k.jenis_pembayaran_air ?? '').toString()) ==
                              _norm(_jenisPembayaranAirFilter);
                    }

                    bool matchesFasilitas = true;
                    if (_fasilitasWajib.isNotEmpty) {
                      final raw = (k.fasilitas ?? '').toString();
                      final Set<String> fasilitasKostKeys = raw
                          .split(RegExp(r'[|,;]'))
                          .map((e) => _facilityKey(_canonicalFacilityLabel(e)))
                          .where((e) => e.isNotEmpty)
                          .toSet();
                      for (final f in _fasilitasWajib) {
                        if (!fasilitasKostKeys.contains(_facilityKey(f))) {
                          matchesFasilitas = false;
                          break;
                        }
                      }
                    }

                    return matchesSearch &&
                        matchesJenis &&
                        matchesHarga &&
                        matchesLuas &&
                        matchesKeamanan &&
                        matchesJamMalam &&
                        matchesListrik &&
                        matchesAir &&
                        matchesFasilitas;
                  }).toList();

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshData,
                      color: const Color(0xFF1E3A8A),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 100),
                          Center(
                            child: Text(
                              'Kost tidak ditemukan. Coba ubah kata kunci atau filter.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshData,
                    color: const Color(0xFF1E3A8A),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 18),
                      itemBuilder: (context, index) {
                        final tesst = filtered[index];

                        final perLabel =
                            ((tesst.per ?? '').toString().trim().isEmpty)
                                ? 'bulan'
                                : tesst.per.toString();

                        // Build facility tags from kost.fasilitas (comma-separated)
                        final List<String> fasilitasTags = [];
                        final rawFasilitas = (tesst.fasilitas ?? '').toString();
                        if (rawFasilitas.trim().isNotEmpty) {
                          fasilitasTags.addAll(
                            rawFasilitas
                                .split(RegExp(r'[|,;]'))
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty),
                          );
                        }

                        return _KostCard(
                          imageHeight: imageHeight,
                          radius: cardRadius,
                          titleFontSize: titleFont,
                          priceFontSize: priceFont,
                          price: tesst.harga_kost ?? 0,
                          per: " / $perLabel",
                          title: tesst.nama_kost ?? '-',
                          location: tesst.alamat_kost ?? '-',
                          genderLabel: (tesst.penghuni == null ||
                                  (tesst.penghuni ?? '').trim().isEmpty)
                              ? '-'
                              : (tesst.penghuni ?? '-'),
                          gambar: tesst.gambar_kost ?? '',
                          fasilitas: fasilitasTags,
                          fungsitap: () {
                            Navigator.of(context).pushNamed(
                              'detail-kost',
                              arguments: {
                                'data_kost': tesst,
                              },
                            );
                          },
                          colorprimary: colorPrimary,
                          colorwhite: colorWhite,
                          s: s,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// helper chip untuk filter jenis kost
class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipItem({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1C3B98) : const Color(0xFFE9EEF9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 14,
              color: selected ? Colors.white : const Color(0xFF1C3B98),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF1F1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeFilterResult {
  final String jenisKost;
  final String keamanan;
  final String batasJamMalam;
  final String jenisListrik;
  final String jenisPembayaranAir;
  final String hargaMax;
  final String luasMax;
  final Set<String> fasilitasWajib;

  const _HomeFilterResult({
    required this.jenisKost,
    required this.keamanan,
    required this.batasJamMalam,
    required this.jenisListrik,
    required this.jenisPembayaranAir,
    required this.hargaMax,
    required this.luasMax,
    required this.fasilitasWajib,
  });
}

class _HomeFilterSheet extends StatefulWidget {
  final double Function(double) s;
  final Color colorPrimary;
  final Color colorTextPrimary;
  final Color colorWhite;

  final List<String> jenisKostOptions;
  final List<String> keamananOptions;
  final List<String> batasJamMalamOptions;
  final List<String> jenisListrikOptions;
  final List<String> jenisPembayaranAirOptions;
  final List<String> fasilitasOptions;

  final int totalKost;
  final int filteredKost;

  final String initialJenisKost;
  final String initialKeamanan;
  final String initialBatasJamMalam;
  final String initialJenisListrik;
  final String initialJenisPembayaranAir;

  final String initialHargaMax;
  final String initialLuasMax;
  final Set<String> initialFasilitasWajib;

  const _HomeFilterSheet({
    required this.s,
    required this.colorPrimary,
    required this.colorTextPrimary,
    required this.colorWhite,
    required this.jenisKostOptions,
    required this.keamananOptions,
    required this.batasJamMalamOptions,
    required this.jenisListrikOptions,
    required this.jenisPembayaranAirOptions,
    required this.fasilitasOptions,
    required this.totalKost,
    required this.filteredKost,
    required this.initialJenisKost,
    required this.initialKeamanan,
    required this.initialBatasJamMalam,
    required this.initialJenisListrik,
    required this.initialJenisPembayaranAir,
    required this.initialHargaMax,
    required this.initialLuasMax,
    required this.initialFasilitasWajib,
  });

  @override
  State<_HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<_HomeFilterSheet> {
  late String _jenisKost;
  late String _keamanan;
  late String _jamMalam;
  late String _listrik;
  late String _air;

  late final TextEditingController _hargaMaxC;
  late final TextEditingController _luasMaxC;

  late Set<String> _fasilitas;

  static String _norm(String s) => s.trim().toLowerCase();

  static bool _containsNormalized(List<String> items, String value) {
    final v = _norm(value);
    return items.any((e) => _norm(e) == v);
  }

  static String _facilityKeyLocal(String input) {
    final s = _norm(input);
    if (s.isEmpty) return '';
    return s.replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();
  }

  @override
  void initState() {
    super.initState();
    _jenisKost = widget.initialJenisKost;
    _keamanan = widget.initialKeamanan;
    _jamMalam = widget.initialBatasJamMalam;
    _listrik = widget.initialJenisListrik;
    _air = widget.initialJenisPembayaranAir;

    _hargaMaxC = TextEditingController(text: widget.initialHargaMax);
    _luasMaxC = TextEditingController(text: widget.initialLuasMax);
    _fasilitas = widget.initialFasilitasWajib.toSet();
  }

  @override
  void dispose() {
    _hargaMaxC.dispose();
    _luasMaxC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    final colorPrimary = widget.colorPrimary;
    final colorTextPrimary = widget.colorTextPrimary;
    final colorWhite = widget.colorWhite;

    final jenisKostValue =
        _containsNormalized(widget.jenisKostOptions, _jenisKost)
            ? _jenisKost
            : 'Semua';
    final keamananValue = _containsNormalized(widget.keamananOptions, _keamanan)
        ? _keamanan
        : 'Semua';
    final jamMalamValue =
        _containsNormalized(widget.batasJamMalamOptions, _jamMalam)
            ? _jamMalam
            : 'Semua';
    final listrikValue =
        _containsNormalized(widget.jenisListrikOptions, _listrik)
            ? _listrik
            : 'Semua';
    final airValue = _containsNormalized(widget.jenisPembayaranAirOptions, _air)
        ? _air
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
                    Icon(
                      Icons.filter_alt_rounded,
                      color: colorPrimary,
                      size: s(18),
                    ),
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
                      '${widget.filteredKost}/${widget.totalKost}',
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
                _homeFilterTextField(
                  controller: _hargaMaxC,
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
                      child: _homeFilterDropdown(
                        label: 'Jenis Kost',
                        value: jenisKostValue,
                        items: widget.jenisKostOptions,
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
                      child: _homeFilterDropdown(
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
                      child: _homeFilterDropdown(
                        label: 'Batas Jam Malam',
                        value: jamMalamValue,
                        items: widget.batasJamMalamOptions,
                        s: s,
                        colorPrimary: colorPrimary,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _jamMalam = v);
                        },
                      ),
                    ),
                    SizedBox(width: s(10)),
                    Expanded(
                      child: _homeFilterDropdown(
                        label: 'Jenis Listrik',
                        value: listrikValue,
                        items: widget.jenisListrikOptions,
                        s: s,
                        colorPrimary: colorPrimary,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _listrik = v);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s(12)),
                _homeFilterDropdown(
                  label: 'Pembayaran Air',
                  value: airValue,
                  items: widget.jenisPembayaranAirOptions,
                  s: s,
                  colorPrimary: colorPrimary,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _air = v);
                  },
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
                _homeFilterTextField(
                  controller: _luasMaxC,
                  hintText: 'Contoh: 14',
                  s: s,
                  colorPrimary: colorPrimary,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                SizedBox(height: s(12)),
                if (widget.fasilitasOptions.isNotEmpty) ...[
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
                      final selectedKeys =
                          _fasilitas.map(_facilityKeyLocal).toSet();
                      final bool selected =
                          selectedKeys.contains(_facilityKeyLocal(f));
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
                            final k = _facilityKeyLocal(f);
                            final existing = _fasilitas.firstWhere(
                              (x) => _facilityKeyLocal(x) == k,
                              orElse: () => '',
                            );
                            if (v) {
                              if (existing.isEmpty) _fasilitas.add(f);
                            } else {
                              if (existing.isNotEmpty) {
                                _fasilitas.remove(existing);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
                SizedBox(height: s(14)),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _jenisKost = 'Semua';
                            _keamanan = 'Semua';
                            _jamMalam = 'Semua';
                            _listrik = 'Semua';
                            _air = 'Semua';
                            _hargaMaxC.clear();
                            _luasMaxC.clear();
                            _fasilitas.clear();
                          });
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reset'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorPrimary,
                          side: BorderSide(
                            color: colorPrimary.withOpacity(0.35),
                          ),
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
                          Navigator.of(context).pop(
                            _HomeFilterResult(
                              jenisKost: jenisKostValue,
                              keamanan: keamananValue,
                              batasJamMalam: jamMalamValue,
                              jenisListrik: listrikValue,
                              jenisPembayaranAir: airValue,
                              hargaMax: _hargaMaxC.text,
                              luasMax: _luasMaxC.text,
                              fasilitasWajib: _fasilitas,
                            ),
                          );
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

Widget _homeFilterTextField({
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

Widget _homeFilterDropdown({
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

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final sb = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final reverseIndex = digits.length - i;
      sb.write(digits[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        sb.write('.');
      }
    }

    final text = sb.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _KostCard extends StatelessWidget {
  final double imageHeight;
  final double radius;
  final double titleFontSize;
  final double priceFontSize;
  final int price;
  final String title;
  final String location;
  final String genderLabel;
  final String gambar;
  final VoidCallback? fungsitap;
  final List<String>? fasilitas;
  final String per;
  final Color colorprimary;
  final Color colorwhite;
  final double Function(double) s;

  _KostCard({
    Key? key,
    required this.imageHeight,
    required this.radius,
    required this.titleFontSize,
    required this.priceFontSize,
    required this.price,
    required this.title,
    required this.location,
    required this.genderLabel,
    required this.gambar,
    required this.fungsitap,
    this.fasilitas,
    required this.per,
    required this.colorprimary,
    required this.colorwhite,
    required this.s,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: fungsitap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar dengan sudut melengkung (top)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          '$gambar',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Color(0xFFE5ECFF),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                  size: 42,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFDDE6FF).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.sell_outlined,
                                  size: 18, color: Color(0xFF1C3B98)),
                              SizedBox(width: 6),
                              Text(
                                formatCurrency(price),
                                style: TextStyle(
                                  color: Color(0xFF1C3B98),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                per,
                                style: TextStyle(
                                  color: Color(0xFF1C3B98),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Info bawah
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // bar atas: price dan gender label di kanan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          genderLabel,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 3,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // if ((fasilitas ?? const []).isNotEmpty) ...[
                  //   SizedBox(height: 8),
                  //   Wrap(
                  //     spacing: 6,
                  //     runSpacing: 6,
                  //     children: [
                  //       for (final tag in fasilitas!)
                  //         Container(
                  //           padding: EdgeInsets.symmetric(
                  //               horizontal: 10, vertical: 6),
                  //           decoration: BoxDecoration(
                  //             color: const Color(0xFFE9EEF9),
                  //             borderRadius: BorderRadius.circular(20),
                  //           ),
                  //           child: Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               const Icon(Icons.check_circle_outline,
                  //                   size: 14, color: Color(0xFF1C3B98)),
                  //               const SizedBox(width: 6),
                  //               Text(
                  //                 tag,
                  //                 style: const TextStyle(
                  //                   fontSize: 12,
                  //                   color: Color(0xFF1F1F1F),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //     ],
                  //   ),
                  // ],
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: fungsitap,
                      icon: Icon(Icons.visibility_rounded, size: s(18)),
                      label: Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontSize: s(13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorprimary,
                        foregroundColor: colorwhite,
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
      ),
    );
  }
}
