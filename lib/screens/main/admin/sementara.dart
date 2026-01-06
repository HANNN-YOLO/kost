import 'package:flutter/material.dart';

class SubcriteriaItem {
  final String nama;
  final double bobot;

  SubcriteriaItem({
    required this.nama,
    required this.bobot,
  });
}

class Sementara extends StatefulWidget {
  static const arah = "/subcriteria-admin";
  const Sementara({super.key});

  @override
  State<Sementara> createState() => _SementaraState();
}

class _SementaraState extends State<Sementara> {
  // Data contoh agar tabel terlihat hidup (tidak terhubung backend)
  final List<String> _kriteriaList = const [
    "Fasilitas",
    "Luas kamar",
    "Keamanan",
    "Harga",
  ];

  String _selectedKriteria = "Fasilitas";
  String _query = "";

  final Map<String, List<SubcriteriaItem>> _subMap = {
    "Fasilitas": [
      SubcriteriaItem(nama: "AC", bobot: 0.25),
      SubcriteriaItem(nama: "Kamar mandi dalam", bobot: 0.30),
      SubcriteriaItem(nama: "Wifi", bobot: 0.20),
    ],
    "Luas kamar": [
      SubcriteriaItem(nama: ">= 3x4m", bobot: 0.40),
      SubcriteriaItem(nama: "< 3x4m", bobot: 0.10),
    ],
    "Keamanan": [
      SubcriteriaItem(nama: "CCTV", bobot: 0.35),
      SubcriteriaItem(nama: "Satpam", bobot: 0.25),
    ],
    "Harga": [
      SubcriteriaItem(nama: "< Rp1jt", bobot: 0.40),
      SubcriteriaItem(nama: "> Rp1,5jt", bobot: 0.10),
    ],
  };

  // Warna dan gaya mengikuti halaman lain
  static const Color _warnaLatar = Color(0xFFF5F7FB);
  static const Color _warnaKartu = Colors.white;
  static const Color _warnaUtama = Color(0xFF1E3A8A);

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    final items = (_subMap[_selectedKriteria] ?? [])
        .where((e) => e.nama.toLowerCase().contains(_query.toLowerCase()))
        .toList();

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
              // Header + tombol tambah
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Manajemen Subkriteria SAW",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: _bukaFormTambah,
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
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add, color: Colors.black87),
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
                    child: _InfoCard(
                      icon: Icons.category_outlined,
                      label: "Terpilih",
                      value: _selectedKriteria,
                      lebarLayar: lebarLayar,
                    ),
                  ),
                  SizedBox(width: lebarLayar * 0.04),
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.list_alt_outlined,
                      label: "Subkriteria",
                      value: "${items.length}",
                      lebarLayar: lebarLayar,
                    ),
                  ),
                ],
              ),

              SizedBox(height: tinggiLayar * 0.03),

              // Kartu pilih kriteria
              _buildPilihKriteriaCard(lebarLayar, tinggiLayar),

              SizedBox(height: tinggiLayar * 0.02),

              // Kartu tabel subkriteria
              Expanded(
                child: _buildTabelCard(lebarLayar, tinggiLayar, items),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPilihKriteriaCard(double lebarLayar, double tinggiLayar) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _warnaKartu,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: lebarLayar * 0.04,
          vertical: tinggiLayar * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Kriteria",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            SizedBox(height: tinggiLayar * 0.012),
            DropdownButtonFormField<String>(
              value: _selectedKriteria,
              items: _kriteriaList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedKriteria = val);
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFE5ECFF),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabelCard(
    double lebarLayar,
    double tinggiLayar,
    List<SubcriteriaItem> items,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _warnaKartu,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: lebarLayar * 0.02,
          vertical: tinggiLayar * 0.015,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: const Text(
                    "Daftar Subkriteria",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Cari subkriteria...",
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ],
            ),
            SizedBox(height: tinggiLayar * 0.015),
            Container(height: 1, color: Colors.grey.shade300),
            SizedBox(height: tinggiLayar * 0.015),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada subkriteria",
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: tinggiLayar * 0.012),
                      itemBuilder: (context, index) {
                        return _buildSubItem(
                          lebarLayar,
                          tinggiLayar,
                          items[index],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _tombolBelumTersedia() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fitur CRUD belum diaktifkan"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSubItem(
    double lebarLayar,
    double tinggiLayar,
    SubcriteriaItem item,
  ) {
    const Color warnaItem = Color(0xFFE5ECFF);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: tinggiLayar * 0.018,
        horizontal: lebarLayar * 0.04,
      ),
      decoration: BoxDecoration(
        color: warnaItem,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nama,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Bobot: ${item.bobot.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: "Ubah (simulasi)",
                onPressed: _tombolBelumTersedia,
                icon: Icon(
                  Icons.edit,
                  color: Colors.green,
                  size: lebarLayar * 0.060,
                ),
              ),
              SizedBox(width: lebarLayar * 0.015),
              IconButton(
                tooltip: "Hapus (simulasi)",
                onPressed: _tombolBelumTersedia,
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: lebarLayar * 0.060,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _bukaFormTambah() {
    final namaController = TextEditingController();
    final bobotController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Tambah Subkriteria",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaController,
                decoration: InputDecoration(
                  labelText: "Nama Subkriteria",
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bobotController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Bobot (0-1)",
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              // Atribut dihilangkan dari form sesuai permintaan
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _warnaUtama,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Simulasi: Subkriteria belum disimpan"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double lebarLayar;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.lebarLayar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: lebarLayar * 0.04,
        vertical: lebarLayar * 0.03,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: lebarLayar * 0.10,
            height: lebarLayar * 0.10,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A)),
          ),
          SizedBox(width: lebarLayar * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
