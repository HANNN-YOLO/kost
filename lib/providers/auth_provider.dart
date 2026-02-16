import 'dart:convert';
import 'package:flutter/widgets.dart';
import '../models/auth_model.dart';
import '../services/auth_services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  // state relasi
  int? id_auth;
  List<AuthModel> hasilnya = [];

  // UI state password
  bool _kelihatan = false;
  bool get kelihatan => _kelihatan;

  void keadaan() {
    _kelihatan = !_kelihatan;
    notifyListeners();
  }

  bool _lihat = false;
  bool get lihat => _lihat;

  void konfirmasi() {
    _lihat = !_lihat;
    notifyListeners();
  }

  // UI set Role
  List<String> _roles = ['Pemilik', 'Penyewa'];
  List<String> get roles => _roles;
  String role = "Pilih";

  void pilihrole(String value) {
    role = value;
    notifyListeners();
  }

  // UI State Halaman
  String? _accesstoken, _email;
  DateTime? _expiresIn;

  String? get accesstoken => _accesstoken;
  String? get email => _email;
  DateTime? get expiresIn => _expiresIn;

  String? get tokens {
    if (_accesstoken != null &&
        _email != null &&
        _expiresIn!.isAfter(DateTime.now())) {
      return _accesstoken;
    } else {
      return null;
    }
  }

  bool get token {
    return tokens != null;
  }

  // Penghubung ke Service
  List<AuthModel> _mydata = [];
  List<AuthModel> get mydata => _mydata;
  final AuthServices _ref = AuthServices();

  Future<void> login(String email, String pass) async {
    try {
      // Validasi dasar sebelum kirim ke server
      if (email.trim().isEmpty || pass.isEmpty) {
        throw "Harap isi email dan sandi terlebih dahulu.";
      }

      final data = await _ref.login(email: email, pass: pass);
      if (data != null) {
        _accesstoken = data['access_token'];
        _email = email;
        _expiresIn = DateTime.now().add(Duration(seconds: data['expires_in']));
      }
    } catch (e) {
      throw e;
    }
    await readrole();
    await autologinbbuat();
    await autologout();
    notifyListeners();
  }

  Future<void> register(String username, String email, String pas1, String pas2,
      String role, BuildContext context) async {
    try {
      // Validasi dasar agar tidak mengirim data tidak lengkap ke server
      if (username.trim().isEmpty ||
          email.trim().isEmpty ||
          pas1.isEmpty ||
          pas2.isEmpty) {
        throw "Harap isi semua field terlebih dahulu.";
      }

      if (role == "Pilih") {
        throw "Harap pilih role sebagai Pemilik atau Penyewa.";
      }

      // Validasi panjang password (minimal 6 karakter)
      if (pas1.length < 6) {
        throw "Kata sandi harus terdiri dari minimal 6 huruf atau angka.";
      }

      if (pas1 != pas2) {
        throw "Sandi tidak sama dengan Konfirmasi Sandi pada saat di input";
      }

      final data = await _ref.register(email: email, pass: pas1);

      if (data != null) {
        await _ref.createuser(
          data['access_token'],
          data['user']['id'],
          username,
          email,
          role,
        );

        await Navigator.of(context).pushReplacementNamed("/login");
      } else {
        throw "Masukkan Email dan Sandi Anda";
      }
    } catch (e) {
      print(e);
      throw e;
    }
    await readrole();
    await autologinbbuat();
    await autologout();
    notifyListeners();
  }

  Future<void> readrole() async {
    try {
      if (_accesstoken == null || _accesstoken!.isEmpty) {
        throw "Sesi login tidak valid. Silakan login ulang.";
      }
      final data = await _ref.readdata(_accesstoken!);
      _mydata = data;
      if (_mydata.isEmpty) {
        throw "Data akun tidak ditemukan di sistem. Silakan hubungi admin untuk menyelesaikan pendaftaran akun Anda.";
      }

      id_auth = mydata.first.id_auth;
      final roleUser = data.first.role;
      if (roleUser == "Admin") {
        // Admin butuh daftar semua user
        final isinya = await _ref.alluser();
        hasilnya = isinya;
      } else {
        // Penyewa/Pemilik cukup data dirinya saja (hindari call admin key)
        hasilnya = data;
      }
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> updateUsername(String username) async {
    try {
      if (_accesstoken == null || _accesstoken!.isEmpty) {
        throw "Sesi login tidak valid. Silakan login ulang.";
      }
      if (id_auth == null) {
        throw "Data akun tidak ditemukan. Silakan login ulang.";
      }

      final trimmed = username.trim();
      if (trimmed.isEmpty) {
        throw "Nama tidak boleh kosong.";
      }

      await _ref.updateUsernameRest(
        token: _accesstoken!,
        idAuth: id_auth!,
        username: trimmed,
      );

      await readrole();
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> deletedata(int id_auth, String UID) async {
    try {
      // Hapus akun di modul auth (Supabase Auth)
      try {
        await _ref.deletedatauath(UID);
      } catch (e) {
        // Jika user sudah tidak ada di modul auth (404 user_not_found),
        // abaikan error tersebut dan lanjut hapus data di tabel rest.
        final msg = e.toString();
        if (!(msg.contains('user_not_found') || msg.contains('404'))) {
          rethrow;
        }
      }

      // Tetap hapus data user di tabel rest aplikasi
      await _ref.deletedatarest(id_auth);
    } catch (e) {
      throw e;
    }
    await readrole();
    notifyListeners();
  }

  // UI State Memori
  Timer? waktunya;

  Future<void> logout() async {
    // Jadikan logout idempotent: selalu bersihkan state lokal.
    _accesstoken = null;
    _email = null;
    _expiresIn = null;
    id_auth = null;
    _mydata = [];
    hasilnya = [];
    role = "Pilih";

    waktunya?.cancel();
    waktunya = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }

  Future<void> autologout() async {
    // Nonaktifkan logout otomatis.
    // User tetap bisa logout manual lewat tombol "Keluar Akun".
    waktunya?.cancel();
    waktunya = null;
    notifyListeners();
  }

  Future<void> autologinbbuat() async {
    if (_accesstoken != null) {
      final awalan = await SharedPreferences.getInstance();
      final isi = json.encode({
        'accesstoken': _accesstoken,
        'email': _email,
        'expiresIn': _expiresIn?.toIso8601String(),
        // 'list_auth': hasilnya
      });

      awalan.setString('auth', isi);
    } else {
      print("Failed");
      throw "Failed";
    }
  }

  Future<bool> autologinbaca() async {
    final pembuka = await SharedPreferences.getInstance();

    if (!pembuka.containsKey('auth')) {
      return false;
    }

    final ambil =
        json.decode(pembuka.get('auth').toString()) as Map<String, dynamic>;
    final waktunya = DateTime.parse(ambil['expiresIn']);

    if (waktunya.isBefore(DateTime.now())) {
      return false;
    }

    _accesstoken = ambil['accesstoken'];
    _email = ambil['email'];
    _expiresIn = waktunya;
    // hasilnya = ambil['list_auth'];

    try {
      await readrole();
    } catch (_) {
      // Jangan crash saat startup (mis. server 500). Balik ke login.
      await logout();
      return false;
    }
    notifyListeners();
    return true;
  }
}
