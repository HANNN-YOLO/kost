import 'dart:convert';

import 'package:flutter/widgets.dart';
import '../models/auth_model.dart';
import '../services/auth_services.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  // UI state password
  bool _kelihatan = false;
  bool get kelihatan => _kelihatan;

  void keadaan() {
    _kelihatan = !_kelihatan;
    notifyListeners();
  }

  // UI set Role
  final role = "User";

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
      String role) async {
    try {
      if (pas1 == pas2) {
        final data = await _ref.register(email: email, pass: pas1);
        if (data != null) {
          _accesstoken = data['access_token'];
          _email = email;
          _expiresIn = DateTime.now().add(Duration(
            seconds: data['expires_in'],
          ));

          await _ref.createuser(
              _accesstoken!, data['user']['id'], username, email, role);
        }
      } else {
        throw "Sandi tidak sama pada saat di input";
      }
    } catch (e) {
      throw e;
    }
    await readrole();
    await autologinbbuat();
    await autologout();
    notifyListeners();
  }

  Future<void> readrole() async {
    try {
      final data = await _ref.readdata(_accesstoken!);
      _mydata = data;
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }

  // UI State Memori
  Timer? waktunya;

  Future<void> logout() async {
    if (_accesstoken != null) {
      _accesstoken == null;
      _email = null;
      _expiresIn = null;

      waktunya?.cancel();
      waktunya = null;
    } else {
      throw "Failed to logout";
    }
  }

  Future<void> autologout() async {
    waktunya?.cancel();
    final saatnya = _expiresIn?.difference(DateTime.now()).inSeconds;
    waktunya = Timer(Duration(seconds: saatnya!), () => logout());
    print("saatnya = $saatnya");
    notifyListeners();
  }

  Future<void> autologinbbuat() async {
    if (_accesstoken != null) {
      final awalan = await SharedPreferences.getInstance();
      final isi = json.encode({
        'accesstoken': _accesstoken,
        'email': _email,
        'expiresIn': _expiresIn?.toIso8601String(),
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

    await readrole();
    notifyListeners();
    return true;
  }
}
