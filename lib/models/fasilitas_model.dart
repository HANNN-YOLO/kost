import 'package:flutter/material.dart';

class FasilitasModel with ChangeNotifier {
  int? id_fasilitas, id_auth;
  bool tempat_tidur,
      kamar_mandi_dalam,
      meja,
      tempat_parkir,
      lemari,
      ac,
      tv,
      kipas,
      dapur_dalam,
      wifi;
  DateTime? createdAt, updatedAt;

  FasilitasModel({
    this.id_fasilitas,
    this.id_auth,
    this.tempat_tidur = false,
    this.kamar_mandi_dalam = false,
    this.meja = false,
    this.tempat_parkir = false,
    this.lemari = false,
    this.ac = false,
    this.tv = false,
    this.kipas = false,
    this.dapur_dalam = false,
    this.wifi = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id_auth': id_auth,
      'tempat_tidur': tempat_tidur,
      'kamar_mandi_dalam': kamar_mandi_dalam,
      'meja': meja,
      'tempat_parkir': tempat_parkir,
      'lemari': lemari,
      'ac': ac,
      'tv': tv,
      'kipas': kipas,
      'dapur_dalam': dapur_dalam,
      'wifi': wifi,
    };

    if (id_fasilitas != null) {
      data['id_fasilitas'] = id_fasilitas;
    }

    if (createdAt != null) {
      data['createdAt'] = createdAt;
    }

    if (updatedAt != null) {
      data['updatedAt'] = updatedAt!.toIso8601String();
    }
    return data;
  }

  factory FasilitasModel.fromJson(Map<String, dynamic> json) {
    return FasilitasModel(
      id_fasilitas: json['id_fasilitas'],
      id_auth: json['id_auth'],
      tempat_tidur: json['tempat_tidur'],
      kamar_mandi_dalam: json['kamar_mandi_dalam'],
      meja: json['meja'],
      tempat_parkir: json['tempat_parkir'],
      lemari: json['lemari'],
      ac: json['ac'],
      tv: json['tv'],
      kipas: json['kipas'],
      dapur_dalam: json['dapur_dalam'],
      wifi: json['wifi'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  void booltempattidur() {
    this.tempat_tidur = !this.tempat_tidur;
    notifyListeners();
  }

  void boolkamarmandidalam() {
    this.kamar_mandi_dalam = !this.kamar_mandi_dalam;
    notifyListeners();
  }

  void boolmeja() {
    this.meja = !this.meja;
    notifyListeners();
  }

  void booltempatparkir() {
    this.tempat_parkir = !this.tempat_parkir;
    notifyListeners();
  }

  void boollemari() {
    this.lemari = !this.lemari;
    notifyListeners();
  }

  void boolac() {
    this.ac = !this.ac;
    notifyListeners();
  }

  void booltv() {
    this.tv = !this.tv;
    notifyListeners();
  }

  void boolkipas() {
    this.kipas = !this.kipas;
    notifyListeners();
  }

  void booldapurdalam() {
    this.dapur_dalam = !this.dapur_dalam;
    notifyListeners();
  }

  void boolwifi() {
    this.wifi = !this.wifi;
    notifyListeners();
  }

  void resetcheckbox() {
    this.tempat_tidur = false;
    this.kamar_mandi_dalam = false;
    this.meja = meja;
    this.tempat_parkir = false;
    this.lemari = false;
    this.ac = false;
    this.tv = false;
    this.kipas = false;
    this.dapur_dalam = false;
    this.wifi = false;
    notifyListeners();
  }
}
