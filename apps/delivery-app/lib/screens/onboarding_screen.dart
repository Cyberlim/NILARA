import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Nilara ",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF1E9C1C),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Delivery",
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF8DC63F),
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.shopping_bag, color: Color(0xFF1E9C1C), size: 30),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Delivering pure water & essentials\nin minutes",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),

              // Rider Illustration
              Image.asset(
                'assets/images/rider.png',
                height: 280,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => Container(
                  height: 220,
                  width: 220,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.two_wheeler, size: 90, color: Color(0xFF1E9C1C)),
                ),
              ),

              const Spacer(),

              // Login / Signup Button -> Navigates to Email & Password Login Screen!
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E9C1C), // Nilara Green
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    "Login / Sign Up",
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    "Continue as Guest",
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 12),
                  children: const [
                    TextSpan(text: "By continuing, you agree to Nilara Delivery\n"),
                    TextSpan(text: "Terms & Conditions", style: TextStyle(color: Color(0xFF1E9C1C), decoration: TextDecoration.underline)),
                    TextSpan(text: " and "),
                    TextSpan(text: "Privacy Policy", style: TextStyle(color: Color(0xFF1E9C1C), decoration: TextDecoration.underline)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
