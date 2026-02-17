import 'package:flutter/material.dart';

class DashboardIncome extends StatefulWidget {
  static const arah = "/dashboard-pemilik";
  const DashboardIncome({super.key});

  @override
  State<DashboardIncome> createState() => _DashboardIncomeState();
}

class _DashboardIncomeState extends State<DashboardIncome> {
  // Palet warna konsisten dengan halaman lain (UI saja)
  static const Color warnaLatar = Color(0xFFF5F7FB);
  static const Color warnaKartu = Colors.white;
  static const Color warnaUtama = Color(0xFF1E3A8A);

  // Data contoh per kost (UI saja)
  final List<_KostData> _kostList = [
    _KostData(
      nama: "Kost Mawar",
      totalKamar: 30,
      terisi: 24,
      incomeTahunan: const [
        _MonthlyIncome("Jan", 3500000),
        _MonthlyIncome("Feb", 3600000),
        _MonthlyIncome("Mar", 3700000),
        _MonthlyIncome("Apr", 3800000),
        _MonthlyIncome("Mei", 3900000),
        _MonthlyIncome("Jun", 4000000),
        _MonthlyIncome("Jul", 4100000),
        _MonthlyIncome("Agu", 4200000),
        _MonthlyIncome("Sep", 4300000),
        _MonthlyIncome("Okt", 4400000),
        _MonthlyIncome("Nov", 4500000),
        _MonthlyIncome("Des", 4600000),
      ],
    ),
    _KostData(
      nama: "Kost Anggrek",
      totalKamar: 20,
      terisi: 15,
      incomeTahunan: const [
        _MonthlyIncome("Jan", 2500000),
        _MonthlyIncome("Feb", 2600000),
        _MonthlyIncome("Mar", 2550000),
        _MonthlyIncome("Apr", 2700000),
        _MonthlyIncome("Mei", 2800000),
        _MonthlyIncome("Jun", 2900000),
        _MonthlyIncome("Jul", 3000000),
        _MonthlyIncome("Agu", 3100000),
        _MonthlyIncome("Sep", 3200000),
        _MonthlyIncome("Okt", 3300000),
        _MonthlyIncome("Nov", 3400000),
        _MonthlyIncome("Des", 3500000),
      ],
    ),
    _KostData(
      nama: "Kost Melati",
      totalKamar: 10,
      terisi: 9,
      incomeTahunan: const [
        _MonthlyIncome("Jan", 1800000),
        _MonthlyIncome("Feb", 1900000),
        _MonthlyIncome("Mar", 2000000),
        _MonthlyIncome("Apr", 2100000),
        _MonthlyIncome("Mei", 2200000),
        _MonthlyIncome("Jun", 2300000),
        _MonthlyIncome("Jul", 2400000),
        _MonthlyIncome("Agu", 2500000),
        _MonthlyIncome("Sep", 2600000),
        _MonthlyIncome("Okt", 2700000),
        _MonthlyIncome("Nov", 2800000),
        _MonthlyIncome("Des", 2900000),
      ],
    ),
  ];

  int _selectedKostIndex = 0;
  _KostData get _selectedKost => _kostList[_selectedKostIndex];

  double get _totalPendapatanTahunan =>
      _selectedKost.incomeTahunan.fold(0.0, (sum, e) => sum + e.value);
  int get totalKamar => _selectedKost.totalKamar;
  int get kamarTerisi => _selectedKost.terisi;
  int get kamarKosong => totalKamar - kamarTerisi;
  double get tingkatHunian => kamarTerisi / totalKamar; // 0..1

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: warnaLatar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05,
            vertical: size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header ala halaman daftar kost (tanpa AppBar)
              _HeaderBar(
                title: "Dashboard Income",
                subtitle: "Ringkasan pendapatan tahunan & okupansi",
                warnaUtama: warnaUtama,
              ),

              SizedBox(height: size.height * 0.02),

              // Kost selector (card + bottom sheet picker)
              _KostSelectorCard(
                namaKost: _selectedKost.nama,
                totalKamar: totalKamar,
                terisi: kamarTerisi,
                warnaUtama: warnaUtama,
                onTap: _showKostPicker,
              ),

              const SizedBox(height: 14),

              // Hero card pendapatan tahunan (lebih menonjol)
              _HeroIncomeCard(
                title: "Pendapatan Tahunan",
                nilai: _formatRupiah(_totalPendapatanTahunan),
                warnaUtama: warnaUtama,
                namaKost: _selectedKost.nama,
              ),
              const SizedBox(height: 14),
              _InfoStatCard(
                icon: Icons.meeting_room_outlined,
                title: "Kamar Terisi",
                value: "$kamarTerisi dari $totalKamar",
                warnaUtama: warnaUtama,
              ),
              const SizedBox(height: 14),
              _InfoStatCard(
                icon: Icons.door_back_door,
                title: "Kamar Kosong",
                value: "$kamarKosong dari $totalKamar",
                warnaUtama: warnaUtama,
              ),

              const SizedBox(height: 20),

              // Tingkat hunian (opsional untuk visual tambahan)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: warnaKartu,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tingkat Hunian",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: tingkatHunian,
                        minHeight: 12,
                        valueColor: AlwaysStoppedAnimation(warnaUtama),
                        backgroundColor: const Color(0xFFDDE6FF),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${(tingkatHunian * 100).toStringAsFixed(0)}% terisi",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ChipStat(
                            label: "Terisi",
                            value: "$kamarTerisi kamar",
                            warna: warnaUtama),
                        _ChipStat(
                            label: "Kosong",
                            value: "$kamarKosong kamar",
                            warna: const Color(0xFFEF4444)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Rincian Bulanan (vertikal)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: warnaKartu,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rincian Bulanan",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._selectedKost.incomeTahunan.map((m) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDDE6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  m.label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E3A8A),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _formatRupiah(m.value),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: const Color(0xFF93C5FD)),
                                ),
                                child: const Text(
                                  "Terkumpul",
                                  style: TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showKostPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.home_work_outlined, color: Colors.black54),
                  SizedBox(width: 8),
                  Text(
                    "Pilih Kost",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _kostList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = _kostList[i];
                    final hunian =
                        (item.terisi / item.totalKamar).clamp(0.0, 1.0);
                    final totalTahunan =
                        item.incomeTahunan.fold(0.0, (sum, e) => sum + e.value);
                    final aktif = i == _selectedKostIndex;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => _selectedKostIndex = i);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: aktif ? warnaUtama : const Color(0xFFE6EAF2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: const BoxDecoration(
                                color: Color(0xFFDDE6FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.house_outlined,
                                  color: Color(0xFF1E3A8A)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.nama,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (aktif)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: const Color(0xFF93C5FD)),
                                          ),
                                          child: const Text(
                                            "Terpilih",
                                            style: TextStyle(
                                              color: Color(0xFF1E3A8A),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.payments_outlined,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        _formatRupiah(totalTahunan),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.people_outline,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${item.terisi}/${item.totalKamar} kamar",
                                        style: const TextStyle(
                                            color: Colors.black54),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: LinearProgressIndicator(
                                            value: hunian,
                                            minHeight: 8,
                                            valueColor: AlwaysStoppedAnimation(
                                                warnaUtama),
                                            backgroundColor:
                                                const Color(0xFFDDE6FF),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
  }

  String _formatRupiah(double value) {
    return "Rp " +
        value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
              (m) => "${m[1]}.",
            );
  }
}

// Header in-body ala halaman daftar kost
class _HeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Color warnaUtama;

  const _HeaderBar({
    required this.title,
    this.subtitle,
    required this.warnaUtama,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13.5,
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}

// Kartu info vertikal (tidak mepet)
class _InfoStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color warnaUtama;

  const _InfoStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.warnaUtama,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: warnaUtama.withOpacity(0.9), width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: warnaUtama,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroIncomeCard extends StatelessWidget {
  final String title;
  final String nilai;
  final String namaKost;
  final Color warnaUtama;

  const _HeroIncomeCard({
    required this.title,
    required this.nilai,
    required this.warnaUtama,
    required this.namaKost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [warnaUtama, const Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.stacked_line_chart, color: warnaUtama),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nilai,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.home_work_outlined,
                        color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        namaKost,
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipStat extends StatelessWidget {
  final String label;
  final String value;
  final Color warna;

  const _ChipStat({
    required this.label,
    required this.value,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: warna.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: warna),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: warna, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _KostData {
  final String nama;
  final int totalKamar;
  final int terisi;
  final List<_MonthlyIncome> incomeTahunan;

  const _KostData({
    required this.nama,
    required this.totalKamar,
    required this.terisi,
    required this.incomeTahunan,
  });
}

class _MonthlyIncome {
  final String label;
  final double value;
  const _MonthlyIncome(this.label, this.value);
}

class _KostSelectorCard extends StatelessWidget {
  final String namaKost;
  final int totalKamar;
  final int terisi;
  final Color warnaUtama;
  final VoidCallback onTap;

  const _KostSelectorCard({
    required this.namaKost,
    required this.totalKamar,
    required this.terisi,
    required this.warnaUtama,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hunian = (terisi / totalKamar).clamp(0.0, 1.0);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFFDDE6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.home_work_outlined,
                  color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          namaKost,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF93C5FD)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.swap_vert,
                                size: 14, color: Color(0xFF1E3A8A)),
                            SizedBox(width: 4),
                            Text(
                              "Ubah",
                              style: TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        "$terisi/$totalKamar kamar",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: hunian,
                      minHeight: 8,
                      valueColor: AlwaysStoppedAnimation(warnaUtama),
                      backgroundColor: const Color(0xFFDDE6FF),
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
