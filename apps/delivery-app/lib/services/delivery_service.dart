import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'user_service.dart';
import 'alert_audio_service.dart';
import 'wallet_service.dart';
import 'incentive_service.dart';

class DeliveryService {
  static final DeliveryService _instance = DeliveryService._internal();
  factory DeliveryService() => _instance;
  DeliveryService._internal();

  static String get baseUrl => UserService.baseUrl;
  static String get socketUrl => UserService.baseUrl.replaceAll('/api/v1', '');

  io.Socket? _socket;
  final ValueNotifier<List<dynamic>> availableOrders = ValueNotifier([]);
  final ValueNotifier<List<dynamic>> myOrders = ValueNotifier([]);
  final ValueNotifier<Map<String, dynamic>?> activeOrder = ValueNotifier(null);
  final ValueNotifier<bool> isOnline = ValueNotifier(true);
  final ValueNotifier<Map<String, dynamic>?> latestIncomingOrder = ValueNotifier(null);

  Future<void> initSocket() async {
    if (_socket != null && _socket!.connected) return;
    
    final token = await UserService().getFreshToken();
    if (token == null) return;

    _socket = io.io(
      socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection()
          .disableAutoConnect()
          .setAuth({'token': token})
          .setExtraHeaders({'authorization': 'Bearer $token'})
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Delivery Socket Connected to $socketUrl');
    });

    _socket!.onConnectError((err) {
      debugPrint('Delivery Socket connect error: $err');
    });

    _socket!.on('new_order_available', (data) {
      debugPrint('New order available: $data');
      if (!isOnline.value) {
        debugPrint('Rider is OFFLINE - skipping audio/vibration alert');
        return;
      }

      fetchAvailableOrders();
      if (data is Map) {
        latestIncomingOrder.value = Map<String, dynamic>.from(data);
      }

      // Play real alert tone and haptics based on rider preferences
      final user = UserService().currentUser.value;
      final prefs = user?.deliveryDetails?['preferences'];
      final String tone = prefs?['alertTone'] ?? 'Loud Ring';
      final double volume = (prefs?['soundVolume'] != null)
          ? (prefs!['soundVolume'] as num).toDouble()
          : 85.0;
      final bool vibrate = prefs?['vibrateOnAlert'] ?? true;

      AlertAudioService().playTone(tone, volume: volume);
      if (vibrate) {
        AlertAudioService().vibrate(durationMs: 700);
      }
    });

    _socket!.on('order_status_updated', (data) {
      debugPrint('Order status updated: $data');
      // If the admin or someone updated a status, we refresh our available orders
      fetchAvailableOrders();
    });

    _socket!.on('incentive_reward_credited', (data) {
      debugPrint('Incentive reward credited socket received: $data');
      WalletService().fetchWalletData();
      IncentiveService().fetchIncentives();
    });

    _socket!.on('wallet_updated', (data) {
      debugPrint('Wallet updated socket received: $data');
      WalletService().fetchWalletData();
    });

    _socket!.onDisconnect((_) {
      debugPrint('Delivery Socket Disconnected');
    });
  }

  void disconnectSocket() {
    _socket?.disconnect();
    _socket = null;
  }

  Future<void> fetchAvailableOrders() async {
    final token = UserService().token.value;
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery/orders/available'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          availableOrders.value = List<dynamic>.from(data['data']);
        }
      } else {
        debugPrint('Failed to fetch available orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching available orders: $e');
    }
  }

  Future<void> fetchMyOrders() async {
    final token = await UserService().getFreshToken();
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery/orders/my-orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          myOrders.value = List<dynamic>.from(data['data'] ?? []);
        }
      } else {
        debugPrint('Failed to fetch my orders: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching my orders: $e');
    }
  }

  Future<bool> acceptOrder(String orderId) async {
    final token = UserService().token.value;
    if (token == null) return false;

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/delivery/orders/$orderId/accept'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          activeOrder.value = data['data'];
          // Remove from available orders since we accepted it
          final currentOrders = List<dynamic>.from(availableOrders.value);
          currentOrders.removeWhere((order) => order['_id'] == orderId);
          availableOrders.value = currentOrders;
          
          // Optionally, join the specific order tracking room if required
          _socket?.emit('join_order_room', orderId);
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error accepting order: $e');
      return false;
    }
  }

  Future<bool> updateDeliveryStatus(String orderId, String status) async {
    final token = UserService().token.value;
    if (token == null) return false;

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/delivery/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          activeOrder.value = data['data'];
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error updating delivery status: $e');
      return false;
    }
  }
}
