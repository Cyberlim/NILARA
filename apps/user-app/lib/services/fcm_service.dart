import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/settings_service.dart';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  static const String baseUrl = 'http://localhost:5000/api/v1';
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initPushNotifications() async {
    try {
      // 1. Request permission for iOS/Web
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else {
        debugPrint('User declined or has not accepted permission');
        return; // Don't proceed if no permission
      }

      // 2. Get the FCM token for this device
      String? token = await _messaging.getToken();
      if (token != null) {
        debugPrint("FCM Token: $token");
        await _sendTokenToBackend(token);
      }

      // 3. Listen to token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        _sendTokenToBackend(newToken);
      });

      // 4. Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (SettingsService().pushNotificationsEnabled.value && message.notification != null) {
          showTopNotification(message.notification!.title ?? 'New Alert', message.notification!.body ?? '');
        }
      });

    } catch (e) {
      debugPrint("FCM Initialization failed: $e");
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // Only send if logged in

      final idToken = await user.getIdToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/users/me/fcm-token'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'token': token}),
      );

      if (response.statusCode == 200) {
        debugPrint("FCM Token successfully synced to backend.");
      } else {
        debugPrint("Failed to sync FCM Token: ${response.body}");
      }
    } catch (e) {
      debugPrint("Error syncing FCM token: $e");
    }
  }
}
