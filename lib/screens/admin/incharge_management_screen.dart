import 'package:flutter/material.dart';

class InchargeManagementScreen extends StatelessWidget {
  const InchargeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage In-Charges')),
      body: const Center(child: Text('Incharge Management Module')),
    );
  }
}
