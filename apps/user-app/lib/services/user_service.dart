import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'settings_service.dart';

class UserProfile {
  final String name;
  final String phone;
  final String email;
  final String photoUrl;
  final bool isPremium;

  UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.photoUrl,
    required this.isPremium,
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    bool? isPremium,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;

  static String _sanitizePhotoUrl(String? url) {
    if (url == null || url.trim().isEmpty || url.contains('pravatar.cc')) {
      return '';
    }
    return url.trim();
  }

  final ValueNotifier<UserProfile> profile = ValueNotifier(
    UserProfile(
      name: "Loading...",
      phone: "",
      email: "",
      photoUrl: "",
      isPremium: false,
    ),
  );

  UserService._internal() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        // Optimistic UI update with Firebase data
        profile.value = UserProfile(
          name: user.displayName ?? "User",
          phone: user.phoneNumber ?? "",
          email: user.email ?? "",
          photoUrl: _sanitizePhotoUrl(user.photoURL),
          isPremium: false,
        );

        // Fetch secure data from Node.js backend
        try {
          final token = await user.getIdToken();
          final response = await http.post(
            Uri.parse('${SettingsService.activeBaseUrl}/auth/sync'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['success'] == true) {
              final mongoUser = data['data'];
              profile.value = UserProfile(
                name: mongoUser['displayName'] ?? user.displayName ?? "User",
                phone: mongoUser['phone'] ?? user.phoneNumber ?? "",
                email: mongoUser['email'] ?? user.email ?? "",
                photoUrl: _sanitizePhotoUrl(mongoUser['photoUrl'] ?? user.photoURL),
                isPremium: mongoUser['role'] == 'premium',
              );
            }
          } else {
            debugPrint('Failed to sync user: ${response.body}');
          }
        } catch (e) {
          debugPrint('Error syncing user with backend: $e');
        }
      } else {
        profile.value = UserProfile(
          name: "Guest",
          phone: "",
          email: "",
          photoUrl: "",
          isPremium: false,
        );
      }
    });
  }

  void updateProfile({String? name, String? phone, String? email, String? photoUrl}) {
    profile.value = profile.value.copyWith(
      name: name,
      phone: phone,
      email: email,
      photoUrl: photoUrl != null ? _sanitizePhotoUrl(photoUrl) : profile.value.photoUrl,
    );
  }
}



