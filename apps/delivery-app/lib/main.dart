import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const NilaraDeliveryApp());
}

class NilaraDeliveryApp extends StatelessWidget {
  const NilaraDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nilara Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF1E9C1C), // Nilara Delivery Green
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1E9C1C),
          secondary: Color(0xFF1E9C1C),
          surface: Colors.white,
          onSurface: Colors.black87,
        ),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
