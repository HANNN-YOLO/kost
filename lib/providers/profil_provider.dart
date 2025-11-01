import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profil_model.dart';
import '../services/profil_service.dart';

class ProfilProvider with ChangeNotifier {
  // state ambil
  String? _accesstoken, _email;
  String? get accesstoken => _accesstoken;
  String? get email => _email;
  int? id_auth;

  void terisi(String value, String isi, int angka) async {
    _accesstoken = value;
    _email = isi;
    id_auth = angka;
    if (_accesstoken != null && _email != null && id_auth != null) {
      readdata(_accesstoken!);
    }
    notifyListeners();
  }

  // State dropdown profil
  List<String> _jkl = ['Laki-Laki', 'Perempuan'];
  List<String> get jkl => _jkl;
  String? defaults = 'Jenis Kelamin';

  void pilihan(String value) {
    defaults = value;
    notifyListeners();
  }

  pilihanbersih() {
    defaults = null;
    notifyListeners();
  }

  // state urus foto
  XFile? _isinya;
  XFile? get isinya => _isinya;

  Future<void> uploadfoto() async {
    final pembuka = ImagePicker();
    final cek = await pembuka.pickImage(source: ImageSource.gallery);
    if (cek != null) {
      _isinya = cek;
    }
    notifyListeners();
  }

  bersihfoto(XFile? foto) {
    foto = null;
    notifyListeners();
  }

  // Penghubung ke Service
  List<ProfilModel> _mydata = [];
  List<ProfilModel> get mydata => _mydata;
  final ProfilService _ref = ProfilService();
  int? id_profil;

  Future<void> readdata(String token) async {
    try {
      final hasilnya = await _ref.readdata(token, id_auth!);
      _mydata = hasilnya;
      id_profil = mydata.first.id_profil;
    } catch (e) {
      // throw e;
    }
    notifyListeners();
  }

  Future<void> createprofil(
      XFile foto, DateTime tgllahir, String jkl, int hp) async {
    try {
      final link = await _ref.uploadfoto(foto, _accesstoken!);
      if (link != null) {
        await _ref.createprofil(
            id_auth!, _accesstoken!, link, tgllahir, jkl, hp);
      }
    } catch (e) {
      throw e;
    }
    await readdata(_accesstoken!);
    notifyListeners();
  }

  Future<void> updateprofil(XFile? foto, String linklama, DateTime tgllahir,
      String jkl, int hp) async {
    final edit = DateTime.now();
    await readdata(_accesstoken!);
    try {
      if (linklama != null && foto == null) {
        await _ref.updateprofil(
            id_profil!, _accesstoken!, linklama, tgllahir, jkl, hp, edit);
      } else {
        await _ref.hapusgambar(linklama, _accesstoken!);
        final link = await _ref.uploadfoto(foto!, _accesstoken!);
        if (link != null) {
          await _ref.updateprofil(
              id_profil!, _accesstoken!, link, tgllahir, jkl, hp, edit);
        }
      }
    } catch (e) {
      print(e);
      throw e;
    }
    await readdata(_accesstoken!);
    notifyListeners();
  }

  // state halaman keluar
  void reset() {
    _accesstoken = null;
    _email = null;

    _mydata = [];
    _isinya = null;
    defaults = "jenis Kelamin";

    id_profil = null;
    id_auth = null;
    notifyListeners();
  }
}
