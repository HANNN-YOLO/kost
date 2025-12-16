import 'dart:convert';
import '../configs/supabase_api_config.dart';
import '../models/profil_model.dart';
import 'package:http/http.dart' as htpp;
import 'package:image_picker/image_picker.dart';

class ProfilService {
  // CD foto
  Future<String> uploadfoto(XFile foto, String token) async {
    final si = "${foto.name}";

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/profil/$si");

    var namanya = await foto.readAsBytes();

    var simpan = await htpp.post(
      url,
      headers: {
        'Content-Type': '/images/$si.jpg',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: namanya,
    );

    if (simpan.statusCode == 200 || simpan.statusCode == 201) {
      final link =
          "${SupabaseApiConfig.masterurl}/storage/v1/object/public/profil/$si";
      print("done $link");
      return link;
    } else {
      print("error foto ${simpan.body}");
      throw "error foto${simpan.body}";
    }
  }

  Future<void> hapusgambar(String link, String token) async {
    var url = Uri.parse("$link");
    final akhir = url.pathSegments.last;

    var arah = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/profil/$akhir");

    var hapus = await htpp.delete(
      arah,
      headers: {
        'Content-Type': '/images/$akhir.jpg',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token'
      },
    );

    if (hapus.statusCode == 200) {
      print("done foto ${hapus.body}");
    } else {
      print("error foto ${hapus.body}");
      throw "error foto ${hapus.body}";
    }
  }

  // CRUD data
  Future<List<ProfilModel>> readdata(String token, int idAuth) async {
    List<ProfilModel> hasilnya = [];

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/profil?id_auth=eq.$idAuth&select=*");

    var simpan = await htpp.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'apikey': '${SupabaseApiConfig.apipublic}'
    });

    if (simpan.statusCode == 200 || simpan.statusCode == 201) {
      final ambil = json.decode(simpan.body) as List<dynamic>;
      ambil.forEach((value) {
        var item = ProfilModel.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      print("errror ${simpan.body}");
      throw "errror ${simpan.body}";
    }
    return hasilnya;
  }

  Future<void> createprofil(
    int id_auth,
    String token,
    String link,
    DateTime tgllahir,
    String jkl,
    int hp,
  ) async {
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/profil");

    final isian = ProfilModel(
      id_auth: id_auth,
      foto: link,
      tgllahir: tgllahir,
      jkl: jkl,
      kontak: hp,
    );

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apikey': '${SupabaseApiConfig.apipublic}'
      },
      body: json.encode(isian.toJson()),
    );

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      print("done ${pengisian.body}");
    } else {
      print("error data ${pengisian.body}");
      throw "error data ${pengisian.body}";
    }
  }

  Future<void> updateprofil(int Id_profil, String token, String link,
      DateTime tgllahir, String jkl, int kontak, DateTime edit) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/profil?id_profil=eq.$Id_profil");

    final isian = ProfilModel(
      foto: link,
      tgllahir: tgllahir,
      jkl: jkl,
      kontak: kontak,
      updatedAt: edit,
    );

    var pengsian = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(isian.toJson()),
    );

    if (pengsian.statusCode == 204) {
      print("done data ${pengsian.body}");
    } else {
      print("error data ${pengsian.body}");
      throw "error data ${pengsian.body}";
    }
  }

  Future<List<ProfilModel>> readuser() async {
    List<ProfilModel> hasilnya = [];

    var url =
        Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/profil?select=*");

    var simpan = await htpp.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
      },
    );

    if (simpan.statusCode == 200 || simpan.statusCode == 201) {
      final isian = json.decode(simpan.body) as List<dynamic>;
      isian.forEach(
        (value) {
          var item = ProfilModel.fromJson(value);
          hasilnya.add(item);
        },
      );
    } else {
      print("error ${simpan.body}");
      throw "error ${simpan.body}";
    }
    return hasilnya;
  }
}
