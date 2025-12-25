import 'package:flutter/material.dart';

class AppbarPolos extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final Color warna;

  AppbarPolos({required this.label, required this.warna});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: warna,
      centerTitle: true,
      title: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
