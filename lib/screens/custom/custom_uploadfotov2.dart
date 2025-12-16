import 'dart:io';
import 'package:flutter/material.dart';

class CustomUploadfotov2 extends StatelessWidget {
  final double tinggi;
  final double radius;
  final VoidCallback fungsi;
  final String? path;

  const CustomUploadfotov2({
    Key? key,
    required this.tinggi,
    required this.radius,
    required this.fungsi,
    required this.path,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //
      onTap: fungsi,
      child: Container(
        height: tinggi,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: path != null
              ? Image.file(
                  File(path!),
                  fit: BoxFit.cover, // ✅ foto menyesuaikan container
                )
              : Center(
                  child: Icon(
                    Icons.add_a_photo,
                    size: 40,
                    color: Colors.grey[700],
                  ),
                ),
        ),
      ),
    );
  }
}
