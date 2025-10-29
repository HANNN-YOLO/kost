import 'package:flutter/material.dart';

class CriteriaManagement extends StatefulWidget {
  const CriteriaManagement({super.key});

  @override
  State<CriteriaManagement> createState() => _CriteriaManagementState();
}

class _CriteriaManagementState extends State<CriteriaManagement> {
  final TextEditingController _controller = TextEditingController();

  // Daftar kriteria
  List<String> kriteriaList = ["Fasilitas", "Luas kamar", "Keamanan", "Harga"];

  // Untuk menandai item mana yang sedang diedit
  int? _editingIndex;
  TextEditingController _editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;

    const warnaLatar = Color(0xFFF5F7FB);
    const warnaKartu = Color(0xFFE5ECFF);

    return Scaffold(
      backgroundColor: warnaLatar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: lebarLayar * 0.05,
            vertical: tinggiLayar * 0.03,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Header
              const Text(
                "Managemen Kriteria kost",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: tinggiLayar * 0.03),

              // 🔹 Input Field
              const Text(
                "Masukan Kriteria",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: tinggiLayar * 0.012),

              Container(
                width: double.infinity,
                height: tinggiLayar * 0.065,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: lebarLayar * 0.04),
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Tulis nama kriteria...",
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        setState(() {
                          kriteriaList.add(value.trim());
                          _controller.clear();
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: tinggiLayar * 0.03),

              // 🔹 Kartu daftar kriteria
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
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
                        "Kriteria yang ditambahkan",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: tinggiLayar * 0.01),
                      Container(
                        height: 1,
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: tinggiLayar * 0.02),

                      // 🔹 Daftar kriteria
                      Column(
                        children: List.generate(
                          kriteriaList.length,
                          (index) => Padding(
                            padding:
                                EdgeInsets.only(bottom: tinggiLayar * 0.015),
                            child: buildKriteriaItem(
                              context,
                              lebarLayar,
                              tinggiLayar,
                              kriteriaList[index],
                              warnaKartu,
                              index,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: tinggiLayar * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  // 🔸 Widget item daftar kriteria
  Widget buildKriteriaItem(
    BuildContext context,
    double lebarLayar,
    double tinggiLayar,
    String nama,
    Color warnaKartu,
    int index,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: tinggiLayar * 0.018,
        horizontal: lebarLayar * 0.04,
      ),
      decoration: BoxDecoration(
        color: warnaKartu,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Jika sedang diedit → tampilkan TextField
          Expanded(
            child: _editingIndex == index
                ? TextField(
                    controller: _editController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    onSubmitted: (newValue) {
                      if (newValue.trim().isNotEmpty) {
                        setState(() {
                          kriteriaList[index] = newValue.trim();
                          _editingIndex = null;
                        });
                      }
                    },
                  )
                : Text(
                    nama,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),

          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    if (_editingIndex == index) {
                      // Jika sedang edit lalu ditekan lagi → simpan
                      _editingIndex = null;
                    } else {
                      // Masuk mode edit
                      _editingIndex = index;
                      _editController.text = kriteriaList[index];
                    }
                  });
                },
                child: Icon(
                  _editingIndex == index ? Icons.check : Icons.edit,
                  color: _editingIndex == index ? Colors.blue : Colors.green,
                  size: lebarLayar * 0.05,
                ),
              ),
              SizedBox(width: lebarLayar * 0.03),
              GestureDetector(
                onTap: () {
                  _tampilkanKonfirmasiHapus(
                    context,
                    kriteriaList[index],
                    () {
                      setState(() {
                        kriteriaList.removeAt(index);
                      });
                      Navigator.pop(context);
                    },
                  );
                },
                child: Icon(Icons.delete,
                    color: Colors.red, size: lebarLayar * 0.05),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔸 Pop-up konfirmasi hapus
  void _tampilkanKonfirmasiHapus(
      BuildContext context, String nama, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          "Hapus Kriteria?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus '$nama' dari daftar?",
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onConfirm,
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
