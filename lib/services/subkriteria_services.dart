import 'dart:convert';

import '../configs/supabase_api_config.dart';
import '../models/subkriteria_models.dart';
import 'package:http/http.dart' as htpp;

class SubkriteriaServices {
  Future<List<SubkriteriaModels>> readdata() async {
    List<SubkriteriaModels> hasilnya = [];

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/subkriteria");

    var simpan = await htpp.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
      },
    );

    if (simpan.statusCode == 200 || simpan.statusCode == 201) {
      final take = json.decode(simpan.body) as List<dynamic>;
      take.forEach((value) {
        var item = SubkriteriaModels.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      hasilnya = [];
      print("gagal ambil data subkriteria ${simpan.body}");
      throw "gagal ambil data subkriteria ${simpan.body}";
    }
    return hasilnya;
  }
}
