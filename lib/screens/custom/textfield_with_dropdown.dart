import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_dropdown_search.dart';

class TextfieldWithDropdown extends StatelessWidget {
  final String label;
  final double lebar;
  final double tinggi;
  final TextEditingController isi;
  final TextInputType jenis;
  final List<String> manalistnya;
  final String label2;
  final String pilihan;
  final List<TextInputFormatter>? inputFormatters;
  // final VoidCallback fungsi;
  final ValueChanged fungsi;

  TextfieldWithDropdown({
    required this.label,
    required this.lebar,
    required this.tinggi,
    required this.isi,
    required this.jenis,
    required this.manalistnya,
    required this.label2,
    required this.pilihan,
    required this.fungsi,
    this.inputFormatters,
  });

  // final bool isnumeric =  label == 'Nomor Telepon' || label == "Harga";

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: lebar * 0.035,
            )),
        SizedBox(height: tinggi * 0.005),
        Container(
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(8),
            //   border: Border.all(
            //     color: Colors.grey.shade300,
            //     width: 1,
            //   ),
            // ),
            child: Padding(
          padding: EdgeInsets.symmetric(horizontal: lebar * 0.01),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: isi,
                    keyboardType: jenis,
                    inputFormatters: inputFormatters,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: lebar * 0.04,
                        vertical: tinggi * 0.018,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: CustomDropdownSearch(
                    manalistnya: manalistnya,
                    label: label,
                    pilihan: pilihan,
                    fungsi: fungsi,
                  ),
                ),
              ),
            ],
          ),
        )),
        SizedBox(height: tinggi * 0.025),
      ],
    );
  }
}
