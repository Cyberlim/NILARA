import 'package:flutter/material.dart';

class ReturnRefundPolicyScreen extends StatelessWidget {
  const ReturnRefundPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return & Refund Policy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Return & Refund Policy content goes here.\n\n'
          'If you are not entirely satisfied with your purchase, we\'re here to help. '
          'You have a certain number of days to return an item from the date you received it.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
