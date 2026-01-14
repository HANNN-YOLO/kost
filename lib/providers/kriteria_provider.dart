import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
    print("inisiasisi");
    final inimi = mana
        .map((e) => {
              'id_auth': int.tryParse(_id_auth.toString()),
              'kategori': e.nama,
              'atribut': e.atribut.value,
              'bobot': int.tryParse(e.bobotController.text),
            })
        .toList();
    print("eh bisanih");

    await createdata(inimi);
    print("cihuy");
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
    final editan = DateTime.now();

    final List<Map<String, dynamic>> lastdata = [];
    final List<Map<String, dynamic>> newdata = [];

    for (var element in manalisnya) {
      if (element.id_kriteria != null) {
        lastdata.add({
          'id_auth': int.tryParse(_id_auth.toString()),
          'id_kriteria': int.tryParse(element.id_kriteria.toString()),
          'kategori': element.nama,
          'atribut': element.atribut.value,
          'bobot': int.tryParse(element.bobotController.text),
          'updatedAt': editan.toIso8601String(),
        });
      } else {
        newdata.add({
          'id_auth': int.tryParse(_id_auth.toString()),
          'kategori': element.nama,
          'atribut': element.atribut.value,
          'bobot': int.tryParse(element.bobotController.text),
        });
      }
    }

    if (newdata != null) {
      await createdata(newdata);
      await readdata();
    }

    if (lastdata != null) {
      await updateddata(lastdata);
      await readdata();
    }

    // await updateddata(ambil);
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
    try {
      await _ref.deletedata(id_kriteria);
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
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
          'bobot': element.bobot.text
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
