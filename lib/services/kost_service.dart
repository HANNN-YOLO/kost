import 'dart:convert';
import '../models/kost_model.dart';
import '../configs/supabase_api_config.dart';
import 'package:http/http.dart' as htpp;
import 'package:image_picker/image_picker.dart';
// import '../configs/supabase_cadangan_api.dart';

class KostService {
  // Flag untuk debug print sekali saja
  static bool _debugKostPrinted = false;

  Map<String, String> _withNoCacheHeaders(Map<String, String> headers) {
    return <String, String>{
      ...headers,
      // Pastikan request tidak memakai cache (berguna ketika data berubah dari device lain)
      'Cache-Control': 'no-store, no-cache, max-age=0, must-revalidate',
      'Pragma': 'no-cache',
    };
  }

  /// Cascade rename value di tabel `kost` untuk kolom text tertentu.
  /// Contoh: ketika admin rename subkriteria keamanan dari 'A' menjadi 'B',
  /// maka semua kost dengan `keamanan = 'A'` akan dipatch menjadi `keamanan = 'B'`.
  Future<void> renameTextValueInKostColumn({
    required String column,
    required String oldValue,
    required String newValue,
  }) async {
    final oldTrim = oldValue.trim();
    final newTrim = newValue.trim();
    if (column.trim().isEmpty) return;
    if (oldTrim.isEmpty || newTrim.isEmpty) return;
    if (oldTrim == newTrim) return;

    final encodedOld = Uri.encodeQueryComponent(oldTrim);
    final url = Uri.parse(
      "${SupabaseApiConfig.masterurl}/rest/v1/kost?$column=eq.$encodedOld",
    );
    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/kost?$column=eq.$encodedOld");

    final resp = await htpp.patch(
      url,
      headers: _withNoCacheHeaders({
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': '${SupabaseCadanganApi.apisecret}'
      }),
      body: json.encode(<String, dynamic>{
        column: newTrim,
      }),
    );

    // PostgREST: PATCH sukses biasanya 204 meskipun 0 row match.
    if (resp.statusCode == 204 || resp.statusCode == 200) {
      return;
    }
    throw "gagal cascade rename kost ($column: '$oldTrim'→'$newTrim') : ${resp.body}";
  }

  // modul Storage
  Future<String> uploadgambar(XFile gambar) async {
    print("inisiasi modul storage");

    // Gunakan nama file unik agar tidak terjadi konflik "Duplicate" di Supabase
    final sanitizedName = gambar.name.replaceAll(' ', '_');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final siapa = "${timestamp}_$sanitizedName";
    print("upload gambar 1 kost");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/kost/$siapa");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/storage/v1/object/kost/$siapa");
    print("upload gambar 2 kost");

    var isian = await gambar.readAsBytes();
    print("upload gambar 3 kost");

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': '/images/$siapa.jpg',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}'
      },
      body: isian,
    );
    print("upload gambar 4 kost");

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      final ambil =
          "${SupabaseApiConfig.masterurl}/storage/v1/object/public/kost/$siapa";
      // final ambil =
      //     "${SupabaseCadanganApi.masterurl}/storage/v1/object/public/kost/$siapa";
      print("done $ambil");
      return ambil;
    } else {
      print("error foto kost ${pengisian.body}");
      throw "error foto kost ${pengisian.body}";
    }
  }

  Future<void> deletegambar(String gambar) async {
    print("inisiasi modul storage");

    var link = Uri.parse("$gambar");
    print("hapus gamba 1 kost");

    var nama = link.pathSegments.last;
    print("hapus gamba 2 kost");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/kost/$nama");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/storage/v1/object/kost/$nama");
    print("hapus gamba 3 kost");

    var delete = await htpp.delete(
      url,
      headers: {
        'Content-Type': 'images/$nama.jpg',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}'
      },
    );
    print("hapus gamba 5 kost");

    if (delete.statusCode == 200) {
      print("done gambar dihapus");
    } else {
      print("error gambar tidak dihapus");
      throw "error gambar tidak dihapus";
    }
  }

  // CRUD table
  Future<void> createdata(
    int id_auth,
    // int? id_fasilitas,
    String? notlp_kost,
    String nama_kost,
    String alamat_kost,
    String pemilik_kost,
    int harga_kost,
    String jenis_kost,
    String penghuni,
    String keamanan,
    String batas_jam_malam,
    String jenis_pembayaran_air,
    String jenis_listrik,
    num panjang,
    num lebar,
    double garis_lintang,
    double garis_bujur,
    String gambar,
    String per,
    String fasilitas,
  ) async {
    print("inisiai buat data kost");

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/kost");
    // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/kost");
    print("buat data 1 kost");

    var isian = KostModel(
      id_auth: id_auth,
      // id_fasilitas: id_fasilitas,
      notlp_kost: notlp_kost,
      nama_kost: nama_kost,
      alamat_kost: alamat_kost,
      pemilik_kost: pemilik_kost,
      harga_kost: harga_kost,
      jenis_kost: jenis_kost,
      penghuni: penghuni,
      keamanan: keamanan,
      batas_jam_malam: batas_jam_malam,
      jenis_listrik: jenis_listrik,
      jenis_pembayaran_air: jenis_pembayaran_air,
      panjang: panjang,
      lebar: lebar,
      garis_lintang: garis_lintang,
      garis_bujur: garis_bujur,
      gambar_kost: gambar,
      per: per,
      fasilitas: fasilitas,
    );
    print("buat data 2 kost");

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
        'Prefer': 'returns=representation',
      },
      body: json.encode(isian.toJson()),
    );
    print("buat data 3 kost");

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      print("done data kost ${pengisian.body}");
    } else {
      print("error kost ${pengisian.body}");
      throw "error kost ${pengisian.body}";
    }
  }

  Future<List<KostModel>> readdata({bool debugPrint = true}) async {
    List<KostModel> hasilnya = [];
    // Urutkan berdasarkan id_kost ascending untuk konsistensi alternatif A1, A2, A3, dst
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kost?order=id_kost.asc");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/kost?order=id_kost.asc");
    var simpan = await htpp.get(
      url,
      headers: _withNoCacheHeaders({
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
      }),
    );
    if (simpan.statusCode == 200) {
      final ambil = json.decode(simpan.body) as List<dynamic>;
      ambil.forEach((value) {
        var take = KostModel.fromJson(value);
        hasilnya.add(take);
      });
      if (debugPrint && !_debugKostPrinted) {
        print(
            "✅ Data kost diurutkan berdasarkan id_kost (${hasilnya.length} data)");
        _debugKostPrinted = true;
      }
    } else {
      print("error ambil data ${simpan.body}");
      throw "error ambil data ${simpan.body}";
    }
    return hasilnya;
  }

  Future<KostModel?> readById(int id_kost) async {
    final url = Uri.parse(
      "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_kost=eq.$id_kost&select=*",
    );

    // final url = Uri.parse(
    //   "${SupabaseCadanganApi.masterurl}/rest/v1/kost?id_kost=eq.$id_kost&select=*",
    // );

    final simpan = await htpp.get(
      url,
      headers: _withNoCacheHeaders({
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
      }),
    );

    if (simpan.statusCode != 200) {
      throw "error ambil 1 kost ${simpan.body}";
    }

    final ambil = json.decode(simpan.body) as List<dynamic>;
    if (ambil.isEmpty) return null;
    return KostModel.fromJson(ambil.first);
  }

  Future<void> deletedata(int id_kost) async {
    print("inisiasi hapus data kost");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_kost=eq.$id_kost");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/kost?id_kost=eq.$id_kost");
    print("data hapus 1 kost");

    var delete = await htpp.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
      },
    );
    print("data hapus 2 kost");

    if (delete.statusCode == 200 || delete.statusCode == 204) {
      print("done hapus data kost");
    } else {
      print("error hapus data kost");
      throw "error hapus data kost";
    }
  }

  Future<void> updatedata(
    int id_kost,
    // int? id_fasilitas,
    int id_auth,
    String nama_kost,
    String nama_pemilik,
    String alamat_kost,
    String? notlp_kost,
    int harga_kost,
    String batas_jam_malam,
    String jenis_listrik,
    String jenis_pembayaran_air,
    String keamanan,
    String jenis_kost,
    String penghuni,
    num panjang,
    num lebar,
    String gambar_kost,
    double garis_lintang,
    double garis_bujur,
    DateTime updatedAt,
    String per,
    String fasilitas,
  ) async {
    print("inisiasi perubahan data kost");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_kost=eq.$id_kost");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/kost?id_kost=eq.$id_kost");
    print("ubah data 1 kost");

    var isian = KostModel(
      id_auth: id_auth,
      id_kost: id_kost,
      // id_fasilitas: id_fasilitas,
      nama_kost: nama_kost,
      pemilik_kost: nama_pemilik,
      alamat_kost: alamat_kost,
      notlp_kost: notlp_kost,
      harga_kost: harga_kost,
      batas_jam_malam: batas_jam_malam,
      jenis_listrik: jenis_listrik,
      jenis_pembayaran_air: jenis_pembayaran_air,
      keamanan: keamanan,
      jenis_kost: jenis_kost,
      penghuni: penghuni,
      panjang: panjang,
      lebar: lebar,
      gambar_kost: gambar_kost,
      garis_lintang: garis_lintang,
      garis_bujur: garis_bujur,
      updatedAt: updatedAt,
      per: per,
      fasilitas: fasilitas,
    );
    print("ubah data 2 kost");

    var updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
      },
      body: json.encode(isian.toJson()),
    );
    print("ubah data 3 kost");

    if (updated.statusCode == 204) {
      print("done perubahan data kost ${updated.body}");
    } else {
      print("gagal perubahan data kost ${updated.body}");
      throw "gagal perubahan data kost ${updated.body}";
    }
  }

  Future<List<KostModel>> readdatapenyewa(String token) async {
    List<KostModel> hasilnya = [];

    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/kost");

    // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/kost");

    var simpan = await htpp.get(
      url,
      headers: _withNoCacheHeaders({
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        // 'apikey': '${SupabaseCadanganApi.apipublic}',
        'Authorization': 'Bearer $token',
      }),
    );
    if (simpan.statusCode == 200) {
      final ambil = json.decode(simpan.body) as List<dynamic>;
      ambil.forEach((value) {
        var item = KostModel.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      print(
          "eror ambil data kost sebagai penyewa: status \\${simpan.statusCode}, body: \\${simpan.body}");
      throw Exception("eror ambil data kost sebagai penyewa");
    }
    return hasilnya;
  }

  Future<List<KostModel>> readdatapemilik(int id_auth, String token) async {
    List<KostModel> hasilnya = [];

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_auth=eq.$id_auth&select=*");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/kost?id_auth=eq.$id_auth&select=*");

    var simpan = await htpp.get(url, headers: {
      "Content-Type": 'application/json',
      'apikey': '${SupabaseApiConfig.apipublic}',
      // 'apikey': '${SupabaseCadanganApi.apipublic}',
      'Authorization': 'Bearer $token',
      'Prefer': 'return=representation',
      'Cache-Control': 'no-store, no-cache, max-age=0, must-revalidate',
      'Pragma': 'no-cache',
    });

    if (simpan.statusCode == 200) {
      final ambil = json.decode(simpan.body) as List<dynamic>;
      ambil.forEach((value) {
        var item = KostModel.fromJson(value);
        hasilnya.add(item);
      });
    } else {
      print("gagal mengambil data kost pemilik${simpan.body}");
      throw "Gagal mengambil data kost pemilik${simpan.body}";
    }
    return hasilnya;
  }

  Future<void> createddatapemilik(
    String token,
    int id_auth,
    // int id_fasilitas,
    String nama_pemilik,
    String nama_kost,
    String alamat,
    String? telpon,
    int harga,
    String jenis_kost,
    String penghuni,
    String keamanan,
    num panjang,
    num lebar,
    String batas_jam_malam,
    String jenis_pembayaran_air,
    String jenis_listrik,
    double garis_lintang,
    double garis_bujur,
    String gambar,
    String per,
    String fasilitas,
  ) async {
    var url = Uri.parse("${SupabaseApiConfig.masterurl}/rest/v1/kost");

    // var url = Uri.parse("${SupabaseCadanganApi.masterurl}/rest/v1/kost");

    final isian = KostModel(
      id_auth: id_auth,
      // id_fasilitas: id_fasilitas,
      pemilik_kost: nama_pemilik,
      nama_kost: nama_kost,
      alamat_kost: alamat,
      notlp_kost: telpon,
      harga_kost: harga,
      jenis_kost: jenis_kost,
      penghuni: penghuni,
      keamanan: keamanan,
      panjang: panjang,
      lebar: lebar,
      batas_jam_malam: batas_jam_malam,
      jenis_pembayaran_air: jenis_pembayaran_air,
      jenis_listrik: jenis_listrik,
      garis_lintang: garis_lintang,
      garis_bujur: garis_bujur,
      gambar_kost: gambar,
      per: per,
      fasilitas: fasilitas,
    );

    print("🔍 DEBUG - Penghuni value: $penghuni");
    print("🔍 DEBUG - ToJson: ${json.encode(isian.toJson())}");

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        // 'apikey': '${SupabaseCadanganApi.apipublic}',
        'Authorization': 'Bearer $token',
        'Prefer': 'return=representation',
      },
      body: json.encode(isian.toJson()),
    );

    if (pengisian.statusCode == 200 || pengisian.statusCode == 201) {
      print("done buat data kost pemilik ${pengisian.body}");
    } else {
      print("gagal buat data kost pemilik ${pengisian.body}");
      throw "gagal buat data kost pemilik ${pengisian.body}";
    }
  }

  Future<void> updateddatapemmilik(
    String token,
    int id_kost,
    int id_auth,
    // int id_fasilitas,
    String nama_pemilik,
    String nama_kost,
    String? telpon,
    String alamat_kost,
    int harga_kost,
    String jenis_kost,
    String penghuni,
    String keamanan,
    num panjang,
    num lebar,
    String batas_jam_malam,
    String jenis_pembayaran_air,
    String jenis_listrik,
    double garis_lintang,
    double garis_bujur,
    String gambar,
    DateTime editan,
    String per,
    String fasilitas,
  ) async {
    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_kost=eq.$id_kost");

    // var url = Uri.parse(
    //     "${SupabaseCadanganApi.masterurl}/rest/v1/kost?id_kost=eq.$id_kost");

    var isian = KostModel(
      id_auth: id_auth,
      // id_fasilitas: id_fasilitas,
      pemilik_kost: nama_pemilik,
      nama_kost: nama_kost,
      notlp_kost: telpon,
      alamat_kost: alamat_kost,
      harga_kost: harga_kost,
      jenis_kost: jenis_kost,
      penghuni: penghuni,
      keamanan: keamanan,
      panjang: panjang,
      lebar: lebar,
      batas_jam_malam: batas_jam_malam,
      jenis_pembayaran_air: jenis_pembayaran_air,
      jenis_listrik: jenis_listrik,
      garis_lintang: garis_lintang,
      garis_bujur: garis_bujur,
      gambar_kost: gambar,
      updatedAt: editan,
      per: per,
      fasilitas: fasilitas,
    );

    print("🔍 DEBUG UPDATE - Penghuni value: $penghuni");
    print("🔍 DEBUG UPDATE - ToJson: ${json.encode(isian.toJson())}");

    var updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        // 'apikey': '${SupabaseCadanganApi.apipublic}',
        'Authorization': 'Bearer $token',
        // 'Prefer': 'return=representation'
      },
      body: json.encode(isian.toJson()),
    );

    if (updated.statusCode == 204) {
      print("done data kost pemilik sudah updated ${updated.body}");
    } else {
      print("gagal updated data kost pemilik ${updated.body}");
      throw "gagal updated data kost pemilik ${updated.body}";
    }
  }

  /// Update `notlp_kost` untuk semua kost pemilik yang sebelumnya masih kosong.
  ///
  /// Target: kost dengan `id_auth` pemilik dan `notlp_kost` = 0 atau NULL.
  /// Ini dipakai agar ketika pemilik mengisi nomor HP di profil, detail kost lama
  /// otomatis ikut menampilkan nomor terbaru.
  Future<void> updateNoTelpKostPemilikJikaKosong(
    String token,
    int id_auth,
    num noTelpBaru,
  ) async {
    final url = Uri.parse(
      "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_auth=eq.$id_auth&or=(notlp_kost.eq.0,notlp_kost.is.null)",
    );
    // final url = Uri.parse(
    //   "${SupabaseCadanganApi.masterurl}/rest/v1/kost?id_auth=eq.$id_auth&or=(notlp_kost.eq.0,notlp_kost.is.null)",
    // );

    final updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        // 'apikey': '${SupabaseCadanganApi.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'notlp_kost': noTelpBaru,
      }),
    );

    // Supabase default PATCH biasanya 204 (no content)
    if (updated.statusCode == 204 ||
        updated.statusCode == 200 ||
        updated.statusCode == 201) {
      return;
    }

    throw "gagal update no tlp kost pemilik ${updated.body}";
  }

  /// Paksa update `notlp_kost` untuk SEMUA kost milik pemilik.
  /// Dipakai ketika pemilik mengganti nomor HP di profil dan ingin semua kost
  /// ikut menyesuaikan.
  Future<void> updateNoTelpKostPemilikSemua(
    String token,
    int id_auth,
    String? noTelpBaru,
  ) async {
    final url = Uri.parse(
      "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_auth=eq.$id_auth",
    );

    // final url = Uri.parse(
    //   "${SupabaseCadanganApi.masterurl}/rest/v1/kost?id_auth=eq.$id_auth",
    // );

    final updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        // 'apikey': '${SupabaseApiConfig.apipublic}',
        // 'apikey': '${SupabaseCadanganApi.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'notlp_kost': noTelpBaru,
      }),
    );

    if (updated.statusCode == 204 ||
        updated.statusCode == 200 ||
        updated.statusCode == 201) {
      return;
    }

    throw "gagal update no tlp semua kost pemilik ${updated.body}";
  }

  /// Paksa update `pemilik_kost` untuk SEMUA kost milik pemilik.
  /// Dipakai ketika pemilik mengganti nama di profil agar detail kost
  /// selalu menampilkan nama pemilik terbaru.
  Future<void> updateNamaPemilikKostSemua(
    String token,
    int id_auth,
    String namaPemilikBaru,
  ) async {
    final url = Uri.parse(
      "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_auth=eq.$id_auth",
    );

    // final url = Uri.parse(
    //   "${SupabaseCadanganApi.masterurl}/rest/v1/kost?id_auth=eq.$id_auth",
    // );

    final updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        // 'apikey': '${SupabaseCadanganApi.apipublic}',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'pemilik_kost': namaPemilikBaru,
      }),
    );

    if (updated.statusCode == 204 ||
        updated.statusCode == 200 ||
        updated.statusCode == 201) {
      return;
    }

    throw "gagal update nama pemilik semua kost ${updated.body}";
  }

  /// Cascade update: saat subkriteria diubah namanya, update semua kost
  /// yang menggunakan nama subkriteria lama menjadi nama baru.
  ///
  /// [kriteriaName] nama kriteria (e.g., "Keamanan", "Batas Jam Malam")
  /// [oldSubkriteriaName] nama subkriteria lama
  /// [newSubkriteriaName] nama subkriteria baru
  Future<void> cascadeUpdateKostAfterSubkriteriaRename({
    required String kriteriaName,
    required String oldSubkriteriaName,
    required String newSubkriteriaName,
  }) async {
    if (oldSubkriteriaName == newSubkriteriaName) {
      return; // Tidak ada perubahan nama
    }

    // Mapping kriteria ke field di tabel kost
    final Map<String, String> kriteriaFieldMap = {
      'keamanan': 'keamanan',
      'batas jam malam': 'batas_jam_malam',
      'jenis pembayaran air': 'jenis_pembayaran_air',
      'jenis listrik': 'jenis_listrik',
      'jenis kost': 'jenis_kost',
    };

    final normalizedKriteria = kriteriaName.toLowerCase().trim();
    final fieldName = kriteriaFieldMap[normalizedKriteria];

    if (fieldName == null) {
      // Kriteria tidak memiliki field terkait di tabel kost (misal: Jarak, Harga)
      return;
    }

    // Update semua kost yang menggunakan nama subkriteria lama
    // Encode value untuk handle spasi dan karakter khusus
    final encodedOldName = Uri.encodeComponent(oldSubkriteriaName);
    final url = Uri.parse(
      "${SupabaseApiConfig.masterurl}/rest/v1/kost?$fieldName=eq.$encodedOldName",
    );

    // final url = Uri.parse(
    //   "${SupabaseCadanganApi.masterurl}/rest/v1/kost?$fieldName=eq.$encodedOldName",
    // );

    print(
        "🔄 Cascade update: mencari kost dengan $fieldName='$oldSubkriteriaName'...");

    final updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}',
        // 'apikey': '${SupabaseCadanganApi.apisecret}',
        // 'Authorization': 'Bearer ${SupabaseCadanganApi.apisecret}',
        'Prefer': 'return=minimal',
      },
      body: json.encode({
        fieldName: newSubkriteriaName,
      }),
    );

    if (updated.statusCode == 204 ||
        updated.statusCode == 200 ||
        updated.statusCode == 201) {
      print(
          "✅ Cascade update berhasil: $fieldName '$oldSubkriteriaName' → '$newSubkriteriaName'");
      return;
    }

    print("⚠️ Gagal cascade update subkriteria $fieldName: ${updated.body}");
  }
}
