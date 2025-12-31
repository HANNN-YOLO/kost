import 'dart:io';
import 'package:flutter/material.dart';

class CustomUploadfotoStack extends StatelessWidget {
  final double tinggi;
  final double panjang;
  final double? radius;
  final VoidCallback fungsi;
  final String? path;
  final Color warnautama;

  const CustomUploadfotoStack({
    Key? key,
    this.radius,
    required this.panjang,
    required this.tinggi,
    required this.fungsi,
    required this.path,
    required this.warnautama,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      //
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
            // kotak
            // ClipRRect(
            //   // borderRadius: BorderRadius.circular(radius),
            //   child: path != null
            //       ? Image.file(
            //           File(path!),
            //           fit: BoxFit.cover, // ✅ foto menyesuaikan container
            //         )
            //       : Center(
            //           child: Icon(
            //             Icons.add_a_photo,
            //             size: 40,
            //             color: Colors.grey[700],
            //           ),
            //         ),
            // ),

            // lingkaran
            ClipOval(
          child: path != null
              ? Image.file(
                  File(path!),
                  fit: BoxFit.cover,
                )
              : Center(
                  child:
                      // Icon(
                      //   Icons.add_a_photo,
                      //   size: 40,
                      //   color: Colors.grey[700],
                      // ),
                      Stack(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Color(0xFFDDE6FF),
                      child: Icon(
                        Icons.person,
                        color: warnautama,
                        size: 30,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit,
                            size: 16,
                            color: warnautama,
                          ),
                        ),
                      ),
                    )
                  ],
                )),
        ),
      ),
    );
  }
}
