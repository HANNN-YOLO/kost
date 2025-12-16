import 'package:flutter/material.dart';
import 'package:kost_saw/screens/custom/appbar_polos.dart';

class DashboardPemilik extends StatelessWidget {
  static const arah = "/dashboard-pemilik";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPolos(
        label: "Mantap Anda Pemilik",
        warna: Colors.cyan,
      ),
      body: Container(
        child: Center(
          child: Text(
            "Coming Soon",
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
