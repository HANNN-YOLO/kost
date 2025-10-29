import 'package:flutter/material.dart';

class FormAddHouse extends StatelessWidget {
  const FormAddHouse({super.key});

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    const warnaLatar = Color(0xFFF5F7FB);
    const warnaTombol = Color(0xFF12111F);

    // 🔹 Fungsi field teks standar
    Widget inputField(String label) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: lebarLayar * 0.035,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: tinggiLayar * 0.005),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: lebarLayar * 0.04,
                  vertical: tinggiLayar * 0.018,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          SizedBox(height: tinggiLayar * 0.025),
        ],
      );
    }

    // 🔹 Fungsi field gambar (dengan ikon)
    Widget gambarField(String label) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
              fontSize: lebarLayar * 0.035,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: tinggiLayar * 0.005),
          Container(
            padding: EdgeInsets.symmetric(horizontal: lebarLayar * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            height: tinggiLayar * 0.065,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),
                Icon(
                  Icons.image_outlined,
                  color: Colors.black.withOpacity(0.7),
                ),
              ],
            ),
          ),
          SizedBox(height: tinggiLayar * 0.025),
        ],
      );
    }

    // 🔹 Widget Fasilitas
    Widget fasilitasItem(String teks, IconData ikon) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: lebarLayar * 0.025,
          vertical: tinggiLayar * 0.009,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_box_outline_blank,
                size: lebarLayar * 0.045, color: Colors.grey.shade600),
            SizedBox(width: lebarLayar * 0.015),
            Icon(ikon, size: lebarLayar * 0.045, color: Colors.grey.shade700),
            SizedBox(width: lebarLayar * 0.015),
            Text(
              teks,
              style: TextStyle(
                fontSize: lebarLayar * 0.032,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: warnaLatar,

      // 🔹 Header tetap di atas (tidak ikut scroll)
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(tinggiLayar * 0.08),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: lebarLayar * 0.06),
          color: warnaLatar,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol kembali
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),

              Text(
                'Form Tambah Kost',
                style: TextStyle(
                  fontSize: lebarLayar * 0.045,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const Icon(Icons.notifications_none, color: Colors.black),
            ],
          ),
        ),
      ),

      // 🔹 Konten scrollable
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: lebarLayar * 0.06,
            vertical: tinggiLayar * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Gambar
              gambarField('Gambar 1'),
              gambarField('Gambar 2 (Opsional)'),

              // 🔹 Input teks
              inputField('Nama Kost'),
              inputField('Harga'),
              inputField('Alamat'),
              inputField('Luas Kamar'),
              inputField('Nama Pemilik'),
              inputField('Nomor Telepon'),
              inputField('Jarak'),

              // 🔹 Fasilitas
              Text(
                'Fasilitas',
                style: TextStyle(
                  color: Colors.black.withOpacity(0.8),
                  fontSize: lebarLayar * 0.035,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: tinggiLayar * 0.01),

              Wrap(
                spacing: lebarLayar * 0.03,
                runSpacing: tinggiLayar * 0.015,
                children: [
                  fasilitasItem('Kamar Mandi', Icons.bathtub_outlined),
                  fasilitasItem('Kamar Mandi', Icons.bathtub_outlined),
                  fasilitasItem('Kamar Mandi', Icons.bathtub_outlined),
                  fasilitasItem('Kamar Mandi', Icons.bathtub_outlined),
                ],
              ),

              SizedBox(height: tinggiLayar * 0.05),
            ],
          ),
        ),
      ),

      // 🔹 Tombol bawah
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(lebarLayar * 0.05),
        child: SizedBox(
          height: tinggiLayar * 0.065,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: warnaTombol,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onPressed: () {},
            child: Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontSize: lebarLayar * 0.04,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
