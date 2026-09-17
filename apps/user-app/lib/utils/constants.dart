import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class Constants {
  // Centralized Base URL for the backend API
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000'; // For Chrome/Web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000'; // For Android Emulator connecting to host machine
    } else if (Platform.isIOS) {
      return 'http://127.0.0.1:5000'; // For iOS Simulator
    } else {
      return 'http://localhost:5000'; // Fallback
    }
  }
}
