import 'package:flutter/material.dart';

class Textfield1barisFull extends StatelessWidget {
  final TextInputType jenis;
  final TextCapitalization bk;
  final TextEditingController ketikan;
  final VoidCallback? fungsi;
  final bool tulis;
  final String label;
  final Icon? icon_kiri;
  final Icon? icon_kanan;
  final bool kelihatan;

  Textfield1barisFull({
    required this.jenis,
    required this.bk,
    required this.ketikan,
    this.fungsi,
    required this.tulis,
    required this.label,
    this.icon_kiri,
    this.icon_kanan,
    this.kelihatan = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      child: TextField(
        keyboardType: jenis,
        textCapitalization: bk,
        controller: ketikan,
        onTap: fungsi,
        readOnly: tulis,
        obscureText: kelihatan,
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          prefixIcon: icon_kiri,
          suffixIcon: icon_kanan,
        ),
      ),
    );
  }
}
