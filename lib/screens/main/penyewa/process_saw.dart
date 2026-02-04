import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/kost_provider.dart';
import '../../../algoritma/simple_additive_weighting.dart';

class ProcessSawPage extends StatefulWidget {
  /// Lokasi user untuk perhitungan kriteria jarak
  final double? userLat;
  final double? userLng;

  const ProcessSawPage({
    super.key,
    this.userLat,
    this.userLng,
  });

  @override
  State<ProcessSawPage> createState() => _ProcessSawPageState();
}

class _ProcessSawPageState extends State<ProcessSawPage> {
  @override
  void initState() {
    super.initState();
    // Jalankan perhitungan SAW saat halaman dibuka dengan lokasi user
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KostProvider>().hitungSAW(
            userLat: widget.userLat,
            userLng: widget.userLng,
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
    const Color colorSuccess = Color(0xFF2E7D32);
    const Color colorError = Color(0xFFD32F2F);
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
          'Perhitungan SAW',
          style:
              TextStyle(color: colorTextPrimary, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Tombol refresh
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            color: colorPrimary,
            onPressed: () {
              context.read<KostProvider>().hitungSAW(
                    userLat: widget.userLat,
                    userLng: widget.userLng,
                  );
            },
          ),
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
                      color: colorError,
                    ),
                    SizedBox(height: s(16)),
                    Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: s(18),
                        fontWeight: FontWeight.w600,
                        color: colorError,
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
                      onPressed: () => provider.hitungSAW(),
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
                    Icons.calculate_outlined,
                    size: s(64),
                    color: colorPrimary.withOpacity(0.5),
                  ),
                  SizedBox(height: s(16)),
                  Text(
                    'Belum ada perhitungan',
                    style: TextStyle(
                      fontSize: s(16),
                      color: colorTextPrimary,
                    ),
                  ),
                  SizedBox(height: s(24)),
                  ElevatedButton.icon(
                    onPressed: () => provider.hitungSAW(),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Hitung SAW'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: colorWhite,
                    ),
                  ),
                ],
              ),
            );
          }

          // Tampilkan hasil SAW
          final hasil = provider.hasilSAW!;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
              child: ListView(
                children: [
                  // Info Card
                  _infoCard(
                    s,
                    colorWhite,
                    shadowColor,
                    colorSuccess,
                    'Perhitungan SAW berhasil! Ditemukan ${hasil.dataAlternatif.length} alternatif dan ${hasil.namaKriteria.length} kriteria.',
                  ),
                  SizedBox(height: s(10)),

                  // Section 1: Tabel Data Alternatif
                  _Section(
                    title: 'Tabel Data Alternatif',
                    s: s,
                    colorWhite: colorWhite,
                    shadowColor: shadowColor,
                    child: _buildTabelDataAlternatif(hasil, s),
                  ),

                  // Section 2: Tabel Matriks Keputusan
                  _Section(
                    title: 'Tabel Matriks Keputusan',
                    s: s,
                    colorWhite: colorWhite,
                    shadowColor: shadowColor,
                    child: _buildTabelMatriksKeputusan(hasil, s),
                  ),

                  // Section 3: Tabel Normalisasi
                  _Section(
                    title: 'Tabel Matriks Ternormalisasi',
                    s: s,
                    colorWhite: colorWhite,
                    shadowColor: shadowColor,
                    child: _buildTabelNormalisasi(hasil, s),
                  ),

                  // Section 4: Tabel Hasil Normalisasi × Bobot
                  _Section(
                    title: 'Tabel Hasil Normalisasi × Bobot',
                    s: s,
                    colorWhite: colorWhite,
                    shadowColor: shadowColor,
                    child: _buildTabelTerbobot(hasil, s),
                  ),

                  // Section 5: Tabel Perhitungan Ranking
                  _Section(
                    title: 'Tabel Perhitungan Nilai Preferensi',
                    s: s,
                    colorWhite: colorWhite,
                    shadowColor: shadowColor,
                    child: _buildTabelPreferensi(hasil, s),
                  ),

                  // Section 6: Tabel Hasil Ranking
                  _Section(
                    title: 'Perangkingan Kost',
                    s: s,
                    colorWhite: colorWhite,
                    shadowColor: shadowColor,
                    child: _buildTabelRanking(hasil, s),
                  ),

                  SizedBox(height: s(18)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget untuk info card sukses
  Widget _infoCard(
    double Function(double) s,
    Color colorWhite,
    Color shadowColor,
    Color colorIcon,
    String text,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(s(14)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: s(10),
            offset: Offset(0, s(4)),
          ),
        ],
      ),
      padding: EdgeInsets.all(s(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: colorIcon, size: s(20)),
          SizedBox(width: s(10)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: s(12), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Tabel Data Alternatif (Data Mentah)
  Widget _buildTabelDataAlternatif(HasilSAW hasil, double Function(double) s) {
    // Kolom: Kode, Keterangan, lalu kriteria
    List<String> columns = ['Kode', 'Keterangan'];
    for (int i = 0; i < hasil.namaKriteria.length; i++) {
      columns.add('C${i + 1}');
    }

    // Baris data - tampilkan data MENTAH
    List<List<String>> rows = [];
    for (var alt in hasil.dataAlternatif) {
      List<String> row = [alt.kode, alt.namaKost];
      for (var kriteria in hasil.namaKriteria) {
        // Gunakan nilaiMentah untuk data asli
        var nilai = alt.nilaiMentah[kriteria] ?? '-';
        row.add(nilai.toString());
      }
      rows.add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Keterangan kriteria
        _buildKeteranganKriteria(hasil, s),
        SizedBox(height: s(10)),
        // Info bahwa ini data mentah
        Container(
          padding: EdgeInsets.all(s(8)),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(s(6)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: s(14), color: Colors.blue[700]),
              SizedBox(width: s(6)),
              Expanded(
                child: Text(
                  'Tabel ini menampilkan data mentah (asli) dari setiap alternatif kost.',
                  style: TextStyle(fontSize: s(10), color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: s(10)),
        _horizontalTable(
            columns: columns, rows: rows, s: s, isDataMentah: true),
      ],
    );
  }

  /// Build keterangan kriteria
  Widget _buildKeteranganKriteria(HasilSAW hasil, double Function(double) s) {
    return Container(
      padding: EdgeInsets.all(s(10)),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(s(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Keterangan Kriteria:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: s(11),
            ),
          ),
          SizedBox(height: s(6)),
          ...List.generate(hasil.namaKriteria.length, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: s(2)),
              child: Text(
                'C${i + 1} = ${hasil.namaKriteria[i]} (${hasil.atributKriteria[i]}) - Bobot: ${hasil.bobotKriteria[i].toStringAsFixed(4)}',
                style: TextStyle(fontSize: s(10)),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Build Tabel Matriks Keputusan
  Widget _buildTabelMatriksKeputusan(
      HasilSAW hasil, double Function(double) s) {
    List<String> columns = ['Ai'];
    for (int i = 0; i < hasil.namaKriteria.length; i++) {
      columns.add('C${i + 1}');
    }

    List<List<String>> rows = [];
    for (int i = 0; i < hasil.matriksKeputusan.length; i++) {
      List<String> row = [hasil.dataAlternatif[i].kode];
      for (var nilai in hasil.matriksKeputusan[i]) {
        row.add(_formatDouble(nilai));
      }
      rows.add(row);
    }

    return _horizontalTable(columns: columns, rows: rows, s: s);
  }

  /// Build Tabel Normalisasi
  Widget _buildTabelNormalisasi(HasilSAW hasil, double Function(double) s) {
    List<String> columns = ['Ai'];
    for (int i = 0; i < hasil.namaKriteria.length; i++) {
      columns.add('C${i + 1}');
    }

    List<List<String>> rows = [];
    for (int i = 0; i < hasil.matriksNormalisasi.length; i++) {
      List<String> row = [hasil.dataAlternatif[i].kode];
      for (var nilai in hasil.matriksNormalisasi[i]) {
        row.add(nilai.toStringAsFixed(2));
      }
      rows.add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rumus normalisasi
        Container(
          padding: EdgeInsets.all(s(10)),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(s(8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rumus Normalisasi:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: s(11)),
              ),
              SizedBox(height: s(4)),
              Text(
                '• Benefit: rij = xij / max(xj)',
                style: TextStyle(fontSize: s(10)),
              ),
              Text(
                '• Cost: rij = min(xj) / xij',
                style: TextStyle(fontSize: s(10)),
              ),
            ],
          ),
        ),
        SizedBox(height: s(10)),
        _horizontalTable(columns: columns, rows: rows, s: s),
      ],
    );
  }

  /// Build Tabel Terbobot (R × W)
  Widget _buildTabelTerbobot(HasilSAW hasil, double Function(double) s) {
    List<String> columns = ['Ai'];
    for (int i = 0; i < hasil.namaKriteria.length; i++) {
      columns.add('C${i + 1}');
    }

    List<List<String>> rows = [];
    for (int i = 0; i < hasil.matriksTerbobot.length; i++) {
      List<String> row = [hasil.dataAlternatif[i].kode];
      for (var nilai in hasil.matriksTerbobot[i]) {
        row.add(nilai.toStringAsFixed(2));
      }
      rows.add(row);
    }

    return _horizontalTable(columns: columns, rows: rows, s: s);
  }

  /// Build Tabel Preferensi (Perhitungan Ranking)
  Widget _buildTabelPreferensi(HasilSAW hasil, double Function(double) s) {
    List<String> columns = ['Ai'];
    for (int i = 0; i < hasil.namaKriteria.length; i++) {
      columns.add('C${i + 1}');
    }
    columns.add('Total');

    List<List<String>> rows = [];
    for (var pref in hasil.hasilPreferensi) {
      List<String> row = [pref.kode];

      for (var nilai in pref.nilaiPerKriteria) {
        // Tampilkan nilai terbobot per kriteria (dibulatkan untuk UI)
        row.add(nilai.toStringAsFixed(2));
      }

      // Total preferensi harus konsisten dengan nilai yang dipakai untuk ranking
      row.add(pref.totalPreferensi.toStringAsFixed(2));
      rows.add(row);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rumus preferensi
        Container(
          padding: EdgeInsets.all(s(10)),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(s(8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rumus Nilai Preferensi:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: s(11)),
              ),
              SizedBox(height: s(4)),
              Text(
                'Vi = Σ(wj × rij)',
                style: TextStyle(fontSize: s(10), fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        SizedBox(height: s(10)),
        _horizontalTable(columns: columns, rows: rows, s: s),
      ],
    );
  }

  /// Build Tabel Ranking
  Widget _buildTabelRanking(HasilSAW hasil, double Function(double) s) {
    List<String> columns = ['Rank', 'Kode', 'Nama Kost', 'Skor'];

    List<List<String>> rows = [];
    for (var rank in hasil.hasilRanking) {
      rows.add([
        '#${rank.peringkat}',
        rank.kode,
        rank.namaKost,
        rank.skor.toStringAsFixed(2),
      ]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _horizontalTable(columns: columns, rows: rows, s: s, isRanking: true),
        SizedBox(height: s(10)),
        // Kesimpulan
        if (hasil.hasilRanking.isNotEmpty)
          Container(
            padding: EdgeInsets.all(s(12)),
            decoration: BoxDecoration(
              color: const Color(0xFF1C3B98),
              borderRadius: BorderRadius.circular(s(8)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.amber,
                  size: s(24),
                ),
                SizedBox(width: s(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekomendasi Terbaik',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: s(12),
                        ),
                      ),
                      SizedBox(height: s(2)),
                      Text(
                        '${hasil.hasilRanking.first.namaKost} dengan skor ${hasil.hasilRanking.first.skor.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: s(11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Format nilai untuk tampilan
  String _formatNilai(dynamic nilai) {
    if (nilai == null) return '-';
    if (nilai is double) return _formatDouble(nilai);
    if (nilai is int) return nilai.toString();
    return nilai.toString();
  }

  /// Format double untuk tampilan
  String _formatDouble(double nilai) {
    if (nilai == nilai.roundToDouble()) {
      return nilai.toInt().toString();
    }
    return nilai.toStringAsFixed(2);
  }

  /// Widget tabel horizontal dengan scroll
  Widget _horizontalTable({
    required List<String> columns,
    required List<List<String>> rows,
    required double Function(double) s,
    bool isRanking = false,
    bool isDataMentah = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = constraints.maxWidth;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: DataTable(
              columnSpacing: s(12),
              dataRowMinHeight: isDataMentah ? s(50) : s(40),
              dataRowMaxHeight: isDataMentah ? s(80) : s(60),
              headingRowColor: WidgetStateColor.resolveWith(
                (states) => const Color(0xFFE9EEF9),
              ),
              columns: [
                for (final c in columns)
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(vertical: s(6)),
                      child: Text(
                        c,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: s(11),
                        ),
                      ),
                    ),
                  ),
              ],
              rows: [
                for (int i = 0; i < rows.length; i++)
                  DataRow(
                    color: isRanking && i == 0
                        ? WidgetStateColor.resolveWith(
                            (states) => const Color(0xFFFFF8E1),
                          )
                        : null,
                    cells: [
                      for (final v in rows[i])
                        DataCell(
                          Container(
                            constraints: BoxConstraints(
                                maxWidth: isDataMentah ? s(150) : s(100)),
                            child: Text(
                              v,
                              style: TextStyle(
                                fontSize: isDataMentah ? s(10) : s(11),
                                fontWeight: isRanking && i == 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: isDataMentah ? 4 : 2,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget Section untuk container dengan judul
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final double Function(double) s;
  final Color colorWhite;
  final Color shadowColor;

  const _Section({
    required this.title,
    required this.child,
    required this.s,
    required this.colorWhite,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    const Color colorTextPrimary = Color(0xFF1F1F1F);
    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(s(14)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: s(10),
            offset: Offset(0, s(4)),
          ),
        ],
      ),
      padding: EdgeInsets.all(s(14)),
      margin: EdgeInsets.only(bottom: s(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: s(14),
              color: colorTextPrimary,
            ),
          ),
          SizedBox(height: s(10)),
          child,
        ],
      ),
    );
  }
}
