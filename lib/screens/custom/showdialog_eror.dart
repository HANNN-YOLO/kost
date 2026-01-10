import 'package:flutter/material.dart';
import 'satu_tombol.dart';

class ShowdialogEror extends StatelessWidget {
  final String label;

  ShowdialogEror({required this.label});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: const [
          Icon(
            Icons.info_outline,
            color: Colors.orange,
          ),
          SizedBox(width: 8),
          Text(
            "Pengingat",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Text(
        label,
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
      actionsAlignment: MainAxisAlignment.end,
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
