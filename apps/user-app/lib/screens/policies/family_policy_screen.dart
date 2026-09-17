import 'package:flutter/material.dart';

class FamilyPolicyScreen extends StatelessWidget {
  const FamilyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Family Policy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Family Policy content goes here.\n\n'
          'Our app is designed to be safe for families. '
          'We adhere to all relevant guidelines to ensure a secure environment for all ages.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
