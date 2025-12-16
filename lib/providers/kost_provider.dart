import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/kost_model.dart';
import '../models/fasilitas_model.dart';
import '../services/kost_service.dart';
import '../services/fasilitas_service.dart';

class KostProvider with ChangeNotifier {
  // state penting
  String? _token, _email;
  DateTime? _expires_in;

  void isi(String value, String ada, DateTime waktunya) {
    _token = value;
    _email = ada;
    _expires_in = waktunya;
    if (_token != null && _email != null) {
      print("done ambil token");
    }
  }

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
      print("CR 1");
      final upload = await _kekost.uploadgambar(gambar);
      print("upload $upload");
      print("CR 2");
      if (upload != null) {
        print("CR 3");
        final all_fasilitas = await _kefasilitas.createdata(
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
        print("CR 4");

        List<String> pembeda = titik_koordinat.split(',');
        double latitude = double.parse(pembeda[0].trim());
        double longitudo = double.parse(pembeda[1].trim());
        print("CR 5");

        // _fasilitas = all_fasilitas;
        print("CR 6");
        if (
            // _fasilitas.first.id_fasilitas != null
            all_fasilitas['id_fasilitas'] != null &&
                upload != null &&
                latitude != null &&
                longitudo != null) {
          print("CR 7");
          await _kekost.createdata(
            // _fasilitas.first.id_fasilitas!,
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
          print("CRC 8");
        }
      }
    } catch (e) {
      throw e;
    }
    notifyListeners();
  }
}
