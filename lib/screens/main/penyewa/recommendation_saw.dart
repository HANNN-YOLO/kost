import 'package:flutter/material.dart';

import 'process_saw.dart';
import 'package:provider/provider.dart';

import '../../../providers/kost_provider.dart';
import '../../../algoritma/simple_additive_weighting.dart';

class RecommendationSawPage extends StatefulWidget {
  final double? destinationLat;
  final double? destinationLng;
  final List<Map<String, dynamic>>? kostData;

  const RecommendationSawPage({
    super.key,
    this.destinationLat,
    this.destinationLng,
    this.kostData,
  });

  @override
  State<RecommendationSawPage> createState() => _RecommendationSawPageState();
}

class _RecommendationSawPageState extends State<RecommendationSawPage> {
  @override
  void initState() {
    super.initState();
    // Jalankan perhitungan SAW saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KostProvider>().hitungSAW(
            userLat: widget.destinationLat,
            userLng: widget.destinationLng,
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
          'Hasil Rekomendasi (SAW)',
          style:
              TextStyle(color: colorTextPrimary, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Lihat Perhitungan SAW',
            icon: const Icon(Icons.table_chart_outlined, color: colorPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProcessSawPage(
                    userLat: widget.destinationLat,
                    userLng: widget.destinationLng,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: s(4)),
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
                    'Menghitung rekomendasi...',
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
                      color: Colors.red,
                    ),
                    SizedBox(height: s(16)),
                    Text(
                      'Terjadi Kesalahan',
                      style: TextStyle(
                        fontSize: s(18),
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
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
                      onPressed: () => provider.hitungSAW(
                        userLat: widget.destinationLat,
                        userLng: widget.destinationLng,
                      ),
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
                    Icons.search_off_rounded,
                    size: s(64),
                    color: colorPrimary.withOpacity(0.5),
                  ),
                  SizedBox(height: s(16)),
                  Text(
                    'Belum ada hasil rekomendasi',
                    style: TextStyle(
                      fontSize: s(16),
                      color: colorTextPrimary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Ambil hasil ranking dari SAW
          final hasilSAW = provider.hasilSAW!;
          final rankings = hasilSAW.hasilRanking;

          // Build list of kost items from ranking
          final kostList = provider.kostpenyewa.isNotEmpty
              ? provider.kostpenyewa
              : provider.kost;

          return SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: s(16), vertical: s(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: s(36),
                        height: s(36),
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: BorderRadius.circular(s(12)),
                          boxShadow: [
                            BoxShadow(
                              color: shadowColor,
                              blurRadius: s(8),
                              offset: Offset(0, s(3)),
                            ),
                          ],
                        ),
                        child: Icon(Icons.emoji_events_rounded,
                            color: Colors.amber, size: s(20)),
                      ),
                      SizedBox(width: s(10)),
                      Text(
                        'Peringkat Kost (SAW)',
                        style: TextStyle(
                          fontSize: s(16),
                          fontWeight: FontWeight.w600,
                          color: colorTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: s(12)),
                  Expanded(
                    child: ListView.separated(
                      itemCount: rankings.length,
                      separatorBuilder: (_, __) => SizedBox(height: s(12)),
                      itemBuilder: (context, index) {
                        final ranking = rankings[index];

                        // Cari data kost berdasarkan idKost dari ranking
                        final kost = kostList.firstWhere(
                          (k) => k.id_kost == ranking.idKost,
                          orElse: () => kostList.first,
                        );

                        // Cari jarak dari kostData jika tersedia
                        double? distanceKm;
                        if (widget.kostData != null) {
                          final kostDataItem = widget.kostData!.firstWhere(
                            (m) => m['id_kost'] == ranking.idKost,
                            orElse: () => {},
                          );
                          if (kostDataItem.isNotEmpty) {
                            distanceKm = (kostDataItem['distanceKm'] as num?)
                                ?.toDouble();
                          }
                        }

                        return _RankingCard(
                          rank: ranking.peringkat,
                          namaKost: ranking.namaKost,
                          skor: ranking.skor,
                          harga: kost.harga_kost ?? 0,
                          distanceKm: distanceKm,
                          luasKamar: (kost.panjang ?? 0) * (kost.lebar ?? 0),
                          panjang: kost.panjang ?? 0,
                          lebar: kost.lebar ?? 0,
                          imageUrl: kost.gambar_kost,
                          idKost: ranking.idKost,
                          idFasilitas: kost.id_fasilitas,
                          s: s,
                          colorPrimary: colorPrimary,
                          colorTextPrimary: colorTextPrimary,
                          colorBackground: colorBackground,
                          colorWhite: colorWhite,
                          shadowColor: shadowColor,
                          destinationLat: widget.destinationLat,
                          destinationLng: widget.destinationLng,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Widget Card untuk menampilkan ranking kost
class _RankingCard extends StatelessWidget {
  final int rank;
  final String namaKost;
  final double skor;
  final int harga;
  final double? distanceKm;
  final int luasKamar;
  final int panjang;
  final int lebar;
  final String? imageUrl;
  final int idKost;
  final int? idFasilitas;
  final double Function(double) s;
  final Color colorPrimary;
  final Color colorTextPrimary;
  final Color colorBackground;
  final Color colorWhite;
  final Color shadowColor;
  final double? destinationLat;
  final double? destinationLng;

  const _RankingCard({
    required this.rank,
    required this.namaKost,
    required this.skor,
    required this.harga,
    this.distanceKm,
    required this.luasKamar,
    required this.panjang,
    required this.lebar,
    this.imageUrl,
    required this.idKost,
    this.idFasilitas,
    required this.s,
    required this.colorPrimary,
    required this.colorTextPrimary,
    required this.colorBackground,
    required this.colorWhite,
    required this.shadowColor,
    this.destinationLat,
    this.destinationLng,
  });

  @override
  Widget build(BuildContext context) {
    // Warna badge berdasarkan peringkat
    Color rankColor;
    Color rankBgColor;
    IconData rankIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      rankBgColor = const Color(0xFFFFF8E1);
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      rankBgColor = const Color(0xFFF5F5F5);
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankBgColor = const Color(0xFFFBE9E7);
      rankIcon = Icons.emoji_events_rounded;
    } else {
      rankColor = colorPrimary;
      rankBgColor = const Color(0xFFE3F2FD);
      rankIcon = Icons.tag;
    }

    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(s(16)),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: s(10),
            offset: Offset(0, s(4)),
          ),
        ],
        border: rank == 1
            ? Border.all(color: const Color(0xFFFFD700), width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image banner dengan badge peringkat
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(s(14))),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: imageUrl == null || imageUrl!.isEmpty
                      ? Container(
                          color: const Color(0xFFE5ECFF),
                          child: Center(
                            child: Icon(
                              Icons.home_rounded,
                              color: Colors.grey,
                              size: s(48),
                            ),
                          ),
                        )
                      : Image.network(
                          imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: const Color(0xFFE5ECFF),
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: s(48),
                              ),
                            ),
                          ),
                        ),
                ),
                // Badge Peringkat (kiri atas)
                Positioned(
                  left: s(12),
                  top: s(12),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: s(12), vertical: s(8)),
                    decoration: BoxDecoration(
                      color: rankBgColor,
                      borderRadius: BorderRadius.circular(s(12)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: s(4),
                          offset: Offset(0, s(2)),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(rankIcon, size: s(18), color: rankColor),
                        SizedBox(width: s(4)),
                        Text(
                          '#$rank',
                          style: TextStyle(
                            fontSize: s(14),
                            fontWeight: FontWeight.w800,
                            color: rank <= 3 ? rankColor : colorPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Badge Harga (kanan atas)
                Positioned(
                  right: s(12),
                  top: s(12),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: s(10), vertical: s(6)),
                    decoration: BoxDecoration(
                      color: colorPrimary.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(s(10)),
                    ),
                    child: Text(
                      _formatCurrency(harga),
                      style: TextStyle(
                        color: colorWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: s(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(s(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Kost
                Text(
                  namaKost,
                  style: TextStyle(
                    fontSize: s(16),
                    fontWeight: FontWeight.w700,
                    color: colorTextPrimary,
                  ),
                ),
                SizedBox(height: s(12)),

                // Info Grid: Skor, Jarak, Luas
                Row(
                  children: [
                    // Skor SAW
                    Expanded(
                      child: _infoChip(
                        icon: Icons.analytics_rounded,
                        label: 'Skor',
                        value: skor.toStringAsFixed(2),
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    SizedBox(width: s(8)),
                    // Jarak
                    Expanded(
                      child: _infoChip(
                        icon: Icons.route_rounded,
                        label: 'Jarak',
                        value: distanceKm != null
                            ? '${distanceKm!.toStringAsFixed(2)} km'
                            : '-',
                        color: const Color(0xFF2196F3),
                      ),
                    ),
                    SizedBox(width: s(8)),
                    // Luas Kamar
                    Expanded(
                      child: _infoChip(
                        icon: Icons.square_foot_rounded,
                        label: 'Luas',
                        value: '${panjang}x${lebar} m²',
                        color: const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: s(12)),

                // Button Lihat Detail
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToDetail(context),
                    icon: Icon(Icons.visibility_rounded, size: s(18)),
                    label: Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: s(13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorPrimary,
                      foregroundColor: colorWhite,
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
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: s(10), horizontal: s(8)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(s(10)),
      ),
      child: Column(
        children: [
          Icon(icon, size: s(20), color: color),
          SizedBox(height: s(4)),
          Text(
            label,
            style: TextStyle(
              fontSize: s(10),
              color: colorTextPrimary.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: s(2)),
          Text(
            value,
            style: TextStyle(
              fontSize: s(12),
              color: colorTextPrimary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    final kostProvider = Provider.of<KostProvider>(context, listen: false);

    final List kostList = kostProvider.kostpenyewa.isNotEmpty
        ? kostProvider.kostpenyewa
        : kostProvider.kost;

    dynamic selectedKost;
    for (final k in kostList) {
      if (k.id_kost == idKost) {
        selectedKost = k;
        break;
      }
    }

    if (selectedKost == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kost tidak ditemukan.')),
      );
      return;
    }

    dynamic selectedFasilitas;
    final List fasilitasList = kostProvider.kostpenyewa.isNotEmpty
        ? kostProvider.fasilitaspenyewa
        : kostProvider.faslitas;

    for (final f in fasilitasList) {
      if (f.id_fasilitas == idFasilitas) {
        selectedFasilitas = f;
        break;
      }
    }

    Navigator.of(context).pushNamed(
      'detail-kost',
      arguments: {
        'data_kost': selectedKost,
        'data_fasilitas': selectedFasilitas,
        if (destinationLat != null) 'destinationLat': destinationLat,
        if (destinationLng != null) 'destinationLng': destinationLng,
        if (distanceKm != null) 'distanceKm': distanceKm,
      },
    );
  }

  String _formatCurrency(int value) {
    final str = value.toString();
    final rev = str.split('').reversed.toList();
    final parts = <String>[];
    for (int i = 0; i < rev.length; i += 3) {
      parts.add(rev.sublist(i, (i + 3).clamp(0, rev.length)).join());
    }
    final grouped = parts.join('.').split('').reversed.join();
    return 'Rp $grouped';
  }
}
