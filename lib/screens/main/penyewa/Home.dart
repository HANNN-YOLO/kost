import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/kost_provider.dart';

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
      backgroundColor: const Color(0xFFF4F4F4),
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
      backgroundColor: Color(0xFFF4F4F4),
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
                itemCount: penghubung.kost.length,
                separatorBuilder: (_, __) => SizedBox(height: 18),
                itemBuilder: (context, index) {
                  return _KostCard(
                    imageHeight: imageHeight,
                    radius: cardRadius,
                    titleFontSize: titleFont,
                    priceFontSize: priceFont,
                    // contoh data statis
                    price: "Rp ${penghubung.kost[index].harga_kost}",
                    title: "${penghubung.kost[index].nama_kost}",
                    location: "${penghubung.kost[index].alamat_kost}",
                    genderLabel: "${penghubung.kost[index].jenis_kost}",
                    gambar: "${penghubung.kost[index].gambar_kost}",
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(radius),
      color: Colors.white,
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gambar dengan sudut melengkung (top)
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: SizedBox(
                height: imageHeight,
                width: double.infinity,
                child: Image.network(
                  '$gambar', // ganti path sesuai aset anda
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    // fallback ketika asset tidak ditemukan
                    return Container(
                      color: Color(0xFFECECEC),
                      child: Center(child: Icon(Icons.image, size: 48)),
                    );
                  },
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
                    Expanded(
                      child: Text(
                        price,
                        style: TextStyle(
                          fontSize: priceFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
