import 'package:flutter/material.dart';

class CharityPage extends StatelessWidget {
  const CharityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Цдака')),
      body: const Center(
        child: Text('Цдака', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}
