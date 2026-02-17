import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../models/tujuan_models.dart';
import '../services/tujuan_services.dart';
// import 'dart:collection';

class TujuanProviders with ChangeNotifier {
  // state penting
  String? _tokenid, _emails;
  DateTime? _expiresin;

  String? get tokenid => _tokenid;
  String? get emails => _emails;
  DateTime? get expiresin => _expiresin;

  void terisi(String token, String email, DateTime waktu) {
    _tokenid = token;
    _emails = email;
    _expiresin = waktu;
    if (_tokenid != null && _emails != null) {
      readdata();
    }
  }

  // state dropdown di penyewa
  List<String> get nama_tujuan {
    return _mydata
        .map((element) => element.namatujuan)
        .whereType<String>()
        .toList();
  }

  /// Mendapatkan semua data tempat tujuan (untuk dropdown)
  List<TujuanModels> get daftarTempat => _mydata;

  /// Mendapatkan koordinat berdasarkan nama tempat
  /// Returns null jika tidak ditemukan
  ({double lat, double lng})? getKoordinatByNama(String nama) {
    final tempat = _mydata.firstWhereOrNull(
      (element) => element.namatujuan == nama,
    );
    if (tempat != null &&
        tempat.garislintang != null &&
        tempat.garisbujur != null) {
      return (lat: tempat.garislintang!, lng: tempat.garisbujur!);
    }
    return null;
  }

  /// Mendapatkan TujuanModels berdasarkan nama
  TujuanModels? getTempatByNama(String nama) {
    return _mydata.firstWhereOrNull(
      (element) => element.namatujuan == nama,
    );
  }

  // state services
  List<TujuanModels> _mydata = [];
  List<TujuanModels> get mydata => _mydata;
  final TujuanServices _ref = TujuanServices();

  Future<void> createdata(String tujuan, String koordinat) async {
    try {
      if (koordinat != null) {
        List<String> sementara = koordinat.split(',');
        double lintang = double.parse(sementara[0]);
        double bujur = double.parse(sementara[1]);

        if (lintang != null && bujur != null) {
          await _ref.createdata(tujuan, lintang, bujur);
        }
      }
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
  }

  Future<void> readdata() async {
    try {
      final hasilnya = await _ref.readdata();
      _mydata = hasilnya;
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }

  Future<void> deletedata(int id_tujuan) async {
    try {
      await _ref.deletedata(id_tujuan);
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
  }

  Future<void> updateddata(
    int id_tujuan,
    String tujuan,
    String koordinat,
  ) async {
    final editan = DateTime.now();
    try {
      if (koordinat != null) {
        final List<String> nama = koordinat.split(',');
        double lintang = double.parse(nama[0]);
        double bujur = double.parse(nama[1]);

        if (lintang != null && bujur != null) {
          await _ref.updateddata(id_tujuan, tujuan, lintang, bujur, editan);
        }
      }
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
  }
}
