import 'dart:convert';

import '../configs/supabase_api_config.dart';
import '../models/kriteria_models.dart';
import 'package:http/http.dart' as htpp;

class KriteriaServices {
  Future<void> createdata(List<Map<String, dynamic>> mana) async {
    print("inisiasi buat kriteria");

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/kriteria");
    print("buat 1 kriteria");

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        'Prefer': 'return=representation',
      },
      body: json.encode(mana),
    );
    print("buat 2 kriteria");

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      print("done buat kriteria ${pengisian.body}");
    } else {
      print("gagal buat data kriteria ${pengisian.body}");
      throw "gagal buat data kriteria ${pengisian.body}";
    }
  }

  Future<List<KriteriaModels>> readdata() async {
    List<KriteriaModels> hasilnya = [];

    // Query dengan order by ranking untuk urutan kriteria yang benar
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kriteria?order=ranking.asc");

    var baca = await htpp.get(url, headers: {
      'Content-Type': 'application/json',
      'apikey': '${SupabaseApiConfig.apisecret}',
      'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
    });

    if (baca.statusCode == 200 || baca.statusCode == 201) {
      final ambil = json.decode(baca.body) as List<dynamic>;
      ambil.forEach((value) {
        var item = KriteriaModels.fromJjson(value);
        hasilnya.add(item);
      });
      print("✅ Kriteria diurutkan berdasarkan ranking");
      for (var k in hasilnya) {
        print("   C${k.ranking}: ${k.kategori} - Bobot: ${k.bobot_decimal}");
      }
    } else {
      print("gagal buat data kriteria ${baca.body}");
      throw "gagal buat data kriteria ${baca.body}";
    }
    return hasilnya;
  }

  Future<void> updateddata(List<Map<String, dynamic>> sebuahlist) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kriteria?on_conflict=id_kriteria");

    var perubahan = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        'Prefer': 'resolution=merge-duplicates'
      },
      body: json.encode(sebuahlist),
    );

    if (perubahan.statusCode <= 205) {
      print(
          "done update data kriteria dengan status code ${perubahan.statusCode} ${perubahan.statusCode}");
    } else {
      print(
          "gagal update data kriteria dengan status code ${perubahan.statusCode} dan masalah nya ${perubahan.body}");
      throw "gagal update data kriteria dengan status code ${perubahan.statusCode} dan masalahnya ${perubahan.body}";
    }
  }

  Future<void> deletedata(int id_kriteria) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kriteria?id_kriteria=eq.$id_kriteria");

    var hapus = await htpp.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
      },
    );

    if (hapus.statusCode == 204) {
      print("berhasil hapus data kriteria pada id $id_kriteria");
    } else {
      print("gagal hapus data kriteria pada id $id_kriteria");
      throw "gagal hapus data kriteria pada id $id_kriteria";
    }
  }
}
