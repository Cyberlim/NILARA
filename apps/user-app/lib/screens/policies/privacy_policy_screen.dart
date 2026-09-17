import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Privacy Policy content goes here.\n\n'
          'We value your privacy and are committed to protecting your personal information. '
          'This policy outlines how we collect, use, and safeguard your data.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
