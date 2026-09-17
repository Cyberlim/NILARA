import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'user_service.dart';

class IncentiveService {
  static final IncentiveService _instance = IncentiveService._internal();
  factory IncentiveService() => _instance;
  IncentiveService._internal();

  static String get baseUrl => UserService.baseUrl;

  final ValueNotifier<List<Map<String, dynamic>>> activeIncentivesNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> expiredIncentivesNotifier = ValueNotifier([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  Future<void> fetchIncentives() async {
    final token = await UserService().getFreshToken();
    if (token == null) return;

    try {
      isLoadingNotifier.value = true;
      final response = await http.get(
        Uri.parse('$baseUrl/delivery/incentives'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        final data = resData['data'] ?? {};
        
        final List<dynamic> rawActive = data['active'] ?? [];
        final List<dynamic> rawExpired = data['expired'] ?? [];

        activeIncentivesNotifier.value = rawActive.map((item) => Map<String, dynamic>.from(item)).toList();
        expiredIncentivesNotifier.value = rawExpired.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        debugPrint("fetchIncentives failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching incentives: $e");
    } finally {
      isLoadingNotifier.value = false;
    }
  }
}
