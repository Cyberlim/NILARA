import re

with open("lib/main.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add imports
imports = """import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';"""
content = content.replace("import 'package:flutter/material.dart';\nimport 'package:google_fonts/google_fonts.dart';\nimport 'screens/splash_screen.dart';", imports)

# Make main async and initialize Firebase
old_main = """void main() {
  runApp(const NilaraDeliveryApp());
}"""

new_main = """void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NilaraDeliveryApp());
}"""
content = content.replace(old_main, new_main)

with open("lib/main.dart", "w", encoding="utf-8") as f:
    f.write(content)
