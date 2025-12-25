import 'package:flutter/material.dart';

enum AtributType { benefit, cost }

class CriteriaManagement extends StatefulWidget {
  static const arah = "/criteria-admin";
  const CriteriaManagement({super.key});

  @override
  State<CriteriaManagement> createState() => _CriteriaManagementState();
}

class _CriteriaManagementState extends State<CriteriaManagement> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  // Daftar kriteria
  List<String> kriteriaList = ["Fasilitas", "Luas kamar", "Keamanan", "Harga"];

  // Bobot untuk setiap kriteria
  Map<String, double> bobotKriteria = {};
  // Atribut (Benefit/Cost) untuk setiap kriteria
  Map<String, AtributType> atributKriteria = {};

  int? _editingIndex;

  @override
  void initState() {
    super.initState();
    for (var k in kriteriaList) {
      bobotKriteria[k] = 0.0;
      atributKriteria[k] = AtributType.benefit;
    }
  }

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
              const Text(
                "Manajemen Kriteria Kost",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: tinggiLayar * 0.03),

              // Input tambah kriteria
              const Text(
                "Masukkan Kriteria",
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
                          bobotKriteria[value.trim()] = 0.0;
                          atributKriteria[value.trim()] = AtributType.benefit;
                          _controller.clear();
                        });
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: tinggiLayar * 0.03),

              // Daftar kriteria
              _buildKriteriaCard(lebarLayar, tinggiLayar, warnaKartu),

              SizedBox(height: tinggiLayar * 0.03),

              // Bobot kriteria
              _buildBobotCard(lebarLayar, tinggiLayar, warnaKartu),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================
  // 🔹 Kartu daftar kriteria
  // ==========================
  Widget _buildKriteriaCard(
      double lebarLayar, double tinggiLayar, Color warnaKartu) {
    return Container(
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
            Container(height: 1, color: Colors.grey.shade300),
            SizedBox(height: tinggiLayar * 0.02),

            // List item kriteria
            Column(
              children: List.generate(
                kriteriaList.length,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: tinggiLayar * 0.015),
                  child: _buildKriteriaItem(
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
    );
  }

  // 🔸 Widget item kriteria
  Widget _buildKriteriaItem(
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
          Expanded(
            child: _editingIndex == index
                ? TextField(
                    controller: _editController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    onSubmitted: (newValue) {
                      if (newValue.trim().isNotEmpty) {
                        setState(() {
                          String old = kriteriaList[index];
                          kriteriaList[index] = newValue.trim();
                          bobotKriteria[newValue.trim()] =
                              bobotKriteria.remove(old) ?? 0.0;
                          atributKriteria[newValue.trim()] =
                              atributKriteria.remove(old) ??
                                  AtributType.benefit;
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
                      _editingIndex = null;
                    } else {
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
                  _showDeleteDialog(kriteriaList[index], () {
                    setState(() {
                      bobotKriteria.remove(kriteriaList[index]);
                      atributKriteria.remove(kriteriaList[index]);
                      kriteriaList.removeAt(index);
                    });
                    Navigator.pop(context);
                  });
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

  // ==========================
  // 🔹 Kartu bobot kriteria
  // ==========================
  Widget _buildBobotCard(
      double lebarLayar, double tinggiLayar, Color warnaKartu) {
    return Container(
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
              "Bobot Kriteria (isi dengan angka)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            SizedBox(height: tinggiLayar * 0.015),
            Container(height: 1, color: Colors.grey.shade300),
            SizedBox(height: tinggiLayar * 0.02),

            // List bobot
            Column(
              children: kriteriaList.map((kriteria) {
                final selected =
                    atributKriteria[kriteria] ?? AtributType.benefit;
                return Padding(
                  padding: EdgeInsets.only(bottom: tinggiLayar * 0.015),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          kriteria,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Dropdown atribut
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: warnaKartu,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<AtributType>(
                            value: selected,
                            items: const [
                              DropdownMenuItem(
                                value: AtributType.benefit,
                                child: Text("Benefit"),
                              ),
                              DropdownMenuItem(
                                value: AtributType.cost,
                                child: Text("Cost"),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() {
                                  atributKriteria[kriteria] = v;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 80,
                        height: 35,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: warnaKartu,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              bobotKriteria[kriteria] =
                                  double.tryParse(value) ?? 0.0;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // 🔸 Dialog hapus
  void _showDeleteDialog(String nama, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Hapus Kriteria?",
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Apakah Anda yakin ingin menghapus '$nama'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.black54)),
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
