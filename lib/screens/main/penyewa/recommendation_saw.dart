import 'package:flutter/material.dart';

import 'process_saw.dart';

class RecommendationSawPage extends StatefulWidget {
  const RecommendationSawPage({super.key});

  @override
  State<RecommendationSawPage> createState() => _RecommendationSawPageState();
}

class _RecommendationSawPageState extends State<RecommendationSawPage> {
  // Dummy UI-only data; replace with real SAW results later
  final List<_KostItem> _items = [
    _KostItem(
      name: 'Kost Melati Putih',
      address: 'Jl. Melati No. 12, Dekat Kampus',
      pricePerMonth: 850000,
      distanceKm: 0.75,
      score: 0.892,
      tags: const ['AC', 'WiFi', 'K. Mandi Dalam'],
      imageUrl: 'https://via.placeholder.com/800x450?text=Kost+Melati+Putih',
    ),
    _KostItem(
      name: 'Kost Mawar Asri',
      address: 'Jl. Mawar No. 5, Timur Kampus',
      pricePerMonth: 700000,
      distanceKm: 1.2,
      score: 0.854,
      tags: const ['WiFi', 'Parkir'],
      imageUrl: 'https://via.placeholder.com/800x450?text=Kost+Mawar+Asri',
    ),
    _KostItem(
      name: 'Kost Kenanga',
      address: 'Jl. Kenanga No. 20',
      pricePerMonth: 950000,
      distanceKm: 0.5,
      score: 0.812,
      tags: const ['AC', 'WiFi'],
      imageUrl: 'https://via.placeholder.com/800x450?text=Kost+Kenanga',
    ),
    _KostItem(
      name: 'Kost Sakura',
      address: 'Jl. Sakura No. 2',
      pricePerMonth: 650000,
      distanceKm: 1.8,
      score: 0.777,
      tags: const ['Dapur', 'Parkir'],
      imageUrl: 'https://via.placeholder.com/800x450?text=Kost+Sakura',
    ),
  ];

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

    // Sort descending by score for UI display only
    final sorted = [..._items]..sort((a, b) => b.score.compareTo(a.score));

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
                  builder: (_) => const ProcessSawPage(),
                ),
              );
            },
          ),
          SizedBox(width: s(4)),
        ],
      ),
      body: SafeArea(
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
                    child: Icon(Icons.star_rate_rounded,
                        color: colorPrimary, size: s(20)),
                  ),
                  SizedBox(width: s(10)),
                  Text(
                    'Daftar Kost Tertinggi (SAW)',
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
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => SizedBox(height: s(12)),
                  itemBuilder: (context, index) {
                    final item = sorted[index];
                    return _KostCard(
                      rank: index + 1,
                      item: item,
                      s: s,
                      colorPrimary: colorPrimary,
                      colorTextPrimary: colorTextPrimary,
                      colorBackground: colorBackground,
                      colorWhite: colorWhite,
                      shadowColor: shadowColor,
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
}

class _KostCard extends StatelessWidget {
  final int rank;
  final _KostItem item;
  final double Function(double) s;
  final Color colorPrimary;
  final Color colorTextPrimary;
  final Color colorBackground;
  final Color colorWhite;
  final Color shadowColor;

  const _KostCard({
    required this.rank,
    required this.item,
    required this.s,
    required this.colorPrimary,
    required this.colorTextPrimary,
    required this.colorBackground,
    required this.colorWhite,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image banner (mirip pemilik)
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(s(16))),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: item.imageUrl == null || item.imageUrl!.isEmpty
                      ? Container(
                          color: const Color(0xFFE5ECFF),
                          child: Center(
                            child: Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: s(32),
                            ),
                          ),
                        )
                      : Image.network(
                          item.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: const Color(0xFFE5ECFF),
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: s(32),
                              ),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  right: s(12),
                  top: s(12),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: s(10), vertical: s(6)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDE6FF).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(s(10)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.sell_outlined,
                            size: s(16), color: colorPrimary),
                        SizedBox(width: s(6)),
                        Text(
                          _formatCurrency(item.pricePerMonth),
                          style: TextStyle(
                            color: colorPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: s(12),
                          ),
                        ),
                        Text(
                          ' / bulan',
                          style: TextStyle(
                            color: colorPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: s(11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: s(12),
                  top: s(12),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: s(10), vertical: s(6)),
                    decoration: BoxDecoration(
                      color: colorWhite.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(s(10)),
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: s(12),
                        fontWeight: FontWeight.w800,
                        color: colorPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(s(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: s(16),
                    fontWeight: FontWeight.w700,
                    color: colorTextPrimary,
                  ),
                ),
                SizedBox(height: s(4)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: s(16), color: Colors.grey),
                    SizedBox(width: s(6)),
                    Expanded(
                      child: Text(
                        item.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: s(12.5),
                          color: colorTextPrimary.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: s(8)),
                Wrap(
                  spacing: s(6),
                  runSpacing: s(6),
                  children: [
                    _chip('Skor: ${item.score.toStringAsFixed(3)}',
                        Icons.leaderboard_outlined),
                    _chip('${item.distanceKm.toStringAsFixed(2)} km',
                        Icons.social_distance_outlined),
                    for (final tag in item.tags)
                      _chip(tag, Icons.check_circle_outline),
                  ],
                ),
                SizedBox(height: s(10)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.remove_red_eye_outlined,
                        size: s(18), color: colorPrimary),
                    label: Text(
                      'Lihat Detail',
                      style: TextStyle(
                        fontSize: s(13),
                        fontWeight: FontWeight.w600,
                        color: colorPrimary,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: s(10), vertical: s(6)),
      decoration: BoxDecoration(
        color: colorBackground,
        borderRadius: BorderRadius.circular(s(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: s(14), color: colorPrimary),
          SizedBox(width: s(6)),
          Text(
            text,
            style: TextStyle(
              fontSize: s(12),
              color: colorTextPrimary.withOpacity(0.75),
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
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

class _KostItem {
  final String name;
  final String address;
  final int pricePerMonth;
  final double distanceKm;
  final double score;
  final List<String> tags;
  final String? imageUrl;

  const _KostItem({
    required this.name,
    required this.address,
    required this.pricePerMonth,
    required this.distanceKm,
    required this.score,
    required this.tags,
    this.imageUrl,
  });
}
