import 'dart:convert';
import '../configs/supabase_api_config.dart';
import '../models/profil_model.dart';
import 'package:http/http.dart' as htpp;
import 'package:image_picker/image_picker.dart';

class ProfilService {
  // CD foto
  Future<String> uploadfoto(XFile foto, String token) async {
    print("inisiasi upload foto");

    final si = "${foto.name}";
    print("upload foto 1 profil");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/profil/$si");
    print("upload foto 2 profil");

    var namanya = await foto.readAsBytes();
    print("upload foto 3 profil");

    var simpan = await htpp.post(
      url,
      headers: {
        'Content-Type': '/images/$si.jpg',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: namanya,
    );
    print("upload foto 4 profil");

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
    print("inisiasi hapus foto");

    var url = Uri.parse("$link");
    print("hapus gambar 1 profil");

    final akhir = url.pathSegments.last;
    print("hapus gambar 2 profil");

    var arah = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/profil/$akhir");
    print("hapus gambar 3 profil");

    var hapus = await htpp.delete(
      arah,
      headers: {
        'Content-Type': '/images/$akhir.jpg',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token'
      },
    );
    print("hapus gambar 4 profil");

    if (hapus.statusCode == 200 || hapus.statusCode == 204) {
      // sukses hapus
      print("done foto ${hapus.body}");
    } else if (hapus.statusCode == 404) {
      // objek sudah tidak ada di storage -> anggap aman (idempotent delete)
      print(
          "foto tidak ditemukan saat dihapus, lanjut tanpa error: ${hapus.body}");
    } else {
      // status lain tetap dianggap error
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
    print("inisiasi buat data");

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/profil");
    print("buat data 1 profil");

    final isian = ProfilModel(
      id_auth: id_auth,
      foto: link,
      tgllahir: tgllahir,
      jkl: jkl,
      kontak: hp,
    );
    print("buat data 2 profil");

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apikey': '${SupabaseApiConfig.apipublic}'
      },
      body: json.encode(isian.toJson()),
    );
    print("buat data 3 profil");

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      print("done ${pengisian.body}");
    } else {
      print("error data ${pengisian.body}");
      throw "error data ${pengisian.body}";
    }
  }

  Future<void> updateprofil(
    int Id_profil,
    String token,
    String link,
    DateTime tgllahir,
    String jkl,
    int kontak,
    DateTime edit,
  ) async {
    print("inisasi perubahan data");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/profil?id_profil=eq.$Id_profil");
    print("ubah data 1 profil");

    final isian = ProfilModel(
      foto: link,
      tgllahir: tgllahir,
      jkl: jkl,
      kontak: kontak,
      updatedAt: edit,
    );
    print("ubah data 2 profil");

    var pengsian = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(isian.toJson()),
    );
    print("ubah data 3 profil");

    if (pengsian.statusCode == 204) {
      print("done data ${pengsian.body}");
    } else {
      print("error data ${pengsian.body}");
      throw "error data ${pengsian.body}";
    }
  }

  Future<void> setFotoProfil(
    int idProfil,
    String token,
    String? link,
    DateTime edit,
  ) async {
    print("inisiasi set foto profil");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/profil?id_profil=eq.$idProfil");
    print("set foto 1 profil");

    final body = json.encode({
      'foto': link,
      'updatedAt': edit.toIso8601String(),
    });

    var response = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );
    print("set foto 2 profil");

    if (response.statusCode == 204) {
      print("done set foto ${response.body}");
    } else {
      print("error set foto ${response.body}");
      throw "error set foto ${response.body}";
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
