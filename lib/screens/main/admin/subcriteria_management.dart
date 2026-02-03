import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custom/custom_dropdown_searhc_v3.dart';
import '../../../providers/kriteria_provider.dart';

class SubcriteriaItem {
  final int? id_subkriteria;
  final int? id_auth;
  final int? id_kriteria;
  final TextEditingController kategori;
  final TextEditingController bobot;

  SubcriteriaItem({
    this.id_subkriteria,
    this.id_auth,
    this.id_kriteria,
    String? kategoriawal,
    String bobotawal = "0",
  })  : bobot = TextEditingController(text: bobotawal),
        kategori = TextEditingController(text: kategoriawal);

  void dispose() {
    bobot.dispose();
    kategori.dispose();
  }
}

class SubcriteriaManagement extends StatefulWidget {
  static const arah = "/subcriteria-admin";
  SubcriteriaManagement({super.key});

  @override
  State<SubcriteriaManagement> createState() => _SubcriteriaManagementState();
}

class _SubcriteriaManagementState extends State<SubcriteriaManagement> {
  final TextEditingController namacontroller = TextEditingController();
  final TextEditingController bobotcontroller = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  bool _noLowerBound = false;
  bool _noUpperBound = false;

  bool keadaan = true;
  int index = 0;
  int? editinde; // Variabel penanda: null = Tambah, angka = Edit index tersebut

  late Future<void> _penghubung;
  List<SubcriteriaItem> _isinya = [];
  bool _isInitialized = false; // Flag untuk memastikan hanya dipanggil sekali

  // Flag perubahan & loading untuk tombol simpan
  bool _hasChanges = false;
  bool _isSaving = false;

  static Color _warnaLatar = Color(0xFFF5F7FB);
  static Color _warnaKartu = Colors.white;
  static Color _warnaUtama = Color(0xFF1E3A8A);

  bool _isRangeKriteria(String? namaKriteria) {
    if (namaKriteria == null) return false;
    final lower = namaKriteria.toLowerCase();
    return lower.contains('biaya') ||
        lower.contains('harga') ||
        lower.contains('fasilitas') ||
        lower.contains('luas') ||
        lower.contains('jarak');
  }

  int? _tryParseIntFlexible(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  String _formatIntId(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining % 3 == 0 && i != s.length - 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  String _buildRentangInfoText({
    required int? minVal,
    required int? maxVal,
    required bool noLowerBound,
    required bool noUpperBound,
  }) {
    if (minVal == null && maxVal == null) return 'Rentang: -';

    if (minVal != null && maxVal != null) {
      return 'Rentang: ≥ ${_formatIntId(minVal)} & ≤ ${_formatIntId(maxVal)}';
    }

    if (noLowerBound && maxVal != null) {
      return 'Rentang: ≤ ${_formatIntId(maxVal)}';
    }

    if (noUpperBound && minVal != null) {
      return 'Rentang: ≥ ${_formatIntId(minVal)}';
    }

    // Jika hanya salah satu terisi tapi checkbox belum dipilih
    if (minVal != null) {
      return 'Rentang: ≥ ${_formatIntId(minVal)} (centang "tanpa batas atas")';
    }
    return 'Rentang: ≤ ${_formatIntId(maxVal!)} (centang "tanpa batas bawah")';
  }

  _KategoriDisplay _kategoriDisplay(String rawKategori) {
    final raw = rawKategori.trim();

    final matchRange = RegExp(r'^>=\s*(\d+)\s*-\s*(\d+)\s*$').firstMatch(raw);
    if (matchRange != null) {
      final minVal = _tryParseIntFlexible(matchRange.group(1) ?? '');
      final maxVal = _tryParseIntFlexible(matchRange.group(2) ?? '');
      if (minVal != null && maxVal != null) {
        final title = '${_formatIntId(minVal)} - ${_formatIntId(maxVal)}';
        final subtitle =
            'Rentang: ≥ ${_formatIntId(minVal)} & ≤ ${_formatIntId(maxVal)}';
        return _KategoriDisplay(title: title, subtitle: subtitle);
      }
    }

    final matchLe = RegExp(r'^<=\s*(\d+)\s*$').firstMatch(raw);
    if (matchLe != null) {
      final maxVal = _tryParseIntFlexible(matchLe.group(1) ?? '');
      if (maxVal != null) {
        return _KategoriDisplay(
          title: _formatIntId(maxVal),
          subtitle: 'Rentang: ≤ ${_formatIntId(maxVal)}',
        );
      }
    }

    final matchGe = RegExp(r'^>=\s*(\d+)\s*$').firstMatch(raw);
    if (matchGe != null) {
      final minVal = _tryParseIntFlexible(matchGe.group(1) ?? '');
      if (minVal != null) {
        return _KategoriDisplay(
          title: _formatIntId(minVal),
          subtitle: 'Rentang: ≥ ${_formatIntId(minVal)}',
        );
      }
    }

    return _KategoriDisplay(title: rawKategori, subtitle: null);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (!_isInitialized) {
      _isInitialized = true;
      keadaan = false;
      _penghubung = Provider.of<KriteriaProvider>(context, listen: false)
          .readdatasubkriteria();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hanya panggil sekali saat pertama kali masuk halaman
    if (!_isInitialized) {
      _isInitialized = true;
      keadaan = false;
      _penghubung = Provider.of<KriteriaProvider>(context, listen: false)
          .readdatasubkriteria();
    }
  }

  @override
  void dispose() {
    namacontroller.dispose();
    bobotcontroller.dispose();
    _minController.dispose();
    _maxController.dispose();
    for (final item in _isinya) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final penghubung = Provider.of<KriteriaProvider>(context, listen: false);

    return FutureBuilder(
      future: _penghubung,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error di jaringan")),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          // --- LOGIKA SINKRONISASI DATA ( DATABASE KE LIST UI ) ---
          if (!keadaan) {
            _isinya.clear();
            // Jika belum ada kriteria terpilih, pilih otomatis kriteria pertama.
            // Gunakan post-frame callback agar tidak memanggil notifyListeners
            // (melalui pilihkriteria) langsung saat build FutureBuilder.
            if ((penghubung.nama == null || penghubung.nama!.isEmpty) &&
                penghubung.kategoriall.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                // Cek lagi untuk menghindari pemanggilan ganda jika state sudah berubah.
                if ((penghubung.nama == null || penghubung.nama!.isEmpty) &&
                    penghubung.kategoriall.isNotEmpty) {
                  penghubung.pilihkriteria(penghubung.kategoriall.first);
                }
              });
            }

            final kriteriaTerpilih = penghubung.mydata.firstWhereOrNull(
                (element) => element.kategori == penghubung.nama);

            if (kriteriaTerpilih != null) {
              final dataDbTerfilter = penghubung.inidata.where((element) =>
                  element.id_kriteria == kriteriaTerpilih.id_kriteria);

              for (var datanya in dataDbTerfilter) {
                _isinya.add(
                  SubcriteriaItem(
                    id_auth: datanya.id_auth,
                    id_kriteria: datanya.id_kriteria,
                    id_subkriteria: datanya.id_subkriteria,
                    kategoriawal: datanya.kategori,
                    bobotawal: datanya.bobot.toString(),
                  ),
                );
              }
            }
            keadaan =
                true; // Dikunci agar saat klik Simpan/Tambah, list lokal tidak dihapus
            // Setelah sinkron dari database, anggap tidak ada perubahan lokal
            _hasChanges = false;
          }

          return Scaffold(
            backgroundColor: _warnaLatar,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: lebarLayar * 0.05,
                  vertical: tinggiLayar * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          penghubung.inidata.isEmpty
                              ? "Tambah Subkriteria SAW"
                              : "Update Subkriteria SAW",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(6),
                            onTap: () {
                              // MODE TAMBAH
                              editinde = null;
                              namacontroller.clear();
                              bobotcontroller.clear();
                              _minController.clear();
                              _maxController.clear();
                              _noLowerBound = false;
                              _noUpperBound = false;

                              showDialog(
                                  context: context,
                                  builder: (_) => StatefulBuilder(
                                        builder: (context, setStateDialog) =>
                                            AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                          backgroundColor: Colors.white,
                                          titlePadding:
                                              const EdgeInsets.fromLTRB(
                                                  24, 20, 24, 0),
                                          contentPadding:
                                              const EdgeInsets.fromLTRB(
                                                  24, 12, 24, 24),
                                          title: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color:
                                                      const Color(0xFFE0EBFF),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.tune_rounded,
                                                  color: Color(0xFF1E3A8A),
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      "Tambah Subkriteria",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      penghubung.nama ?? '-',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey[600],
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                                maxWidth: 420),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: namacontroller,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          "Nama Subkriteria",
                                                      hintText:
                                                          "Contoh: Sangat Dekat / 1 - 3 km",
                                                      prefixIcon: const Icon(
                                                        Icons.label_outline,
                                                        size: 20,
                                                      ),
                                                      filled: true,
                                                      fillColor: const Color(
                                                          0xFFF5F7FB),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  TextField(
                                                    controller: bobotcontroller,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          "Bobot (0 - 1)",
                                                      hintText: "Contoh: 0.25",
                                                      prefixIcon: const Icon(
                                                        Icons.scale_outlined,
                                                        size: 20,
                                                      ),
                                                      filled: true,
                                                      fillColor: const Color(
                                                          0xFFF5F7FB),
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                    ),
                                                  ),
                                                  if (_isRangeKriteria(
                                                      penghubung.nama)) ...[
                                                    const SizedBox(height: 16),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "Range nilai (opsional)",
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    // Field Min & Max dibuat agak renggang supaya tidak terlalu sempit
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextField(
                                                            controller:
                                                                _minController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            enabled:
                                                                !_noLowerBound,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText: "Min",
                                                              hintText:
                                                                  "misal 700000",
                                                              filled: true,
                                                              fillColor:
                                                                  const Color(
                                                                      0xFFF5F7FB),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 16),
                                                        Expanded(
                                                          child: TextField(
                                                            controller:
                                                                _maxController,
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            enabled:
                                                                !_noUpperBound,
                                                            decoration:
                                                                InputDecoration(
                                                              labelText: "Max",
                                                              hintText:
                                                                  "misal 900000",
                                                              filled: true,
                                                              fillColor:
                                                                  const Color(
                                                                      0xFFF5F7FB),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                borderSide:
                                                                    BorderSide
                                                                        .none,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Jika diisi, sistem otomatis membentuk label >= Min-Max.",
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                              height: 6),
                                                          AnimatedBuilder(
                                                            animation:
                                                                Listenable
                                                                    .merge([
                                                              _minController,
                                                              _maxController,
                                                            ]),
                                                            builder:
                                                                (context, _) {
                                                              final minVal =
                                                                  _tryParseIntFlexible(
                                                                      _minController
                                                                          .text
                                                                          .trim());
                                                              final maxVal =
                                                                  _tryParseIntFlexible(
                                                                      _maxController
                                                                          .text
                                                                          .trim());

                                                              final text =
                                                                  _buildRentangInfoText(
                                                                minVal: minVal,
                                                                maxVal: maxVal,
                                                                noLowerBound:
                                                                    _noLowerBound,
                                                                noUpperBound:
                                                                    _noUpperBound,
                                                              );

                                                              return Text(
                                                                text,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                          .grey[
                                                                      800],
                                                                ),
                                                              );
                                                            },
                                                          ),

                                                          const SizedBox(
                                                              height: 8),

                                                          // Checkbox hanya bisa dipakai jika salah satu sisi kosong
                                                          AnimatedBuilder(
                                                            animation:
                                                                Listenable
                                                                    .merge([
                                                              _minController,
                                                              _maxController,
                                                            ]),
                                                            builder:
                                                                (context, _) {
                                                              final minFilled =
                                                                  _minController
                                                                      .text
                                                                      .trim()
                                                                      .isNotEmpty;
                                                              final maxFilled =
                                                                  _maxController
                                                                      .text
                                                                      .trim()
                                                                      .isNotEmpty;

                                                              final bothFilled =
                                                                  minFilled &&
                                                                      maxFilled;

                                                              final canNoLowerBound =
                                                                  !bothFilled &&
                                                                      maxFilled;
                                                              final canNoUpperBound =
                                                                  !bothFilled &&
                                                                      minFilled;

                                                              // Auto-reset state yang sudah tidak valid
                                                              if (!canNoLowerBound &&
                                                                  _noLowerBound) {
                                                                WidgetsBinding
                                                                    .instance
                                                                    .addPostFrameCallback(
                                                                  (_) {
                                                                    setStateDialog(
                                                                        () {
                                                                      _noLowerBound =
                                                                          false;
                                                                    });
                                                                  },
                                                                );
                                                              }
                                                              if (!canNoUpperBound &&
                                                                  _noUpperBound) {
                                                                WidgetsBinding
                                                                    .instance
                                                                    .addPostFrameCallback(
                                                                  (_) {
                                                                    setStateDialog(
                                                                        () {
                                                                      _noUpperBound =
                                                                          false;
                                                                    });
                                                                  },
                                                                );
                                                              }

                                                              return Column(
                                                                children: [
                                                                  CheckboxListTile(
                                                                    value: canNoLowerBound
                                                                        ? _noLowerBound
                                                                        : false,
                                                                    onChanged: canNoLowerBound
                                                                        ? (val) {
                                                                            setStateDialog(() {
                                                                              _noLowerBound = val ?? false;
                                                                              if (_noLowerBound) {
                                                                                _noUpperBound = false;
                                                                                _minController.clear();
                                                                              }
                                                                            });
                                                                          }
                                                                        : null,
                                                                    dense: true,
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    title:
                                                                        const Text(
                                                                      'Tanpa batas bawah (≤ Max)',
                                                                    ),
                                                                  ),
                                                                  CheckboxListTile(
                                                                    value: canNoUpperBound
                                                                        ? _noUpperBound
                                                                        : false,
                                                                    onChanged: canNoUpperBound
                                                                        ? (val) {
                                                                            setStateDialog(() {
                                                                              _noUpperBound = val ?? false;
                                                                              if (_noUpperBound) {
                                                                                _noLowerBound = false;
                                                                                _maxController.clear();
                                                                              }
                                                                            });
                                                                          }
                                                                        : null,
                                                                    dense: true,
                                                                    contentPadding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    title:
                                                                        const Text(
                                                                      'Tanpa batas atas (≥ Min)',
                                                                    ),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),

                                                    const SizedBox(height: 4),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        'Centang "tanpa batas" jika ingin hanya menggunakan salah satu sisi (misal ≤ 9 atau ≥ 20).',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                          actionsPadding:
                                              const EdgeInsets.fromLTRB(
                                                  16, 0, 16, 12),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text("Batal"),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: _warnaUtama,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 18,
                                                        vertical: 10),
                                              ),
                                              onPressed: () {
                                                final namaBaru =
                                                    namacontroller.text.trim();
                                                final bobotRaw =
                                                    bobotcontroller.text.trim();
                                                final bobotParsed =
                                                    double.tryParse(bobotRaw
                                                        .replaceAll(',', '.'));

                                                if (namaBaru.isEmpty ||
                                                    bobotParsed == null) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Nama dan bobot wajib diisi dengan benar.'),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                String kategoriLabel = namaBaru;
                                                if (_isRangeKriteria(
                                                    penghubung.nama)) {
                                                  final minText = _minController
                                                      .text
                                                      .trim();
                                                  final maxText = _maxController
                                                      .text
                                                      .trim();

                                                  final bothFilled =
                                                      minText.isNotEmpty &&
                                                          maxText.isNotEmpty;
                                                  final allowSingleSide =
                                                      !bothFilled;

                                                  if (allowSingleSide &&
                                                      _noLowerBound &&
                                                      _noUpperBound) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Pilih salah satu: tanpa batas bawah ATAU tanpa batas atas.'),
                                                      ),
                                                    );
                                                    return;
                                                  }

                                                  if (allowSingleSide &&
                                                      _noLowerBound) {
                                                    if (maxText.isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Isi nilai Max untuk menggunakan tanpa batas bawah.'),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    final maxVal =
                                                        _tryParseIntFlexible(
                                                            maxText);
                                                    if (maxVal == null) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Max harus berupa angka bulat.'),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    kategoriLabel =
                                                        "<= $maxVal";
                                                  } else if (allowSingleSide &&
                                                      _noUpperBound) {
                                                    if (minText.isEmpty) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Isi nilai Min untuk menggunakan tanpa batas atas.'),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    final minVal =
                                                        _tryParseIntFlexible(
                                                            minText);
                                                    if (minVal == null) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Min harus berupa angka bulat.'),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    kategoriLabel =
                                                        ">= $minVal";
                                                  } else if (bothFilled) {
                                                    final minVal =
                                                        _tryParseIntFlexible(
                                                            minText);
                                                    final maxVal =
                                                        _tryParseIntFlexible(
                                                            maxText);
                                                    if (minVal == null ||
                                                        maxVal == null) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Min dan Max harus berupa angka bulat.'),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    if (minVal > maxVal) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Min tidak boleh lebih besar dari Max.'),
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    kategoriLabel =
                                                        ">= $minVal-$maxVal";
                                                  }
                                                }

                                                if (bobotParsed <= 0) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Bobot subkriteria tidak boleh 0 atau negatif.'),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                final sudahAdaBobotSama =
                                                    _isinya.any((item) =>
                                                        double.tryParse(item
                                                            .bobot.text
                                                            .trim()
                                                            .replaceAll(
                                                                ',', '.')) ==
                                                        bobotParsed);

                                                if (sudahAdaBobotSama) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Bobot subkriteria tidak boleh ada yang sama.'),
                                                    ),
                                                  );
                                                  return;
                                                }

                                                setState(() {
                                                  final kSekarang = penghubung
                                                      .mydata
                                                      .firstWhereOrNull(
                                                          (element) =>
                                                              element
                                                                  .kategori ==
                                                              penghubung.nama);

                                                  _isinya.add(SubcriteriaItem(
                                                    id_auth: penghubung.id_auth,
                                                    id_kriteria:
                                                        kSekarang?.id_kriteria,
                                                    kategoriawal: kategoriLabel,
                                                    bobotawal: bobotRaw,
                                                  ));
                                                  namacontroller.clear();
                                                  bobotcontroller.clear();
                                                  _minController.clear();
                                                  _maxController.clear();
                                                  _hasChanges = true;
                                                  Navigator.pop(context);
                                                });
                                              },
                                              child: const Text(
                                                "Simpan",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ));
                            },
                            child: Container(
                              width: lebarLayar * 0.09,
                              height: lebarLayar * 0.09,
                              decoration: BoxDecoration(
                                  color: _warnaKartu,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 3,
                                        offset: Offset(0, 2))
                                  ]),
                              child: Icon(Icons.add, color: Colors.black87),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: tinggiLayar * 0.03),
                    // Ringkasan
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 3,
                                      offset: Offset(0, 2))
                                ]),
                            child: Row(
                              children: [
                                CircleAvatar(
                                    backgroundColor: Color(0xFFDDE6FF),
                                    child: Icon(Icons.category_outlined,
                                        color: Color(0xFF1E3A8A))),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Terpilih",
                                          style: TextStyle(fontSize: 15)),
                                      Text(
                                        penghubung.nama!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: lebarLayar * 0.04),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 3,
                                      offset: Offset(0, 2))
                                ]),
                            child: Row(
                              children: [
                                CircleAvatar(
                                    backgroundColor: Color(0xFFDDE6FF),
                                    child: Icon(Icons.list_alt_outlined,
                                        color: Color(0xFF1E3A8A))),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Subkriteria",
                                        style: TextStyle(fontSize: 15)),
                                    Text("${_isinya.length}",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tinggiLayar * 0.03),
                    // Card Dropdown
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(lebarLayar * 0.04),
                      decoration: BoxDecoration(
                          color: _warnaKartu,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 3,
                                offset: Offset(0, 2))
                          ]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pilih Kriteria",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          SizedBox(height: tinggiLayar * 0.012),
                          CustomDropdownSearchv3(
                            manalistnya: penghubung.kategoriall,
                            label: "Pilih",
                            pilihan: penghubung.nama!,
                            fungsi: (value) {
                              penghubung.pilihkriteria(value);
                              setState(() {
                                keadaan =
                                    false; // Buka kunci keadaan agar load data kriteria baru
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: tinggiLayar * 0.02),
                    // Tabel Daftar Subkriteria
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: _warnaKartu,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 3,
                                  offset: Offset(0, 2))
                            ]),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: Text("Daftar Subkriteria",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600))),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Cari...",
                                      isDense: true,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            Expanded(
                              child: _isinya.isEmpty
                                  ? Center(child: Text("Belum ada subkriteria"))
                                  : ListView.separated(
                                      itemCount: _isinya.length,
                                      separatorBuilder: (context, index) =>
                                          SizedBox(height: 10),
                                      itemBuilder: (context, idx) {
                                        final kategoriRaw =
                                            _isinya[idx].kategori.text;
                                        final kategoriDisplay =
                                            _kategoriDisplay(kategoriRaw);

                                        return Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFE9F0FF),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    kategoriDisplay.title,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (kategoriDisplay
                                                          .subtitle !=
                                                      null)
                                                    Text(
                                                      kategoriDisplay.subtitle!,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[700],
                                                      ),
                                                    ),
                                                  Text(
                                                      "Bobot : ${_isinya[idx].bobot.text}"),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                      icon: Icon(Icons.edit,
                                                          color: Colors.green),
                                                      onPressed: () {
                                                        // --- LOGIKA EDIT BERDASARKAN INDEX ---
                                                        editinde = idx;
                                                        namacontroller.text =
                                                            _isinya[idx]
                                                                .kategori
                                                                .text;
                                                        bobotcontroller.text =
                                                            _isinya[idx]
                                                                .bobot
                                                                .text;
                                                        _minController.clear();
                                                        _maxController.clear();
                                                        _noLowerBound = false;
                                                        _noUpperBound = false;

                                                        // Coba prefill min/max & checkbox jika kategori berupa range angka
                                                        final kat = _isinya[idx]
                                                            .kategori
                                                            .text
                                                            .trim();
                                                        final matches =
                                                            RegExp(r'(\d+)')
                                                                .allMatches(kat)
                                                                .toList();

                                                        if (kat.startsWith(
                                                            '<= ')) {
                                                          // Tanpa batas bawah (hanya Max)
                                                          _noLowerBound = true;
                                                          if (matches
                                                              .isNotEmpty) {
                                                            _maxController
                                                                .text = matches
                                                                    .last
                                                                    .group(1) ??
                                                                '';
                                                          }
                                                        } else if (kat
                                                            .startsWith('>=')) {
                                                          if (kat
                                                              .contains('-')) {
                                                            // Range lengkap >= Min-Max
                                                            if (matches
                                                                .isNotEmpty) {
                                                              _minController
                                                                  .text = matches
                                                                      .first
                                                                      .group(
                                                                          1) ??
                                                                  '';
                                                            }
                                                            if (matches
                                                                    .length >=
                                                                2) {
                                                              _maxController
                                                                  .text = matches[
                                                                          1]
                                                                      .group(
                                                                          1) ??
                                                                  '';
                                                            }
                                                          } else {
                                                            // Tanpa batas atas (hanya Min)
                                                            _noUpperBound =
                                                                true;
                                                            if (matches
                                                                .isNotEmpty) {
                                                              _minController
                                                                  .text = matches
                                                                      .first
                                                                      .group(
                                                                          1) ??
                                                                  '';
                                                            }
                                                          }
                                                        } else {
                                                          // Fallback: isi Min/Max dari dua angka pertama jika ada
                                                          if (matches
                                                              .isNotEmpty) {
                                                            _minController
                                                                .text = matches
                                                                    .first
                                                                    .group(1) ??
                                                                '';
                                                          }
                                                          if (matches.length >=
                                                              2) {
                                                            _maxController
                                                                .text = matches[
                                                                        1]
                                                                    .group(1) ??
                                                                '';
                                                          }
                                                        }
                                                        // Tampilkan dialog yang sama
                                                        showDialog(
                                                            context: context,
                                                            builder: (_) =>
                                                                StatefulBuilder(
                                                                  builder: (context,
                                                                          setStateDialog) =>
                                                                      AlertDialog(
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              18),
                                                                    ),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .white,
                                                                    titlePadding:
                                                                        const EdgeInsets
                                                                            .fromLTRB(
                                                                            24,
                                                                            20,
                                                                            24,
                                                                            0),
                                                                    contentPadding:
                                                                        const EdgeInsets
                                                                            .fromLTRB(
                                                                            24,
                                                                            12,
                                                                            24,
                                                                            24),
                                                                    title: Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          width:
                                                                              40,
                                                                          height:
                                                                              40,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                const Color(0xFFE0EBFF),
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                          ),
                                                                          child:
                                                                              const Icon(
                                                                            Icons.edit_note,
                                                                            color:
                                                                                Color(0xFF1E3A8A),
                                                                            size:
                                                                                22,
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            width:
                                                                                12),
                                                                        Expanded(
                                                                          child:
                                                                              Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              const Text(
                                                                                "Update Subkriteria",
                                                                                style: TextStyle(
                                                                                  fontWeight: FontWeight.w700,
                                                                                  fontSize: 16,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 4),
                                                                              Text(
                                                                                penghubung.nama ?? '-',
                                                                                style: TextStyle(
                                                                                  fontSize: 13,
                                                                                  color: Colors.grey[600],
                                                                                ),
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    content:
                                                                        ConstrainedBox(
                                                                      constraints:
                                                                          const BoxConstraints(
                                                                              maxWidth: 420),
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          children: [
                                                                            TextField(
                                                                              controller: namacontroller,
                                                                              decoration: InputDecoration(
                                                                                labelText: "Nama Subkriteria",
                                                                                prefixIcon: const Icon(
                                                                                  Icons.label_outline,
                                                                                  size: 20,
                                                                                ),
                                                                                filled: true,
                                                                                fillColor: const Color(0xFFF5F7FB),
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  borderSide: BorderSide.none,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            const SizedBox(height: 12),
                                                                            TextField(
                                                                              controller: bobotcontroller,
                                                                              keyboardType: TextInputType.number,
                                                                              decoration: InputDecoration(
                                                                                labelText: "Bobot (0 - 1)",
                                                                                prefixIcon: const Icon(
                                                                                  Icons.scale_outlined,
                                                                                  size: 20,
                                                                                ),
                                                                                filled: true,
                                                                                fillColor: const Color(0xFFF5F7FB),
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  borderSide: BorderSide.none,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            if (_isRangeKriteria(penghubung.nama)) ...[
                                                                              const SizedBox(height: 16),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  "Range nilai (opsional)",
                                                                                  style: TextStyle(
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    color: Colors.grey[700],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 6),
                                                                              // Field Min & Max dibuat agak renggang supaya tidak terlalu sempit
                                                                              Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: TextField(
                                                                                      controller: _minController,
                                                                                      keyboardType: TextInputType.number,
                                                                                      enabled: !_noLowerBound,
                                                                                      decoration: InputDecoration(
                                                                                        labelText: "Min",
                                                                                        hintText: "misal 700000",
                                                                                        filled: true,
                                                                                        fillColor: const Color(0xFFF5F7FB),
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(12),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 16),
                                                                                  Expanded(
                                                                                    child: TextField(
                                                                                      controller: _maxController,
                                                                                      keyboardType: TextInputType.number,
                                                                                      enabled: !_noUpperBound,
                                                                                      decoration: InputDecoration(
                                                                                        labelText: "Max",
                                                                                        hintText: "misal 900000",
                                                                                        filled: true,
                                                                                        fillColor: const Color(0xFFF5F7FB),
                                                                                        border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(12),
                                                                                          borderSide: BorderSide.none,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 4),
                                                                              Align(
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Text(
                                                                                  "Jika diisi, sistem otomatis membentuk label >= Min-Max.",
                                                                                  style: TextStyle(
                                                                                    fontSize: 11,
                                                                                    color: Colors.grey[600],
                                                                                  ),
                                                                                ),
                                                                              ),

                                                                              const SizedBox(height: 6),
                                                                              AnimatedBuilder(
                                                                                animation: Listenable.merge([
                                                                                  _minController,
                                                                                  _maxController,
                                                                                ]),
                                                                                builder: (context, _) {
                                                                                  final minVal = _tryParseIntFlexible(_minController.text.trim());
                                                                                  final maxVal = _tryParseIntFlexible(_maxController.text.trim());

                                                                                  final text = _buildRentangInfoText(
                                                                                    minVal: minVal,
                                                                                    maxVal: maxVal,
                                                                                    noLowerBound: _noLowerBound,
                                                                                    noUpperBound: _noUpperBound,
                                                                                  );

                                                                                  return Text(
                                                                                    text,
                                                                                    style: TextStyle(
                                                                                      fontSize: 12,
                                                                                      fontWeight: FontWeight.w700,
                                                                                      color: Colors.grey[800],
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                              const SizedBox(height: 8),
                                                                              // Checkbox hanya bisa dipakai jika salah satu sisi kosong
                                                                              AnimatedBuilder(
                                                                                animation: Listenable.merge([
                                                                                  _minController,
                                                                                  _maxController,
                                                                                ]),
                                                                                builder: (context, _) {
                                                                                  final minFilled = _minController.text.trim().isNotEmpty;
                                                                                  final maxFilled = _maxController.text.trim().isNotEmpty;

                                                                                  final bothFilled = minFilled && maxFilled;
                                                                                  final canNoLowerBound = !bothFilled && maxFilled;
                                                                                  final canNoUpperBound = !bothFilled && minFilled;

                                                                                  if (!canNoLowerBound && _noLowerBound) {
                                                                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                                      setStateDialog(() {
                                                                                        _noLowerBound = false;
                                                                                      });
                                                                                    });
                                                                                  }
                                                                                  if (!canNoUpperBound && _noUpperBound) {
                                                                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                                      setStateDialog(() {
                                                                                        _noUpperBound = false;
                                                                                      });
                                                                                    });
                                                                                  }

                                                                                  return Column(
                                                                                    children: [
                                                                                      CheckboxListTile(
                                                                                        value: canNoLowerBound ? _noLowerBound : false,
                                                                                        onChanged: canNoLowerBound
                                                                                            ? (val) {
                                                                                                setStateDialog(() {
                                                                                                  _noLowerBound = val ?? false;
                                                                                                  if (_noLowerBound) {
                                                                                                    _noUpperBound = false;
                                                                                                    _minController.clear();
                                                                                                  }
                                                                                                });
                                                                                              }
                                                                                            : null,
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: const Text(
                                                                                          'Tanpa batas bawah (≤)',
                                                                                        ),
                                                                                      ),
                                                                                      CheckboxListTile(
                                                                                        value: canNoUpperBound ? _noUpperBound : false,
                                                                                        onChanged: canNoUpperBound
                                                                                            ? (val) {
                                                                                                setStateDialog(() {
                                                                                                  _noUpperBound = val ?? false;
                                                                                                  if (_noUpperBound) {
                                                                                                    _noLowerBound = false;
                                                                                                    _maxController.clear();
                                                                                                  }
                                                                                                });
                                                                                              }
                                                                                            : null,
                                                                                        dense: true,
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: const Text(
                                                                                          'Tanpa batas atas (≥)',
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ],
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    actionsPadding:
                                                                        const EdgeInsets
                                                                            .fromLTRB(
                                                                            16,
                                                                            0,
                                                                            16,
                                                                            12),
                                                                    actions: [
                                                                      TextButton(
                                                                        onPressed:
                                                                            () =>
                                                                                Navigator.pop(context),
                                                                        child:
                                                                            const Text(
                                                                          "Batal",
                                                                        ),
                                                                      ),
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              _warnaUtama,
                                                                          elevation:
                                                                              0,
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(24),
                                                                          ),
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 18,
                                                                              vertical: 10),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          final namaBaru = namacontroller
                                                                              .text
                                                                              .trim();
                                                                          final bobotRaw = bobotcontroller
                                                                              .text
                                                                              .trim();
                                                                          final bobotParsed = double.tryParse(bobotRaw.replaceAll(
                                                                              ',',
                                                                              '.'));

                                                                          if (namaBaru.isEmpty ||
                                                                              bobotParsed == null) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(
                                                                                content: Text('Nama dan bobot wajib diisi dengan benar.'),
                                                                              ),
                                                                            );
                                                                            return;
                                                                          }

                                                                          if (bobotParsed <=
                                                                              0) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              const SnackBar(
                                                                                content: Text('Bobot subkriteria tidak boleh 0 atau negatif.'),
                                                                              ),
                                                                            );
                                                                            return;
                                                                          }

                                                                          final sudahAdaBobotSama = _isinya
                                                                              .asMap()
                                                                              .entries
                                                                              .any((entry) {
                                                                            if (entry.key ==
                                                                                editinde) {
                                                                              return false;
                                                                            }
                                                                            final v =
                                                                                double.tryParse(entry.value.bobot.text.trim().replaceAll(',', '.'));
                                                                            return v ==
                                                                                bobotParsed;
                                                                          });

                                                                          if (sudahAdaBobotSama) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              const SnackBar(
                                                                                content: Text('Bobot subkriteria tidak boleh ada yang sama.'),
                                                                              ),
                                                                            );
                                                                            return;
                                                                          }

                                                                          String
                                                                              kategoriLabel =
                                                                              namaBaru;
                                                                          if (_isRangeKriteria(
                                                                              penghubung.nama)) {
                                                                            final minText =
                                                                                _minController.text.trim();
                                                                            final maxText =
                                                                                _maxController.text.trim();

                                                                            final bothFilled =
                                                                                minText.isNotEmpty && maxText.isNotEmpty;
                                                                            final allowSingleSide =
                                                                                !bothFilled;

                                                                            if (allowSingleSide &&
                                                                                _noLowerBound &&
                                                                                _noUpperBound) {
                                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                                const SnackBar(
                                                                                  content: Text('Pilih salah satu: tanpa batas bawah ATAU tanpa batas atas.'),
                                                                                ),
                                                                              );
                                                                              return;
                                                                            }

                                                                            if (allowSingleSide &&
                                                                                _noLowerBound) {
                                                                              if (maxText.isEmpty) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Text('Isi nilai Max untuk menggunakan tanpa batas bawah.'),
                                                                                  ),
                                                                                );
                                                                                return;
                                                                              }
                                                                              final maxVal = _tryParseIntFlexible(maxText);
                                                                              if (maxVal == null) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Text('Max harus berupa angka bulat.'),
                                                                                  ),
                                                                                );
                                                                                return;
                                                                              }
                                                                              kategoriLabel = "<= $maxVal";
                                                                            } else if (allowSingleSide &&
                                                                                _noUpperBound) {
                                                                              if (minText.isEmpty) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Text('Isi nilai Min untuk menggunakan tanpa batas atas.'),
                                                                                  ),
                                                                                );
                                                                                return;
                                                                              }
                                                                              final minVal = _tryParseIntFlexible(minText);
                                                                              if (minVal == null) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Text('Min harus berupa angka bulat.'),
                                                                                  ),
                                                                                );
                                                                                return;
                                                                              }
                                                                              kategoriLabel = ">= $minVal";
                                                                            } else if (bothFilled) {
                                                                              final minVal = _tryParseIntFlexible(minText);
                                                                              final maxVal = _tryParseIntFlexible(maxText);
                                                                              if (minVal == null || maxVal == null) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Text('Min dan Max harus berupa angka bulat.'),
                                                                                  ),
                                                                                );
                                                                                return;
                                                                              }
                                                                              if (minVal > maxVal) {
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Text('Min tidak boleh lebih besar dari Max.'),
                                                                                  ),
                                                                                );
                                                                                return;
                                                                              }
                                                                              kategoriLabel = ">= $minVal-$maxVal";
                                                                            }
                                                                          }

                                                                          setState(
                                                                              () {
                                                                            _isinya[editinde!].kategori.text =
                                                                                kategoriLabel;
                                                                            _isinya[editinde!].bobot.text =
                                                                                bobotRaw;
                                                                            _hasChanges =
                                                                                true;
                                                                            _minController.clear();
                                                                            _maxController.clear();
                                                                            Navigator.pop(context);
                                                                          });
                                                                        },
                                                                        child:
                                                                            const Text(
                                                                          "Simpan Perubahan",
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ));
                                                      }),
                                                  IconButton(
                                                      icon: Icon(Icons.delete,
                                                          color: Colors.red),
                                                      onPressed: () async {
                                                        // --- LOGIKA HAPUS YANG BENAR ---
                                                        final itemDipilih =
                                                            _isinya[idx];
                                                        if (itemDipilih
                                                                .id_subkriteria !=
                                                            null) {
                                                          await penghubung
                                                              .deletedatasubkriteria(
                                                                  itemDipilih
                                                                      .id_subkriteria!);
                                                        }
                                                        setState(() {
                                                          _isinya.removeAt(idx);
                                                          _hasChanges = true;
                                                        });
                                                      }),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      },
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
            bottomNavigationBar: Padding(
              padding: EdgeInsets.all(lebarLayar * 0.05),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: Size(double.infinity, tinggiLayar * 0.065),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                onPressed: (!_hasChanges || _isSaving)
                    ? null
                    : () async {
                        setState(() {
                          _isSaving = true;
                        });

                        try {
                          // Jika data di database (inidata) kosong untuk kriteria ini, panggil savemassal
                          final kSekarang = penghubung.mydata.firstWhereOrNull(
                              (e) => e.kategori == penghubung.nama);
                          final dataDb = penghubung.inidata.where(
                              (e) => e.id_kriteria == kSekarang?.id_kriteria);

                          if (dataDb.isEmpty) {
                            await penghubung.savemassalsubkriteria(_isinya);
                          } else {
                            await penghubung.updatedmassalsubkriteria(_isinya);
                          }

                          // Refresh UI setelah simpan database
                          if (!mounted) return;
                          setState(() {
                            keadaan = false;
                            _isSaving = false;
                          });
                        } catch (e) {
                          if (!mounted) return;
                          setState(() {
                            _isSaving = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Gagal menyimpan subkriteria: ${e.toString()}'),
                            ),
                          );
                        }
                      },
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Menyimpan...',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Text(
                        // Cek apakah ada data di database untuk kriteria terpilih ini
                        penghubung.inidata.any((element) {
                          final kTerpilih = penghubung.mydata.firstWhereOrNull(
                              (e) => e.kategori == penghubung.nama);
                          return element.id_kriteria == kTerpilih?.id_kriteria;
                        })
                            ? "Simpan Perubahan Data"
                            : "Simpan Data",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          );
        }
        return Scaffold(body: Center(child: Text("Error")));
      },
    );
  }
}

class _KategoriDisplay {
  final String title;
  final String? subtitle;

  const _KategoriDisplay({required this.title, required this.subtitle});
}
