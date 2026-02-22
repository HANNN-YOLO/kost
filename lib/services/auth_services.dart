import 'dart:convert';
import 'dart:io';
import '../configs/supabase_api_config.dart';
import '../models/auth_model.dart';
import 'package:http/http.dart' as htpp;
// import '../configs/supabase_cadangan_api.dart';

class AuthServices {
  // modul auth
  Future<Map<String, dynamic>?> login({
    required String email,
    required String pass,
  }) async {
    print("inisiasi modul auth");

    try {
      var url = Uri.parse(
          "${SupabaseApiConfig.masterurl}/auth/v1/token?grant_type=password");

      // var url = Uri.parse(
      //     "${SupabaseCadanganApi.masterurl}/auth/v1//token?grant_type=password");
      print("login 1 auth");

      final isi = AuthModel(Email: email, password: pass);
      print("login 2 auth");

      var pengisian = await htpp.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': '${SupabaseApiConfig.apipublic}'
          // 'apikey': '${SupabaseCadanganApi.apipublic}',
        },
        body: json.encode(isi.toJson()),
      );
      print("login 3 auth");

      if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
        final data = json.decode(pengisian.body);
        print(data);
        return data;
      } else {
        print("error ${pengisian.body}");
        Map<String, dynamic>? ambil;
        try {
          ambil = json.decode(pengisian.body) as Map<String, dynamic>;
        } catch (_) {
          ambil = null;
        }

        final String? errorCode = ambil?['error_code']?.toString();
        final String? error = ambil?['error']?.toString();
        final String? errorDescription =
            ambil?['error_description']?.toString();
        final String message =
            ambil?['msg']?.toString() ?? ambil?['message']?.toString() ?? '';
        final String rawLower = pengisian.body.toLowerCase();

        final bool isInvalidCredential = errorCode == "invalid_credentials" ||
            error == "invalid_grant" ||
            (errorDescription != null &&
                errorDescription
                    .toLowerCase()
                    .contains('invalid login credentials')) ||
            rawLower.contains('invalid login credentials');

        if (isInvalidCredential) {
          throw "Email atau sandi yang Anda masukkan salah.";
        }

        if (errorCode == "anonymous_provider_disabled") {
          throw "Masukkan email dan sandi Anda.";
        }

        if (message.isNotEmpty) {
          throw "Gagal masuk: $message";
        }

        throw "Gagal masuk: periksa kembali data Anda dan coba lagi.";
      }
    } on SocketException catch (_) {
      throw "Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.";
    } on htpp.ClientException catch (_) {
      throw "Gagal terhubung ke server. Silakan periksa koneksi atau konfigurasi server.";
    }
  }

  Future<Map<String, dynamic>?> register({
    required String email,
    required String pass,
  }) async {
    print("inisiasi modul auth");

    try {
      var url = Uri.parse("${SupabaseApiConfig.masterurl}/auth/v1/signup");
      // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/auth/v1/signup");
      print("register 1 auth");

      final isi = AuthModel(Email: email, password: pass);
      print("register 2 auth");

      var pengisian = await htpp.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'apikey': '${SupabaseApiConfig.apipublic}'
          // 'apikey': '${SupabaseCadanganApi.apipublic}',
        },
        body: json.encode(isi.toJson()),
      );
      print("register 3 auth");

      if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
        final data = json.decode(pengisian.body);
        print(data);
        return data;
      } else {
        print("error ${pengisian.body}");
        final data = json.decode(pengisian.body);
        final String? errorCode = data["error_code"]?.toString();
        final String message =
            data["msg"]?.toString() ?? data["message"]?.toString() ?? "";

        if (errorCode == "validation_failed") {
          throw "Masukkan Sandi Anda";
        }

        if (errorCode == "user_already_exists" ||
            message.toLowerCase().contains("already registered") ||
            message.toLowerCase().contains("already exists")) {
          throw "Email sudah digunakan, silakan gunakan email lain.";
        }

        throw "Terjadi kesalahan saat mendaftar: ${message.isNotEmpty ? message : 'coba lagi.'}";
      }
    } on SocketException catch (_) {
      throw "Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.";
    } on htpp.ClientException catch (_) {
      throw "Gagal terhubung ke server. Silakan periksa koneksi atau konfigurasi server.";
    }
  }

  // modul realtime
  Future<void> createuser(
    String token,
    String UID,
    String username,
    String Email,
    String role,
  ) async {
    print("inisiasi buat data auth");
    try {
      var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/auth");
      // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/auth");
      print("buat data 1 auth");

      final isi = AuthModel(
        UID: UID,
        username: username,
        Email: Email,
        role: role,
      );
      print("buat data 2 auth");

      var pengisian = await htpp.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'apikey': '${SupabaseApiConfig.apipublic}'
            // 'apikey': '${SupabaseCadanganApi.apipublic}',
          },
          body: json.encode(isi.toJson()));

      if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
        print("done ${pengisian.body}");
      } else {
        print("error ${pengisian.body}");
        try {
          final data = json.decode(pengisian.body);
          final String code = data["code"]?.toString() ?? "";
          final String message =
              data["message"]?.toString() ?? pengisian.body.toString();

          if (code == "22P02" && message.contains("enum")) {
            throw "Role tidak valid. Silakan pilih Pemilik atau Penyewa.";
          }

          if (code == "23505" || message.toLowerCase().contains("duplicate")) {
            throw "Email sudah digunakan, silakan gunakan email lain.";
          }

          throw message;
        } catch (_) {
          throw "Terjadi kesalahan saat menyimpan data pengguna. Silakan coba lagi.";
        }
      }
    } on SocketException catch (_) {
      throw "Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.";
    } on htpp.ClientException catch (_) {
      throw "Gagal terhubung ke server. Silakan periksa koneksi atau konfigurasi server.";
    }
  }

  Future<List<AuthModel>> readdata(String token) async {
    List<AuthModel> hasilnya = [];
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/auth");
    // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/auth");

    var simpan = await htpp.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'apikey': '${SupabaseApiConfig.apipublic}',
        // 'apiley': '${SupabaseCadanganApi.apipublic}',
        'Cache-Control': 'no-store, no-cache, max-age=0, must-revalidate',
        'Pragma': 'no-cache',
      },
    );

    if (simpan.statusCode == 200 || simpan.statusCode == 201) {
      final save = json.decode(simpan.body) as List<dynamic>;
      save.forEach((value) {
        var item = AuthModel.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      final status = simpan.statusCode;
      final raw = simpan.body.toString();

      // Beberapa error umum dari Supabase / jaringan
      if (status == 401 || status == 403) {
        throw "Sesi login sudah habis atau tidak memiliki akses. Silakan login ulang.";
      }
      if (status >= 500) {
        throw "Server sedang bermasalah (kode: $status). Coba lagi sebentar.";
      }

      // Fallback: tampilkan pesan singkat
      String message = raw;
      try {
        final decoded = json.decode(raw);
        if (decoded is Map) {
          message = (decoded['message']?.toString() ??
                  decoded['msg']?.toString() ??
                  decoded['error']?.toString() ??
                  raw)
              .trim();
        }
      } catch (_) {
        // ignore
      }

      throw "Gagal memuat data akun (kode: $status). ${message.isNotEmpty ? message : ''}";
    }
    return hasilnya;
  }

  Future<List<AuthModel>> alluser() async {
    List<AuthModel> hasilnya = [];
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/auth?select=*");
    // var url =
    //     Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/auth?select=*");

    var hasil = await htpp.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
      // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
      'apikey': '${SupabaseApiConfig.apisecret}',
      // 'apikey': '${SupabaseCadanganApi.apisecret}',
      'Cache-Control': 'no-store, no-cache, max-age=0, must-revalidate',
      'Pragma': 'no-cache',
    });

    if (hasil.statusCode == 200 || hasil.statusCode == 201) {
      final take = json.decode(hasil.body) as List<dynamic>;
      take.forEach((value) {
        var item = AuthModel.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      print("error ${hasil.body}");
      throw "error ${hasil.body}";
    }
    return hasilnya;
  }

  Future<List<AuthModel>> readlist(String token) async {
    List<AuthModel> hasilnya = [];

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/auth?select=*");
    // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/auth?select=*");

    var simpan = await htpp.get(url, headers: {
      'Content-Type': 'application/json',
      'apikey': '${SupabaseApiConfig.apipublic}',
      // 'apikey': '${SupabaseCadanganApi.apipublic}',
      'Authorization': 'Bearer $token'
    });

    if (simpan.statusCode == 200 || simpan.statusCode == 201) {
      final ambil = json.decode(simpan.body) as List<dynamic>;
      ambil.forEach((value) {
        var item = AuthModel.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      print("gagal ambil data read semua user ${simpan.body}");
      throw "Gagal ambil data read semua user ${simpan.body}";
    }
    return hasilnya;
  }

  Future<void> deletedatarest(int id_auth) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/auth?id_auth=eq.$id_auth");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/auth?id_auth=eq.$id_auth");

    var hapus = await htpp.delete(url, headers: {
      'Content-Type': 'application/json',
      'apikey': '${SupabaseApiConfig.apisecret}',
      'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
      // 'apikey': '${SupabaseCadanganApi.apisecret}',
      // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}'
    });

    if (hapus.statusCode == 204) {
      print("berhasil hapus data user di modul rest ${hapus.body}");
    } else {
      print("gagal hapus data user di modul rest${hapus.body}");
      throw "gagal hapus data user di modul rest${hapus.body}";
    }
  }

  Future<void> deletedatauath(String UID) async {
    var url =
        Uri.parse("${SupabaseApiConfig.masterurl}/auth/v1/admin/users/$UID");

    // var url =
    //     Uri.parse("${SupabaseCadanganApi.masterurl}/auth/v1/admin/users/$UID");

    var hapus = await htpp.delete(url, headers: {
      'Content-Type': 'application/json',
      'apikey': '${SupabaseApiConfig.apisecret}',
      'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
      // 'apikey': '${SupabaseCadanganApi.apisecret}',
      // 'Authorization': '${SupabaseCadanganApi.apisecret}',
    });

    if (hapus.statusCode == 200) {
      print("done hapus data user di modul auth");
    } else {
      print("gagal hapus data user di modul auth karena ${hapus.body}");
      throw "gagal hapus data user di modul auth karena ${hapus.body}";
    }
  }

  Future<void> updateUsernameRest({
    required String token,
    required int idAuth,
    required String username,
    DateTime? updatedAt,
  }) async {
    final url = Uri.parse(
      "${SupabaseApiConfig.masterurl}/rest/v1/auth?id_auth=eq.$idAuth",
    );

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/auth?id_auth=eq.$idAuth");

    final payload = <String, dynamic>{
      'username': username,
      'updatedAt': (updatedAt ?? DateTime.now()).toIso8601String(),
    };

    final updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        // 'apikey': '${SupabaseCadanganApi.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    if (updated.statusCode == 204 ||
        updated.statusCode == 200 ||
        updated.statusCode == 201) {
      return;
    }

    throw "gagal update nama pengguna ${updated.body}";
  }
}
