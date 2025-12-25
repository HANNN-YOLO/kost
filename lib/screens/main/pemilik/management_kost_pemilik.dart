import 'package:flutter/material.dart';

class ManagementKostPemilik extends StatefulWidget {
  static const arah = "/management-board-pemilik";
  const ManagementKostPemilik({super.key});

  @override
  State<ManagementKostPemilik> createState() => _ManagementKostPemilikState();
}

class _ManagementKostPemilikState extends State<ManagementKostPemilik> {
  // Sample data (UI only, no backend)
  final List<_OwnerKost> _kostSaya = [
    _OwnerKost(
      nama: "Kost Mawar",
      lokasi: "Jl. Melati No. 12",
      harga: "Rp 1.200.000 / bulan",
      gambar:
          "https://images.unsplash.com/photo-1560185127-2e2a61fabe27?w=600&auto=format&fit=crop",
      pemasukanBulanIni: 3600000,
    ),
    _OwnerKost(
      nama: "Kost Anggrek",
      lokasi: "Jl. Kenanga No. 5",
      harga: "Rp 900.000 / bulan",
      gambar:
          "https://images.unsplash.com/photo-1582582621955-7e8f7f884a87?w=600&auto=format&fit=crop",
      pemasukanBulanIni: 1800000,
    ),
  ];

  double get _totalPemasukan =>
      _kostSaya.fold(0.0, (sum, e) => sum + e.pemasukanBulanIni);

  static const Color warnaLatar = Color(0xFFF5F7FB);
  static const Color warnaKartu = Colors.white;
  static const Color warnaUtama = Color(0xFF1E3A8A);
  static const Color aksenBiru = Color(0xFF007BFF);

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: warnaLatar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: lebarLayar * 0.05,
            vertical: tinggiLayar * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header modern + tombol tambah
              _HeaderBar(
                title: "Daftar Kost",
                subtitle: "Kelola properti kost milik Anda",
                onAdd: _bukaFormTambah,
                warnaUtama: warnaUtama,
              ),

              SizedBox(height: tinggiLayar * 0.02),

              // Ringkasan
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Icons.other_houses,
                      label: "Total Kost Anda",
                      value: "${_kostSaya.length}",
                      lebarLayar: lebarLayar,
                    ),
                  ),
                ],
              ),

              SizedBox(height: tinggiLayar * 0.02),

              // Daftar langsung tanpa filter

              SizedBox(height: tinggiLayar * 0.01),

              // Daftar kost
              Expanded(
                child: _kostSaya.isEmpty
                    ? Center(
                        child: Text(
                          "Belum ada kost terdaftar",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _kostSaya.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: tinggiLayar * 0.02),
                        itemBuilder: (context, index) {
                          final item = _kostSaya[index];
                          return _OwnerKostCard(
                            item: item,
                            onEdit: _tombolBelumTersedia,
                            onDelete: _tombolBelumTersedia,
                            onTap: _tombolBelumTersedia,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _tombolBelumTersedia() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fitur belum diaktifkan"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _bukaFormTambah() {
    // Gunakan rootNavigator agar menggunakan routes dari MaterialApp utama
    Navigator.of(context, rootNavigator: true)
        .pushNamed('/form-add-house-pemilik');
  }

  String _formatRupiah(double value) {
    // Simple formatter for display only
    return "Rp " +
        value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
              (m) => "${m[1]}.",
            );
  }
}

class _OwnerKostCard extends StatelessWidget {
  final _OwnerKost item;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const _OwnerKostCard({
    required this.item,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lebarLayar = MediaQuery.of(context).size.width;
    final double tinggiGambar = lebarLayar < 480 ? lebarLayar * 0.42 : 220;

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
            // Banner gambar
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      item.gambar,
                      width: double.infinity,
                      height: tinggiGambar,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE5ECFF),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Label harga
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDDE6FF).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sell_outlined,
                              size: 18, color: Color(0xFF1E3A8A)),
                          const SizedBox(width: 6),
                          Text(
                            item.harga,
                            style: const TextStyle(
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Konten
            Padding(
              padding: EdgeInsets.all(lebarLayar * 0.035),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nama,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.lokasi,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Aksi ringkas
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MiniIconBtn(
                              icon: Icons.edit_outlined,
                              label: "Edit",
                              onTap: onEdit),
                          const SizedBox(width: 6),
                          _MiniIconBtn(
                              icon: Icons.delete_outline,
                              label: "Hapus",
                              onTap: onDelete,
                              danger: true),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Chip pemasukan
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5ECFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Pemasukan bulan ini: ${_formatRupiah(item.pemasukanBulanIni)}",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
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

  String _formatRupiah(double value) {
    return "Rp " +
        value.toStringAsFixed(0).replaceAllMapped(
              RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
              (m) => "${m[1]}.",
            );
  }
}

class _HeaderBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onAdd;
  final Color warnaUtama;

  const _HeaderBar({
    required this.title,
    this.subtitle,
    this.onAdd,
    required this.warnaUtama,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onAdd,
            child: Container(
              width: size.width * 0.12,
              height: size.width * 0.12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.add, color: warnaUtama),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onFilter;

  const _SearchBar({
    required this.controller,
    this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded(
        //   child: TextField(
        //     controller: controller,
        //     decoration: InputDecoration(
        //       hintText: "Cari kost...",
        //       prefixIcon: const Icon(Icons.search, color: Colors.black54),
        //       filled: true,
        //       fillColor: const Color(0xFFF5F7FB),
        //       contentPadding: const EdgeInsets.symmetric(vertical: 14),
        //       border: OutlineInputBorder(
        //         borderRadius: BorderRadius.circular(12),
        //         borderSide: BorderSide.none,
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(width: 10),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onFilter,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: const Icon(Icons.tune, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  final int index;
  final ValueChanged<int>? onChanged;
  final Color warnaUtama;

  const _FilterChips({
    required this.index,
    required this.onChanged,
    required this.warnaUtama,
  });

  @override
  Widget build(BuildContext context) {
    final opsi = const ["Semua", "Aktif", "Nonaktif"];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, i) {
          final aktif = i == index;
          return InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => onChanged?.call(i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: aktif ? const Color(0xFFDDE6FF) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: aktif ? warnaUtama : const Color(0xFFE6EAF2),
                ),
                boxShadow: aktif
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Text(
                opsi[i],
                style: TextStyle(
                  color: aktif ? warnaUtama : Colors.black87,
                  fontWeight: aktif ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: opsi.length,
      ),
    );
  }
}

class _MiniIconBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;

  const _MiniIconBtn({
    required this.icon,
    required this.label,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : const Color(0xFF1E3A8A);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
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

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _InputField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF5F7FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OwnerKost {
  final String nama;
  final String lokasi;
  final String harga;
  final String gambar;
  final double pemasukanBulanIni;

  _OwnerKost({
    required this.nama,
    required this.lokasi,
    required this.harga,
    required this.gambar,
    required this.pemasukanBulanIni,
  });
}
