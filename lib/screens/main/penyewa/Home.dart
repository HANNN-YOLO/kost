import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../shared/formatCurrency.dart';
import 'package:provider/provider.dart';
import '../../../providers/kost_provider.dart';

class KostHomePage extends StatefulWidget {
  static const routeName = '/kost_home';

  const KostHomePage({Key? key}) : super(key: key);

  @override
  State<KostHomePage> createState() => _KostHomePageState();
}

class _KostHomePageState extends State<KostHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedJenis = 'Semua';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final penghubung = Provider.of<KostProvider>(context);
    const Color colorPrimary = Color(0xFF1C3B98);
    const Color colorWhite = Colors.white;
    final double screenWidth = MediaQuery.of(context).size.width;
    const double figmaWidth = 402;
    double scale = screenWidth / figmaWidth;
    double s(double size) => size * scale;

    // AppBar custom dengan gaya lebih minimalis & modern
    final AppBar appBar = AppBar(
      elevation: 0,
      toolbarHeight: 90,
      backgroundColor: const Color(0xFFF5F7FB),
      foregroundColor: Colors.black,
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Cari kost terbaik',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Temukan kost idealmu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ],
            ),
            // Container(
            //   width: 40,
            //   height: 40,
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(14),
            //     boxShadow: const [
            //       BoxShadow(
            //         color: Color.fromRGBO(0, 0, 0, 0.06),
            //         blurRadius: 10,
            //         offset: Offset(0, 4),
            //       ),
            //     ],
            //   ),
            //   child: IconButton(
            //     onPressed: () {},
            //     icon: const Icon(Icons.notifications_none_rounded, size: 20),
            //     padding: EdgeInsets.zero,
            //     color: Colors.black87,
            //   ),
            // ),
          ],
        ),
      ),
    );

    final tinggiBody = tinggiLayar - appBar.preferredSize.height - topPadding;

    // Breakpoints (adaptive)
    String kategori;
    if (lebarLayar < 600) {
      kategori = "mobile";
    } else if (lebarLayar < 1200) {
      kategori = "tablet";
    } else {
      kategori = "desktop";
    }

    // Styling adaptif berdasarkan kategori
    double horizontalPadding;
    double cardRadius;
    double imageHeight;
    double titleFont;
    double priceFont;
    switch (kategori) {
      case "mobile":
        horizontalPadding = 16;
        cardRadius = 14;
        imageHeight = tinggiBody * 0.32;
        titleFont = 16;
        priceFont = 16;
        break;
      case "tablet":
        horizontalPadding = 32;
        cardRadius = 16;
        imageHeight = tinggiBody * 0.28;
        titleFont = 18;
        priceFont = 18;
        break;
      default: // desktop
        horizontalPadding = 64;
        cardRadius = 18;
        imageHeight = tinggiBody * 0.22;
        titleFont = 20;
        priceFont = 20;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: PreferredSize(
        preferredSize: appBar.preferredSize,
        child: SafeArea(child: appBar),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),

            // Search field
            Material(
              elevation: 0,
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Cari kost',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Umum'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Khusus Putri'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Khusus Putra'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // List kost terfilter
            Expanded(
              child: Builder(
                builder: (context) {
                  if (penghubung.isLoadingPenyewaKost &&
                      penghubung.kostpenyewa.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final semuaKost = penghubung.kostpenyewa;

                  final filtered = semuaKost.where((k) {
                    final nama = (k.nama_kost ?? '').toLowerCase();
                    final alamat = (k.alamat_kost ?? '').toLowerCase();
                    final jenis = (k.jenis_kost ?? '').toLowerCase();

                    bool matchesSearch = true;
                    if (_searchQuery.isNotEmpty) {
                      matchesSearch = nama.contains(_searchQuery) ||
                          alamat.contains(_searchQuery) ||
                          jenis.contains(_searchQuery);
                    }

                    bool matchesJenis = true;
                    if (_selectedJenis != 'Semua') {
                      matchesJenis = (k.jenis_kost ?? '') == _selectedJenis;
                    }

                    return matchesSearch && matchesJenis;
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Kost tidak ditemukan. Coba ubah kata kunci atau filter.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final tesst = filtered[index];
                      final yes = penghubung.fasilitaspenyewa.firstWhereOrNull(
                        (element) => element.id_fasilitas == tesst.id_fasilitas,
                      );

                      final perLabel =
                          ((tesst.per ?? '').toString().trim().isEmpty)
                              ? 'bulan'
                              : tesst.per.toString();

                      // Build facility tags from database flags
                      final List<String> fasilitasTags = [];
                      if (yes != null) {
                        if (yes.ac) fasilitasTags.add('AC');
                        if (yes.wifi) fasilitasTags.add('WiFi');
                        if (yes.kamar_mandi_dalam) {
                          fasilitasTags.add('K. Mandi Dalam');
                        }
                        if (yes.tempat_parkir) fasilitasTags.add('Parkir');
                        if (yes.dapur_dalam) fasilitasTags.add('Dapur');
                      }

                      return _KostCard(
                        imageHeight: imageHeight,
                        radius: cardRadius,
                        titleFontSize: titleFont,
                        priceFontSize: priceFont,
                        price: tesst.harga_kost ?? 0,
                        per: " / $perLabel",
                        title: tesst.nama_kost ?? '-',
                        location: tesst.alamat_kost ?? '-',
                        genderLabel: tesst.jenis_kost ?? '-',
                        gambar: tesst.gambar_kost ?? '',
                        fasilitas: fasilitasTags,
                        fungsitap: () {
                          Navigator.of(context).pushNamed(
                            'detail-kost',
                            arguments: {
                              'data_kost': tesst,
                              if (yes != null) 'data_fasilitas': yes,
                            },
                          );
                        },
                        colorprimary: colorPrimary,
                        colorwhite: colorWhite,
                        s: s,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// helper chip untuk filter jenis kost
class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipItem({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1C3B98) : const Color(0xFFE9EEF9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 14,
              color: selected ? Colors.white : const Color(0xFF1C3B98),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : const Color(0xFF1F1F1F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on _KostHomePageState {
  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedJenis == label;
    return _FilterChipItem(
      label: label,
      selected: isSelected,
      onTap: () {
        setState(() {
          _selectedJenis = label;
        });
      },
    );
  }
}

class _KostCard extends StatelessWidget {
  final double imageHeight;
  final double radius;
  final double titleFontSize;
  final double priceFontSize;
  final int price;
  final String title;
  final String location;
  final String genderLabel;
  final String gambar;
  final VoidCallback? fungsitap;
  final List<String>? fasilitas;
  final String per;
  final Color colorprimary;
  final Color colorwhite;
  final double Function(double) s;

  _KostCard({
    Key? key,
    required this.imageHeight,
    required this.radius,
    required this.titleFontSize,
    required this.priceFontSize,
    required this.price,
    required this.title,
    required this.location,
    required this.genderLabel,
    required this.gambar,
    required this.fungsitap,
    this.fasilitas,
    required this.per,
    required this.colorprimary,
    required this.colorwhite,
    required this.s,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: fungsitap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar dengan sudut melengkung (top)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          '$gambar',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              color: Color(0xFFE5ECFF),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                  size: 42,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFDDE6FF).withOpacity(0.95),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.sell_outlined,
                                  size: 18, color: Color(0xFF1C3B98)),
                              SizedBox(width: 6),
                              Text(
                                formatCurrency(price),
                                style: TextStyle(
                                  color: Color(0xFF1C3B98),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                per,
                                style: TextStyle(
                                  color: Color(0xFF1C3B98),
                                  fontWeight: FontWeight.w600,
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
            ),

            // Info bawah
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // bar atas: price dan gender label di kanan
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          genderLabel,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 3,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // if ((fasilitas ?? const []).isNotEmpty) ...[
                  //   SizedBox(height: 8),
                  //   Wrap(
                  //     spacing: 6,
                  //     runSpacing: 6,
                  //     children: [
                  //       for (final tag in fasilitas!)
                  //         Container(
                  //           padding: EdgeInsets.symmetric(
                  //               horizontal: 10, vertical: 6),
                  //           decoration: BoxDecoration(
                  //             color: const Color(0xFFE9EEF9),
                  //             borderRadius: BorderRadius.circular(20),
                  //           ),
                  //           child: Row(
                  //             mainAxisSize: MainAxisSize.min,
                  //             children: [
                  //               const Icon(Icons.check_circle_outline,
                  //                   size: 14, color: Color(0xFF1C3B98)),
                  //               const SizedBox(width: 6),
                  //               Text(
                  //                 tag,
                  //                 style: const TextStyle(
                  //                   fontSize: 12,
                  //                   color: Color(0xFF1F1F1F),
                  //                 ),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //     ],
                  //   ),
                  // ],
                  SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: fungsitap,
                      icon: Icon(Icons.visibility_rounded, size: s(18)),
                      label: Text(
                        'Lihat Detail',
                        style: TextStyle(
                          fontSize: s(13),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorprimary,
                        foregroundColor: colorwhite,
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
      ),
    );
  }
}
