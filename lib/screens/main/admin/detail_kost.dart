import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom/satu_tombol.dart';
import '../../../providers/kost_provider.dart';

class DetailKost extends StatelessWidget {
  static const arah = "detail-kost-admin";

  static const Color warnaUtama = Color(0xFF1E3A8A);
  static const Color warnaLatar = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    final terima = ModalRoute.of(context)?.settings.arguments as int;
    final pakai = Provider.of<KostProvider>(context)
        .kost
        .firstWhere((element) => element.id_kost == terima);

    return Scaffold(
      backgroundColor: warnaLatar,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailHeader(
              imageUrl: pakai.gambar_kost,
              price: pakai.harga_kost?.toString() ?? '-',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pakai.nama_kost ?? '-',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          pakai.alamat_kost ?? '-',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: Icons.sell_outlined,
                        label: 'Harga',
                        value: pakai.harga_kost?.toString() ?? '-',
                      ),
                      _StatChip(
                        icon: Icons.king_bed_outlined,
                        label: 'Ukuran',
                        value: "${pakai.panjang} x ${pakai.lebar}",
                      ),
                      _StatChip(
                        icon: Icons.home_work_outlined,
                        label: 'Jenis',
                        value: pakai.jenis_kost ?? '-',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Informasi Umum',
                    children: [
                      _InfoTile(
                          icon: Icons.person_outline,
                          label: 'Pemilik',
                          value: pakai.pemilik_kost ?? '-'),
                      _InfoTile(
                          icon: Icons.phone_outlined,
                          label: 'Kontak',
                          value: pakai.notlp_kost?.toString() ?? '-'),
                      _InfoTile(
                          icon: Icons.king_bed_outlined,
                          label: 'Ukuran Kamar',
                          value: "${pakai.panjang} x ${pakai.lebar}"),
                      _InfoTile(
                          icon: Icons.home_work_outlined,
                          label: 'Jenis Kost',
                          value: pakai.jenis_kost ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Fasilitas & Utilitas',
                    children: [
                      _InfoTile(
                          icon: Icons.flash_on_outlined,
                          label: 'Jenis Listrik',
                          value: pakai.jenis_listrik ?? '-'),
                      _InfoTile(
                          icon: Icons.water_drop_outlined,
                          label: 'Pembayaran Air',
                          value: pakai.jenis_pembayaran_air ?? '-'),
                      _InfoTile(
                          icon: Icons.security_outlined,
                          label: 'Keamanan',
                          value: pakai.keamanan ?? '-'),
                      _FacilityChips(
                        label: 'Fasilitas',
                        icon: Icons.list_alt_outlined,
                        raw: pakai.id_fasilitas?.toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SatuTombol(
            warna: warnaUtama,
            fungsi: () => Navigator.of(context).pop(),
            label: "Kembali",
          ),
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final String? imageUrl;
  final String price;

  const _DetailHeader({
    required this.imageUrl,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFE5ECFF),
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined,
                    color: Colors.grey, size: 34),
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sell_outlined,
                    size: 18, color: Color(0xFF1E3A8A)),
                const SizedBox(width: 6),
                Text(
                  price,
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE6FF),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF1E3A8A)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5ECFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF1E3A8A)),
          const SizedBox(width: 6),
          Text(
            "$label: $value",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityChips extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? raw;

  const _FacilityChips({
    required this.label,
    required this.icon,
    required this.raw,
  });

  List<String> _tokens(String? s) {
    if (s == null) return [];
    final trimmed = s.trim();
    if (trimmed.isEmpty || trimmed == '-') return [];
    return trimmed
        .split(RegExp(r'[|,;]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _tokens(raw);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFDDE6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF1E3A8A)),
            ),
            const SizedBox(width: 10),
            const Text(
              'Fasilitas',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text(
            '-',
            style: TextStyle(fontWeight: FontWeight.w700),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map(
                  (e) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: const Color(0xFF1E3A8A).withOpacity(0.25)),
                    ),
                    child: Text(
                      e,
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
