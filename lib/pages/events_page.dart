import 'package:flutter/material.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('События')),
      body: const Center(
        child: Text('События', style: TextStyle(fontSize: 24, color: Colors.white)),
      ),
    );
  }
}
