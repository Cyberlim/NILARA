import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_service.dart';

class MarketingService {
  static final MarketingService _instance = MarketingService._internal();
  factory MarketingService() => _instance;
  MarketingService._internal();

  static String get baseUrl => SettingsService.activeBaseUrl;

  Future<List<dynamic>> fetchActiveCoupons() async {
    try {
      String? token;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        token = await user.getIdToken();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/marketing/coupons/active'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching coupons: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchActiveGifts() async {
    try {
      String? token;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        token = await user.getIdToken();
      }

      final response = await http.get(
        Uri.parse('$baseUrl/marketing/gifts/active'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      print('Error fetching gifts: $e');
      return [];
    }
  }
}
