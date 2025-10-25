import 'package:flutter/material.dart';
import 'dart:io';

class custom_editfoto extends StatelessWidget {
  final VoidCallback fungsi;
  final String? path;
  final String? pathlama;
  final double tinggi;
  final double panjang;
  final double? radius;

  custom_editfoto({
    super.key,
    // required this.pakai,
    required this.fungsi,
    required this.path,
    required this.pathlama,
    required this.tinggi,
    required this.panjang,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: fungsi,
      child: Container(
        height: tinggi,
        width: panjang,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey),
          // borderRadius: BorderRadius.circular(radius),
        ),
        child:
            //kotak
            // path != null
            //     ? Image.file(File(path!), fit: BoxFit.cover)
            //     : (pathlama != null
            //         ? Image.network(pathlama!, fit: BoxFit.cover)
            //         : Center(
            //             child: Icon(
            //               Icons.add_a_photo,
            //               size: 40,
            //               color: Colors.grey[700],
            //             ),
            //           )),

            // lingkaran
            ClipOval(
          child: path != null
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
      ),
    );
  }
}
