import 'package:flutter/material.dart';
import '../../custom/appbar_polos.dart';

class Dashboard extends StatelessWidget {
  static const arah = "/dashboard";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppbarPolos(label: "Halaman Admin", warna: Colors.cyan),
    );
  }
}
