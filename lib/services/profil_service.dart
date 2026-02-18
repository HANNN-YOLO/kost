import 'dart:convert';
import '../configs/supabase_api_config.dart';
import '../models/profil_model.dart';
import 'package:http/http.dart' as htpp;
import 'package:image_picker/image_picker.dart';

class ProfilService {
  // CD foto
  Future<String> uploadfoto(XFile foto, String token) async {
    print("inisiasi upload foto");

    // Gunakan nama file yang unik agar tidak bentrok dengan upload pengguna lain
    final sanitizedName = foto.name.replaceAll(' ', '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final si = "${timestamp}_$sanitizedName";
    print("upload foto 1 profil");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/profil/$si");
    print("upload foto 2 profil");

    var namanya = await foto.readAsBytes();
    print("upload foto 3 profil");

    var simpan = await htpp.post(
      url,
      headers: {
        // Samakan header dengan modul upload gambar kost yang sudah stabil
        'Content-Type': '/images/$si.jpg',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
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
        'Content-Type': 'application/octet-stream',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
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

  Future<void> deletegambaradmin(String link) async {
    var inilink = Uri.parse("$link");

    final namanya = inilink.pathSegments.last;

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/profil/$namanya");

    var delete = await htpp.delete(url, headers: {
      'Content-Type': '/images/$namanya.jpg',
      'apikey': '${SupabaseApiConfig.apisecret}',
      'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
    });

    if (delete.statusCode == 200 || delete.statusCode == 204) {
      // berhasil hapus atau sudah tidak ada (204)
      print("berhasil hapus gambar user di Admin ${delete.statusCode}");
    } else if (delete.statusCode == 404) {
      // objek sudah tidak ada di storage, anggap aman (idempotent delete)
      print(
          "gambar user tidak ditemukan saat dihapus di Admin, lanjut tanpa error: ${delete.body}");
    } else {
      print("gagal hapus data user di admin dengan kendala ${delete.body}");
      throw "gagal hapus data user di admin dengan kendala ${delete.body}";
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
    String? link,
    String? hp,
  ) async {
    print("inisiasi buat data");

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/profil");
    print("buat data 1 profil");

    // Kirim field `foto` secara eksplisit (boleh null) agar database tidak
    // menerapkan nilai default yang tidak diinginkan.
    final Map<String, dynamic> isian = <String, dynamic>{
      'id_auth': id_auth,
      'foto': link,
      'kontak': hp,
    };
    print("buat data 2 profil");

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apikey': '${SupabaseApiConfig.apipublic}'
      },
      body: json.encode(isian),
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
    int idProfil,
    String token,
    String? link,
    String? kontak,
    DateTime edit, {
    bool setFoto = false,
  }) async {
    print("inisasi perubahan data");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/profil?id_profil=eq.$idProfil");
    print("ubah data 1 profil");

    // NOTE: kontak boleh NULL. Untuk bisa clear kontak di Supabase,
    // field harus dikirim eksplisit (kontak: null).
    final Map<String, dynamic> body = <String, dynamic>{
      'updatedAt': edit.toIso8601String(),
      'kontak': kontak,
    };
    // Default: hanya update foto kalau ada link baru.
    // Jika setFoto=true, kirim foto eksplisit (boleh null) untuk memastikan
    // database tidak mengisi default aneh saat foto memang kosong.
    if (setFoto) {
      body['foto'] = link;
    } else if (link != null) {
      body['foto'] = link;
    }
    print("ubah data 2 profil");

    var pengsian = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
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

  Future<void> adminUpdateProfil({
    required int idProfil,
    String? jkl,
    String? kontak,
    bool setKontak = false,
    DateTime? tgllahir,
  }) async {
    print("inisiasi update profil oleh admin");

    final Map<String, dynamic> body = {};
    if (jkl != null) body['jkl'] = jkl;
    if (setKontak) {
      // kontak boleh null untuk clear.
      body['kontak'] = kontak;
    } else if (kontak != null) {
      body['kontak'] = kontak;
    }
    if (tgllahir != null) {
      body['tgllahir'] = tgllahir.toIso8601String();
    }
    body['updatedAt'] = DateTime.now().toIso8601String();

    if (body.isEmpty) return;

    final url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/profil?id_profil=eq.$idProfil");

    final response = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 204) {
      print("berhasil update profil admin $idProfil");
    } else {
      print("gagal update profil admin ${response.body}");
      throw "gagal update profil admin ${response.body}";
    }
  }

  Future<void> deleteProfilById(int idProfil) async {
    print("inisiasi hapus profil oleh admin");

    final url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/profil?id_profil=eq.$idProfil");

    final response = await htpp.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print("berhasil hapus profil $idProfil");
    } else {
      print("gagal hapus profil ${response.body}");
      throw "gagal hapus profil ${response.body}";
    }
  }
}
