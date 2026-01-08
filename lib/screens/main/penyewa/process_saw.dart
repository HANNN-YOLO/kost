import 'package:flutter/material.dart';

class ProcessSawPage extends StatelessWidget {
  const ProcessSawPage({super.key});

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
          'Perhitungan SAW',
          style:
              TextStyle(color: colorTextPrimary, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
          child: ListView(
            children: [
              _hintCard(
                s,
                colorWhite,
                shadowColor,
                colorPrimary,
                'Ini hanya UI pratinjau. Data akan diisi dari hasil perhitungan SAW saat fungsi siap.',
              ),
              SizedBox(height: s(10)),
              _Section(
                title: 'Tabel Matriks Keputusan',
                s: s,
                colorWhite: colorWhite,
                shadowColor: shadowColor,
                child: _horizontalTable(
                  columns: const ['Alternatif', 'C1', 'C2', 'C3', 'C4', 'C5'],
                  rows: const [
                    ['A1', '4', '800rb', '2', '1km', 'Ada'],
                    ['A2', '3', '700rb', '3', '1.5km', 'Tidak'],
                    ['A3', '5', '950rb', '2', '0.5km', 'Ada'],
                    ['A4', '3', '650rb', '4', '1.8km', 'Ada'],
                  ],
                  s: s,
                ),
              ),
              _Section(
                title: 'Tabel Normalisasi',
                s: s,
                colorWhite: colorWhite,
                shadowColor: shadowColor,
                child: _horizontalTable(
                  columns: const ['Alternatif', 'r1', 'r2', 'r3', 'r4', 'r5'],
                  rows: const [
                    ['A1', '0.80', '0.82', '0.67', '0.67', '1.00'],
                    ['A2', '0.60', '1.00', '0.50', '0.44', '0.50'],
                    ['A3', '1.00', '0.74', '0.67', '1.00', '1.00'],
                    ['A4', '0.60', '1.08', '1.00', '0.28', '1.00'],
                  ],
                  s: s,
                ),
              ),
              _Section(
                title: 'Tabel Hasil Normalisasi × Bobot',
                s: s,
                colorWhite: colorWhite,
                shadowColor: shadowColor,
                child: _horizontalTable(
                  columns: const [
                    'Alternatif',
                    'w1*r1',
                    'w2*r2',
                    'w3*r3',
                    'w4*r4',
                    'w5*r5'
                  ],
                  rows: const [
                    ['A1', '0.20', '0.25', '0.10', '0.07', '0.15'],
                    ['A2', '0.15', '0.30', '0.08', '0.05', '0.08'],
                    ['A3', '0.25', '0.22', '0.10', '0.15', '0.15'],
                    ['A4', '0.15', '0.32', '0.15', '0.04', '0.15'],
                  ],
                  s: s,
                ),
              ),
              _Section(
                title: 'Menghitung Nilai Preferensi (per kriteria)',
                s: s,
                colorWhite: colorWhite,
                shadowColor: shadowColor,
                child: _horizontalTable(
                  columns: const ['Alternatif', 'C1', 'C2', 'C3', 'C4', 'C5'],
                  rows: const [
                    ['A1', '0.20', '0.25', '0.10', '0.07', '0.15'],
                    ['A2', '0.15', '0.30', '0.08', '0.05', '0.08'],
                    ['A3', '0.25', '0.22', '0.10', '0.15', '0.15'],
                    ['A4', '0.15', '0.32', '0.15', '0.04', '0.15'],
                  ],
                  s: s,
                ),
              ),
              _Section(
                title: 'Tabel Hasil Preferensi (Σ bobot×normalisasi)',
                s: s,
                colorWhite: colorWhite,
                shadowColor: shadowColor,
                child: _horizontalTable(
                  columns: const ['Alternatif', 'Nilai Preferensi'],
                  rows: const [
                    ['A1', '0.77'],
                    ['A2', '0.66'],
                    ['A3', '0.87'],
                    ['A4', '0.81'],
                  ],
                  s: s,
                ),
              ),
              _Section(
                title: 'Total Nilai Preferensi',
                s: s,
                colorWhite: colorWhite,
                shadowColor: shadowColor,
                child: _horizontalTable(
                  columns: const ['Alternatif', 'Total'],
                  rows: const [
                    ['A1', '0.770'],
                    ['A2', '0.660'],
                    ['A3', '0.870'],
                    ['A4', '0.810'],
                  ],
                  s: s,
                ),
              ),
              _Section(
                title: 'Perangkingan Kost',
                s: s,
                colorWhite: colorWhite,
                shadowColor: shadowColor,
                child: _horizontalTable(
                  columns: const [
                    'Peringkat',
                    'Alternatif',
                    'Nama Kost',
                    'Skor'
                  ],
                  rows: const [
                    ['#1', 'A3', 'Kost Kenanga', '0.870'],
                    ['#2', 'A4', 'Kost Sakura', '0.810'],
                    ['#3', 'A1', 'Kost Melati Putih', '0.770'],
                    ['#4', 'A2', 'Kost Mawar Asri', '0.660'],
                  ],
                  s: s,
                ),
              ),
              SizedBox(height: s(18)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hintCard(
    double Function(double) s,
    Color colorWhite,
    Color shadowColor,
    Color colorPrimary,
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
          Icon(Icons.info_outline, color: colorPrimary, size: s(20)),
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

  Widget _horizontalTable({
    required List<String> columns,
    required List<List<String>> rows,
    required double Function(double) s,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth =
            constraints.maxWidth; // ensure table at least full width
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: minWidth),
            child: DataTable(
              columnSpacing: s(16),
              headingRowColor: MaterialStateColor.resolveWith(
                (states) => const Color(0xFFE9EEF9),
              ),
              columns: [
                for (final c in columns)
                  DataColumn(
                    label: Padding(
                      padding: EdgeInsets.symmetric(vertical: s(8)),
                      child: Text(
                        c,
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: s(12)),
                      ),
                    ),
                  ),
              ],
              rows: [
                for (final r in rows)
                  DataRow(
                    cells: [
                      for (final v in r)
                        DataCell(
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: s(8)),
                            child: Text(
                              v,
                              style: TextStyle(fontSize: s(12)),
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
