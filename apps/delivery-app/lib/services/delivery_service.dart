import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'user_service.dart';
import 'alert_audio_service.dart';

class DeliveryService {
  static final DeliveryService _instance = DeliveryService._internal();
  factory DeliveryService() => _instance;
  DeliveryService._internal();

  static const String baseUrl = 'http://localhost:5000/api/v1';
  static const String socketUrl = 'http://localhost:5000';

  IO.Socket? _socket;
  final ValueNotifier<List<dynamic>> availableOrders = ValueNotifier([]);
  final ValueNotifier<Map<String, dynamic>?> activeOrder = ValueNotifier(null);

  void initSocket() {
    if (_socket != null) return;
    
    final token = UserService().token.value;
    if (token == null) return;

    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'auth': {
        'token': 'Bearer $token',
      },
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      debugPrint('Delivery Socket Connected');
    });

    _socket!.on('new_order_available', (data) {
      debugPrint('New order available: $data');
      fetchAvailableOrders();

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
