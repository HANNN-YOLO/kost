import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/kost_model.dart';
import '../models/fasilitas_model.dart';
import '../models/profil_model.dart';
import '../models/auth_model.dart';
import '../models/kriteria_models.dart';
import '../models/subkriteria_models.dart';
import '../services/kost_service.dart';
import '../services/fasilitas_service.dart';
import '../services/kriteria_services.dart';
import '../services/subkriteria_services.dart';
import '../algoritma/simple_additive_weighting.dart';

class KostProvider with ChangeNotifier {
  // state penting
  String? _token, _email;
  DateTime? _expires_in;

  List<AuthModel> _listauth = [];
  List<AuthModel> get listauth => _listauth;

  int? id_authnya;

  String? get token => _token;

  List<ProfilModel> _dataku = [];
  List<ProfilModel> get dataku => _dataku;

  bool keadaan = false;

  void isi(
    String value,
    String ada,
    DateTime waktunya,
    List<AuthModel> manalistya,
    int id_auth,
  ) {
    _token = value;
    _email = ada;
    _expires_in = waktunya;
    _listauth = manalistya;
    id_authnya = id_auth;
    if (_token != null && _email != null && _listauth != null) {
      final cek = listauth.firstWhere((element) => element.id_auth == id_auth);
      // if (!keadaan) {
      if (cek.role == "Admin") {
        readdata();
      } else if (cek.role == "Penyewa") {
        readdatapenyewa(_token!);
      } else if (cek.role == "Pemilik") {
        // Hindari reload berulang jika isi() terpanggil berkali-kali (ProxyProvider)
        // final bool shouldForce =
        //     !_hasLoadedPemilikKost || _loadedPemilikAuthId != id_auth;
        readdatapemilik(id_auth, _token!);
      } else {
        print("gagal verifikasi role login");
        throw "Gagal verifikasi role login";
      }

      // Pastikan data kriteria & subkriteria SAW ikut ter-load
      // (dipakai juga untuk opsi dropdown keamanan, listrik, dll.)

      fetchKriteria();
      fetchSubkriteria();
      // }
    }
  }

  void inilist(List<ProfilModel>? mana) {
    _dataku = mana!;
    if (_dataku != null && id_authnya != null && token != null) {
      readdatapemilik(id_authnya!, token!);
    }
  }

  void isiprofil(List<ProfilModel> manawoi) {
    _dataku = manawoi;
    if (dataku.isNotEmpty && id_authnya != null && token != null) {
      readdatapemilik(id_authnya!, token!);
    }
  }

  // final cek = _listauth.firstWhere((element) => element.role == namas);

  // state foto
  XFile? _foto;
  XFile? get foto => _foto;

  void clearFoto({bool notify = true}) {
    _foto = null;
    if (notify) {
      notifyListeners();
    }
  }

  // Flag untuk mencegah multiple image picker calls
  bool _isPickingImage = false;
  bool get isPickingImage => _isPickingImage;

  void uploadfoto() async {
    // Cegah multiple calls jika sedang picking image
    if (_isPickingImage) {
      print('Image picker already active, ignoring tap');
      return;
    }

    try {
      _isPickingImage = true;
      notifyListeners();

      final ambil = ImagePicker();
      final take = await ambil.pickImage(source: ImageSource.gallery);
      if (take != null) {
        _foto = take;
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      _isPickingImage = false;
      notifyListeners();
    }
  }

  // state pilihan

  // nama pemilik di Admin
  final namas = "Pemilik";
  List<AuthModel> get isian {
    return _listauth.where((element) => element.role == namas).toList();
  }

  List<String> get naman =>
      isian.map((element) => element.username).whereType<String>().toList();

  List<int> get kunci =>
      isian.map((element) => element.id_auth).whereType<int>().toList();

  String namanya = "Pilih";

  void pilihpemilik(String value) {
    namanya = value;
    notifyListeners();
  }

  // untuk admin mengisi kost karena ada nama sama telepon yang fix
  final TextEditingController nama = TextEditingController();
  final TextEditingController telepon = TextEditingController();

  // nama.text = _listauth.firstWhere((element) => element.id_auth == id_auth);

  List<AuthModel> get idnya {
    return _listauth.where((element) => element.id_auth == id_authnya).toList();
  }

  List<String> get name {
    return idnya
        .map((element) => element.username)
        .whereType<String>()
        .toList();
  }

  String pilihan = "pilih";

  void pilihanpemilik(String value) {
    pilihan = value;
    notifyListeners();
  }

  // jenis kost (dropdown dari subkriteria jenis kost, fallback ke 3 opsi)
  List<String> _jeniskost = ['Umum', 'Khusus Putri', 'Khusus Putra'];
  List<String> get jeniskost {
    final dinamis = _getSubkriteriaOptions(
      (nama) => nama.contains('jenis') && nama.contains('kost'),
    );
    return dinamis.isNotEmpty ? dinamis : _jeniskost;
  }

  String jeniskosts = "Pilih";

  void pilihkost(String value) {
    jeniskosts = value;
    notifyListeners();
  }

  // tipe penghuni (enum: Umum, Putra, Putri)
  List<String> _penghuniOptions = ['Umum', 'Putra', 'Putri'];
  List<String> get penghuniOptions => _penghuniOptions;

  String penghunis = "Pilih";

  void pilihpenghuni(String value) {
    penghunis = value;
    notifyListeners();
  }

  // jenis keamanan
  List<String> _jeniskeamanan = ['Penjaga', 'Penjaga sama CCTV'];

  List<String> get jeniskeamananan {
    final dinamis = _getSubkriteriaOptions((nama) => nama.contains('keamanan'));
    return dinamis
        // .isNotEmpty ? dinamis : _jeniskeamanan
        ;
  }

  String jeniskeamanans = "Pilih";

  void pilihkeamanan(String value) {
    jeniskeamanans = value;
    notifyListeners();
  }

  // batas jam malam
  List<String> _jenisbatasjammalam = [
    '21:00',
    '22:00',
    '23:00 -24:00',
    'beri kunci pagar',
  ];
  List<String> get jenisbatasjammalam {
    final dinamis = _getSubkriteriaOptions(
      (nama) => nama.contains('batas') || nama.contains('jam malam'),
    );
    return dinamis.isNotEmpty ? dinamis : _jenisbatasjammalam;
  }

  String batasjammalams = "Pilih";

  void pilihbatasjammalam(String value) {
    batasjammalams = value;
    notifyListeners();
  }

  // Cache untuk opsi dinamis supaya kostNeedsSubkriteriaFix lebih cepat
  List<String> _cachedKeamananOptions = [];
  List<String> _cachedBatasJamMalamOptions = [];
  List<String> _cachedJenisAirOptions = [];
  List<String> _cachedJenisListrikOptions = [];
  List<String> _cachedJenisKostOptions = [];

  void _refreshDynamicOptionsCache() {
    _cachedKeamananOptions =
        _getSubkriteriaOptions((nama) => nama.contains('keamanan'));
    _cachedBatasJamMalamOptions = _getSubkriteriaOptions(
      (nama) => nama.contains('batas') || nama.contains('jam malam'),
    );
    _cachedJenisAirOptions = _getSubkriteriaOptions(
      (nama) => nama.contains('air') || nama.contains('pembayaran'),
    );
    _cachedJenisListrikOptions =
        _getSubkriteriaOptions((nama) => nama.contains('listrik'));
    _cachedJenisKostOptions = _getSubkriteriaOptions(
      (nama) => nama.contains('jenis') && nama.contains('kost'),
    );
  }

  /// Opsi subkriteria dinamis (tanpa fallback) untuk validasi data tersimpan.
  /// Jika list kosong, artinya data kriteria/subkriteria belum tersedia atau
  /// tidak ada subkriteria untuk kriteria tersebut.
  List<String> get keamananOptionsDynamic => _cachedKeamananOptions;

  List<String> get batasJamMalamOptionsDynamic => _cachedBatasJamMalamOptions;

  List<String> get jenisAirOptionsDynamic => _cachedJenisAirOptions;

  List<String> get jenisListrikOptionsDynamic => _cachedJenisListrikOptions;

  List<String> get jenisKostOptionsDynamic => _cachedJenisKostOptions;

  /// True jika ada nilai dropdown pada data kost yang sudah tidak valid
  /// karena subkriteria terkait sudah dihapus.
  bool kostNeedsSubkriteriaFix(KostModel kost) {
    final keamanan = (kost.keamanan ?? '').trim();
    final batas = (kost.batas_jam_malam ?? '').trim();
    final air = (kost.jenis_pembayaran_air ?? '').trim();
    final listrik = (kost.jenis_listrik ?? '').trim();
    final jenisKost = (kost.jenis_kost ?? '').trim();

    final optKeamanan = keamananOptionsDynamic;
    if (optKeamanan.isNotEmpty && keamanan.isNotEmpty) {
      if (!optKeamanan.contains(keamanan)) return true;
    }

    final optBatas = batasJamMalamOptionsDynamic;
    if (optBatas.isNotEmpty && batas.isNotEmpty) {
      if (!optBatas.contains(batas)) return true;
    }

    final optAir = jenisAirOptionsDynamic;
    if (optAir.isNotEmpty && air.isNotEmpty) {
      if (!optAir.contains(air)) return true;
    }

    final optListrik = jenisListrikOptionsDynamic;
    if (optListrik.isNotEmpty && listrik.isNotEmpty) {
      if (!optListrik.contains(listrik)) return true;
    }

    final optJenisKost = jenisKostOptionsDynamic;
    if (optJenisKost.isNotEmpty && jenisKost.isNotEmpty) {
      if (!optJenisKost.contains(jenisKost)) return true;
    }

    return false;
  }

  // jenis pembayaran air
  List<String> _jenispembayaranair = ['meteran', 'pembayaran awal'];
  List<String> get jenispembayaranair {
    final dinamis = _getSubkriteriaOptions(
      (nama) => nama.contains('air') || nama.contains('pembayaran'),
    );
    return dinamis.isNotEmpty ? dinamis : _jenispembayaranair;
  }

  String jenispembayaranairs = "Pilih";

  void pilihjenispembayaranair(String value) {
    jenispembayaranairs = value;
    notifyListeners();
  }

  // jenis listrik
  List<String> _jenislistrik = ['token', 'perbulan'];
  List<String> get jenislistrik {
    final dinamis = _getSubkriteriaOptions((nama) => nama.contains('listrik'));
    return dinamis.isNotEmpty ? dinamis : _jenislistrik;
  }

  String jenislistriks = "Pilih";

  void pilihjenislistrik(String value) {
    jenislistriks = value;
    notifyListeners();
  }

  // kategori bayaran kost
  List<String> _per = ['bulan', 'tahun'];
  List<String> get per => _per;

  String pernama = "Pilih";

  void pilihbayar(value) {
    pernama = value;
    notifyListeners();
  }

  void resetpilihan() {
    // Reset state yang terkait FORM saja.
    // Jangan hapus token/_listauth di sini, karena dipakai untuk dropdown pemilik
    // dan state login akan hilang ketika user hanya keluar-masuk halaman form.
    _foto = null;
    namanya = "Pilih";
    jeniskosts = "Pilih";
    penghunis = "Pilih";
    jeniskeamanans = "Pilih";
    batasjammalams = "Pilih";
    jenispembayaranairs = "Pilih";
    jenislistriks = "Pilih";
    pernama = "Pilih";
    notifyListeners();
  }

  /// Reset TOTAL state provider (dipakai saat logout).
  void resetSession() {
    resetpilihan();
    _token = null;
    _email = null;
    _expires_in = null;
    _listauth = [];
    id_authnya = null;
    _dataku = [];

    _hasLoadedPemilikKost = false;
    _loadedPemilikAuthId = null;
    notifyListeners();
  }

  /// Ambil opsi subkriteria berdasarkan nama kriteria (lowercase) yang cocok.
  /// Dipakai untuk mengisi dropdown keamanan, batas jam malam, jenis air, listrik.
  List<String> _getSubkriteriaOptions(
    bool Function(String lowerNamaKriteria) match,
  ) {
    if (_listKriteria.isEmpty || _listSubkriteria.isEmpty) return [];

    final matchedIds = _listKriteria
        .where((k) {
          final nama = (k.kategori ?? '').toLowerCase();
          return match(nama);
        })
        .map((k) => k.id_kriteria)
        .whereType<int>()
        .toSet();

    if (matchedIds.isEmpty) return [];

    final hasil = _listSubkriteria
        .where((s) => matchedIds.contains(s.id_kriteria))
        .map((s) => s.kategori)
        .whereType<String>()
        .toSet()
        .toList();

    hasil.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return hasil;
  }

  // state konversi
  Future<void> konversicreatedata(
    String? notlp_kost,
    String nama_kost,
    String alamat_kost,
    String pemilik_kost,
    int harga_kost,
    String titik_koordinat,
    String jenis_kost,
    String penghuni,
    String keamanan,
    String batas_jam_malam,
    String jenis_pembayaran_air,
    String jenis_listrik,
    num panjang,
    num lebar,
    XFile gambar,
    String per,
    List<dynamic> manalistnya,
  ) async {
    List<dynamic> inimilistnya = manalistnya
        .map((element) => element.namaFasilitasController.text)
        .toList();

    String fasilitas = inimilistnya.join(", ");
    await createdata(
      id_authnya!,
      notlp_kost,
      nama_kost,
      alamat_kost,
      pemilik_kost,
      harga_kost,
      titik_koordinat,
      jenis_kost,
      penghuni,
      keamanan,
      batas_jam_malam,
      jenis_pembayaran_air,
      jenis_listrik,
      panjang,
      lebar,
      gambar,
      per,
      fasilitas,
    );
  }

  /// Khusus admin: buat kost untuk pemilik yang dipilih (override id_auth).
  Future<void> konversicreatedataAdmin(
    int idAuthPemilik,
    String? notlp_kost,
    String nama_kost,
    String alamat_kost,
    String pemilik_kost,
    int harga_kost,
    String titik_koordinat,
    String jenis_kost,
    String penghuni,
    String keamanan,
    String batas_jam_malam,
    String jenis_pembayaran_air,
    String jenis_listrik,
    num panjang,
    num lebar,
    XFile gambar,
    String per,
    List<dynamic> manalistnya,
  ) async {
    final inimilistnya = manalistnya
        .map((element) => element.namaFasilitasController.text)
        .toList();
    final fasilitas = inimilistnya.join(", ");

    await createdata(
      idAuthPemilik,
      notlp_kost,
      nama_kost,
      alamat_kost,
      pemilik_kost,
      harga_kost,
      titik_koordinat,
      jenis_kost,
      penghuni,
      keamanan,
      batas_jam_malam,
      jenis_pembayaran_air,
      jenis_listrik,
      panjang,
      lebar,
      gambar,
      per,
      fasilitas,
    );
  }

  Future<void> konversiupdatedata(
    XFile? foto,
    String fotolama,
    int id_kost,
    int id_auth,
    String nama_kost,
    String pemilik_kost,
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
    String koordinnat,
    String per,
    List<dynamic> seelist,
  ) async {
    List<dynamic> konvert =
        seelist.map((element) => element.namaFasilitasController.text).toList();

    String fasilitas = konvert.join(", ");

    await updatedata(
      foto,
      fotolama,
      id_kost,
      id_auth,
      nama_kost,
      pemilik_kost,
      alamat_kost,
      notlp_kost,
      harga_kost,
      batas_jam_malam,
      jenis_listrik,
      jenis_pembayaran_air,
      keamanan,
      jenis_kost,
      penghuni,
      panjang,
      lebar,
      koordinnat,
      per,
      fasilitas,
    );
  }

  Future<void> konversicreateddatapemilik(
    String token,
    XFile foto,
    int id_auth,
    String koordinat,
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
    String per,
    List<dynamic> manalistnya,
  ) async {
    List<dynamic> mapping =
        manalistnya.map((element) => element.fasilitas.text).toList();

    String fasilitas = mapping.join(", ");

    await createdatapemilik(
      token,
      foto,
      id_auth,
      koordinat,
      nama_pemilik,
      nama_kost,
      alamat,
      telpon,
      harga,
      jenis_kost,
      penghuni,
      keamanan,
      panjang,
      lebar,
      batas_jam_malam,
      jenis_pembayaran_air,
      jenis_listrik,
      per,
      fasilitas,
    );
  }

  Future<void> konversiupdateddatapemilik(
    String token,
    int id_auth,
    int id_kost,
    String fotolama,
    XFile? foto,
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
    String koordinat,
    String per,
    List<dynamic> wherelist,
  ) async {
    List<dynamic> pemisah =
        wherelist.map((element) => element.fasilitas.text).toList();

    String fasilitas = pemisah.join(", ");

    await updateddatapemilik(
      token,
      id_auth,
      // id_fasilitas,
      id_kost,
      fotolama,
      foto,
      nama_pemilik,
      nama_kost,
      telpon,
      alamat_kost,
      harga_kost,
      jenis_kost,
      penghuni,
      keamanan,
      panjang,
      lebar,
      batas_jam_malam,
      jenis_pembayaran_air,
      jenis_listrik,
      koordinat,
      per,
      fasilitas,
    );
  }

  // state service

  // Admin
  List<KostModel> _kost = [];
  List<KostModel> get kost => _kost;
  int get semunya => _kost.length;
  final KostService _kekost = KostService();

  List<FasilitasModel> _fasilitas = [];
  List<FasilitasModel> get faslitas => _fasilitas;
  final FasilitasService _kefasilitas = FasilitasService();

  // Penyewa
  List<KostModel> _kostpenyewa = [];
  List<KostModel> get kostpenyewa => _kostpenyewa;
  int get semuanyapenyewa => _kostpenyewa.length;

  List<FasilitasModel> _fasilitaspenyewa = [];
  List<FasilitasModel> get fasilitaspenyewa => _fasilitaspenyewa;

  // Pemilik
  List<KostModel> _kostpemilik = [];
  List<KostModel> get kostpemilik => _kostpemilik;

  List<FasilitasModel> _fasilitaspemilik = [];
  List<FasilitasModel> get fasilitaspemilik => _fasilitaspemilik;

  // Flag untuk menandai apakah data kost pemilik sudah pernah di-load
  bool _hasLoadedPemilikKost = false;
  bool get hasLoadedPemilikKost => _hasLoadedPemilikKost;

  // Cache id_auth pemilik terakhir yang sudah di-load
  int? _loadedPemilikAuthId;

  // Loading flags untuk daftar kost
  bool _isLoadingAdminKost = false;
  bool get isLoadingAdminKost => _isLoadingAdminKost;

  bool _isLoadingPenyewaKost = false;
  bool get isLoadingPenyewaKost => _isLoadingPenyewaKost;

  bool _isLoadingPemilikKost = false;
  bool get isLoadingPemilikKost => _isLoadingPemilikKost;

  FasilitasModel inputan = FasilitasModel();

  Future<void> createdata(
    int id_auth,
    // bool tempat_tidur,
    // bool kamar_mandi_dalam,
    // bool meja,
    // bool tempat_parkir,
    // bool lemari,
    // bool ac,
    // bool tv,
    // bool kipas,
    // bool dapur_dalam,
    // bool wifi,
    String? notlp_kost,
    String nama_kost,
    String alamat_kost,
    String pemilik_kost,
    int harga_kost,
    String titik_koordinat,
    String jenis_kost,
    String penghuni,
    String keamanan,
    String batas_jam_malam,
    String jenis_pembayaran_air,
    String jenis_listrik,
    num panjang,
    num lebar,
    XFile gambar,
    String per,
    String fasilitas,
  ) async {
    try {
      final upload = await _kekost.uploadgambar(gambar);
      if (upload != null) {
        // final all_fasilitas = await _kefasilitas.createdata(
        //   id_auth = id_auth,
        //   tempat_tidur,
        //   kamar_mandi_dalam,
        //   meja,
        //   tempat_parkir,
        //   lemari,
        //   ac,
        //   tv,
        //   kipas,
        //   dapur_dalam,
        //   wifi,
        // );

        List<String> pembeda = titik_koordinat.split(',');
        double latitude = double.parse(pembeda[0].trim());
        double longitudo = double.parse(pembeda[1].trim());

        if (
            // all_fasilitas['id_fasilitas'] != null &&
            upload != null && latitude != null && longitudo != null) {
          await _kekost.createdata(
            id_auth,
            // all_fasilitas['id_fasilitas'],
            notlp_kost,
            nama_kost,
            alamat_kost,
            pemilik_kost,
            harga_kost,
            jenis_kost,
            penghuni,
            keamanan,
            batas_jam_malam,
            jenis_pembayaran_air,
            jenis_listrik,
            panjang,
            lebar,
            latitude,
            longitudo,
            upload,
            per,
            fasilitas,
          );
        }
      }
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
  }

  Future<void> readdata() async {
    _isLoadingAdminKost = true;
    notifyListeners();

    try {
      final hasilnya = await _kekost.readdata();
      // Tabel 'fasilitas' sudah dihapus; fasilitas kini disimpan di kolom
      // `kost.fasilitas` (string). Jadi tidak perlu fetch tabel terpisah.
      _fasilitas = <FasilitasModel>[];
      _kost = hasilnya;
    } catch (e) {
      throw e;
    } finally {
      _isLoadingAdminKost = false;
      notifyListeners();
    }
  }

  Future<void> deletedata(int id_kost, String gambar) async {
    try {
      // final cek = _kost.firstWhere((element) => element.id_kost == id_kost);
      // await _kekost.deletegambar(cek.gambar_kost!);
      // await _kefasilitas.deletedata(cek.id_fasilitas!);
      await _kekost.deletedata(id_kost);
      await _kekost.deletegambar(gambar);
      print("done data kehapus");
      await _kekost.deletedata(id_kost);
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
  }

  Future<void> updatedata(
    XFile? foto,
    String fotolama,
    // int id_fasilitas,
    // bool tempat_tidur,
    // bool kamar_mandi_dalam,
    // bool meja,
    // bool tempat_parkir,
    // bool lemari,
    // bool ac,
    // bool tv,
    // bool kipas,
    // bool dapur_dalam,
    // bool wifi,
    int id_kost,
    int id_auth,
    String nama_kost,
    String pemilik_kost,
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
    String koordinnat,
    String per,
    String fasilitas,
  ) async {
    try {
      DateTime edit = DateTime.now();

      if (fotolama != null && foto == null) {
        // await _kefasilitas.updateddata(
        //   id_fasilitas,
        //   id_auth,
        //   tempat_tidur,
        //   kamar_mandi_dalam,
        //   meja,
        //   tempat_parkir,
        //   lemari,
        //   ac,
        //   tv,
        //   kipas,
        //   dapur_dalam,
        //   wifi,
        //   edit,
        // );

        List<String> bedakan = koordinnat.split(',');
        double latitude = double.parse(bedakan[0].trim());
        double longitudo = double.parse(bedakan[1].trim());

        if (fotolama != null && latitude != null && longitudo != null) {
          await _kekost.updatedata(
            id_kost,
            // id_fasilitas,
            id_auth,
            nama_kost,
            pemilik_kost,
            alamat_kost,
            notlp_kost,
            harga_kost,
            batas_jam_malam,
            jenis_listrik,
            jenis_pembayaran_air,
            keamanan,
            jenis_kost,
            penghuni,
            panjang,
            lebar,
            fotolama,
            latitude,
            longitudo,
            edit,
            per,
            fasilitas,
          );
        }
      } else {
        await _kekost.deletegambar(fotolama);
        final upload = await _kekost.uploadgambar(foto!);
        if (upload != null) {
          // await _kefasilitas.updateddata(
          //   id_fasilitas,
          //   id_auth,
          //   tempat_tidur,
          //   kamar_mandi_dalam,
          //   meja,
          //   tempat_parkir,
          //   lemari,
          //   ac,
          //   tv,
          //   kipas,
          //   dapur_dalam,
          //   wifi,
          //   edit,
          // );

          List<String> bedakan = koordinnat.split(',');
          double latitude = double.parse(bedakan[0].trim());
          double longitudo = double.parse(bedakan[1].trim());

          if (upload != null && latitude != null && longitudo != null) {
            await _kekost.updatedata(
              id_kost,
              // id_fasilitas,
              id_auth,
              nama_kost,
              pemilik_kost,
              alamat_kost,
              notlp_kost,
              harga_kost,
              batas_jam_malam,
              jenis_listrik,
              jenis_pembayaran_air,
              keamanan,
              jenis_kost,
              penghuni,
              panjang,
              lebar,
              upload,
              latitude,
              longitudo,
              edit,
              per,
              fasilitas,
            );
          }
        }
      }
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
  }

  Future<void> readdatapenyewa(String token) async {
    _isLoadingPenyewaKost = true;
    notifyListeners();

    try {
      final inikost = await _kekost.readdatapenyewa(token);
      // Tabel 'fasilitas' sudah dihapus; fasilitas kini disimpan di kolom
      // `kost.fasilitas` (string). Jadi tidak perlu fetch tabel terpisah.
      _fasilitaspenyewa = <FasilitasModel>[];
      _kostpenyewa = inikost;
    } catch (e) {
      debugPrint('Error ambil data kost sebagai penyewa: $e');
    } finally {
      _isLoadingPenyewaKost = false;
      notifyListeners();
    }
  }

  // tidak kena refresh pada saat buat data di pemilik lansung
  // Future<void> readdatapemilik(int id_auth, String token,
  //     {bool force = false}) async {
  //   // Cegah request ganda saat masih loading
  //   if (_isLoadingPemilikKost) {
  //     return;
  //   }

  //   // Jika sudah pernah load dan tidak dipaksa, jangan fetch lagi
  //   if (_hasLoadedPemilikKost && !force && _loadedPemilikAuthId == id_auth) {
  //     return;
  //   }

  //   _isLoadingPemilikKost = true;
  //   _loadedPemilikAuthId = id_auth;
  //   notifyListeners();

  //   try {
  //     final hasilkost = await _kekost.readdatapemilik(id_auth, token);
  //     final hasilifasilitas =
  //         await _kefasilitas.readdatapemilik(id_auth, token);

  //     _kostpemilik = hasilkost;
  //     _fasilitaspemilik = hasilifasilitas;
  //   } catch (e) {
  //     throw e;
  //   } finally {
  //     _isLoadingPemilikKost = false;
  //     _hasLoadedPemilikKost = true;
  //     notifyListeners();
  //   }
  // }

  Future<void> readdatapemilik(int id_auth, String token) async {
    try {
      final hasilnya = await _kekost.readdatapemilik(id_auth, token);
      _kostpemilik = hasilnya;
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }

  Future<void> createdatapemilik(
    String token,
    XFile foto,
    int id_auth,
    // bool tempat_tidur,
    // bool kamar_mandi_dalam,
    // bool meja,
    // bool tempat_parkir,
    // bool lemari,
    // bool ac,
    // bool tv,
    // bool kipas,
    // bool dapur_dalam,
    // bool wifi,
    String koordinat,
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
    String per,
    String fasilitas,
  ) async {
    try {
      final ambil = await _kekost.uploadgambar(foto);
      // final namanya = await _kefasilitas.createdatapemilik(
      //   token,
      //   id_auth,
      //   tempat_tidur,
      //   kamar_mandi_dalam,
      //   meja,
      //   tempat_parkir,
      //   lemari,
      //   ac,
      //   tv,
      //   kipas,
      //   dapur_dalam,
      //   wifi,
      // );

      // final idFasilitas = namanya['id_fasilitas'];
      // if (idFasilitas == null) {
      //   throw 'Gagal membuat fasilitas (id_fasilitas kosong).';
      // }

      final parts = koordinat.split(',');
      if (parts.length != 2) {
        throw 'Format titik koordinat tidak valid. Contoh: -5.147665, 119.432731';
      }
      final garis_lintang = double.tryParse(parts[0].trim());
      final garis_bujur = double.tryParse(parts[1].trim());
      if (garis_lintang == null || garis_bujur == null) {
        throw 'Format titik koordinat tidak valid. Contoh: -5.147665, 119.432731';
      }

      await _kekost.createddatapemilik(
        token,
        id_auth,
        // idFasilitas,
        nama_pemilik,
        nama_kost,
        alamat,
        telpon,
        harga,
        jenis_kost,
        penghuni,
        keamanan,
        panjang,
        lebar,
        batas_jam_malam,
        jenis_pembayaran_air,
        jenis_listrik,
        garis_lintang,
        garis_bujur,
        ambil,
        per,
        fasilitas,
      );

      await readdatapemilik(id_auth, token);
    } catch (e) {
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateddatapemilik(
    String token,
    int id_auth,
    // int id_fasilitas,
    int id_kost,
    String fotolama,
    XFile? foto,
    // bool tempat_tidur,
    // bool kamar_mandi_dalam,
    // bool meja,
    // bool tempat_parkir,
    // bool lemari,
    // bool ac,
    // bool tv,
    // bool dapur_dalam,
    // bool wifi,
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
    String koordinat,
    String per,
    String fasilitas,
  ) async {
    try {
      final hari_ini = DateTime.now();

      if (fotolama != null && foto == null) {
        // await _kefasilitas.updateddatapemilik(
        //   token,
        //   id_authnya!,
        //   id_fasilitas,
        //   tempat_tidur,
        //   kamar_mandi_dalam,
        //   meja,
        //   tempat_parkir,
        //   lemari,
        //   ac,
        //   tv,
        //   dapur_dalam,
        //   wifi,
        //   hari_ini,
        // );

        List<String> cek = koordinat.split(',');
        double garis_lintang = double.parse(cek[0].trim());
        double garis_bujur = double.parse(cek[1].trim());

        if (garis_lintang != null && garis_bujur != null) {
          await _kekost.updateddatapemmilik(
            token,
            id_kost,
            id_auth,
            // id_fasilitas,
            nama_pemilik,
            nama_kost,
            telpon,
            alamat_kost,
            harga_kost,
            jenis_kost,
            penghuni,
            keamanan,
            panjang,
            lebar,
            batas_jam_malam,
            jenis_pembayaran_air,
            jenis_listrik,
            garis_lintang,
            garis_bujur,
            fotolama,
            hari_ini,
            per,
            fasilitas,
          );
        }
      } else {
        await _kekost.deletegambar(fotolama);
        final namanya = await _kekost.uploadgambar(foto!);

        if (namanya != null) {
          // await _kefasilitas.updateddatapemilik(
          //   token,
          //   id_authnya!,
          //   id_fasilitas,
          //   tempat_tidur,
          //   kamar_mandi_dalam,
          //   meja,
          //   tempat_parkir,
          //   lemari,
          //   ac,
          //   tv,
          //   dapur_dalam,
          //   wifi,
          //   hari_ini,
          // );

          List<String> path = koordinat.split(',');
          double garis_lintang = double.parse(path[0].trim());
          double garis_bujur = double.parse(path[1].trim());

          if (namanya != null && garis_lintang != null && garis_bujur != null) {
            await _kekost.updateddatapemmilik(
              token,
              id_kost,
              id_auth,
              // id_fasilitas,
              nama_pemilik,
              nama_kost,
              telpon,
              alamat_kost,
              harga_kost,
              jenis_kost,
              penghuni,
              keamanan,
              panjang,
              lebar,
              batas_jam_malam,
              jenis_pembayaran_air,
              jenis_listrik,
              garis_lintang,
              garis_bujur,
              namanya,
              hari_ini,
              per,
              fasilitas,
            );
          }
        }
      }
    } catch (e) {
      throw e;
    }
    await readdatapemilik(id_authnya!, token);
    notifyListeners();
  }

  Future<void> deletedatapemilik(int id_kost, String gambar) async {
    try {
      // await _kefasilitas.deletedatapemilik(token!, id_fasilitas);
      await _kekost.deletedata(id_kost);
      await _kekost.deletegambar(gambar);
    } catch (e) {
      throw e;
    }
    await readdatapemilik(id_authnya!, token!);
    notifyListeners();
  }

  // ============================================
  // STATE DAN METHOD UNTUK SAW (Simple Additive Weighting)
  // ============================================

  // Service untuk kriteria dan subkriteria
  final KriteriaServices _kriteriaService = KriteriaServices();
  final SubkriteriaServices _subkriteriaService = SubkriteriaServices();

  // State untuk data kriteria dan subkriteria
  List<KriteriaModels> _listKriteria = [];
  List<KriteriaModels> get listKriteria => _listKriteria;

  List<SubkriteriaModels> _listSubkriteria = [];
  List<SubkriteriaModels> get listSubkriteria => _listSubkriteria;

  // State untuk hasil SAW
  HasilSAW? _hasilSAW;
  HasilSAW? get hasilSAW => _hasilSAW;

  // State untuk lokasi user (untuk kriteria jarak)
  double? _userLat;
  double? _userLng;
  double? get userLat => _userLat;
  double? get userLng => _userLng;

  // Map untuk menyimpan jarak per kost (id_kost -> jarak dalam km)
  // Ini digunakan untuk mengambil jarak yang sudah dihitung dari halaman sebelumnya
  Map<int, double> _jarakKostMap = {};
  Map<int, double> get jarakKostMap => _jarakKostMap;

  // Loading flag untuk SAW
  bool _isLoadingSAW = false;
  bool get isLoadingSAW => _isLoadingSAW;

  // Error message untuk SAW
  String? _errorSAW;
  String? get errorSAW => _errorSAW;

  /// Set lokasi user untuk perhitungan kriteria jarak
  void setUserLocation(double lat, double lng) {
    _userLat = lat;
    _userLng = lng;
    print("📍 Lokasi user di-set: ($_userLat, $_userLng)");
    notifyListeners();
  }

  /// Set jarak kost yang sudah dihitung dari halaman sebelumnya
  /// [jarakMap] = Map dari id_kost ke jarak dalam km
  void setJarakKostMap(Map<int, double> jarakMap) {
    _jarakKostMap = jarakMap;
    print("📏 Jarak kost di-set: ${_jarakKostMap.length} kost");
    for (var entry in _jarakKostMap.entries) {
      print(" id_kost=${entry.key} → ${entry.value.toStringAsFixed(2)} km");
    }
    notifyListeners();
  }

  /// Clear jarak kost map
  void clearJarakKostMap() {
    _jarakKostMap = {};
    notifyListeners();
  }

  /// Clear lokasi user
  void clearUserLocation() {
    _userLat = null;
    _userLng = null;
    notifyListeners();
  }

  // Flag untuk debug print sekali saja
  static bool _debugKriteriaPrinted = false;
  static bool _debugSubkriteriaPrinted = false;

  /// Mengambil data kriteria dari database
  Future<void> fetchKriteria() async {
    if (!_debugKriteriaPrinted) print("\n📋 Mengambil data kriteria...");
    try {
      _listKriteria = await _kriteriaService.readdata(
        log: !_debugKriteriaPrinted,
      );
      if (!_debugKriteriaPrinted) {
        print("✅ Berhasil mengambil ${_listKriteria.length} kriteria");
        _debugKriteriaPrinted = true;
      }
      // Refresh cache opsi dinamis setelah data kriteria berubah
      _refreshDynamicOptionsCache();
    } catch (e) {
      print("❌ Gagal mengambil kriteria: $e");
      _listKriteria = [];
      _refreshDynamicOptionsCache();
    }
    notifyListeners();
  }

  /// Mengambil data subkriteria dari database
  Future<void> fetchSubkriteria() async {
    if (!_debugSubkriteriaPrinted) print("\n📋 Mengambil data subkriteria...");
    try {
      _listSubkriteria = await _subkriteriaService.readdata(
        log: !_debugSubkriteriaPrinted,
      );
      if (!_debugSubkriteriaPrinted) {
        print("✅ Berhasil mengambil ${_listSubkriteria.length} subkriteria");
        _debugSubkriteriaPrinted = true;
      }
      // Refresh cache opsi dinamis setelah data subkriteria berubah
      _refreshDynamicOptionsCache();
    } catch (e) {
      print("❌ Gagal mengambil subkriteria: $e");
      _listSubkriteria = [];
      _refreshDynamicOptionsCache();
    }
    notifyListeners();
  }

  /// Menjalankan perhitungan SAW untuk penyewa
  /// Menggunakan data kost penyewa dan kriteria yang tersedia
  /// [userLat] dan [userLng] opsional untuk kriteria jarak
  Future<void> hitungSAW({double? userLat, double? userLng}) async {
    print("\n" + "=" * 60);
    print("🚀 INISIASI PERHITUNGAN SAW DARI PROVIDER");
    print("=" * 60);

    // Set lokasi user jika ada
    if (userLat != null && userLng != null) {
      setUserLocation(userLat, userLng);
    }

    _isLoadingSAW = true;
    _errorSAW = null;
    notifyListeners();

    try {
      // Ambil data kriteria dan subkriteria terlebih dahulu
      await fetchKriteria();
      await fetchSubkriteria();

      // Validasi data
      if (_kostpenyewa.isEmpty) {
        throw "Tidak ada data kost untuk dihitung!";
      }
      if (_listKriteria.isEmpty) {
        throw "Tidak ada data kriteria! Silakan tambah kriteria terlebih dahulu.";
      }

      print("📊 Data untuk SAW:");
      print("   - Jumlah Kost: ${_kostpenyewa.length}");
      print("   - Jumlah Fasilitas: ${_fasilitaspenyewa.length}");
      print("   - Jumlah Kriteria: ${_listKriteria.length}");
      print("   - Jumlah Subkriteria: ${_listSubkriteria.length}");
      print("   - Lokasi User: ($_userLat, $_userLng)");
      print("   - Jarak Kost Map: ${_jarakKostMap.length} kost");

      // Debug: Tampilkan detail kost dan id_fasilitas nya
      print("\n📦 DEBUG KOST DAN ID_FASILITAS:");
      for (var kost in _kostpenyewa) {
        print(
          "   Kost: ${kost.nama_kost} (id_kost=${kost.id_kost}, id_fasilitas=${kost.id_fasilitas})",
        );
      }

      // Debug: Tampilkan detail fasilitas
      print("\n📦 DEBUG FASILITAS TERSEDIA:");
      for (var f in _fasilitaspenyewa) {
        print(
          "   Fasilitas: id_fasilitas=${f.id_fasilitas}, id_auth=${f.id_auth}",
        );
      }

      // Jalankan perhitungan SAW dengan lokasi user DAN jarak yang sudah dihitung
      _hasilSAW = SimpleAdditiveWeighting.hitungSAW(
        listKost: _kostpenyewa,
        listFasilitas: _fasilitaspenyewa,
        listKriteria: _listKriteria,
        listSubkriteria: _listSubkriteria,
        userLat: _userLat,
        userLng: _userLng,
        jarakKostMap: _jarakKostMap, // Kirim jarak yang sudah dihitung
      );

      if (_hasilSAW == null) {
        throw "Gagal melakukan perhitungan SAW!";
      }

      print("\n✅ PERHITUNGAN SAW BERHASIL!");
      if (_hasilSAW!.hasilRanking.isNotEmpty) {
        print(
          "   Hasil ranking terbaik: ${_hasilSAW!.hasilRanking.first.namaKost}",
        );
      } else {
        print(
          "   ⚠️ Tidak ada kost yang lolos penilaian (semua tidak cocok dengan subkriteria).",
        );
      }
    } catch (e) {
      print("❌ ERROR SAW: $e");
      _errorSAW = e.toString();
      _hasilSAW = null;
    } finally {
      _isLoadingSAW = false;
      notifyListeners();
    }
  }

  /// Menjalankan perhitungan SAW untuk Admin (dengan semua data kost)
  Future<void> hitungSAWAdmin({double? userLat, double? userLng}) async {
    print("\n" + "=" * 60);
    print("🚀 INISIASI PERHITUNGAN SAW ADMIN DARI PROVIDER");
    print("=" * 60);

    if (userLat != null && userLng != null) {
      setUserLocation(userLat, userLng);
    }

    _isLoadingSAW = true;
    _errorSAW = null;
    notifyListeners();

    try {
      await fetchKriteria();
      await fetchSubkriteria();

      if (_kost.isEmpty) {
        throw "Tidak ada data kost untuk dihitung!";
      }
      if (_listKriteria.isEmpty) {
        throw "Tidak ada data kriteria! Silakan tambah kriteria terlebih dahulu.";
      }

      _hasilSAW = SimpleAdditiveWeighting.hitungSAW(
        listKost: _kost,
        listFasilitas: _fasilitas,
        listKriteria: _listKriteria,
        listSubkriteria: _listSubkriteria,
        userLat: _userLat,
        userLng: _userLng,
      );

      if (_hasilSAW == null) {
        throw "Gagal melakukan perhitungan SAW!";
      }

      print("\n✅ PERHITUNGAN SAW ADMIN BERHASIL!");
    } catch (e) {
      print("❌ ERROR SAW ADMIN: $e");
      _errorSAW = e.toString();
      _hasilSAW = null;
    } finally {
      _isLoadingSAW = false;
      notifyListeners();
    }
  }

  /// Reset hasil SAW
  void resetSAW() {
    _hasilSAW = null;
    _errorSAW = null;
    notifyListeners();
  }

  /// Mendapatkan kost berdasarkan ID dari hasil ranking
  KostModel? getKostById(int idKost) {
    try {
      return _kostpenyewa.firstWhere((k) => k.id_kost == idKost);
    } catch (e) {
      try {
        return _kost.firstWhere((k) => k.id_kost == idKost);
      } catch (e) {
        return null;
      }
    }
  }

  /// Mendapatkan fasilitas berdasarkan ID
  FasilitasModel? getFasilitasById(int idFasilitas) {
    try {
      return _fasilitaspenyewa.firstWhere((f) => f.id_fasilitas == idFasilitas);
    } catch (e) {
      try {
        return _fasilitas.firstWhere((f) => f.id_fasilitas == idFasilitas);
      } catch (e) {
        return null;
      }
    }
  }
}
