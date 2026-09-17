import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DesignPreviewScreen extends StatelessWidget {
  const DesignPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1E3A8A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Design Preview",
          style: GoogleFonts.outfit(
            color: const Color(0xFF1E3A8A),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility, size: 80, color: Color(0xFF3B82F6)),
            const SizedBox(height: 24),
            Text(
              "Design Preview & Approval",
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Placeholder for the next step.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
