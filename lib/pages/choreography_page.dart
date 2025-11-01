import 'package:flutter/material.dart';

class ChoreographyPage extends StatelessWidget {
  const ChoreographyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choreography')),
      body: const Center(
        child: Text(
          'Choreography notes will go here 🩰',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
