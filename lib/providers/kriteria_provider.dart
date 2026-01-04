import 'package:flutter/material.dart';
import '../models/kriteria_models.dart';
import '../services/kriteria_services.dart';

class KriteriaProvider with ChangeNotifier {
  // state penting
  String? _token, _email;
  DateTime? _expires_in;
  int? _id_auth;

  String? get token => _token;
  String? get email => _email;
  DateTime? get expires_in => _expires_in;
  int? get id_auth => id_auth;

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
    }
  }

  // state service
  List<KriteriaModels> _mydata = [];
  List<KriteriaModels> get mydata => _mydata;
  final KriteriaServices _ref = KriteriaServices();

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
}
