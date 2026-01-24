import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../algoritma/rank_order_centroid.dart';
import '../models/kriteria_models.dart';
import '../models/subkriteria_models.dart';
import '../services/kriteria_services.dart';
import '../services/subkriteria_services.dart';
import 'dart:collection';

class KriteriaProvider with ChangeNotifier {
  // state penting
  String? _token, _email;
  DateTime? _expires_in;
  int? _id_auth;

  String? get token => _token;
  String? get email => _email;
  DateTime? get expires_in => _expires_in;
  int? get id_auth => _id_auth;

  void wajiib_terisi(
    String tokennya,
    String emailnya,
    DateTime waktunya,
    int id_authnya,
  ) {
    _token = tokennya;
    _email = emailnya;
    _expires_in = waktunya;
    _id_auth = id_authnya;
    if (_token != null &&
        _email != null &&
        _expires_in != null &&
        _id_auth != null) {
      print("keadaan yang akan dijalankan");
      readdata();
      readdatasubkriteria();
    }
  }

  // state pilihan
  String? nama = "";

  List<String> get kategoriall {
    return _mydata
        .map((element) => element.kategori)
        .whereType<String>()
        .toList();
  }

  List<int> get idnya {
    return _mydata
        .map((element) => element.id_kriteria)
        .whereType<int>()
        .toList();
  }

  // final cek = _mydata.(value) =>

  int? get idta {
    final pengecekan =
        _inidata.firstWhereOrNull((elemen) => elemen.kategori == nama);
    return pengecekan!.id_kriteria;
  }

  List<SubkriteriaModels> get mana {
    if (idta == null) return [];
    return _inidata.where((element) => element.id_kriteria == idta).toList();
  }

  void pilihkriteria(String value) {
    nama = value;
    notifyListeners();
  }

  // state pengecekan
  int get dapat {
    if (mydata.isEmpty || inidata.isEmpty) return 0;
    return _mydata
        .where((element) => element.id_kriteria == _inidata.first.id_kriteria)
        .length;
  }

  // state service
  List<KriteriaModels> _mydata = [];
  List<KriteriaModels> get mydata => _mydata;
  final KriteriaServices _ref = KriteriaServices();

  List<SubkriteriaModels> _inidata = [];
  List<SubkriteriaModels> get inidata => _inidata;
  final SubkriteriaServices _def = SubkriteriaServices();

  // var cek = _mydata.f
  // state cek angka
  // cek = _mydaz

  Future<void> savemassal(List<dynamic> mana) async {
    print("\n" + "=" * 50);
    print("🚀 INISIASI SIMPAN MASSAL KRITERIA DENGAN ROC");
    print("=" * 50);

    // STEP 1: Buat list data kriteria dengan ranking
    // Ranking berdasarkan urutan input (index + 1)
    final List<Map<String, dynamic>> dataKriteria = [];

    for (int i = 0; i < mana.length; i++) {
      var e = mana[i];
      dataKriteria.add({
        'id_auth': int.tryParse(_id_auth.toString()),
        'kategori': e.nama,
        'atribut': e.atribut.value,
        'ranking': i + 1, // Ranking berdasarkan urutan
      });
    }

    print("\n📋 Data sebelum ROC:");
    for (var item in dataKriteria) {
      print("   - ${item['kategori']} (Ranking: ${item['ranking']})");
    }

    // STEP 2: Aplikasikan bobot ROC
    print("\n🔢 Menghitung bobot dengan Rank Order Centroid...");
    final List<Map<String, dynamic>> datadenganROC =
        RankOrderCentroid.aplikasikanBobot(dataKriteria);

    print("\n📋 Data setelah ROC:");
    for (var item in datadenganROC) {
      print(
          "   - ${item['kategori']} → Bobot: ${item['bobot']}% (Ranking: ${item['ranking']})");
    }

    // STEP 3: Simpan ke database via service
    print("\n💾 Menyimpan ke database...");
    await createdata(datadenganROC);

    print("✅ SELESAI: Data kriteria berhasil disimpan dengan bobot ROC!");
    print("=" * 50 + "\n");
  }

  Future<void> createdata(List<Map<String, dynamic>> manami) async {
    print("inisiaisi again");
    try {
      await _ref.createdata(manami);
      print("done gak nih");
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
  }

  Future<void> readdata() async {
    try {
      final sementara = await _ref.readdata();
      _mydata = sementara;
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }

  Future<void> updatedmassal(List<dynamic> manalisnya) async {
    print("\n" + "=" * 50);
    print("🔄 INISIASI UPDATE MASSAL KRITERIA DENGAN ROC");
    print("=" * 50);

    final editan = DateTime.now();

    // STEP 1: Pisahkan data baru dan data lama
    final List<Map<String, dynamic>> semuaData = [];
    final List<Map<String, dynamic>> lastdata = [];
    final List<Map<String, dynamic>> newdata = [];

    // Buat list semua data dengan ranking
    for (int i = 0; i < manalisnya.length; i++) {
      var element = manalisnya[i];
      semuaData.add({
        'id_auth': int.tryParse(_id_auth.toString()),
        'id_kriteria': element.id_kriteria,
        'kategori': element.nama,
        'atribut': element.atribut.value,
        'ranking': i + 1, // Ranking berdasarkan urutan tampilan
      });
    }

    print("\n📋 Total kriteria yang akan diproses: ${semuaData.length}");

    // STEP 2: Aplikasikan bobot ROC ke SEMUA data
    print("\n🔢 Menghitung bobot dengan Rank Order Centroid...");
    final List<Map<String, dynamic>> datadenganROC =
        RankOrderCentroid.aplikasikanBobot(semuaData);

    // STEP 3: Pisahkan data baru dan yang perlu update
    for (var item in datadenganROC) {
      if (item['id_kriteria'] != null) {
        // Data lama - perlu update
        lastdata.add({
          'id_auth': item['id_auth'],
          'id_kriteria': int.tryParse(item['id_kriteria'].toString()),
          'kategori': item['kategori'],
          'atribut': item['atribut'],
          'bobot': item['bobot'],
          'bobot_decimal': item['bobot_decimal'], // Tambahkan bobot desimal
          'ranking': item['ranking'],
          'updatedAt': editan.toIso8601String(),
        });
        print(
            "   📝 UPDATE: ${item['kategori']} → Bobot: ${item['bobot']}% (Decimal: ${item['bobot_decimal']})");
      } else {
        // Data baru - perlu create
        newdata.add({
          'id_auth': item['id_auth'],
          'kategori': item['kategori'],
          'atribut': item['atribut'],
          'bobot': item['bobot'],
          'bobot_decimal': item['bobot_decimal'], // Tambahkan bobot desimal
          'ranking': item['ranking'],
        });
        print(
            "   ➕ CREATE: ${item['kategori']} → Bobot: ${item['bobot']}% (Decimal: ${item['bobot_decimal']})");
      }
    }

    // STEP 4: Simpan ke database
    if (newdata.isNotEmpty) {
      print("\n💾 Menyimpan ${newdata.length} data baru...");
      await createdata(newdata);
      await readdata();
    }

    if (lastdata.isNotEmpty) {
      print("\n💾 Mengupdate ${lastdata.length} data lama...");
      await updateddata(lastdata);
      await readdata();
    }

    print("\n✅ SELESAI: Update massal berhasil dengan bobot ROC!");
    print("=" * 50 + "\n");
  }

  Future<void> updateddata(List<Map<String, dynamic>> mana) async {
    try {
      await _ref.updateddata(mana);
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
  }

  Future<void> deletedata(int id_kriteria) async {
    print("\n" + "=" * 50);
    print("🗑️ PROSES HAPUS KRITERIA & RECALCULATE ROC");
    print("=" * 50);

    try {
      // STEP 1: Hapus kriteria dari database
      print("\n📌 Menghapus kriteria dengan ID: $id_kriteria");
      await _ref.deletedata(id_kriteria);
      print("   ✅ Berhasil dihapus dari database");

      // STEP 2: Baca ulang data terbaru
      await readdata();
      print("\n📊 Jumlah kriteria tersisa: ${_mydata.length}");

      // STEP 3: Jika masih ada kriteria, recalculate ROC
      if (_mydata.isNotEmpty) {
        await _recalculateROC();
      } else {
        print("\n⚠️ Tidak ada kriteria tersisa, skip recalculate ROC");
      }

      print("\n✅ SELESAI: Hapus kriteria dan recalculate ROC berhasil!");
      print("=" * 50 + "\n");
    } catch (e) {
      print("❌ Error saat hapus kriteria: $e");
      throw e;
    }
    notifyListeners();
  }

  /// Method untuk menghitung ulang bobot ROC setelah ada perubahan jumlah kriteria
  Future<void> _recalculateROC() async {
    print("\n" + "-" * 40);
    print("🔄 RECALCULATE ROC - Menyesuaikan bobot");
    print("-" * 40);

    final editan = DateTime.now();

    // Urutkan berdasarkan ranking yang ada (atau id jika ranking null)
    List<KriteriaModels> dataUrut = List.from(_mydata);
    dataUrut.sort((a, b) {
      int rankA = a.ranking ?? a.id_kriteria ?? 999;
      int rankB = b.ranking ?? b.id_kriteria ?? 999;
      return rankA.compareTo(rankB);
    });

    // Buat list data dengan ranking baru (1, 2, 3, ...)
    final List<Map<String, dynamic>> dataKriteria = [];
    for (int i = 0; i < dataUrut.length; i++) {
      var item = dataUrut[i];
      dataKriteria.add({
        'id_auth': item.id_auth,
        'id_kriteria': item.id_kriteria,
        'kategori': item.kategori,
        'atribut': item.atribut,
        'ranking': i + 1, // Ranking baru: 1, 2, 3, ...
      });
      print("   📌 ${item.kategori} → Ranking baru: ${i + 1}");
    }

    // Aplikasikan ROC
    print("\n🔢 Menghitung bobot baru dengan ROC...");
    final List<Map<String, dynamic>> datadenganROC =
        RankOrderCentroid.aplikasikanBobot(dataKriteria);

    // Siapkan data untuk update ke database
    final List<Map<String, dynamic>> updateData = [];
    for (var item in datadenganROC) {
      updateData.add({
        'id_auth': item['id_auth'],
        'id_kriteria': item['id_kriteria'],
        'kategori': item['kategori'],
        'atribut': item['atribut'],
        'bobot': item['bobot'],
        'bobot_decimal': item['bobot_decimal'], // Tambahkan bobot desimal
        'ranking': item['ranking'],
        'updatedAt': editan.toIso8601String(),
      });
      print(
          "   ✨ ${item['kategori']} → Bobot: ${item['bobot']}% | Decimal: ${item['bobot_decimal']} (Ranking: ${item['ranking']})");
    }

    // Update ke database
    print("\n💾 Menyimpan bobot baru ke database...");
    await _ref.updateddata(updateData);
    await readdata();

    print("-" * 40);
  }

  Future<void> readdatasubkriteria() async {
    try {
      final salah = await _def.readdata();
      _inidata = salah;
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }

  Future<void> savemassalsubkriteria(List<dynamic> inilist) async {
    // Validasi bobot: tidak boleh 0 dan tidak boleh ada yang sama
    final List<double> bobotList = [];

    for (var element in inilist) {
      final raw = element.bobot.text.toString().trim();
      final parsed = double.tryParse(raw.replaceAll(',', '.'));

      if (parsed == null) {
        throw 'Bobot subkriteria harus berupa angka yang valid.';
      }
      if (parsed <= 0) {
        throw 'Bobot subkriteria tidak boleh 0 atau negatif.';
      }
      if (bobotList.contains(parsed)) {
        throw 'Bobot subkriteria tidak boleh ada yang sama.';
      }
      bobotList.add(parsed);
    }

    final namanya = inilist
        .map((element) => {
              'id_auth': element.id_auth,
              'id_kriteria': element.id_kriteria,
              'kategori': element.kategori.text,
              'bobot': element.bobot.text,
            })
        .toList();

    await createdadtasubkriteria(namanya);
  }

  Future<void> createdadtasubkriteria(
      List<Map<String, dynamic>> hasillist) async {
    try {
      await _def.createdata(hasillist);
    } catch (e) {
      throw e;
    }
    await readdatasubkriteria();
    notifyListeners();
  }

  Future<void> deletedatasubkriteria(int id_subkriteria) async {
    try {
      await _def.deletedata(id_subkriteria);
    } catch (e) {
      throw e;
    }
    await readdatasubkriteria();
    notifyListeners();
  }

  Future<void> updatedmassalsubkriteria(List<dynamic> mana) async {
    final editan = DateTime.now();

    final List<Map<String, dynamic>> newdata = [];
    final List<Map<String, dynamic>> lastdata = [];

    for (var element in mana) {
      if (element.id_subkriteria != null) {
        lastdata.add({
          'id_kriteria': element.id_kriteria,
          'id_auth': element.id_auth,
          'id_subkriteria': element.id_subkriteria,
          'kategori': element.kategori.text,
          'bobot': element.bobot.text,
          'updatedAt': editan.toIso8601String(),
        });
      } else {
        newdata.add({
          'id_auth': element.id_auth,
          'id_kriteria': element.id_kriteria,
          'kategori': element.kategori.text,
          'bobot': element.bobot.text,
        });
      }
    }

    if (newdata != null) {
      await createdadtasubkriteria(newdata);
      await readdatasubkriteria();
    }

    if (lastdata != null) {
      await updateddatasubkritera(lastdata);
      await readdatasubkriteria();
    }
  }

  Future<void> updateddatasubkritera(List<Map<String, dynamic>> inilah) async {
    try {
      await _def.updateddata(inilah);
    } catch (e) {
      throw e;
    }
    await readdatasubkriteria();
    notifyListeners();
  }
}
