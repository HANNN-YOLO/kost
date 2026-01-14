import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class CustomDropdownSearchv3 extends StatelessWidget {
  final List<String> manalistnya;
  final String label;
  final String pilihan;
  final ValueChanged? fungsi;

  CustomDropdownSearchv3({
    required this.manalistnya,
    required this.label,
    required this.pilihan,
    this.fungsi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: DropdownSearch<String>(
        items: (f, cs) => manalistnya,
        selectedItem: pilihan,
        popupProps: PopupProps.menu(fit: FlexFit.loose),
        onChanged: fungsi,
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFE5ECFF),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            hintText: label,
            hintStyle: TextStyle(fontWeight: FontWeight.w500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}
