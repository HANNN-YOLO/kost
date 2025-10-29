import 'package:flutter/material.dart';

class CriteriaManagement extends StatelessWidget {
  const CriteriaManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criteria Management'),
      ),
      body: const Center(
        child: Text('This is the Criteria Management Page'),
      ),
    );
  }
}
