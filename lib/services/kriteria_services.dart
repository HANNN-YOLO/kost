import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../configs/supabase_api_config.dart';
import '../models/kriteria_models.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as htpp;
// import '../configs/supabase_cadangan_api.dart';

class KriteriaServices {
  Future<void> createdata(List<Map<String, dynamic>> mana) async {
    print("inisiasi buat kriteria");

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/kriteria");

    // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/kriteria");
    print("buat 1 kriteria");

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
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

  Future<List<KriteriaModels>> readdata({bool log = false}) async {
    List<KriteriaModels> hasilnya = [];

    // Query dengan order by ranking untuk urutan kriteria yang benar
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kriteria?order=ranking.asc");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/kriteria?order=ranking.asc");

    htpp.Response? baca;
    const maxAttempts = 2;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        baca = await htpp.get(url, headers: {
          'Content-Type': 'application/json',
          'apikey': '${SupabaseApiConfig.apisecret}',
          'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
          // 'apikey': '${SupabaseCadanganApi.apisecret}',
          // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}'
        }).timeout(const Duration(seconds: 20));
        break;
      } on TimeoutException catch (e) {
        if (attempt >= maxAttempts) {
          throw 'Koneksi timeout saat mengambil data kriteria. Coba lagi. (${e.message ?? ''})';
        }
        await Future<void>.delayed(const Duration(milliseconds: 600));
        continue;
      } on SocketException catch (e) {
        if (attempt >= maxAttempts) {
          throw 'Koneksi terputus saat mengambil data kriteria. Coba lagi. (${e.osError?.message ?? e.message})';
        }
        await Future<void>.delayed(const Duration(milliseconds: 600));
        continue;
      } on htpp.ClientException catch (e) {
        if (attempt >= maxAttempts) {
          throw 'Gagal terhubung ke server saat mengambil data kriteria. Coba lagi. (${e.message})';
        }
        await Future<void>.delayed(const Duration(milliseconds: 600));
        continue;
      }
    }

    if (baca == null) {
      throw 'Gagal mengambil data kriteria. Coba lagi.';
    }

    if (baca.statusCode == 200 || baca.statusCode == 201) {
      final ambil = json.decode(baca.body) as List<dynamic>;
      ambil.forEach((value) {
        var item = KriteriaModels.fromJjson(value);
        hasilnya.add(item);
      });
      if (kDebugMode && log) {
        debugPrint("✅ Kriteria diurutkan berdasarkan ranking");
        for (var k in hasilnya) {
          debugPrint(
              "   C${k.ranking}: ${k.kategori} - Bobot: ${k.bobot_decimal}");
        }
      }
    } else {
      print("gagal ambil data kriteria: ${baca.statusCode} ${baca.body}");
      throw "Gagal ambil data kriteria (${baca.statusCode}).";
    }
    return hasilnya;
  }

  Future<void> updateddata(List<Map<String, dynamic>> sebuahlist) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kriteria?on_conflict=id_kriteria");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/kriteria?on_conflict=id_kriteria");

    var perubahan = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
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

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/kriteria?id_kriteria=eq.$id_kriteria");

    var hapus = await htpp.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}'
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
