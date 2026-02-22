import 'dart:convert';
// import '../configs/supabase_cadangan_api.dart';
import '../configs/supabase_api_config.dart';
import '../models/tujuan_models.dart';
import 'package:http/http.dart' as htpp;

class TujuanServices {
  Future<void> createdata(String tujuan, double lintang, double bujur) async {
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/tempat");

    // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/tempat");

    var isian = TujuanModels(
      namatujuan: tujuan,
      garislintang: lintang,
      garisbujur: bujur,
    );

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
        'Prefer': 'returns=resolution'
      },
      body: json.encode(isian.toJson()),
    );

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      print("done create data ${pengisian.body}");
    } else {
      print("gagal create data ${pengisian.body}");
      throw "gagal create data ${pengisian.body}";
    }
  }

  Future<List<TujuanModels>> readdata() async {
    List<TujuanModels> hasilnya = [];

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/tempat");

    // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/tempat");

    var pengambilan = await htpp.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}'
      },
    );

    if (pengambilan.statusCode == 200 || pengambilan.statusCode == 201) {
      final take = json.decode(pengambilan.body) as List<dynamic>;

      take.forEach((value) {
        final pengambilan = TujuanModels.fromJson(value);
        hasilnya.add(pengambilan);
      });
    } else {
      print("gagal ambil data tujuan ${pengambilan.body}");
      throw "gagal ambil data tujuan ${pengambilan.body}";
    }
    return hasilnya;
  }

  Future<void> updateddata(int id_tujuan, String tujuan, double lintang,
      double bujur, DateTime editan) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/tempat?id_tujuan=eq.$id_tujuan");

    // var url = Uri.parse(
    // "${SupabaseCadanganApi.masterurl}/rest/v1/tempat?id_tujuan=eq.$id_tujuan");

    var isian = TujuanModels(
        namatujuan: tujuan,
        garislintang: lintang,
        garisbujur: bujur,
        updatedAt: editan);

    var updated = await htpp.patch(url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': '${SupabaseApiConfig.apisecret}',
          'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
          // 'apikey': '${SupabaseCadanganApi.apisecret}',
          // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}'
        },
        body: json.encode(isian.toJson()));

    if (updated.statusCode <= 205) {
      print("update data tujuan ${updated.body}");
    } else {
      print("gagal update datab tujuan ${updated.body}");
      throw "gagal update data tujuan ${updated.body}";
    }
  }

  Future<void> deletedata(int id_tujuan) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/tempat?id_tujuan=eq.$id_tujuan");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/tempat?id_tujuan=eq.$id_tujuan");

    var hapus = await htpp.delete(url, headers: {
      'Content-Type': 'application/json',
      'apikey': '${SupabaseApiConfig.apisecret}',
      'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
      // 'apikey': '${SupabaseCadanganApi.apisecret}',
      // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}'
    });

    if (hapus.statusCode == 204) {
      print("done hapus data tujuann ${hapus.body}");
    } else {
      print("gagal hapus data tujuan ${hapus.body}");
      throw "gagal hapus data tujuan ${hapus.body}";
    }
  }
}
