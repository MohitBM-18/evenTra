import 'package:flutter/material.dart';

class HelpRequestScreen extends StatelessWidget {
  const HelpRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Requests')),
      body: const Center(child: Text('Help Request Module')),
    );
  }
}
