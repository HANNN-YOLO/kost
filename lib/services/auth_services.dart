import 'dart:convert';
import '../configs/supabase_api_config.dart';
import '../models/auth_model.dart';
import 'package:http/http.dart' as htpp;

class AuthServices {
  Future<Map<String, dynamic>?> login(
      {required String email, required String pass}) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/auth/v1/token?grant_type=password");

    final isi = AuthModel(Email: email, password: pass);

    var pengisian = await htpp.post(url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': '${SupabaseApiConfig.apipublic}'
        },
        body: json.encode(isi.toJson()));

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      final data = json.decode(pengisian.body);
      print(data);
      return data;
    } else {
      print("error ${pengisian.body}");
      throw "error ${pengisian.body}";
    }
  }

  Future<Map<String, dynamic>?> register(
      {required String email, required String pass}) async {
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/auth/v1/signup");

    final isi = AuthModel(Email: email, password: pass);

    var pengisian = await htpp.post(url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': '${SupabaseApiConfig.apipublic}'
        },
        body: json.encode(isi.toJson()));

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      final data = json.decode(pengisian.body);
      print(data);
      return data;
    } else {
      print("error ${pengisian.body}");
      throw "error ${pengisian.body}";
    }
  }

  Future<void> createuser(String token, String UID, String username,
      String Email, String role) async {
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/auth");

    final isi =
        AuthModel(UID: UID, username: username, Email: Email, role: role);

    var pengisian = await htpp.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'apikey': '${SupabaseApiConfig.apipublic}'
        },
        body: json.encode(isi.toJson()));

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      print("done ${pengisian.body}");
    } else {
      print("error ${pengisian.body}");
      throw "error ${pengisian.body}";
    }
  }

  Future<List<AuthModel>> readdata(String token) async {
    List<AuthModel> hasilnya = [];
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/auth");

    var simpan = await htpp.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apikey': '${SupabaseApiConfig.apipublic}'
      },
    );

    if (simpan.statusCode == 200 || simpan.statusCode == 201) {
      final save = json.decode(simpan.body) as List<dynamic>;
      save.forEach((value) {
        var item = AuthModel.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      print("error ${simpan.body}");
      throw "error ${simpan.body}";
    }
    return hasilnya;
  }
}
