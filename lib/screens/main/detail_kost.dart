import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../custom/satu_tombol.dart';
import '../../providers/kost_provider.dart';
import '../../models/kost_model.dart';
import '../../models/fasilitas_model.dart';

class DetailKost extends StatelessWidget {
  static const arah = "detail-kost";

  static const Color warnaUtama = Color(0xFF1E3A8A);
  static const Color warnaLatar = Color(0xFFF5F7FB);

  @override
  Widget build(BuildContext context) {
    final gunakan =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    final terima = gunakan['data_kost'];
    final pakai = gunakan['data_fasilitas'];
    // final terima = {
    //   ModalRoute.of(context)?.settings.arguments as KostModel,
    //   ModalRoute.of(context)?.settings.arguments as int
    // };

    // final terima = ModalRoute.of(context)?.settings.arguments as KostModel;
    // final test = ModalRoute.of(context)?.settings.arguments as FasilitasModel;

    // final pakai = Provider.of<KostProvider>(context).

    // admin
    // final pakai = Provider.of<KostProvider>(context)
    //         .kost
    //         .firstWhere((element) => element.id_kost == terima) ??
    //     Provider.of<KostProvider>(context)
    //         .kostpemilik
    //         .firstWhere((element) => element.id_kost == terima) ??
    //     Provider.of<KostProvider>(context)
    //         .kostpenyewa
    //         .firstWhere((element) => element.id_kost == terima);

    // final cek = Provider.of<KostProvider>(context).faslitas.firstWhere(
    //         (element) => element.id_fasilitas == terima.id_fasilitas) ??
    //     Provider.of<KostProvider>(context).fasilitaspemilik.firstWhere(
    //         (element) => element.id_fasilitas == terima.id_fasilitas) ??
    //     Provider.of<KostProvider>(context).fasilitaspenyewa.firstWhere(
    //         (element) => element.id_fasilitas == terima.id_fasilitas);

    // // pemilik
    // final pakaipemilik = Provider.of<KostProvider>(context)
    //     .kostpemilik
    //     .firstWhere((element) => element.id_kost == terima);
    // final cekpemilik = Provider.of<KostProvider>(context)
    //     .fasilitaspemilik
    //     .firstWhere(
    //         (element) => element.id_fasilitas == pakaipemilik.id_fasilitas);

    // // Penyewa
    // final pakaipenyewa = Provider.of<KostProvider>(context)
    //     .kostpenyewa
    //     .firstWhere((element) => element.id_kost == terima);
    // final cekpenyewa = Provider.of<KostProvider>(context)
    //     .fasilitaspenyewa
    //     .firstWhere(
    //         (element) => element.id_fasilitas == pakaipenyewa.id_fasilitas);

    return Scaffold(
      backgroundColor: warnaLatar,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DetailHeader(
              imageUrl: terima.gambar_kost,
              //  pakai.gambar_kost,
              // pakai != null
              //     ? pakai.gambar_kost.toString()
              //     : pakaipemilik != null
              //         ? pakaipemilik.gambar_kost.toString()
              //         : pakaipenyewa != null
              //             ? pakaipenyewa.gambar_kost.toString()
              //             : "https://i.pinimg.com/originals/98/1d/6b/981d6b2e0ccb5e968a0618c8d47671da.jpg",
              //
              price: terima.harga_kost.toString(),
              // pakai.harga_kost?.toString() ?? '-',
              // pakai != null
              //     ? pakai.harga_kost.toString()
              //     : pakaipemilik != null
              //         ? pakaipemilik.harga_kost.toString()
              //         : pakaipenyewa != null
              //             ? pakaipenyewa.harga_kost.toString()
              //             : "0",
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    terima.nama_kost ?? "-",
                    // pakai.nama_kost ?? '-',
                    // pakai != null
                    //     ? pakai.nama_kost.toString()
                    //     : pakaipemilik != null
                    //         ? pakaipemilik.nama_kost.toString()
                    //         : pakaipenyewa != null
                    //             ? pakaipenyewa.nama_kost.toString()
                    //             : "-",
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
                          terima.alamat_kost ?? "-",
                          // pakai.alamat_kost ?? '-',
                          // pakai != null
                          //     ? pakai.alamat_kost.toString()
                          //     : pakaipemilik != null
                          //         ? pakaipemilik.alamat_kost.toString()
                          //         : pakaipenyewa != null
                          //             ? pakaipenyewa.alamat_kost.toString()
                          //             : "-",
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
                        value: terima.harga_kost.toString(),
                        // pakai.harga_kost?.toString() ?? '-',
                        // pakai != null
                        //     ? pakai.harga_kost.toString()
                        //     : pakaipemilik != null
                        //         ? pakaipemilik.harga_kost.toString()
                        //         : pakaipenyewa != null
                        //             ? pakaipenyewa.harga_kost.toString()
                        //             : "0",
                      ),
                      _StatChip(
                          icon: Icons.king_bed_outlined,
                          label: 'Ukuran',
                          value: "${terima.panjang} x ${terima.lebar}"
                          // "${pakai.panjang} x ${pakai.lebar}",
                          // pakai != null
                          //     ? "${pakai.panjang} x ${pakai.lebar}"
                          //     : pakaipemilik != null
                          //         ? "${pakaipemilik.panjang} x ${pakaipemilik.lebar}"
                          //         : pakaipenyewa != null
                          //             ? "${pakaipenyewa.panjang} x ${pakaipenyewa.lebar}"
                          //             : "tidal terdedifinisi",
                          ),
                      _StatChip(
                        icon: Icons.home_work_outlined,
                        label: 'Jenis',
                        value: terima.jenis_kost.toString(),
                        // pakai.jenis_kost ?? '-',
                        // pakai != null
                        //     ? pakai.jenis_kost!
                        //     : pakaipemilik != null
                        //         ? pakaipemilik.jenis_kost!
                        //         : pakaipenyewa != null
                        //             ? pakaipenyewa.jenis_kost!
                        //             : "-",
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
                        value: terima.pemilik_kost.toString(),
                        // pakai.pemilik_kost ?? '-',
                        // pakai != null
                        //     ? pakai.pemilik_kost!
                        //     : pakaipemilik != null
                        //         ? pakaipemilik.pemilik_kost!
                        //         : pakaipenyewa != null
                        //             ? pakaipenyewa.pemilik_kost!
                        //             : "-",
                      ),
                      _InfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Kontak',
                        value: terima.notlp_kost.toString(),
                        // pakai.notlp_kost?.toString() ?? '-',
                        // pakai != null
                        //     ? pakai.notlp_kost.toString()
                        //     : pakaipemilik != null
                        //         ? pakaipemilik.notlp_kost.toString()
                        //         : pakaipenyewa != null
                        //             ? pakaipenyewa.notlp_kost.toString()
                        //             : "tidak terdaftar",
                      ),
                      _InfoTile(
                          icon: Icons.king_bed_outlined,
                          label: 'Ukuran Kamar',
                          value: "${terima.panjang} x ${terima.lebar}"
                          // "${pakai.panjang} x ${pakai.lebar}",
                          // pakai != null
                          //     ? "${pakai.panjang} x ${pakai.lebar}"
                          //     : pakaipemilik != null
                          //         ? "${pakaipemilik.panjang} x ${pakaipemilik.lebar}"
                          //         : pakaipenyewa != null
                          //             ? "${pakaipenyewa.panjang} x ${pakaipenyewa.lebar}"
                          //             : "tidal terdedifinisi",
                          ),
                      _InfoTile(
                        icon: Icons.home_work_outlined,
                        label: 'Jenis Kost',
                        value: terima.jenis_kost.toString(),
                        // pakai.jenis_kost ?? '-',
                        // pakai != null
                        //     ? pakai.jenis_kost.toString()
                        //     : pakaipemilik != null
                        //         ? pakaipemilik.jenis_kost.toString()
                        //         : pakaipenyewa != null
                        //             ? pakaipenyewa.jenis_kost.toString()
                        //             : "-",
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SectionCard(
                    title: 'Fasilitas & Utilitas',
                    children: [
                      _InfoTile(
                        icon: Icons.flash_on_outlined,
                        label: 'Jenis Listrik',
                        value: terima.jenis_listrik.toString(),
                        // pakai.jenis_listrik ?? '-',
                        // pakai != null
                        //     ? pakai.jenis_listrik.toString()
                        //     : pakaipemilik != null
                        //         ? pakaipemilik.jenis_listrik.toString()
                        //         : pakaipenyewa != null
                        //             ? pakaipenyewa.jenis_listrik.toString()
                        //             : "tidak ada listrik tersedia",
                      ),
                      _InfoTile(
                        icon: Icons.water_drop_outlined,
                        label: 'Pembayaran Air',
                        value: terima.jenis_pembayaran_air.toString(),
                        // pakai.jenis_pembayaran_air ?? '-',
                        // pakai != null
                        //     ? pakai.jenis_pembayaran_air.toString()
                        //     : pakaipemilik != null
                        //         ? pakaipemilik.jenis_pembayaran_air
                        //             .toString()
                        //         : pakaipenyewa != null
                        //             ? pakaipenyewa.jenis_pembayaran_air
                        //                 .toString()
                        //             : "tidak ada air berseih",
                      ),
                      _InfoTile(
                        icon: Icons.security_outlined,
                        label: 'Keamanan',
                        value: terima.keamanan.toString(),
                        // pakai.keamanan ?? '-',
                        // pakai != null
                        //     ? pakai.keamanan.toString()
                        //     : pakaipemilik != null
                        //         ? pakaipemilik.keamanan.toString()
                        //         : pakaipenyewa != null
                        //             ? pakaipenyewa.keamanan.toString()
                        //             : "tidak ada keamanan",
                      ),
                      _FacilityChips(
                        label: 'Fasilitas',
                        icon: Icons.list_alt_outlined,
                        raw1:
                            // "ada lek"
                            pakai.tempat_tidur == true
                                ? "Ada tempat tidur"
                                : "tidak ada tempat tidur",
                        // cek.tempat_tidur == true
                        //     ? "Ada tempat tidur"
                        //     : cekpemilik.tempat_tidur == true
                        //         ? "Ada tempat tidur"
                        //         : cekpenyewa.tempat_tidur == true
                        //             ? "Ada tempat tidur"
                        //             : "tidak ada tempat tidur",
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
  final String? raw1;
  // final String? raw2;

  const _FacilityChips({
    required this.label,
    required this.icon,
    required this.raw1,
    // required this.raw2,
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
    final items = _tokens(raw1);
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
