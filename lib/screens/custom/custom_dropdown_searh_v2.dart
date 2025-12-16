import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CustomDropdownSearchv2 extends StatelessWidget {
  final List<String> manalistnya;
  final String label;
  final String pilihan;
  final ValueChanged? fungsi;
  final double? lebar;
  final double? tinggi;

  CustomDropdownSearchv2({
    required this.manalistnya,
    required this.label,
    required this.pilihan,
    this.lebar,
    this.tinggi,
    this.fungsi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // color: Colors.white,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: DropdownSearch<String>(
        items: (f, cs) => manalistnya,
        selectedItem: pilihan,
        popupProps: PopupProps.menu(fit: FlexFit.loose),
        onChanged: fungsi,
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: lebar! * 0.04,
              vertical: tinggi! * 0.018,
            ),
            filled: true,
            fillColor: Colors.white,
            hintText: label,
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
