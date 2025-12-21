import 'package:flutter/material.dart';
import '../../custom/appbar_polos.dart';
import '../../custom/satu_tombol.dart';
import 'package:provider/provider.dart';
import '../../../providers/kost_provider.dart';

class DetailKost extends StatelessWidget {
  static const arah = "detail-kost-admin";
  @override
  Widget build(BuildContext context) {
    final terima = ModalRoute.of(context)?.settings.arguments as int;
    final pakai = Provider.of<KostProvider>(context)
        .kost
        .firstWhere((element) => element.id_kost == terima);

    return Scaffold(
      appBar: AppbarPolos(
        label: "Detail kost ${pakai.nama_kost}",
        warna: Colors.cyan,
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Container(
            // height: double.infinity,
            // width: double.infinity,
            child: Column(
              children: [
                Container(
                  height: 700,
                  // color: Colors.yellow,
                  child: Column(
                    children: [
                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: DecorationImage(
                                image: NetworkImage("${pakai.gambar_kost}"),
                                fit: BoxFit.cover)),
                      ),
                      Text("Nama Pemilik : ${pakai.pemilik_kost}"),
                      Text("Nama Kost : ${pakai.nama_kost}"),
                      Text("Alamat Kost : ${pakai.alamat_kost}"),
                      Text("No tlp kost : ${pakai.notlp_kost}"),
                      Text("Harga Kost : ${pakai.harga_kost}"),
                      Text("Luas Kamar : ${pakai.panjang}x${pakai.lebar}"),
                      Text("Fasilitas : ${pakai.id_fasilitas}"),
                      Text("jenis kost : ${pakai.jenis_kost}"),
                      Text("jenis listrik : ${pakai.jenis_listrik}"),
                      Text(
                          "jenis pembayaran air : ${pakai.jenis_pembayaran_air}"),
                      Text("jenis keamanan : ${pakai.keamanan}"),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  color: Colors.cyan,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: SatuTombol(
                    warna: Colors.red,
                    fungsi: () {
                      Navigator.of(context).pop();
                    },
                    label: "Kembali",
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
