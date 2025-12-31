import 'package:flutter/material.dart';
import '../../custom/custom_UploadFoto.dart';
import '../../custom/custom_editfoto.dart';
import '../../custom/showdialog_eror.dart';
import '../../custom/custom_dropdown_search.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profil_provider.dart';
import '../../../providers/kost_provider.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  static const arah = "/profil-user";
  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int index = 0;
  String? mesaage;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController tglLahirController = TextEditingController();
  final TextEditingController noHpController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((value) async {
      final penghubung = Provider.of<AuthProvider>(context, listen: false);
      final penghubung2 = Provider.of<ProfilProvider>(context, listen: false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      try {
        namaController.text = penghubung.mydata[index].username ?? "Default";
        emailController.text = penghubung.mydata[index].Email ?? "Default";

        if (penghubung2.accesstoken != null) {
          await penghubung2.readdata(
            penghubung2.accesstoken!,
            penghubung2.id_auth!,
          );
        } else {
          Navigator.of(context).pop();
          throw Exception("User tidak terautentikasi.");
        }

        Navigator.of(context).pop();

        if (penghubung2.mydata.isEmpty) {
          penghubung2.defaults = "Jenis Kelamin";
        } else {
          tglLahirController.text = DateFormat('dd-MM-yyyy')
              .format(penghubung2.mydata[index].tgllahir!);
          noHpController.text = "${penghubung2.mydata[index].kontak}";
          penghubung2.pilihan("${penghubung2.mydata[index].jkl}");
        }
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    namaController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final penghubung = Provider.of<AuthProvider>(context, listen: false);
    final penghubung2 = Provider.of<ProfilProvider>(context, listen: false);
    final penghubung3 = Provider.of<KostProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F9FC),
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Consumer<ProfilProvider>(
              builder: (context, value, child) {
                if (value.mydata.isEmpty) {
                  return CustomUploadfoto(
                    tinggi: 100,
                    panjang: 100,
                    radius: 40,
                    fungsi: () {
                      value.uploadfoto();
                    },
                    path: value.isinya?.path,
                  );
                } else {
                  return custom_editfoto(
                    fungsi: () {
                      value.uploadfoto();
                    },
                    path: value.isinya?.path,
                    pathlama: value.mydata[index].foto!,
                    tinggi: 100,
                    panjang: 100,
                    radius: 40,
                  );
                }
              },
            ),
            SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Detail",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            SizedBox(height: 12),
            buildTextfiel(
              controllers: namaController,
              keadaan: true,
              label: "Nama",
            ),
            Consumer<ProfilProvider>(
              builder: (context, value, child) {
                return Column(
                  children: [
                    buildTextfiel(
                      controllers: tglLahirController,
                      keadaan: true,
                      label: "Tanggal Lahir",
                      fungsi: () async {
                        final penanggalan = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1945),
                          lastDate: DateTime(9999),
                          initialDate: DateTime.now(),
                        );

                        tglLahirController.text =
                            "${penanggalan?.day.toString().padLeft(2, '0')}-"
                            "${penanggalan?.month.toString().padLeft(2, '0')}-"
                            "${penanggalan?.year.toString()}";
                      },
                    ),
                    CustomDropdownSearch(
                      manalistnya: penghubung2.jkl,
                      label: "Jenis Kelamin",
                      pilihan: penghubung2.defaults!,
                      fungsi: (value) {
                        penghubung2.pilihan(value);
                      },
                    ),
                    SizedBox(height: 20),
                    buildTextfiel(
                      controllers: noHpController,
                      keadaan: false,
                      label: "No. Hp",
                    ),
                  ],
                );
              },
            ),
            buildTextfiel(
              controllers: emailController,
              keadaan: true,
              label: "Email",
            ),
            if (mesaage != null) ...[
              Center(
                child: Text(
                  mesaage!,
                  style: TextStyle(color: Colors.greenAccent),
                ),
              )
            ],
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await penghubung.logout();
                    penghubung2.reset();
                    penghubung3.resetpilihan();
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ShowdialogEror(label: "${e.toString()}");
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: Text(
                  "Keluar",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Color(0xFFF7F9FC),
        child: ElevatedButton(
          onPressed: () async {
            try {
              if (penghubung2.mydata.isEmpty) {
                await penghubung2.createprofil(
                  penghubung2.isinya!,
                  DateFormat('dd-MM-yyyy').parse(tglLahirController.text),
                  penghubung2.defaults!,
                  int.parse(noHpController.text),
                );
                setState(() {
                  tglLahirController.text = DateFormat('dd-MM-yyyy')
                      .format(penghubung2.mydata[index].tgllahir!);
                  noHpController.text = "${penghubung2.mydata[index].kontak}";
                  penghubung2.defaults = "${penghubung2.mydata[index].jkl}";
                  mesaage = "Profil berhasil dibuat";
                });
                // -------------------------------------
              } else {
                await penghubung2.updateprofil(
                  penghubung2.isinya,
                  penghubung2.mydata[index].foto!,
                  DateFormat('dd-MM-yyyy').parse(tglLahirController.text),
                  penghubung2.defaults!,
                  int.parse(noHpController.text),
                );
                setState(() {
                  tglLahirController.text = DateFormat('dd-MM-yyyy')
                      .format(penghubung2.mydata[index].tgllahir!);
                  noHpController.text = "${penghubung2.mydata[index].kontak}";
                  penghubung2.defaults = "${penghubung2.mydata[index].jkl}";
                  mesaage = "Profil berhasil Diperbarui";
                });
              }
            } catch (e) {
              mesaage = "Data Gagal diperbarui Diperbarui";
              showDialog(
                context: context,
                builder: (context) {
                  return ShowdialogEror(label: "${e.toString()}");
                },
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            "Simpan",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class buildTextfiel extends StatelessWidget {
  final TextEditingController controllers;
  final bool keadaan;
  final String label;
  final VoidCallback? fungsi;

  buildTextfiel({
    required this.controllers,
    required this.keadaan,
    required this.label,
    this.fungsi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 25.0),
      child: TextField(
        controller: controllers,
        readOnly: keadaan,
        onTap: fungsi,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
