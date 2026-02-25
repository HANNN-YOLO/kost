import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/kriteria_provider.dart';
import '../shared/atribut_type.dart';

class KriteriaItem {
  final int? id_kriteria;
  String nama;
  AtributType atribut;
  int ranking; // Ranking untuk ROC (1 = paling penting)
  double bobotDecimal; // Bobot desimal dari database (0.0 - 1.0)
  final TextEditingController bobotController;

  KriteriaItem({
    this.id_kriteria,
    required this.nama,
    this.atribut = AtributType.Benefit,
    this.ranking = 0,
    this.bobotDecimal = 0.0,
    String bobotAwal = "0",
  }) : bobotController = TextEditingController(text: bobotAwal);

  void dispose() {
    bobotController.dispose();
  }
}

class CriteriaManagement extends StatefulWidget {
  static const arah = "/criteria-admin";

  const CriteriaManagement({super.key, this.index = 0});

  final int index;

  @override
  State<CriteriaManagement> createState() => _CriteriaManagementState();
}

class _CriteriaManagementState extends State<CriteriaManagement> {
  final TextEditingController _inputBaruController = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  final List<KriteriaItem> _listKriteria = [];

  // Menyimpan urutan awal kriteria (berdasarkan id_kriteria)
  List<int?> _initialOrder = [];

  // Flag untuk menandai apakah urutan sudah diubah
  bool _hasOrderChanged = false;

  // Flag loading ketika menyimpan perubahan
  bool _isSaving = false;

  // int? _editingIndex;

  bool inisiasi = false;

  late Future<void> _penghubung;

  void _setInitialOrder() {
    _initialOrder = _listKriteria.map((k) => k.id_kriteria).toList();
    _hasOrderChanged = false;
  }

  bool _isSameOrderAsInitial() {
    if (_initialOrder.length != _listKriteria.length) return false;
    for (int i = 0; i < _listKriteria.length; i++) {
      if (_listKriteria[i].id_kriteria != _initialOrder[i]) {
        return false;
      }
    }
    return true;
  }

  // void _perbaruidata() {
  //   setState(() {
  //     inisiasi = false;
  //     _penghubung =
  //         Provider.of<KriteriaProvider>(context, listen: false).readdata();
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    inisiasi = false;
    _penghubung =
        Provider.of<KriteriaProvider>(context, listen: false).readdata();
    // _perbaruidata();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // final penghubung = Provider.of<KriteriaProvider>(context, listen: false);
  //   _perbaruidata();
  // }

  @override
  void dispose() {
    _inputBaruController.dispose();
    _editController.dispose();
    for (var item in _listKriteria) {
      item.dispose();
    }
    super.dispose();
  }

  /// Warna badge ranking berdasarkan posisi prioritas
  Color _getRankingColor(int ranking) {
    switch (ranking) {
      case 1:
        return Colors.green; // Ranking 1 = Paling penting
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tinggiLayar = MediaQuery.of(context).size.height;
    final lebarLayar = MediaQuery.of(context).size.width;
    final penghubung = Provider.of<KriteriaProvider>(context, listen: false);

    const warnaLatar = Color(0xFFF5F7FB);
    const warnaKartu = Color(0xFFE5ECFF);

    return FutureBuilder(
      future: _penghubung,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("kesalahan inisiaisi")),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          //
          if (!inisiasi && penghubung.mydata.isNotEmpty) {
            _listKriteria.clear();

            for (int i = 0; i < penghubung.mydata.length; i++) {
              var data = penghubung.mydata[i];
              _listKriteria.add(
                KriteriaItem(
                  id_kriteria: data.id_kriteria,
                  nama: data.kategori!,
                  atribut: AtributType.fromString(data.atribut!),
                  ranking: data.ranking ??
                      (i + 1), // Gunakan ranking dari DB atau urutan
                  bobotDecimal:
                      data.bobot_decimal ?? 0.0, // Ambil bobot desimal dari DB
                  bobotAwal: data.bobot.toString(),
                ),
              );
            }
            // Urutkan berdasarkan ranking
            _listKriteria.sort((a, b) => a.ranking.compareTo(b.ranking));
            // Simpan urutan awal untuk mendeteksi perubahan urutan
            _setInitialOrder();
            inisiasi = true;
          }

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
                    penghubung.mydata.isEmpty
                        ? Text(
                            "Manajemen Kriteria Kost",
                          )
                        : Text(
                            "Updated Kriteria Kost",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                    SizedBox(height: tinggiLayar * 0.03),

                    SizedBox(height: tinggiLayar * 0.03),

                    // Kartu: Daftar Kriteria dengan ROC (All-in-One)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: lebarLayar * 0.04,
                          vertical: tinggiLayar * 0.02),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 3)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Icon(Icons.format_list_numbered,
                                  color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text("Daftar Kriteria (ROC)",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "💡 Geser untuk mengubah urutan prioritas\n"
                            "Posisi 1 = Paling Penting (bobot tertinggi)",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          Divider(height: 20),

                          // ReorderableListView untuk drag & drop
                          ReorderableListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _listKriteria.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) {
                                  newIndex -= 1;
                                }
                                final item = _listKriteria.removeAt(oldIndex);
                                _listKriteria.insert(newIndex, item);

                                // Update ranking sesuai posisi baru
                                for (int i = 0; i < _listKriteria.length; i++) {
                                  _listKriteria[i].ranking = i + 1;
                                }

                                // Cek apakah urutan berbeda dengan urutan awal
                                _hasOrderChanged = !_isSameOrderAsInitial();

                                print("\n🔄 Urutan berubah:");
                                for (var k in _listKriteria) {
                                  print("   Ranking ${k.ranking}: ${k.nama}");
                                }
                              });
                            },
                            itemBuilder: (context, index) {
                              final item = _listKriteria[index];
                              return Container(
                                key: ValueKey(item.nama + index.toString()),
                                margin: EdgeInsets.only(
                                    bottom: tinggiLayar * 0.012),
                                padding: EdgeInsets.symmetric(
                                    vertical: tinggiLayar * 0.012,
                                    horizontal: lebarLayar * 0.03),
                                decoration: BoxDecoration(
                                  color: warnaKartu,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _getRankingColor(index + 1)
                                        .withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Baris 1: Ranking + Nama + Actions
                                    Row(
                                      children: [
                                        // Badge Ranking
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: _getRankingColor(index + 1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${index + 1}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),

                                        // Nama Kriteria (read-only)
                                        Expanded(
                                          child: Text(
                                            item.nama,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),

                                        // Hanya tampilkan handle drag (tanpa edit/hapus)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.drag_handle,
                                                color: Colors.grey[500],
                                                size: 20),
                                          ],
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 10),

                                    // Baris 2: Bobot + Atribut
                                    Row(
                                      children: [
                                        // Bobot Desimal (Read-Only)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey[400]!),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.percent,
                                                  size: 14,
                                                  color: Colors.grey[600]),
                                              SizedBox(width: 4),
                                              Text(
                                                item.bobotDecimal
                                                    .toStringAsFixed(4),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 10),

                                        // Dropdown Atribut
                                        Container(
                                          height: 32,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey[300]!),
                                          ),
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<AtributType>(
                                              value: item.atribut,
                                              isDense: true,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87,
                                              ),
                                              items: [
                                                DropdownMenuItem(
                                                    value: AtributType.Benefit,
                                                    child: Text("Benefit")),
                                                DropdownMenuItem(
                                                    value: AtributType.Cost,
                                                    child: Text("Cost")),
                                              ],
                                              onChanged: (v) {
                                                if (v == null) return;
                                                setState(() {
                                                  item.atribut = v;
                                                  // Anggap sebagai perubahan yang perlu disimpan
                                                  _hasOrderChanged = true;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Info jika kosong
                          if (_listKriteria.isEmpty)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Text(
                                  "Belum ada kriteria.\nMasukkan kriteria baru di atas.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontStyle: FontStyle.italic,
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
            ),
            bottomNavigationBar:
                // _buildTombolSimpan(lebarLayar, tinggiLayar, penghubung),
                Padding(
              padding: EdgeInsets.all(lebarLayar * 0.05),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: Size(double.infinity, tinggiLayar * 0.065),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                onPressed: (!_hasOrderChanged || _isSaving)
                    ? null
                    : () async {
                        setState(() {
                          _isSaving = true;
                        });

                        try {
                          // Simpan/Update data
                          if (penghubung.mydata.isEmpty) {
                            await penghubung.savemassal(_listKriteria);
                          } else {
                            await penghubung.updatedmassal(_listKriteria);
                          }

                          // Reset inisiasi agar data dari DB di-load ulang ke _listKriteria
                          if (!mounted) return;
                          setState(() {
                            inisiasi = false;
                            _listKriteria.clear();
                            _penghubung = Provider.of<KriteriaProvider>(context,
                                    listen: false)
                                .readdata();
                            _isSaving = false;
                          });
                        } catch (e) {
                          if (!mounted) return;
                          setState(() {
                            _isSaving = false;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menyimpan perubahan: $e'),
                            ),
                          );
                        }
                      },
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Menyimpan...',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Text(
                        penghubung.mydata.isEmpty
                            ? "Simpan"
                            : "Simpan perubahan",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: Text("pastikan terhubung sama jaringan"),
          ),
        );
      },
    );
  }
}
