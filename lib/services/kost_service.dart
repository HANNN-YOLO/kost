import 'dart:convert';
import '../models/kost_model.dart';
import '../configs/supabase_api_config.dart';
import 'package:http/http.dart' as htpp;
import 'package:image_picker/image_picker.dart';

class KostService {
  // modul Storage
  Future<String> uploadgambar(XFile gambar) async {
    final siapa = "${gambar.name}";

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/kost/$siapa");

    var isian = await gambar.readAsBytes();

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': '/images/$siapa.jpg',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
      },
      body: isian,
    );

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      final ambil =
          "${SupabaseApiConfig.masterurl}/storage/v1/object/public/kost/$siapa";
      print("done $ambil");
      return ambil;
    } else {
      print("error foto kost ${pengisian.body}");
      throw "error foto kost ${pengisian.body}";
    }
  }

  // CRUD table
  Future<void> createdata(
    int id_fasilitas,
    int notlp_kost,
    String nama_kost,
    String alamat_kost,
    String pemilik_kost,
    int harga_kost,
    String jenis_kost,
    String keamanan,
    String batas_jam_malam,
    String jenis_pembayaran_air,
    String jenis_listrik,
    int panjang,
    int lebar,
    double garis_lintang,
    double garis_bujur,
    String gambar,
  ) async {
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/kost");

    var isian = KostModel(
      id_fasilitas: id_fasilitas,
      notlp_kost: notlp_kost,
      nama_kost: nama_kost,
      alamat_kost: alamat_kost,
      pemilik_kost: pemilik_kost,
      harga_kost: harga_kost,
      jenis_kost: jenis_kost,
      keamanan: keamanan,
      batas_jam_malam: batas_jam_malam,
      jenis_listrik: jenis_listrik,
      jenis_pembayaran_air: jenis_pembayaran_air,
      panjang: panjang,
      lebar: lebar,
      garis_lintang: garis_lintang,
      garis_bujur: garis_bujur,
      gambar_kost: gambar,
    );

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        'Prefer': 'returns=representation',
      },
      body: json.encode(isian.toJson()),
    );

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      // final ambil = json.decode(pengisian.body);
      print("done kost");
    } else {
      print("error kost ${pengisian.body}");
      throw "error kost ${pengisian.body}";
    }
  }
}
