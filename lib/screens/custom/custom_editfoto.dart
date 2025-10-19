import 'package:flutter/material.dart';
import 'dart:io';

class custom_editfoto extends StatelessWidget {
  final VoidCallback fungsi;
  final String? path;

  final String? pathlama;

  const custom_editfoto({
    super.key,
    // required this.pakai,
    required this.fungsi,
    required this.path,
    required this.pathlama,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: fungsi,
      child: Container(
        height: 100,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            path != null
                ? Image.file(File(path!), fit: BoxFit.cover)
                : (pathlama != null
                    ? Image.network(pathlama!, fit: BoxFit.cover)
                    : Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 40,
                        color: Colors.grey[700],
                      ),
                    )),
      ),
    );
  }
}
