import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/kost_model.dart';
import '../models/fasilitas_model.dart';
import '../models/auth_model.dart';
import '../services/kost_service.dart';
import '../services/fasilitas_service.dart';

class KostProvider with ChangeNotifier {
  // state penting
  String? _token, _email;
  DateTime? _expires_in;
  List<AuthModel> _listauth = [];
  List<AuthModel> get listauth => _listauth;
  int? id_auth;

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
    id_auth = id_auth;
    if (_token != null && _email != null) {
      // readdata();
      // readdatapenyewa(_token!);
      if (listauth.first.role == "Admin") {
        readdata();
      } else if (listauth.first.role == "Penyewa") {
        readdatapenyewa(_token!);
      }
    }
  }

  // final cek = _listauth.firstWhere((element) => element.role == namas);

  // state foto
  XFile? _foto;
  XFile? get foto => _foto;

  void uploadfoto() async {
    final ambil = ImagePicker();
    final take = await ambil.pickImage(source: ImageSource.gallery);
    if (take != null) {
      _foto = take;
    }
    notifyListeners();
  }

  // state pilihan
  // nama pemilik
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

  // jenis kost
  List<String> _jeniskost = ['Umum', 'Khusus Putri', 'Khusus Putra'];
  List<String> get jeniskost => _jeniskost;
  String jeniskosts = "Pilih";

  void pilihkost(String value) {
    jeniskosts = value;
    notifyListeners();
  }

  // jenis keamanan
  List<String> _jeniskeamanan = ['Penjaga', 'Penjaga sama CCTV'];
  List<String> get jeniskeamanan => _jeniskeamanan;
  String jeniskeamanans = "Pilih";

  void pilihkeamanan(String value) {
    jeniskeamanans = value;
    notifyListeners();
  }

  // batas jam malam
  List<String> _jenisbatasjammalam = [
    '21.00',
    '22.00',
    '23.00 -24.00',
    'beri kunci pagar'
  ];
  List<String> get jenisbatasjammalam => _jenisbatasjammalam;
  String batasjammalams = "PIlih";

  void pilihbatasjammalam(String value) {
    batasjammalams = value;
  }

  // jenis pembayaran air
  List<String> _jenispembayaranair = ['meteran', 'pembayaran awal'];
  List<String> get jenispembayaranair => _jenispembayaranair;
  String jenispembayaranairs = "Pilih";

  void pilihjenispembayaranair(String value) {
    jenispembayaranairs = value;
    notifyListeners();
  }

  // jenis listrik
  List<String> _jenislistrik = ['token', 'perbulan'];
  List<String> get jenislistrik => _jenislistrik;
  String jenislistriks = "Pilih";

  void pilihjenislistrik(String value) {
    jenislistriks = value;
  }

  void resetpilihan() {
    this._foto = null;
    this.namanya = "Pilih";
    this.jeniskosts = "Pilih";
    this.jeniskeamanans = "Pilih";
    this.batasjammalams = "Pilih";
    this.jenispembayaranairs = "Pilih";
    this.jenislistriks = "Pilih";
    notifyListeners();
  }

  // state service
  List<KostModel> _kost = [];
  List<KostModel> get kost => _kost;
  int get semunya => _kost.length;
  final KostService _kekost = KostService();

  List<FasilitasModel> _fasilitas = [];
  List<FasilitasModel> get faslitas => _fasilitas;
  final FasilitasService _kefasilitas = FasilitasService();

  FasilitasModel inputan = FasilitasModel();

  Future<void> createdata(
    int id_auth,
    bool tempat_tidur,
    bool kamar_mandi_dalam,
    bool meja,
    bool tempat_parkir,
    bool lemari,
    bool ac,
    bool tv,
    bool kipas,
    bool dapur_dalam,
    bool wifi,
    int notlp_kost,
    String nama_kost,
    String alamat_kost,
    String pemilik_kost,
    int harga_kost,
    String titik_koordinat,
    String jenis_kost,
    String keamanan,
    String batas_jam_malam,
    String jenis_pembayaran_air,
    String jenis_listrik,
    int panjang,
    int lebar,
    XFile gambar,
  ) async {
    try {
      final upload = await _kekost.uploadgambar(gambar);
      if (upload != null) {
        final all_fasilitas = await _kefasilitas.createdata(
          id_auth = id_auth,
          tempat_tidur,
          kamar_mandi_dalam,
          meja,
          tempat_parkir,
          lemari,
          ac,
          tv,
          kipas,
          dapur_dalam,
          wifi,
        );

        List<String> pembeda = titik_koordinat.split(',');
        double latitude = double.parse(pembeda[0].trim());
        double longitudo = double.parse(pembeda[1].trim());

        if (all_fasilitas['id_fasilitas'] != null &&
            upload != null &&
            latitude != null &&
            longitudo != null) {
          await _kekost.createdata(
            id_auth,
            all_fasilitas['id_fasilitas'],
            notlp_kost,
            nama_kost,
            alamat_kost,
            pemilik_kost,
            harga_kost,
            jenis_kost,
            keamanan,
            batas_jam_malam,
            jenis_pembayaran_air,
            jenis_listrik,
            panjang,
            lebar,
            latitude,
            longitudo,
            upload,
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
    try {
      final hasilnya = await _kekost.readdata();
      final isinya = await _kefasilitas.readdata();
      _fasilitas = isinya;
      _kost = hasilnya;
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }

  Future<void> deletedata(int id_kost) async {
    try {
      final cek = _kost.firstWhere((element) => element.id_kost == id_kost);
      await _kekost.deletegambar(cek.gambar_kost!);
      await _kefasilitas.deletedata(cek.id_fasilitas!);
      print("done data kehapus");
      // await _kekost.deletedata(id_kost);
    } catch (e) {
      throw e;
    }
    await readdata();
    notifyListeners();
  }

  Future<void> updatedata(
    XFile? foto,
    String fotolama,
    int id_fasilitas,
    bool tempat_tidur,
    bool kamar_mandi_dalam,
    bool meja,
    bool tempat_parkir,
    bool lemari,
    bool ac,
    bool tv,
    bool kipas,
    bool dapur_dalam,
    bool wifi,
    int id_kost,
    int id_auth,
    String nama_kost,
    String pemilik_kost,
    String alamat_kost,
    int notlp_kost,
    int harga_kost,
    String batas_jam_malam,
    String jenis_listrik,
    String jenis_pembayaran_air,
    String keamanan,
    String jenis_kost,
    int panjang,
    int lebar,
    String koordinnat,
  ) async {
    try {
      DateTime edit = DateTime.now();

      if (fotolama != null && foto == null) {
        await _kefasilitas.updateddata(
          id_fasilitas,
          id_auth,
          tempat_tidur,
          kamar_mandi_dalam,
          meja,
          tempat_parkir,
          lemari,
          ac,
          tv,
          kipas,
          dapur_dalam,
          wifi,
          edit,
        );

        List<String> bedakan = koordinnat.split(',');
        double latitude = double.parse(bedakan[0].trim());
        double longitudo = double.parse(bedakan[1].trim());

        if (fotolama != null && latitude != null && longitudo != null) {
          await _kekost.updatedata(
            id_kost,
            id_fasilitas,
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
            panjang,
            lebar,
            fotolama,
            latitude,
            longitudo,
            edit,
          );
        }
      } else {
        await _kekost.deletegambar(fotolama);
        final upload = await _kekost.uploadgambar(foto!);
        if (upload != null) {
          await _kefasilitas.updateddata(
            id_fasilitas,
            id_auth,
            tempat_tidur,
            kamar_mandi_dalam,
            meja,
            tempat_parkir,
            lemari,
            ac,
            tv,
            kipas,
            dapur_dalam,
            wifi,
            edit,
          );

          List<String> bedakan = koordinnat.split(',');
          double latitude = double.parse(bedakan[0].trim());
          double longitudo = double.parse(bedakan[1].trim());

          if (upload != null && latitude != null && longitudo != null) {
            await _kekost.updatedata(
              id_kost,
              id_fasilitas,
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
              panjang,
              lebar,
              upload,
              latitude,
              longitudo,
              edit,
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
    try {
      final inikost = await _kekost.readdatapenyewa(token);
      final inifasilitas = await _kefasilitas.readdatapenyewa(token);
      _kost = inikost;
      _fasilitas = inifasilitas;
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }
}
