import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/profil_model.dart';
import '../models/auth_model.dart';
import '../services/profil_service.dart';

class ProfilProvider with ChangeNotifier {
  // state ambil
  String? _accesstoken, _email;
  String? get accesstoken => _accesstoken;
  String? get email => _email;
  int? id_auth;
  List<AuthModel> _listauth = [];
  List<AuthModel> get listauth => _listauth;

  List<ProfilModel> hasil = [];

  void terisi(
    String value,
    String isi,
    int angka,
    List<AuthModel> hasil,
  ) async {
    // Jika user berganti (login akun lain) dalam 1 sesi aplikasi,
    // pastikan cache foto lokal tidak "nyangkut" ke akun berikutnya.
    final int? previousAuthId = id_auth;
    final bool authChanged = previousAuthId != null && previousAuthId != angka;
    if (authChanged) {
      _isinya = null;
      _mydata = [];
      this.hasil = [];
      id_profil = null;
    }

    _accesstoken = value;
    _email = isi;
    id_auth = angka;
    _listauth = hasil;
    if (_accesstoken != null &&
        _email != null &&
        id_auth != null &&
        _listauth.isNotEmpty) {
      AuthModel? currentAuth;
      for (final a in _listauth) {
        if (a.id_auth == id_auth) {
          currentAuth = a;
          break;
        }
      }

      if (currentAuth?.role == "Admin") {
        readuser();
      }
      readdata(_accesstoken!, id_auth!);
    }
    notifyListeners();
  }

  // state urus foto
  XFile? _isinya;
  XFile? get isinya => _isinya;

  // Flag untuk mencegah multiple image picker calls
  bool _isPickingImage = false;
  bool get isPickingImage => _isPickingImage;

  Future<void> uploadfoto() async {
    // Cegah multiple calls jika sedang picking image
    if (_isPickingImage) {
      print('Image picker already active, ignoring tap');
      return;
    }

    try {
      _isPickingImage = true;
      notifyListeners();

      final pembuka = ImagePicker();
      final cek = await pembuka.pickImage(source: ImageSource.gallery);
      if (cek != null) {
        _isinya = cek;
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      _isPickingImage = false;
      notifyListeners();
    }
  }

  void bersihfoto() {
    _isinya = null;
    notifyListeners();
  }

  // Penghubung ke Service
  List<ProfilModel> _mydata = [];
  List<ProfilModel> get mydata => _mydata;

  List<ProfilModel> _alluser = [];
  List<ProfilModel> get alluser => _alluser;
  int get semuanya => _alluser.length;
  final ProfilService _ref = ProfilService();
  int? id_profil;

  Future<void> readdata(String token, int id_auth) async {
    try {
      final hasilnya = await _ref.readdata(token, id_auth);
      _mydata = hasilnya;
      hasil = hasilnya;
      if (mydata.isNotEmpty) {
        id_profil = mydata.first.id_profil;
      } else {
        id_profil = null;
      }
    } catch (e) {
      // throw e;
    }
    notifyListeners();
  }

  Future<void> createprofil(XFile? foto, int hp) async {
    try {
      String? link;
      if (foto != null) {
        link = await _ref.uploadfoto(foto, _accesstoken!);
      }
      await _ref.createprofil(
        id_auth!,
        _accesstoken!,
        link,
        hp,
      );
    } catch (e) {
      throw e;
    }
    await readdata(_accesstoken!, id_auth!);
    notifyListeners();
  }

  Future<void> updateprofil(
    XFile? foto,
    String? linklama,
    int hp,
  ) async {
    final edit = DateTime.now();
    await readdata(_accesstoken!, id_auth!);
    try {
      final bool hasOldLink = linklama != null && linklama.isNotEmpty;

      if (foto == null) {
        // Tidak ada foto baru, hanya update data lain.
        await _ref.updateprofil(
          id_profil!,
          _accesstoken!,
          hasOldLink ? linklama! : null,
          hp,
          edit,
        );
      } else {
        // Ada foto baru
        if (hasOldLink) {
          // Jika ada foto lama, hapus dulu dari storage
          await _ref.hapusgambar(linklama!, _accesstoken!);
        }

        final link = await _ref.uploadfoto(
          foto,
          _accesstoken!,
        );
        if (link != null) {
          await _ref.updateprofil(
            id_profil!,
            _accesstoken!,
            link,
            hp,
            edit,
          );
        }
      }
    } catch (e) {
      print(e);
      throw e;
    }
    await readdata(_accesstoken!, id_auth!);
    notifyListeners();
  }

  Future<void> hapusFotoProfil() async {
    if (_accesstoken == null || id_auth == null || id_profil == null) return;
    if (_mydata.isEmpty) return;

    final String? linklama = _mydata.first.foto;
    final edit = DateTime.now();

    try {
      if (linklama != null && linklama.isNotEmpty) {
        await _ref.hapusgambar(linklama, _accesstoken!);
      }

      await _ref.setFotoProfil(
        id_profil!,
        _accesstoken!,
        null,
        edit,
      );
    } catch (e) {
      print(e);
      throw e;
    }

    await readdata(_accesstoken!, id_auth!);
    notifyListeners();
  }

  Future<void> readuser() async {
    try {
      final hasil = await _ref.readuser();
      _alluser = hasil;
    } catch (e) {
      // Jangan bikin aplikasi crash kalau jaringan / server bermasalah
      // Cukup log error-nya supaya bisa dilihat di debug console.
      print('Error readuser: $e');
    }
    notifyListeners();
  }

  Future<void> adminUpdateUserProfil({
    required int idProfil,
    String? jkl,
    int? kontak,
    DateTime? tgllahir,
  }) async {
    try {
      await _ref.adminUpdateProfil(
        idProfil: idProfil,
        jkl: jkl,
        kontak: kontak,
        tgllahir: tgllahir,
      );
    } catch (e) {
      throw e;
    }
    await readuser();
    notifyListeners();
  }

  Future<void> deletegambaradmin(String link) async {
    try {
      await _ref.deletegambaradmin(link);
    } catch (e) {
      final msg = e.toString();
      // Jika error karena object sudah tidak ditemukan di storage (404/not_found),
      // abaikan agar aplikasi tidak crash saat menghapus pengguna yang sudah tidak punya gambar.
      if (!(msg.contains('not_found') || msg.contains('404'))) {
        throw e;
      }
    }
    await readuser();
    notifyListeners();
  }

  // Future<void> deleteUserByProfilId(int idProfil) async {
  //   try {
  //     await _ref.deleteProfilById(idProfil);
  //     // refresh daftar pengguna setelah hapus
  //     await readuser();
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  // state halaman keluar
  void reset() {
    _accesstoken = null;
    _email = null;

    _mydata = [];
    _isinya = null;
    // defaults = 'Jenis Kelamin';

    id_profil = null;
    id_auth = null;
    notifyListeners();
  }
}
