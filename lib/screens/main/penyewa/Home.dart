import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/kost_provider.dart';

// ini perubahan irwan

class KostHomePage extends StatelessWidget {
  static const routeName = '/kost_home';
  bool keadaan = true;

  KostHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final topPadding = MediaQuery.of(context).padding.top;
    final penghubung = Provider.of<KostProvider>(context);

    // AppBar custom tinggi agar proporsi mudah dihitung
    final AppBar appBar = AppBar(
      elevation: 0,
      toolbarHeight: 100,
      backgroundColor: const Color(0xFFF5F7FB),
      foregroundColor: Colors.black,
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
        child: Text(
          "Temukan Kost\nPilihan anda",
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            height: 1.05,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 5),
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none),
            color: Colors.black,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ),
      ],
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
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 0,
          bottom: 0,
        ),
        child: Column(
          children: [
            SizedBox(height: 8),

            // Search field
            Material(
              elevation: 0,
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Cari kost...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Expanded area with ListView of cards
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.only(bottom: 80),
                itemCount: penghubung.kostpenyewa.length,
                separatorBuilder: (_, __) => SizedBox(height: 18),
                itemBuilder: (context, index) {
                  final tesst = penghubung.kostpenyewa[index];
                  final yes = penghubung.fasilitaspenyewa.firstWhere(
                      (element) => element.id_fasilitas == tesst.id_fasilitas);

                  // Build facility tags from database flags (minimal change)
                  final List<String> fasilitasTags = [
                    if (yes.ac) 'AC',
                    if (yes.wifi) 'WiFi',
                    if (yes.kamar_mandi_dalam) 'K. Mandi Dalam',
                    if (yes.tempat_parkir) 'Parkir',
                    if (yes.dapur_dalam) 'Dapur',
                  ];

                  return _KostCard(
                    imageHeight: imageHeight,
                    radius: cardRadius,
                    titleFontSize: titleFont,
                    priceFontSize: priceFont,
                    // contoh data statis
                    price: "Rp ${penghubung.kostpenyewa[index].harga_kost}",
                    title: "${penghubung.kostpenyewa[index].nama_kost}",
                    location: "${penghubung.kostpenyewa[index].alamat_kost}",
                    genderLabel: "${penghubung.kostpenyewa[index].jenis_kost}",
                    gambar: "${penghubung.kostpenyewa[index].gambar_kost}",
                    fasilitas: fasilitasTags,
                    fungsitap: () {
                      Navigator.of(context).pushNamed(
                        'detail-kost',
                        arguments:
                            // penghubung.kostpenyewa[index],
                            {
                          'data_kost': tesst,
                          'data_fasilitas': yes,
                        },
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

class _KostCard extends StatelessWidget {
  final double imageHeight;
  final double radius;
  final double titleFontSize;
  final double priceFontSize;
  final String price;
  final String title;
  final String location;
  final String genderLabel;
  final String gambar;
  final VoidCallback? fungsitap;
  final List<String>? fasilitas;

  _KostCard(
      {Key? key,
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
      this.fasilitas})
      : super(key: key);

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
                                price,
                                style: TextStyle(
                                  color: Color(0xFF1C3B98),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                ' / bulan',
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
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if ((fasilitas ?? const []).isNotEmpty) ...[
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final tag in fasilitas!)
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE9EEF9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 14, color: Color(0xFF1C3B98)),
                                const SizedBox(width: 6),
                                Text(
                                  tag,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1F1F1F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
