import 'package:flutter/material.dart';

class Label1barisFull extends StatelessWidget {
  final String label;
  final double lebar;
  final double? jarak;

  Label1barisFull({required this.label, required this.lebar, this.jarak});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.symmetric(horizontal: jarak ?? 10),
      child: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: lebar * 0.035),
      ),
    );
  }
}
