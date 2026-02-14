import 'dart:convert';
import '../models/kost_model.dart';
import '../configs/supabase_api_config.dart';
import 'package:http/http.dart' as htpp;
import 'package:image_picker/image_picker.dart';

class KostService {
  // Flag untuk debug print sekali saja
  static bool _debugKostPrinted = false;

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
    print("upload gambar 2 kost");

    var isian = await gambar.readAsBytes();
    print("upload gambar 3 kost");

    var pengisian = await htpp.post(
      url,
      headers: {
        'Content-Type': '/images/$siapa.jpg',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
      },
      body: isian,
    );
    print("upload gambar 4 kost");

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

  Future<void> deletegambar(String gambar) async {
    print("inisiasi modul storage");

    var link = Uri.parse("$gambar");
    print("hapus gamba 1 kost");

    var nama = link.pathSegments.last;
    print("hapus gamba 2 kost");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/storage/v1/object/kost/$nama");
    print("hapus gamba 3 kost");

    var delete = await htpp.delete(
      url,
      headers: {
        'Content-Type': 'images/$nama.jpg',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
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
    int? notlp_kost,
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
    var simpan = await htpp.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': ' Bearer ${SupabaseApiConfig.apisecret}'
      },
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

  Future<void> deletedata(int id_kost) async {
    print("inisiasi hapus data kost");

    var url = Uri.parse(
        "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_kost=eq.$id_kost");
    print("data hapus 1 kost");

    var delete = await htpp.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apisecret}',
        'Authorization': 'Bearer ${SupabaseApiConfig.apisecret}'
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
    int? notlp_kost,
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

    var simpan = await htpp.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
        'Authorization': 'Bearer $token'
      },
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

    var simpan = await htpp.get(url, headers: {
      "Content-Type": 'applicaation/json',
      'apikey': '${SupabaseApiConfig.apipublic}',
      'Authorization': 'Bearer $token',
      'Prefer': 'return=representation'
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
    int? telpon,
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
        'Authorization': 'Bearer $token',
        'Prefer': 'return=represenstation',
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
    int? telpon,
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
    int noTelpBaru,
  ) async {
    final url = Uri.parse(
      "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_auth=eq.$id_auth&or=(notlp_kost.eq.0,notlp_kost.is.null)",
    );

    final updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
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
    int noTelpBaru,
  ) async {
    final url = Uri.parse(
      "${SupabaseApiConfig.masterurl}/rest/v1/kost?id_auth=eq.$id_auth",
    );

    final updated = await htpp.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'apikey': '${SupabaseApiConfig.apipublic}',
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
}
