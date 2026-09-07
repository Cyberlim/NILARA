import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  bool onboardingComplete;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.onboardingComplete = false,
  });
}

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const String baseUrl = 'http://localhost:5000/api/v1';

  final ValueNotifier<UserProfile?> currentUser = ValueNotifier(null);
  final ValueNotifier<String?> token = ValueNotifier(null);
  final ValueNotifier<bool> isInitialized = ValueNotifier(false);

  Future<void> init() async {
    // Wait for the first auth state event to resolve
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (user != null) {
      final idToken = await user.getIdToken();
      token.value = idToken;
      await _syncWithBackend(idToken!);
    } else {
      currentUser.value = null;
      token.value = null;
    }
    isInitialized.value = true;
    
    // Continue listening for subsequent changes
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        final idToken = await user.getIdToken();
        token.value = idToken;
        // Don't need to await here for UI responsiveness on subsequent changes
        _syncWithBackend(idToken!);
      } else {
        currentUser.value = null;
        token.value = null;
      }
    });
  }

  Future<bool> _syncWithBackend(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/sync'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $idToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Sync successful
        if (data['success'] == true) {
          final userData = data['data'];
          if (userData['role'] != 'delivery') {
            // Not a delivery partner!
            debugPrint("User is not a delivery partner! Role is: ${userData['role']}");
            await logout();
            return false;
          }
          currentUser.value = UserProfile(
            id: userData['id'] ?? '',
            name: userData['displayName'] ?? '',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            role: userData['role'],
            onboardingComplete: userData['onboardingComplete'] ?? false,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error syncing user: $e');
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (userCredential.user != null) {
        final idToken = await userCredential.user!.getIdToken();
        final success = await _syncWithBackend(idToken!);
        return success;
      }
      return false;
    } catch (e) {
      debugPrint("Login error: $e");
      return false;
    }
  }
  
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    currentUser.value = null;
    token.value = null;
  }
}
