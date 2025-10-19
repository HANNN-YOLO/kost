import 'package:flutter/material.dart';
import 'satu_tombol.dart';

class ShowdialogEror extends StatelessWidget {
  final String label;

  ShowdialogEror({required this.label});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Kesalahan"),
      content: Text(label),
      actions: [
        Builder(
          builder: (context) {
            return SatuTombol(
              warna: Colors.red,
              fungsi: () {
                Navigator.of(context).pop();
              },
              label: "Back",
            );
          },
        ),
      ],
    );
  }
}
