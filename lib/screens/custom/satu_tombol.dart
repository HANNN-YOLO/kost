import 'package:flutter/material.dart';

class SatuTombol extends StatelessWidget {
  final Color warna;
  final VoidCallback fungsi;
  final String label;

  const SatuTombol({
    super.key,
    required this.warna,
    required this.fungsi,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: warna,
      ),
      onPressed: fungsi,
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }
}
