import 'dart:convert';

import '../configs/supabase_api_config.dart';
import '../models/fasilitas_model.dart';
import 'package:http/http.dart' as htpp;

class FasilitasService {
  Future<Map<String, dynamic>> createdata(
    int id_auth,
    bool tempat_tidur,
    bool kamar_mandi_dalam,
    bool meja,
    bool tempat_parkir,
    bool lemari,
    bool ac,
    bool tv,
    bool kipas,
    bool dapur_dalam,
    bool wifi,
  ) async {
    print("inisiasi buat data fasilitas");

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/fasilitas");
    print("buat data 1 fasiitas");

    var isian = FasilitasModel(
      id_auth: id_auth,
      tempat_tidur: tempat_tidur,
      kamar_mandi_dalam: kamar_mandi_dalam,
      meja: meja,
      tempat_parkir: tempat_parkir,
      lemari: lemari,
      ac: ac,
      tv: tv,
      kipas: kipas,
      dapur_dalam: dapur_dalam,
      wifi: wifi,
    );
    print("buat data 2 fasiitas");

    var pengsian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Prefer': 'return=representation',
      },
      body: json.encode(isian.toJson()),
    );
    print("buat data 3 fasiitas");

    if (pengsian.statusCode == 200 || pengsian.statusCode == 201) {
      final List hasilnya = json.decode(pengsian.body);
      final Map<String, dynamic> hasil = hasilnya[0];
      print("done data fasilitas $hasilnya dan ini key fasilitas $hasil");
      return hasil;
    } else {
      print("error fasilitas ${pengsian.body}");
      throw "error fasilitas ${pengsian.body}";
    }
  }

  Future<void> deletedata(int id_fasilitas) async {
    print("inisiasi hapus data fasilitas");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/fasilitas?id_fasilitas=eq.$id_fasilitas");
    print("hapus data 1 fasiiliatas");

    var delete = await htpp.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
      },
    );
    print("hapus data 2 fasilitas");

    if (delete.statusCode == 204) {
      print("done hapus data fasilitas");
    } else {
      print("error hapus data fasilitas");
      throw "error hapus data fasilitas";
    }
  }

  Future<void> updateddata(
    int id_fasilitas,
    int id_auth,
    bool tempat_tidur,
    bool kamar_mandi_dalam,
    bool meja,
    bool tempat_parkir,
    bool lemari,
    bool ac,
    bool tv,
    bool kipas,
    bool dapur_dalam,
    bool wifi,
    DateTime updatedAt,
  ) async {
    print("insiaisi perubahan data fasilitas");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/fasilitas?id_fasilitas=eq.$id_fasilitas");
    print("update data fasilitas 1");

    var isian = FasilitasModel(
      id_auth: id_auth,
      tempat_tidur: tempat_tidur,
      kamar_mandi_dalam: kamar_mandi_dalam,
      meja: meja,
      tempat_parkir: tempat_parkir,
      lemari: lemari,
      ac: ac,
      tv: tv,
      kipas: kipas,
      dapur_dalam: dapur_dalam,
      wifi: wifi,
      updatedAt: updatedAt,
    );
    print("update data fasilitas 2");

    var updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
      },
      body: json.encode(isian.toJson()),
    );
    print("update data fasilitas 3");

    if (updated.statusCode == 204) {
      print("data perubahan di fasilitas dengan isi nya ${updated.body}");
    } else {
      print("error data tidak bisa ke update ${updated.body}");
      throw "error data tidak bisa ke updated ${updated.body}";
    }
  }

  Future<List<FasilitasModel>> readdata() async {
    List<FasilitasModel> hasilnya = [];
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/fasilitas");

    var save = await htpp.get(url, headers: {
      'Content-Type': 'application/json',
      'apikey': '${SupabaseApiConfig.apisecret}',
      'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
    });

    if (save.statusCode == 200) {
      final ambil = json.decode(save.body) as List<dynamic>;
      ambil.forEach((value) {
        var item = FasilitasModel.fromJson(value);
        hasilnya.add(item);
      });
      // print("done ambil datanya fasilitas $ambil");
    } else {
      print("error ambi data fasilitas ${save.body}");
      throw "error ambil data fasilitas ${save.body}";
    }
    return hasilnya;
  }

  Future<List<FasilitasModel>> readdatapenyewa(String token) async {
    List<FasilitasModel> hasilnya = [];

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/fasilitas");

    var simpan = await htpp.get(
      url,
      headers: {
        "Content-Type": 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token'
      },
    );
    if (simpan.statusCode == 200) {
      final ambil = json.decode(simpan.body) as List<dynamic>;
      ambil.forEach((value) {
        var item = FasilitasModel.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      print("error ambil data fasilitas penyewa");
      throw "error ambil data fasilitas penyewa";
    }
    return hasilnya;
  }

  Future<List<FasilitasModel>> readdatapemilik(
    int id_auth,
    String token,
  ) async {
    List<FasilitasModel> hasilnya = [];

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/fasilitas?id_auth=eq.$id_auth&select=*");

    var simpan = await htpp.get(url, headers: {
      'Content-Type': 'application/json',
      'apikey': '${SupabaseApiConfig.apipublic}',
      'Authorization': 'Bearer $token',
      // 'Prefer': 'returns=representation'
    });

    if (simpan.statusCode == 200) {
      final ambil = json.decode(simpan.body) as List<dynamic>;
      ambil.forEach((value) {
        var item = FasilitasModel.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      print("gagal mengambil data fasilitas pemilik ${simpan.body}");
      throw "Gagagl mengambil data fasilitas pemilik ${simpan.body}";
    }
    return hasilnya;
  }

  Future<Map<String, dynamic>> createdatapemilik(
    String token,
    int id_auth,
    bool tempat_tidur,
    bool kamar_mandi_dalam,
    bool meja,
    bool tempat_parkir,
    bool lemari,
    bool ac,
    bool tv,
    bool kipas,
    bool dapur_dalam,
    bool wifi,
  ) async {
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/fasilitas");

    final isian = FasilitasModel(
        id_auth: id_auth,
        tempat_tidur: tempat_tidur,
        kamar_mandi_dalam: kamar_mandi_dalam,
        meja: meja,
        tempat_parkir: tempat_parkir,
        ac: ac,
        tv: tv,
        kipas: kipas,
        dapur_dalam: dapur_dalam,
        wifi: wifi);

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token',
        'Prefer': 'return=representation'
      },
      body: json.encode(isian.toJson()),
    );

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      final List ambil = json.decode(pengisian.body);
      final Map<String, dynamic> inicuy = ambil[0];
      print(
          "data fasilitas dari pemilik sebanyak $ambil dan ini key nya $inicuy");
      return inicuy;
    } else {
      print("gagal ambil key fasilitas ${pengisian.body}");
      throw "Gagal ambil key fasilitas ${pengisian.body}";
    }
  }

  Future<void> updateddatapemilik(
    String token,
    int id_auth,
    int id_fasilitas,
    bool tempat_tidur,
    bool kamar_mandi_dalam,
    bool meja,
    bool tempat_parkir,
    bool lemari,
    bool ac,
    bool tv,
    bool dapur_dalam,
    bool wifi,
    DateTime editan,
  ) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/fasilitas?id_fasilitas=eq.$id_fasilitas");

    final isian = FasilitasModel(
      id_auth: id_auth,
      tempat_tidur: tempat_tidur,
      kamar_mandi_dalam: kamar_mandi_dalam,
      meja: meja,
      tempat_parkir: tempat_parkir,
      lemari: lemari,
      ac: ac,
      tv: tv,
      dapur_dalam: dapur_dalam,
      wifi: wifi,
      updatedAt: editan,
    );

    var updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'Application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(isian.toJson()),
    );

    if (updated.statusCode == 204) {
      print("done updated data fasilitas pemilik ${updated.body}");
    } else {
      print("gagal updated data fasilitas pemilik ${updated.body}");
      throw "gagal updated data fasilitas pemilik ${updated.body}";
    }
  }

  Future<void> deletedatapemilik(String token, int id_fasilitas) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/fasilitas?id_fasilitas=eq.$id_fasilitas");

    var hapus = await htpp.delete(url, headers: {
      'Content-Type': 'application/json',
      'apikey': '${SupabaseApiConfig.apipublic}',
      'Authorization': 'Bearer $token'
    });

    if (hapus.statusCode == 204) {
      print(
          "hapus berhasil di data fasilitas pemilik sekaligus di tabel kost karena cascade");
    } else {
      print("data gagal di hapus di data fasilitas pemilik");
      throw "data gagagl di hapus di data fasilitas pemilik";
    }
  }
}
