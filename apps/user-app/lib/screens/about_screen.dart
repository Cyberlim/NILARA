import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "About Nilara",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.water_drop, size: 80, color: Color(0xFF168BDB)),
            ),
            const SizedBox(height: 24),
            Text(
              "Nilara",
              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              "Version 1.0.0",
              style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Providing pure, refreshing drinking water straight to your doorstep. Stay hydrated, stay healthy with Nilara.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54, height: 1.5),
              ),
            ),
            const SizedBox(height: 60),
            Text("© 2026 Nilara. All rights reserved.", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade400)),
          ],
        ),
      ),
    );
  }
}
