import 'dart:convert';
// import '../configs/supabase_cadangan_api.dart';
import '../configs/supabase_api_config.dart';
import '../models/subkriteria_models.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as htpp;

class SubkriteriaServices {
  Future<List<SubkriteriaModels>> readdata({bool log = false}) async {
    List<SubkriteriaModels> hasilnya = [];

    // Urutkan berdasarkan id_kriteria lalu bobot untuk konsistensi
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/sub_kriteria?order=id_kriteria.asc,bobot.desc");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/sub_kriteria?order=id_kriteria.asc,bobot.desc");

    var simpan = await htpp.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
      },
    );

    if (simpan.statusCode == 200 || simpan.statusCode == 201) {
      final take = json.decode(simpan.body) as List<dynamic>;
      take.forEach((value) {
        var item = SubkriteriaModels.fromJson(value);
        hasilnya.add(item);
      });
      if (kDebugMode && log) {
        debugPrint("✅ Subkriteria diurutkan (${hasilnya.length} data)");
      }
    } else {
      hasilnya = [];
      print("gagal ambil data subkriteria ${simpan.body}");
      throw "gagal ambil data subkriteria ${simpan.body}";
    }
    return hasilnya;
  }

  Future<void> createdata(List<Map<String, dynamic>> mana) async {
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/sub_kriteria");

    // var url =
    //     Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/sub_kriteria");

    var upload = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
        'Prefer': 'return=repsentation',
      },
      body: json.encode(mana),
    );

    if (upload.statusCode == 200 || upload.statusCode == 201) {
      print("done simpan data subkriteria dengan sebanyak ${upload.body}");
    } else {
      print("gagal upload data karena ${upload.body}");
      throw "gagal upload data karena ${upload.body}";
    }
  }

  Future<void> deletedata(int id_subkriteria) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/sub_kriteria?id_subkriteria=eq.$id_subkriteria");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/sub_kriteria?id_subkriteria=eq.$id_subkriteria");

    var delete = await htpp.delete(url, headers: {
      'Content-Type': 'application/json',
      'apikey': '${SupabaseApiConfig.apisecret}',
      'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
      // 'apikey': '${SupabaseCadanganApi.apisecret}',
      // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}'
    });

    if (delete.statusCode == 204) {
      print("hapus data sub_kriteria berhasil pada id $id_subkriteria");
    } else {
      print("gagal hapus data sub_kriteria karena kendala ${delete.body}");
      throw "gagal hapus data sub kriteria karena kendala ${delete.body}";
    }
  }

  Future<void> updateddata(List<Map<String, dynamic>> mana) async {
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/sub_kriteria");

    // var url =
    //     Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/sub_kriteria");

    var editan = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
        'Prefer': 'resolution=merge-duplicates'
      },
      body: json.encode(mana),
    );

    if (editan.statusCode <= 205) {
      print("done updated data sub kriteria dengan data ${editan.body}");
    } else {
      print("gagal update data subkriteria dikarenakan ${editan.body}");
      throw "gagal update data subkriteria dikarenakan ${editan.body}";
    }
  }
}
