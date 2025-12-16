import 'dart:convert';

import '../configs/supabase_api_config.dart';
import '../models/fasilitas_model.dart';
import 'package:http/http.dart' as htpp;

class FasilitasService {
  Future<Map<String, dynamic>> createdata(
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
    // List<FasilitasModel> hasilnya = [];
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/fasilitas");

    var isian = FasilitasModel(
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

    if (pengsian.statusCode == 200 || pengsian.statusCode == 201) {
      final List hasilnya = json.decode(pengsian.body);
      final Map<String, dynamic> hasil = hasilnya[0];

      print("done fasilitas $hasil");
      return hasil;
    } else {
      print("error fasilitas ${pengsian.body}");
      throw "error fasilitas ${pengsian.body}";
    }
  }
}
