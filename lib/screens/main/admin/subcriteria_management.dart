import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../custom/custom_dropdown_searhc_v3.dart';
import '../../../providers/kriteria_provider.dart';
import '../../../providers/kost_provider.dart';

class SubcriteriaItem {
  final int? id_subkriteria;
  final int? id_kriteria;
  final TextEditingController kategori;
  final TextEditingController bobot;
  num? nilaiMin;
  num? nilaiMax;
  String? minOperator;
  String? maxOperator;

  SubcriteriaItem({
    this.id_subkriteria,
    this.id_kriteria,
    String? kategoriawal,
    String bobotawal = "0",
    this.nilaiMin,
    this.nilaiMax,
    this.minOperator,
    this.maxOperator,
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

  // Operator strict untuk range:
  // - Min strict: nilai > min (bukan >=)
  // - Max strict: nilai < max (bukan <=)
  bool _strictMin = false;
  bool _strictMax = false;

  String _decodeKategoriLabel(String rawKategori) {
    // Backward-compat: data lama mungkin mengandung suffix metadata.
    const oldDelimiter = '||__META__||';
    final oldIdx = rawKategori.indexOf(oldDelimiter);
    if (oldIdx >= 0) {
      return rawKategori.substring(0, oldIdx).trim();
    }

    // Format baru: "nama||>|<="  (delimiter || diikuti 2-3 karakter operator)
    // Contoh: "test||>| " = nama "test", min strict >, no max
    const newDelimiter = '||';
    final newIdx = rawKategori.indexOf(newDelimiter);
    if (newIdx >= 0) {
      // Cek apakah setelah || ada karakter operator (>, <, ≥, ≤, atau spasi)
      final afterDelim = rawKategori.substring(newIdx + newDelimiter.length);
      if (afterDelim.length >= 3 && afterDelim[1] == '|') {
        // Format valid: 2 operator dipisah |
        return rawKategori.substring(0, newIdx).trim();
      }
    }

    return rawKategori.trim();
  }

  _RangeOps _decodeRangeOps(String rawKategori) {
    // 1. Coba decode format baru: "nama||>|<="
    const newDelimiter = '||';
    final newIdx = rawKategori.indexOf(newDelimiter);
    if (newIdx >= 0) {
      final afterDelim = rawKategori.substring(newIdx + newDelimiter.length);
      // Format: {minOp}|{maxOp} dimana op adalah >, ≥, <, ≤, atau spasi
      if (afterDelim.length >= 3 && afterDelim[1] == '|') {
        final minOp = afterDelim[0];
        final maxOp = afterDelim[2];

        bool minInclusive = true;
        bool maxInclusive = true;

        // Min operator: '>' strict, '≥' atau '>=' inclusive
        if (minOp == '>') {
          minInclusive = false;
        } else if (minOp == '≥') {
          minInclusive = true;
        }
        // else spasi/kosong = no min = default inclusive

        // Max operator: '<' strict, '≤' atau '<=' inclusive
        if (maxOp == '<') {
          maxInclusive = false;
        } else if (maxOp == '≤') {
          maxInclusive = true;
        }
        // else spasi/kosong = no max = default inclusive

        return _RangeOps(
            minInclusive: minInclusive, maxInclusive: maxInclusive);
      }
    }

    // 2. Backward-compat: data lama dengan META JSON
    const oldDelimiter = '||__META__||';
    final oldIdx = rawKategori.indexOf(oldDelimiter);
    if (oldIdx >= 0) {
      final metaStr = rawKategori.substring(oldIdx + oldDelimiter.length);
      try {
        final meta = json.decode(metaStr);
        if (meta is Map) {
          final minInc = meta['minInclusive'];
          final maxInc = meta['maxInclusive'];
          return _RangeOps(
            minInclusive: (minInc is bool) ? minInc : true,
            maxInclusive: (maxInc is bool) ? maxInc : true,
          );
        }
      } catch (_) {
        // ignore
      }
    }

    // 3. Fallback: infer dari operator di label (untuk data yang tidak ada encoding)
    final s = rawKategori.trim();
    bool minInclusive = true;
    bool maxInclusive = true;

    if (RegExp(r'(^|\s)>\s*\d').hasMatch(s) &&
        !RegExp(r'(^|\s)>=\s*\d').hasMatch(s) &&
        !RegExp(r'(^|\s)≥\s*\d').hasMatch(s)) {
      minInclusive = false;
    }
    if (RegExp(r'(^|\s)<\s*\d').hasMatch(s) &&
        !RegExp(r'(^|\s)<=\s*\d').hasMatch(s) &&
        !RegExp(r'(^|\s)≤\s*\d').hasMatch(s)) {
      maxInclusive = false;
    }

    return _RangeOps(minInclusive: minInclusive, maxInclusive: maxInclusive);
  }

  // Helper: Convert operator string dari DB ke boolean untuk UI

  // Helper: Convert boolean UI ke operator string untuk DB
  String? _inclusiveToOperator(bool inclusive, bool isMin, bool exists) {
    if (!exists) return null; // Tidak ada min/max
    if (isMin) {
      return inclusive ? '>=' : '>';
    } else {
      return inclusive ? '<=' : '<';
    }
  }

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

  num? _tryParseNumFlexible(String raw) {
    // Ambil angka pertama dari string, dukung koma/titik sebagai desimal.
    // Contoh: "<=1 km" -> 1, "1.1" -> 1.1, "1,9" -> 1.9
    final m = RegExp(r'([0-9]+(?:[\.,][0-9]+)?)').firstMatch(raw);
    if (m == null) return null;
    final s = (m.group(1) ?? '').replaceAll(',', '.');
    if (s.isEmpty) return null;
    return num.tryParse(s);
  }

  String _formatNumPlain(num value) {
    // Untuk disimpan di kategori/DB: tanpa pemisah ribuan, pakai '.' untuk desimal.
    if (value % 1 == 0) return value.toInt().toString();
    final fixed = value.toDouble().toStringAsFixed(6);
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  String _formatNumDisplay(num value) {
    // Untuk ditampilkan di UI: int pakai pemisah ribuan, desimal tetap apa adanya.
    if (value % 1 == 0) return _formatIntId(value.toInt());
    return _formatNumPlain(value);
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

  double _parseBobotForSort(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  void _sortSubkriteriaByBobot() {
    // Urutkan bobot terbesar -> terkecil (lebih relevan untuk SAW).
    _isinya.sort((a, b) {
      final bb = _parseBobotForSort(b.bobot.text);
      final ba = _parseBobotForSort(a.bobot.text);
      final cmp = bb.compareTo(ba);
      if (cmp != 0) return cmp;
      return a.kategori.text
          .trim()
          .toLowerCase()
          .compareTo(b.kategori.text.trim().toLowerCase());
    });
  }

  String _buildRentangInfoText({
    required num? minVal,
    required num? maxVal,
    required bool noLowerBound,
    required bool noUpperBound,
    required bool minInclusive,
    required bool maxInclusive,
    String? unitSuffix,
  }) {
    if (minVal == null && maxVal == null) return 'Rentang: -';

    final suffix = (unitSuffix == null) ? '' : unitSuffix;

    if (minVal != null && maxVal != null) {
      final opMin = minInclusive ? '≥' : '>';
      final opMax = maxInclusive ? '≤' : '<';
      return 'Rentang: $opMin ${_formatNumDisplay(minVal)}$suffix & $opMax ${_formatNumDisplay(maxVal)}$suffix';
    }

    if (noLowerBound && maxVal != null) {
      final opMax = maxInclusive ? '≤' : '<';
      return 'Rentang: $opMax ${_formatNumDisplay(maxVal)}$suffix';
    }

    if (noUpperBound && minVal != null) {
      final opMin = minInclusive ? '≥' : '>';
      return 'Rentang: $opMin ${_formatNumDisplay(minVal)}$suffix';
    }

    // Jika hanya salah satu terisi tapi checkbox belum dipilih
    if (minVal != null) {
      final opMin = minInclusive ? '≥' : '>';
      return 'Rentang: $opMin ${_formatNumDisplay(minVal)}$suffix (centang "tanpa batas atas")';
    }
    final opMax = maxInclusive ? '≤' : '<';
    return 'Rentang: $opMax ${_formatNumDisplay(maxVal!)}$suffix (centang "tanpa batas bawah")';
  }

  String _normalizeNamaForCompare(String raw) {
    final label = _decodeKategoriLabel(raw);
    return label.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _isDuplicateNama(String kandidat, {int? ignoreIndex}) {
    final cand = _normalizeNamaForCompare(kandidat);
    if (cand.isEmpty) return false;
    for (final entry in _isinya.asMap().entries) {
      if (ignoreIndex != null && entry.key == ignoreIndex) continue;
      final existing = _normalizeNamaForCompare(entry.value.kategori.text);
      if (existing == cand) return true;
    }
    return false;
  }

  Future<void> _showDeleteConfirmation({
    required int index,
    required KriteriaProvider penghubung,
  }) async {
    final item = _isinya[index];
    final unitSuffix =
        (penghubung.nama?.toLowerCase().contains('jarak') ?? false)
            ? ' km'
            : null;
    final kategoriDisplay = _kategoriDisplay(
      item.kategori.text,
      min: item.nilaiMin,
      max: item.nilaiMax,
      unitSuffix: unitSuffix,
      minOperator: item.minOperator,
      maxOperator: item.maxOperator,
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isDeleting = false;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final messenger = ScaffoldMessenger.of(dialogContext);
            final nav = Navigator.of(dialogContext);
            return WillPopScope(
              onWillPop: () async => !isDeleting,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                backgroundColor: Colors.white,
                titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
                title: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFB42318),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Hapus Subkriteria?',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subkriteria ini akan dihapus dan tidak bisa dikembalikan.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE6E9F2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kategoriDisplay.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (kategoriDisplay.subtitle != null)
                            Text(
                              kategoriDisplay.subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                actions: [
                  TextButton(
                    onPressed: isDeleting
                        ? null
                        : () => Navigator.of(dialogContext).pop(),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB42318),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                    ),
                    onPressed: isDeleting
                        ? null
                        : () async {
                            setStateDialog(() {
                              isDeleting = true;
                            });

                            try {
                              if (item.id_subkriteria != null) {
                                await penghubung.deletedatasubkriteria(
                                  item.id_subkriteria!,
                                );
                              }

                              if (!mounted) return;
                              setState(() {
                                _isinya.removeAt(index);
                                _hasChanges = true;
                              });
                              nav.pop();
                            } catch (e) {
                              setStateDialog(() {
                                isDeleting = false;
                              });
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Gagal menghapus subkriteria: ${e.toString()}',
                                  ),
                                ),
                              );
                            }
                          },
                    child: isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Hapus',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
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

  _KategoriDisplay _kategoriDisplay(
    String rawKategori, {
    num? min,
    num? max,
    String? unitSuffix,
    String? minOperator,
    String? maxOperator,
  }) {
    final suffix = unitSuffix ?? '';
    final rawTitle = _decodeKategoriLabel(rawKategori);

    // Prioritas 1: Gunakan operator yang diberikan
    // Prioritas 2: Decode dari kategori (backward compat)
    String opMin;
    String opMax;

    if (minOperator != null || maxOperator != null) {
      opMin = minOperator ?? '>=';
      opMax = maxOperator ?? '<=';
    } else {
      final ops = _decodeRangeOps(rawKategori);
      opMin = ops.minInclusive ? '≥' : '>';
      opMax = ops.maxInclusive ? '≤' : '<';
    }

    if (min != null || max != null) {
      final minVal = min;
      final maxVal = max;

      if (minVal != null && maxVal != null) {
        final subtitle =
            'Rentang: $opMin ${_formatNumDisplay(minVal)}$suffix & $opMax ${_formatNumDisplay(maxVal)}$suffix';
        return _KategoriDisplay(
          title: rawTitle.isNotEmpty
              ? rawTitle
              : '${_formatNumDisplay(minVal)} - ${_formatNumDisplay(maxVal)}$suffix',
          subtitle: subtitle,
        );
      }
      if (maxVal != null) {
        final subtitle = 'Rentang: $opMax ${_formatNumDisplay(maxVal)}$suffix';
        return _KategoriDisplay(
          title: rawTitle.isNotEmpty
              ? rawTitle
              : '$opMax ${_formatNumDisplay(maxVal)}$suffix',
          subtitle: subtitle,
        );
      }
      if (minVal != null) {
        final subtitle = 'Rentang: $opMin ${_formatNumDisplay(minVal)}$suffix';
        return _KategoriDisplay(
          title: rawTitle.isNotEmpty
              ? rawTitle
              : '$opMin ${_formatNumDisplay(minVal)}$suffix',
          subtitle: subtitle,
        );
      }
    }

    // Default: tampilkan apa adanya dari database.
    return _KategoriDisplay(
        title: rawTitle.isEmpty ? rawKategori : rawTitle, subtitle: null);
  }

  @override
  void initState() {
    super.initState();
    if (!_isInitialized) {
      _isInitialized = true;
      keadaan = false;
      final penghubung = Provider.of<KriteriaProvider>(context, listen: false);
      _penghubung = Future.wait([
        penghubung.readdata(),
        penghubung.readdatasubkriteria(),
      ]).then((_) {
        // Auto-select kriteria pertama setelah data berhasil di-load
        final current = (penghubung.nama ?? '').trim();
        final isUnselected = current.isEmpty ||
            current.toLowerCase() == 'pilih' ||
            current.toLowerCase() == 'pilih kriteria';

        if (mounted && isUnselected && penghubung.kategoriall.isNotEmpty) {
          penghubung.pilihkriteria(penghubung.kategoriall.first);
        }
      });
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
            final current = (penghubung.nama ?? '').trim();
            final isUnselected = current.isEmpty ||
                current.toLowerCase() == 'pilih' ||
                current.toLowerCase() == 'pilih kriteria';

            if (isUnselected && penghubung.kategoriall.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                // Cek lagi untuk menghindari pemanggilan ganda jika state sudah berubah.
                final current2 = (penghubung.nama ?? '').trim();
                final isUnselected2 = current2.isEmpty ||
                    current2.toLowerCase() == 'pilih' ||
                    current2.toLowerCase() == 'pilih kriteria';

                if (isUnselected2 && penghubung.kategoriall.isNotEmpty) {
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
                final rawKategori = datanya.kategori ?? '';

                // Prioritas 1: Baca operator dari kolom database (data baru)
                String? minOp = datanya.min_operator;
                String? maxOp = datanya.max_operator;

                // Prioritas 2: Jika operator NULL, fallback ke decode dari kategori (backward compatibility)
                if (minOp == null && maxOp == null) {
                  final ops = _decodeRangeOps(rawKategori);
                  // Convert boolean ke string operator untuk consistency
                  minOp = _inclusiveToOperator(
                      !ops.minInclusive, true, datanya.nilai_min != null);
                  maxOp = _inclusiveToOperator(
                      !ops.maxInclusive, false, datanya.nilai_max != null);
                }

                _isinya.add(
                  SubcriteriaItem(
                    id_kriteria: datanya.id_kriteria,
                    id_subkriteria: datanya.id_subkriteria,
                    kategoriawal: _decodeKategoriLabel(rawKategori),
                    bobotawal: datanya.bobot.toString(),
                    nilaiMin: datanya.nilai_min,
                    nilaiMax: datanya.nilai_max,
                    minOperator: minOp,
                    maxOperator: maxOp,
                  ),
                );
              }

              _sortSubkriteriaByBobot();
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
                              _strictMin = false;
                              _strictMax = false;

                              String? dialogError;

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
                                                  if (dialogError != null) ...[
                                                    Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFFFF1F1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xFFFCA5A5),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        dialogError!,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Color(0xFFB42318),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 12),
                                                  ],
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
                                                    const SizedBox(height: 12),

                                                    // Preview range dipindahkan tepat di bawah input Bobot
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFF0F9FF),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        border: Border.all(
                                                          color: const Color(
                                                              0xFF0284C7),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: AnimatedBuilder(
                                                        animation:
                                                            Listenable.merge([
                                                          _minController,
                                                          _maxController,
                                                        ]),
                                                        builder: (context, _) {
                                                          final minVal =
                                                              _tryParseNumFlexible(
                                                            _minController.text
                                                                .trim(),
                                                          );
                                                          final maxVal =
                                                              _tryParseNumFlexible(
                                                            _maxController.text
                                                                .trim(),
                                                          );
                                                          final unitSuffix = (penghubung
                                                                      .nama
                                                                      ?.toLowerCase()
                                                                      .contains(
                                                                          'jarak') ??
                                                                  false)
                                                              ? ' km'
                                                              : null;
                                                          final text =
                                                              _buildRentangInfoText(
                                                            minVal: minVal,
                                                            maxVal: maxVal,
                                                            noLowerBound:
                                                                _noLowerBound,
                                                            noUpperBound:
                                                                _noUpperBound,
                                                            minInclusive:
                                                                !_strictMin,
                                                            maxInclusive:
                                                                !_strictMax,
                                                            unitSuffix:
                                                                unitSuffix,
                                                          );
                                                          return Text(
                                                            text,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                  0xFF0284C7),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),

                                                    const SizedBox(height: 12),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16),
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                            0xFFFAFBFC),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                          color: Colors.grey
                                                              .withOpacity(0.2),
                                                          width: 1,
                                                        ),
                                                      ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "📊 Pengaturan Range Nilai",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: const Color(
                                                                  0xFF1E3A8A),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              height: 16),

                                                          // Section Nilai Minimum
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .blue
                                                                    .withOpacity(
                                                                        0.1),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "🔽 Nilai Minimum",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                            .blue[
                                                                        700],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                TextField(
                                                                  controller:
                                                                      _minController,
                                                                  keyboardType:
                                                                      const TextInputType
                                                                          .numberWithOptions(
                                                                    decimal:
                                                                        true,
                                                                  ),
                                                                  enabled:
                                                                      !_noLowerBound,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        "Nilai Min",
                                                                    hintText:
                                                                        "misal 700000",
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        const Color(
                                                                            0xFFF5F7FB),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none,
                                                                    ),
                                                                    prefixIcon: const Icon(
                                                                        Icons
                                                                            .trending_up,
                                                                        size:
                                                                            18),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                // Min-related options
                                                                AnimatedBuilder(
                                                                  animation:
                                                                      Listenable
                                                                          .merge([
                                                                    _minController,
                                                                    _maxController,
                                                                  ]),
                                                                  builder:
                                                                      (context,
                                                                          _) {
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
                                                                    final canNoLowerBound =
                                                                        !minFilled &&
                                                                            maxFilled;
                                                                    final canStrictMin =
                                                                        minFilled &&
                                                                            !_noLowerBound;

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
                                                                                      _strictMin = false;
                                                                                      _minController.clear();
                                                                                    }
                                                                                  });
                                                                                }
                                                                              : null,
                                                                          dense:
                                                                              true,
                                                                          contentPadding:
                                                                              EdgeInsets.zero,
                                                                          title:
                                                                              Text(
                                                                            '🚫 Tanpa batas minimum',
                                                                            style:
                                                                                TextStyle(fontSize: 12),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                6),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                'Operator minimum',
                                                                                style: TextStyle(
                                                                                  fontSize: 11,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Colors.grey[700],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            ToggleButtons(
                                                                              isSelected: [
                                                                                canStrictMin ? !_strictMin : true,
                                                                                canStrictMin ? _strictMin : false,
                                                                              ],
                                                                              onPressed: canStrictMin
                                                                                  ? (idx) {
                                                                                      setStateDialog(() {
                                                                                        _strictMin = (idx == 1);
                                                                                      });
                                                                                    }
                                                                                  : null,
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              constraints: const BoxConstraints(
                                                                                minHeight: 34,
                                                                                minWidth: 44,
                                                                              ),
                                                                              children: const [
                                                                                Padding(
                                                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                  child: Text('≥'),
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                  child: Text('>'),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                4),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),

                                                          const SizedBox(
                                                              height: 12),

                                                          // Section Nilai Maximum
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              border:
                                                                  Border.all(
                                                                color: Colors
                                                                    .red
                                                                    .withOpacity(
                                                                        0.1),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  "🔼 Nilai Maksimum",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    color: Colors
                                                                            .red[
                                                                        700],
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),
                                                                TextField(
                                                                  controller:
                                                                      _maxController,
                                                                  keyboardType:
                                                                      const TextInputType
                                                                          .numberWithOptions(
                                                                    decimal:
                                                                        true,
                                                                  ),
                                                                  enabled:
                                                                      !_noUpperBound,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    labelText:
                                                                        "Nilai Max",
                                                                    hintText:
                                                                        "misal 900000",
                                                                    filled:
                                                                        true,
                                                                    fillColor:
                                                                        const Color(
                                                                            0xFFF5F7FB),
                                                                    border:
                                                                        OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                      borderSide:
                                                                          BorderSide
                                                                              .none,
                                                                    ),
                                                                    prefixIcon: const Icon(
                                                                        Icons
                                                                            .trending_down,
                                                                        size:
                                                                            18),
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 8),

                                                                // Max-related options
                                                                AnimatedBuilder(
                                                                  animation:
                                                                      Listenable
                                                                          .merge([
                                                                    _minController,
                                                                    _maxController,
                                                                  ]),
                                                                  builder:
                                                                      (context,
                                                                          _) {
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
                                                                    final canNoUpperBound =
                                                                        minFilled &&
                                                                            !maxFilled;
                                                                    final canStrictMax =
                                                                        maxFilled &&
                                                                            !_noUpperBound;

                                                                    return Column(
                                                                      children: [
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
                                                                                      _strictMax = false;
                                                                                      _maxController.clear();
                                                                                    }
                                                                                  });
                                                                                }
                                                                              : null,
                                                                          dense:
                                                                              true,
                                                                          contentPadding:
                                                                              EdgeInsets.zero,
                                                                          title:
                                                                              Text(
                                                                            '🚫 Tanpa batas maksimum',
                                                                            style:
                                                                                TextStyle(fontSize: 12),
                                                                          ),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                6),
                                                                        Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Text(
                                                                                'Operator maksimum',
                                                                                style: TextStyle(
                                                                                  fontSize: 11,
                                                                                  fontWeight: FontWeight.w600,
                                                                                  color: Colors.grey[700],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            ToggleButtons(
                                                                              isSelected: [
                                                                                canStrictMax ? !_strictMax : true,
                                                                                canStrictMax ? _strictMax : false,
                                                                              ],
                                                                              onPressed: canStrictMax
                                                                                  ? (idx) {
                                                                                      setStateDialog(() {
                                                                                        _strictMax = (idx == 1);
                                                                                      });
                                                                                    }
                                                                                  : null,
                                                                              borderRadius: BorderRadius.circular(10),
                                                                              constraints: const BoxConstraints(
                                                                                minHeight: 34,
                                                                                minWidth: 44,
                                                                              ),
                                                                              children: const [
                                                                                Padding(
                                                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                  child: Text('≤'),
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                  child: Text('<'),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                4),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
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
                                                setStateDialog(() {
                                                  dialogError = null;
                                                });

                                                final namaBaru =
                                                    namacontroller.text.trim();
                                                final bobotRaw =
                                                    bobotcontroller.text.trim();
                                                final bobotParsed =
                                                    double.tryParse(bobotRaw
                                                        .replaceAll(',', '.'));

                                                if (namaBaru.isEmpty ||
                                                    bobotParsed == null) {
                                                  setStateDialog(() {
                                                    dialogError =
                                                        'Nama dan bobot wajib diisi dengan benar.';
                                                  });
                                                  return;
                                                }

                                                final namaNorm = namaBaru
                                                    .replaceAll(',', '.');
                                                final bobotNorm = bobotRaw
                                                    .replaceAll(',', '.');
                                                if (namaNorm == bobotNorm) {
                                                  setStateDialog(() {
                                                    dialogError =
                                                        'Nama subkriteria tidak boleh sama persis dengan nilai/bobot.';
                                                  });
                                                  return;
                                                }

                                                final kategoriLabel = namaBaru;
                                                var kategoriToSave =
                                                    kategoriLabel;
                                                num? nilaiMin;
                                                num? nilaiMax;
                                                if (_isRangeKriteria(
                                                    penghubung.nama)) {
                                                  final minText = _minController
                                                      .text
                                                      .trim();
                                                  final maxText = _maxController
                                                      .text
                                                      .trim();

                                                  final minFilled =
                                                      minText.isNotEmpty;
                                                  final maxFilled =
                                                      maxText.isNotEmpty;

                                                  if (_noLowerBound &&
                                                      _noUpperBound) {
                                                    setStateDialog(() {
                                                      dialogError =
                                                          'Pilih salah satu: tanpa batas bawah ATAU tanpa batas atas.';
                                                    });
                                                    return;
                                                  }

                                                  if (!minFilled &&
                                                      !maxFilled) {
                                                    setStateDialog(() {
                                                      dialogError =
                                                          'Untuk kriteria range, isi Min & Max atau pilih salah satu mode tanpa batas.';
                                                    });
                                                    return;
                                                  }

                                                  if (minFilled && maxFilled) {
                                                    final minVal =
                                                        _tryParseNumFlexible(
                                                            minText);
                                                    final maxVal =
                                                        _tryParseNumFlexible(
                                                            maxText);
                                                    if (minVal == null ||
                                                        maxVal == null) {
                                                      setStateDialog(() {
                                                        dialogError =
                                                            'Min dan Max harus berupa angka.';
                                                      });
                                                      return;
                                                    }
                                                    if (minVal > maxVal) {
                                                      setStateDialog(() {
                                                        dialogError =
                                                            'Min tidak boleh lebih besar dari Max.';
                                                      });
                                                      return;
                                                    }
                                                    nilaiMin = minVal;
                                                    nilaiMax = maxVal;
                                                  } else if (minFilled &&
                                                      !maxFilled) {
                                                    if (!_noUpperBound) {
                                                      setStateDialog(() {
                                                        dialogError =
                                                            'Isi nilai Max atau centang "Tanpa batas maksimum".';
                                                      });
                                                      return;
                                                    }
                                                    final minVal =
                                                        _tryParseNumFlexible(
                                                            minText);
                                                    if (minVal == null) {
                                                      setStateDialog(() {
                                                        dialogError =
                                                            'Min harus berupa angka.';
                                                      });
                                                      return;
                                                    }
                                                    nilaiMin = minVal;
                                                    nilaiMax = null;
                                                  } else if (!minFilled &&
                                                      maxFilled) {
                                                    if (!_noLowerBound) {
                                                      setStateDialog(() {
                                                        dialogError =
                                                            'Isi nilai Min atau centang "Tanpa batas minimum".';
                                                      });
                                                      return;
                                                    }
                                                    final maxVal =
                                                        _tryParseNumFlexible(
                                                            maxText);
                                                    if (maxVal == null) {
                                                      setStateDialog(() {
                                                        dialogError =
                                                            'Max harus berupa angka.';
                                                      });
                                                      return;
                                                    }
                                                    nilaiMin = null;
                                                    nilaiMax = maxVal;
                                                  }

                                                  // Kategori tetap bersih (tidak ada encoding)
                                                  kategoriToSave =
                                                      kategoriLabel;
                                                }

                                                if (_isDuplicateNama(
                                                    kategoriLabel)) {
                                                  setStateDialog(() {
                                                    dialogError =
                                                        'Nama subkriteria tidak boleh sama: "$kategoriLabel"';
                                                  });
                                                  return;
                                                }

                                                if (bobotParsed <= 0) {
                                                  setStateDialog(() {
                                                    dialogError =
                                                        'Bobot subkriteria tidak boleh 0 atau negatif.';
                                                  });
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
                                                  setStateDialog(() {
                                                    dialogError =
                                                        'Bobot subkriteria tidak boleh ada yang sama.';
                                                  });
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

                                                  // Generate operator string untuk disimpan ke DB
                                                  String? minOpToSave;
                                                  String? maxOpToSave;

                                                  if (nilaiMin != null) {
                                                    minOpToSave =
                                                        _strictMin ? '>' : '>=';
                                                  }
                                                  if (nilaiMax != null) {
                                                    maxOpToSave =
                                                        _strictMax ? '<' : '<=';
                                                  }

                                                  _isinya.add(SubcriteriaItem(
                                                    id_kriteria:
                                                        kSekarang?.id_kriteria,
                                                    kategoriawal:
                                                        kategoriToSave,
                                                    bobotawal: bobotRaw,
                                                    nilaiMin: nilaiMin,
                                                    nilaiMax: nilaiMax,
                                                    minOperator: minOpToSave,
                                                    maxOperator: maxOpToSave,
                                                  ));

                                                  _sortSubkriteriaByBobot();
                                                  namacontroller.clear();
                                                  bobotcontroller.clear();
                                                  _minController.clear();
                                                  _maxController.clear();
                                                  _strictMin = false;
                                                  _strictMax = false;
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
                                        final unitSuffix = (penghubung.nama
                                                    ?.toLowerCase()
                                                    .contains('jarak') ??
                                                false)
                                            ? ' km'
                                            : null;
                                        final kategoriDisplay =
                                            _kategoriDisplay(
                                          kategoriRaw,
                                          min: _isinya[idx].nilaiMin,
                                          max: _isinya[idx].nilaiMax,
                                          unitSuffix: unitSuffix,
                                          minOperator: _isinya[idx].minOperator,
                                          maxOperator: _isinya[idx].maxOperator,
                                        );

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
                                                        final item =
                                                            _isinya[idx];
                                                        namacontroller.text =
                                                            _decodeKategoriLabel(
                                                                item.kategori
                                                                    .text);
                                                        bobotcontroller.text =
                                                            item.bobot.text;
                                                        _minController.clear();
                                                        _maxController.clear();
                                                        _noLowerBound = false;
                                                        _noUpperBound = false;

                                                        // Convert operator string ke boolean untuk UI
                                                        _strictMin =
                                                            (item.minOperator ==
                                                                '>');
                                                        _strictMax =
                                                            (item.maxOperator ==
                                                                '<');

                                                        // Prefill min/max & checkbox: utamakan kolom DB (nilaiMin/nilaiMax). Fallback ke parsing string kategori.
                                                        if (_isRangeKriteria(
                                                                penghubung
                                                                    .nama) &&
                                                            (item.nilaiMin !=
                                                                    null ||
                                                                item.nilaiMax !=
                                                                    null)) {
                                                          final minVal =
                                                              item.nilaiMin;
                                                          final maxVal =
                                                              item.nilaiMax;
                                                          if (minVal != null) {
                                                            _minController
                                                                    .text =
                                                                _formatNumPlain(
                                                                    minVal);
                                                          }
                                                          if (maxVal != null) {
                                                            _maxController
                                                                    .text =
                                                                _formatNumPlain(
                                                                    maxVal);
                                                          }

                                                          _noLowerBound =
                                                              (minVal == null &&
                                                                  maxVal !=
                                                                      null);
                                                          _noUpperBound =
                                                              (minVal != null &&
                                                                  maxVal ==
                                                                      null);
                                                        } else {
                                                          // Coba prefill dari string kategori (legacy)
                                                          final kat =
                                                              _decodeKategoriLabel(
                                                                      item.kategori
                                                                          .text)
                                                                  .trim();
                                                          final matches = RegExp(
                                                                  r'(\d+(?:[\.,]\d+)?)')
                                                              .allMatches(kat)
                                                              .toList();

                                                          if (kat.startsWith(
                                                              '<= ')) {
                                                            // Tanpa batas bawah (hanya Max)
                                                            _noLowerBound =
                                                                true;
                                                            if (matches
                                                                .isNotEmpty) {
                                                              _maxController
                                                                  .text = matches
                                                                      .last
                                                                      .group(
                                                                          1) ??
                                                                  '';
                                                            }
                                                          } else if (kat
                                                              .startsWith(
                                                                  '>=')) {
                                                            if (kat.contains(
                                                                '-')) {
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
                                                          }
                                                        }
                                                        // Tampilkan dialog yang sama
                                                        String? dialogError;
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
                                                                            if (dialogError !=
                                                                                null) ...[
                                                                              Container(
                                                                                width: double.infinity,
                                                                                padding: const EdgeInsets.all(12),
                                                                                decoration: BoxDecoration(
                                                                                  color: const Color(0xFFFFF1F1),
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  border: Border.all(
                                                                                    color: const Color(0xFFFCA5A5),
                                                                                  ),
                                                                                ),
                                                                                child: Text(
                                                                                  dialogError!,
                                                                                  style: const TextStyle(
                                                                                    fontSize: 12,
                                                                                    fontWeight: FontWeight.w600,
                                                                                    color: Color(0xFFB42318),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 12),
                                                                            ],
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
                                                                              const SizedBox(height: 12),

                                                                              // Preview range dipindahkan tepat di bawah input Bobot
                                                                              Container(
                                                                                padding: const EdgeInsets.all(12),
                                                                                decoration: BoxDecoration(
                                                                                  color: const Color(0xFFF0F9FF),
                                                                                  borderRadius: BorderRadius.circular(8),
                                                                                  border: Border.all(
                                                                                    color: const Color(0xFF0284C7),
                                                                                    width: 1,
                                                                                  ),
                                                                                ),
                                                                                child: AnimatedBuilder(
                                                                                  animation: Listenable.merge([
                                                                                    _minController,
                                                                                    _maxController,
                                                                                  ]),
                                                                                  builder: (context, _) {
                                                                                    final minVal = _tryParseNumFlexible(
                                                                                      _minController.text.trim(),
                                                                                    );
                                                                                    final maxVal = _tryParseNumFlexible(
                                                                                      _maxController.text.trim(),
                                                                                    );
                                                                                    final unitSuffix = (penghubung.nama?.toLowerCase().contains('jarak') ?? false) ? ' km' : null;
                                                                                    final text = _buildRentangInfoText(
                                                                                      minVal: minVal,
                                                                                      maxVal: maxVal,
                                                                                      noLowerBound: _noLowerBound,
                                                                                      noUpperBound: _noUpperBound,
                                                                                      minInclusive: !_strictMin,
                                                                                      maxInclusive: !_strictMax,
                                                                                      unitSuffix: unitSuffix,
                                                                                    );
                                                                                    return Text(
                                                                                      text,
                                                                                      style: const TextStyle(
                                                                                        fontSize: 12,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        color: Color(0xFF0284C7),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ),

                                                                              const SizedBox(height: 12),
                                                                              Container(
                                                                                padding: const EdgeInsets.all(16),
                                                                                decoration: BoxDecoration(
                                                                                  color: const Color(0xFFFAFBFC),
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  border: Border.all(
                                                                                    color: Colors.grey.withOpacity(0.2),
                                                                                    width: 1,
                                                                                  ),
                                                                                ),
                                                                                child: Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Text(
                                                                                      "📊 Pengaturan Range Nilai",
                                                                                      style: TextStyle(
                                                                                        fontSize: 14,
                                                                                        fontWeight: FontWeight.w700,
                                                                                        color: const Color(0xFF1E3A8A),
                                                                                      ),
                                                                                    ),
                                                                                    const SizedBox(height: 16),

                                                                                    // Section Nilai Minimum
                                                                                    Container(
                                                                                      padding: const EdgeInsets.all(12),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                        border: Border.all(
                                                                                          color: Colors.blue.withOpacity(0.1),
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            "🔽 Nilai Minimum",
                                                                                            style: TextStyle(
                                                                                              fontSize: 12,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              color: Colors.blue[700],
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 8),
                                                                                          TextField(
                                                                                            controller: _minController,
                                                                                            keyboardType: const TextInputType.numberWithOptions(
                                                                                              decimal: true,
                                                                                            ),
                                                                                            enabled: !_noLowerBound,
                                                                                            decoration: InputDecoration(
                                                                                              labelText: "Nilai Min",
                                                                                              hintText: "misal 700000",
                                                                                              filled: true,
                                                                                              fillColor: const Color(0xFFF5F7FB),
                                                                                              border: OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.circular(8),
                                                                                                borderSide: BorderSide.none,
                                                                                              ),
                                                                                              prefixIcon: const Icon(Icons.trending_up, size: 18),
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 8),

                                                                                          // Min-related options
                                                                                          AnimatedBuilder(
                                                                                            animation: Listenable.merge([
                                                                                              _minController,
                                                                                              _maxController,
                                                                                            ]),
                                                                                            builder: (context, _) {
                                                                                              final minFilled = _minController.text.trim().isNotEmpty;
                                                                                              final maxFilled = _maxController.text.trim().isNotEmpty;
                                                                                              final canNoLowerBound = !minFilled && maxFilled;
                                                                                              final canStrictMin = minFilled && !_noLowerBound;

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
                                                                                                                _strictMin = false;
                                                                                                                _minController.clear();
                                                                                                              }
                                                                                                            });
                                                                                                          }
                                                                                                        : null,
                                                                                                    dense: true,
                                                                                                    contentPadding: EdgeInsets.zero,
                                                                                                    title: Text(
                                                                                                      '🚫 Tanpa batas minimum',
                                                                                                      style: TextStyle(fontSize: 12),
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(height: 6),
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Expanded(
                                                                                                        child: Text(
                                                                                                          'Operator minimum',
                                                                                                          style: TextStyle(
                                                                                                            fontSize: 11,
                                                                                                            fontWeight: FontWeight.w600,
                                                                                                            color: Colors.grey[700],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      ToggleButtons(
                                                                                                        isSelected: [
                                                                                                          canStrictMin ? !_strictMin : true,
                                                                                                          canStrictMin ? _strictMin : false,
                                                                                                        ],
                                                                                                        onPressed: canStrictMin
                                                                                                            ? (idx) {
                                                                                                                setStateDialog(() {
                                                                                                                  _strictMin = (idx == 1);
                                                                                                                });
                                                                                                              }
                                                                                                            : null,
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                        constraints: const BoxConstraints(
                                                                                                          minHeight: 34,
                                                                                                          minWidth: 44,
                                                                                                        ),
                                                                                                        children: const [
                                                                                                          Padding(
                                                                                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                                            child: Text('≥'),
                                                                                                          ),
                                                                                                          Padding(
                                                                                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                                            child: Text('>'),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  const SizedBox(height: 4),
                                                                                                ],
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),

                                                                                    const SizedBox(height: 12),

                                                                                    // Section Nilai Maximum
                                                                                    Container(
                                                                                      padding: const EdgeInsets.all(12),
                                                                                      decoration: BoxDecoration(
                                                                                        color: Colors.white,
                                                                                        borderRadius: BorderRadius.circular(8),
                                                                                        border: Border.all(
                                                                                          color: Colors.red.withOpacity(0.1),
                                                                                          width: 1,
                                                                                        ),
                                                                                      ),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Text(
                                                                                            "🔼 Nilai Maksimum",
                                                                                            style: TextStyle(
                                                                                              fontSize: 12,
                                                                                              fontWeight: FontWeight.w600,
                                                                                              color: Colors.red[700],
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 8),
                                                                                          TextField(
                                                                                            controller: _maxController,
                                                                                            keyboardType: const TextInputType.numberWithOptions(
                                                                                              decimal: true,
                                                                                            ),
                                                                                            enabled: !_noUpperBound,
                                                                                            decoration: InputDecoration(
                                                                                              labelText: "Nilai Max",
                                                                                              hintText: "misal 900000",
                                                                                              filled: true,
                                                                                              fillColor: const Color(0xFFF5F7FB),
                                                                                              border: OutlineInputBorder(
                                                                                                borderRadius: BorderRadius.circular(8),
                                                                                                borderSide: BorderSide.none,
                                                                                              ),
                                                                                              prefixIcon: const Icon(Icons.trending_down, size: 18),
                                                                                            ),
                                                                                          ),
                                                                                          const SizedBox(height: 8),

                                                                                          // Max-related options
                                                                                          AnimatedBuilder(
                                                                                            animation: Listenable.merge([
                                                                                              _minController,
                                                                                              _maxController,
                                                                                            ]),
                                                                                            builder: (context, _) {
                                                                                              final minFilled = _minController.text.trim().isNotEmpty;
                                                                                              final maxFilled = _maxController.text.trim().isNotEmpty;
                                                                                              final canNoUpperBound = minFilled && !maxFilled;
                                                                                              final canStrictMax = maxFilled && !_noUpperBound;

                                                                                              return Column(
                                                                                                children: [
                                                                                                  CheckboxListTile(
                                                                                                    value: canNoUpperBound ? _noUpperBound : false,
                                                                                                    onChanged: canNoUpperBound
                                                                                                        ? (val) {
                                                                                                            setStateDialog(() {
                                                                                                              _noUpperBound = val ?? false;
                                                                                                              if (_noUpperBound) {
                                                                                                                _noLowerBound = false;
                                                                                                                _strictMax = false;
                                                                                                                _maxController.clear();
                                                                                                              }
                                                                                                            });
                                                                                                          }
                                                                                                        : null,
                                                                                                    dense: true,
                                                                                                    contentPadding: EdgeInsets.zero,
                                                                                                    title: Text(
                                                                                                      '🚫 Tanpa batas maksimum',
                                                                                                      style: TextStyle(fontSize: 12),
                                                                                                    ),
                                                                                                  ),
                                                                                                  const SizedBox(height: 6),
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Expanded(
                                                                                                        child: Text(
                                                                                                          'Operator maksimum',
                                                                                                          style: TextStyle(
                                                                                                            fontSize: 11,
                                                                                                            fontWeight: FontWeight.w600,
                                                                                                            color: Colors.grey[700],
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      ToggleButtons(
                                                                                                        isSelected: [
                                                                                                          canStrictMax ? !_strictMax : true,
                                                                                                          canStrictMax ? _strictMax : false,
                                                                                                        ],
                                                                                                        onPressed: canStrictMax
                                                                                                            ? (idx) {
                                                                                                                setStateDialog(() {
                                                                                                                  _strictMax = (idx == 1);
                                                                                                                });
                                                                                                              }
                                                                                                            : null,
                                                                                                        borderRadius: BorderRadius.circular(10),
                                                                                                        constraints: const BoxConstraints(
                                                                                                          minHeight: 34,
                                                                                                          minWidth: 44,
                                                                                                        ),
                                                                                                        children: const [
                                                                                                          Padding(
                                                                                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                                            child: Text('≤'),
                                                                                                          ),
                                                                                                          Padding(
                                                                                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                                                                                            child: Text('<'),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  const SizedBox(height: 4),
                                                                                                ],
                                                                                              );
                                                                                            },
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
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
                                                                          setStateDialog(
                                                                              () {
                                                                            dialogError =
                                                                                null;
                                                                          });

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
                                                                            setStateDialog(() {
                                                                              dialogError = 'Nama dan bobot wajib diisi dengan benar.';
                                                                            });
                                                                            return;
                                                                          }

                                                                          final namaNorm = namaBaru.replaceAll(
                                                                              ',',
                                                                              '.');
                                                                          final bobotNorm = bobotRaw.replaceAll(
                                                                              ',',
                                                                              '.');
                                                                          if (namaNorm ==
                                                                              bobotNorm) {
                                                                            setStateDialog(() {
                                                                              dialogError = 'Nama subkriteria tidak boleh sama persis dengan nilai/bobot.';
                                                                            });
                                                                            return;
                                                                          }

                                                                          if (bobotParsed <=
                                                                              0) {
                                                                            setStateDialog(() {
                                                                              dialogError = 'Bobot subkriteria tidak boleh 0 atau negatif.';
                                                                            });
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
                                                                            setStateDialog(() {
                                                                              dialogError = 'Bobot subkriteria tidak boleh ada yang sama.';
                                                                            });
                                                                            return;
                                                                          }

                                                                          final kategoriLabel =
                                                                              namaBaru;
                                                                          var kategoriToSave =
                                                                              kategoriLabel;
                                                                          if (_isRangeKriteria(
                                                                              penghubung.nama)) {
                                                                            final minText =
                                                                                _minController.text.trim();
                                                                            final maxText =
                                                                                _maxController.text.trim();

                                                                            num?
                                                                                nilaiMin;
                                                                            num?
                                                                                nilaiMax;

                                                                            final minFilled =
                                                                                minText.isNotEmpty;
                                                                            final maxFilled =
                                                                                maxText.isNotEmpty;

                                                                            if (_noLowerBound &&
                                                                                _noUpperBound) {
                                                                              setStateDialog(() {
                                                                                dialogError = 'Pilih salah satu: tanpa batas bawah ATAU tanpa batas atas.';
                                                                              });
                                                                              return;
                                                                            }

                                                                            if (!minFilled &&
                                                                                !maxFilled) {
                                                                              setStateDialog(() {
                                                                                dialogError = 'Untuk kriteria range, isi Min & Max atau pilih salah satu mode tanpa batas.';
                                                                              });
                                                                              return;
                                                                            }

                                                                            if (minFilled &&
                                                                                maxFilled) {
                                                                              final minVal = _tryParseNumFlexible(minText);
                                                                              final maxVal = _tryParseNumFlexible(maxText);
                                                                              if (minVal == null || maxVal == null) {
                                                                                setStateDialog(() {
                                                                                  dialogError = 'Min dan Max harus berupa angka.';
                                                                                });
                                                                                return;
                                                                              }
                                                                              if (minVal > maxVal) {
                                                                                setStateDialog(() {
                                                                                  dialogError = 'Min tidak boleh lebih besar dari Max.';
                                                                                });
                                                                                return;
                                                                              }
                                                                              nilaiMin = minVal;
                                                                              nilaiMax = maxVal;
                                                                            } else if (minFilled &&
                                                                                !maxFilled) {
                                                                              if (!_noUpperBound) {
                                                                                setStateDialog(() {
                                                                                  dialogError = 'Isi nilai Max atau centang "Tanpa batas maksimum".';
                                                                                });
                                                                                return;
                                                                              }
                                                                              final minVal = _tryParseNumFlexible(minText);
                                                                              if (minVal == null) {
                                                                                setStateDialog(() {
                                                                                  dialogError = 'Min harus berupa angka.';
                                                                                });
                                                                                return;
                                                                              }
                                                                              nilaiMin = minVal;
                                                                              nilaiMax = null;
                                                                            } else if (!minFilled &&
                                                                                maxFilled) {
                                                                              if (!_noLowerBound) {
                                                                                setStateDialog(() {
                                                                                  dialogError = 'Isi nilai Min atau centang "Tanpa batas minimum".';
                                                                                });
                                                                                return;
                                                                              }
                                                                              final maxVal = _tryParseNumFlexible(maxText);
                                                                              if (maxVal == null) {
                                                                                setStateDialog(() {
                                                                                  dialogError = 'Max harus berupa angka.';
                                                                                });
                                                                                return;
                                                                              }
                                                                              nilaiMin = null;
                                                                              nilaiMax = maxVal;
                                                                            }

                                                                            // Simpan nilai min/max ke item (kolom DB)
                                                                            _isinya[editinde!].nilaiMin =
                                                                                nilaiMin;
                                                                            _isinya[editinde!].nilaiMax =
                                                                                nilaiMax;

                                                                            // Simpan operator sebagai string terpisah (tidak di-encode ke kategori)
                                                                            String?
                                                                                minOpToSave;
                                                                            String?
                                                                                maxOpToSave;

                                                                            if (nilaiMin !=
                                                                                null) {
                                                                              minOpToSave = _strictMin ? '>' : '>=';
                                                                            }
                                                                            if (nilaiMax !=
                                                                                null) {
                                                                              maxOpToSave = _strictMax ? '<' : '<=';
                                                                            }

                                                                            _isinya[editinde!].minOperator =
                                                                                minOpToSave;
                                                                            _isinya[editinde!].maxOperator =
                                                                                maxOpToSave;

                                                                            // Kategori tetap bersih (tidak ada encoding)
                                                                            kategoriToSave =
                                                                                kategoriLabel;
                                                                          } else {
                                                                            // Jika bukan kriteria range, pastikan kolom range dikosongkan
                                                                            _isinya[editinde!].nilaiMin =
                                                                                null;
                                                                            _isinya[editinde!].nilaiMax =
                                                                                null;
                                                                            _isinya[editinde!].minOperator =
                                                                                null;
                                                                            _isinya[editinde!].maxOperator =
                                                                                null;
                                                                          }

                                                                          if (_isDuplicateNama(
                                                                            kategoriLabel,
                                                                            ignoreIndex:
                                                                                editinde,
                                                                          )) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              SnackBar(
                                                                                content: Text(
                                                                                  'Nama subkriteria tidak boleh sama: "$kategoriLabel"',
                                                                                ),
                                                                              ),
                                                                            );
                                                                            return;
                                                                          }

                                                                          setState(
                                                                              () {
                                                                            _isinya[editinde!].kategori.text =
                                                                                kategoriToSave;
                                                                            _isinya[editinde!].bobot.text =
                                                                                bobotRaw;

                                                                            _sortSubkriteriaByBobot();
                                                                            _hasChanges =
                                                                                true;
                                                                            _minController.clear();
                                                                            _maxController.clear();
                                                                            _strictMin =
                                                                                false;
                                                                            _strictMax =
                                                                                false;
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
                                                        await _showDeleteConfirmation(
                                                          index: idx,
                                                          penghubung:
                                                              penghubung,
                                                        );
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

                          // Refresh data kost setelah cascade update subkriteria
                          final kostProvider = Provider.of<KostProvider>(
                            context,
                            listen: false,
                          );
                          await kostProvider.fetchSubkriteria();
                          await kostProvider.readdata();

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

class _RangeOps {
  final bool minInclusive;
  final bool maxInclusive;

  const _RangeOps({required this.minInclusive, required this.maxInclusive});
}
