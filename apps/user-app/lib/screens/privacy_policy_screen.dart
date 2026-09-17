import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Privacy Policy",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Last updated: August 2026", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            _buildSection("1. Information We Collect", "We collect information you provide directly to us, such as when you create or modify your account, request services, contact customer support, or otherwise communicate with us."),
            _buildSection("2. How We Use Information", "We may use the information we collect about you to provide, maintain, and improve our services, including to process transactions, send related information, and authenticate users."),
            _buildSection("3. Data Security", "We take reasonable measures to help protect information about you from loss, theft, misuse and unauthorized access, disclosure, alteration and destruction."),
            _buildSection("4. Your Choices", "You may correct your account information at any time by logging into your online or in-app account. If you wish to cancel your account, please email us."),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Text(content, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54, height: 1.5)),
        ],
      ),
    );
  }
}
