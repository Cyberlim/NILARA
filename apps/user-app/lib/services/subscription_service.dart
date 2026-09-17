import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'settings_service.dart';

class Subscription {
  final String id;
  final String planName;
  final String status;
  final String nextDelivery;
  final String productName;
  final int quantity;
  final double price;
  final double discountedPrice;
  final String frequency;
  final DateTime? startDate;
  final DateTime? endDate;
  final int remainingDays;
  final String deliveryTimePref;
  final bool leaveAtDoor;
  final bool callBeforeDelivery;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? contact;
  final List<DateTime> skippedDeliveries;
  final List<DateTime> completedDeliveries;
  final String specialInstructions;

  Subscription({
    required this.id,
    required this.planName,
    required this.status,
    required this.nextDelivery,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.discountedPrice,
    required this.frequency,
    this.startDate,
    this.endDate,
    required this.remainingDays,
    this.deliveryTimePref = "6 AM - 8 AM",
    required this.leaveAtDoor,
    required this.callBeforeDelivery,
    this.address,
    this.contact,
    this.skippedDeliveries = const [],
    this.completedDeliveries = const [],
    this.specialInstructions = "",
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    DateTime? parsedStartDate;
    if (json['startDate'] != null) {
      parsedStartDate = DateTime.tryParse(json['startDate']);
    }

    DateTime? parsedEndDate;
    if (json['endDate'] != null) {
      parsedEndDate = DateTime.tryParse(json['endDate']);
    } else if (parsedStartDate != null) {
      // Fallback for subscriptions that didn't have an endDate set originally
      parsedEndDate = parsedStartDate.add(const Duration(days: 30));
    }

    int calcRemaining = 30;
    if (parsedEndDate != null) {
      calcRemaining = parsedEndDate.difference(DateTime.now()).inDays;
      if (calcRemaining < 0) calcRemaining = 0;
    }

    return Subscription(
      id: json['_id'] ?? '',
      planName: json['planName'] ?? '',
      status: json['status'] ?? 'Active',
      nextDelivery: json['deliveryTime'] ?? 'Tomorrow',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? json['price'] ?? 0).toDouble(),
      frequency: json['frequency'] ?? 'Daily',
      startDate: parsedStartDate,
      endDate: parsedEndDate,
      remainingDays: calcRemaining,
      deliveryTimePref: json['deliveryTime'] ?? '6 AM - 8 AM',
      leaveAtDoor: json['leaveAtDoor'] == true,
      callBeforeDelivery: json['callBeforeDelivery'] == true,
      address: json['address'] as Map<String, dynamic>?,
      contact: json['contact'] as Map<String, dynamic>?,
      skippedDeliveries: (json['skippedDeliveries'] as List<dynamic>?)
          ?.map((e) => DateTime.tryParse(e.toString()))
          .where((e) => e != null)
          .cast<DateTime>()
          .toList() ?? [],
      completedDeliveries: (json['completedDeliveries'] as List<dynamic>?)
          ?.map((e) => DateTime.tryParse(e.toString()))
          .where((e) => e != null)
          .cast<DateTime>()
          .toList() ?? [],
      specialInstructions: json['specialInstructions'] ?? "",
    );
  }

  int get durationMonths {
    if (startDate != null && endDate != null) {
      int days = endDate!.difference(startDate!).inDays;
      return (days / 30).round() > 0 ? (days / 30).round() : 1;
    }
    return 1;
  }

  Subscription copyWith({
    String? status,
    String? deliveryTimePref,
    bool? leaveAtDoor,
    bool? callBeforeDelivery,
    String? specialInstructions,
  }) {
    return Subscription(
      id: this.id,
      planName: this.planName,
      status: status ?? this.status,
      nextDelivery: this.nextDelivery,
      productName: this.productName,
      quantity: this.quantity,
      price: this.price,
      discountedPrice: this.discountedPrice,
      frequency: this.frequency,
      endDate: this.endDate,
      remainingDays: this.remainingDays,
      deliveryTimePref: deliveryTimePref ?? this.deliveryTimePref,
      leaveAtDoor: leaveAtDoor ?? this.leaveAtDoor,
      callBeforeDelivery: callBeforeDelivery ?? this.callBeforeDelivery,
      address: this.address,
      contact: contact ?? this.contact,
      skippedDeliveries: this.skippedDeliveries,
      completedDeliveries: this.completedDeliveries,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;

  String get baseUrl => '${SettingsService.activeBaseUrl}/subscriptions';
  
  // ValueNotifier for UI reactivity in Profile Screen
  final ValueNotifier<Subscription?> activeSubscription = ValueNotifier(null);

  SubscriptionService._internal() {
    _init();
  }

  Future<void> _init() async {
    final subs = await getMySubscriptions();
    if (subs.isNotEmpty) {
      activeSubscription.value = subs.first;
    }
  }

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<List<Subscription>> getMySubscriptions() async {
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('$baseUrl/my-subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['data'] as List)
              .map((item) => Subscription.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching subscriptions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createSubscription(Map<String, dynamic> payload) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final sub = Subscription.fromJson(data['data']);
        activeSubscription.value = sub;
        return {'success': true, 'data': data['data']};
      } else {
        debugPrint('Failed to create subscription: ${response.statusCode} - ${response.body}');
        try {
          final data = json.decode(response.body);
          return {'success': false, 'message': data['message'] ?? 'Failed to create subscription'};
        } catch (_) {
          return {'success': false, 'message': 'Failed to create subscription: ${response.statusCode}'};
        }
      }
    } catch (e) {
      debugPrint('Error creating subscription: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Quick actions
  Future<void> toggleStatus() async {
    if (activeSubscription.value != null) {
      final sub = activeSubscription.value!;
      final newStatus = sub.status == 'Active' ? 'Suspended' : 'Active';
      
      try {
        final token = await _getToken();
        if (token == null) throw Exception('No auth token');

        final response = await http.patch(
          Uri.parse('$baseUrl/${sub.id}/user-status'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({'status': newStatus}),
        );

        if (response.statusCode == 200) {
          activeSubscription.value = sub.copyWith(status: newStatus);
        } else {
          debugPrint('Failed to toggle status: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        debugPrint('Error toggling subscription status: $e');
      }
    }
  }

  Future<void> updatePreferences({String? deliveryTimePref, bool? leaveAtDoor, bool? callBeforeDelivery, String? specialInstructions}) async {
    if (activeSubscription.value != null) {
      final sub = activeSubscription.value!;
      
      // Optimistic update
      activeSubscription.value = sub.copyWith(
        deliveryTimePref: deliveryTimePref,
        leaveAtDoor: leaveAtDoor,
        callBeforeDelivery: callBeforeDelivery,
        specialInstructions: specialInstructions,
      );

      try {
        final token = await _getToken();
        if (token == null) return;

        final payload = <String, dynamic>{};
        if (deliveryTimePref != null) payload['deliveryTime'] = deliveryTimePref;
        if (leaveAtDoor != null) payload['leaveAtDoor'] = leaveAtDoor;
        if (callBeforeDelivery != null) payload['callBeforeDelivery'] = callBeforeDelivery;
        if (specialInstructions != null) payload['specialInstructions'] = specialInstructions;

        final response = await http.patch(
          Uri.parse('$baseUrl/${sub.id}/preferences'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(payload),
        );

        if (response.statusCode != 200) {
          debugPrint('Failed to update preferences: ${response.body}');
          // Rollback could be implemented here
        }
      } catch (e) {
        debugPrint('Error updating preferences: $e');
      }
    }
  }

  Future<String?> skipDate(DateTime date) async {
    if (activeSubscription.value == null) return null;
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.patch(
        Uri.parse('$baseUrl/${activeSubscription.value!.id}/skip'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'date': date.toIso8601String()}),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['action'] as String?;
      }
      debugPrint('Failed to skip next delivery: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error skipping next delivery: $e');
      return null;
    }
  }

  Future<String?> skipDateRange(DateTime start, DateTime end) async {
    if (activeSubscription.value == null) return null;
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.patch(
        Uri.parse('$baseUrl/${activeSubscription.value!.id}/skip'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'dateRange': [start.toIso8601String(), end.toIso8601String()]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['action'] as String?;
      }
      debugPrint('Failed to skip date range: ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error skipping date range: $e');
      return null;
    }
  }

  Future<bool> removeSkipDate(DateTime date) async {
    if (activeSubscription.value == null) return false;
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.patch(
        Uri.parse('$baseUrl/${activeSubscription.value!.id}/skip'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'removeDate': date.toIso8601String()}),
      );
      
      if (response.statusCode == 200) {
        return true;
      }
      debugPrint('Failed to remove skip date: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error removing skip date: $e');
      return false;
    }
  }

  Future<bool> reschedule(String newTime) async {
    if (activeSubscription.value == null) return false;
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token');

      final response = await http.patch(
        Uri.parse('$baseUrl/${activeSubscription.value!.id}/reschedule'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'deliveryTime': newTime}),
      );
      
      if (response.statusCode == 200) {
        return true;
      }
      debugPrint('Failed to reschedule delivery: ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error rescheduling delivery: $e');
      return false;
    }
  }
}
