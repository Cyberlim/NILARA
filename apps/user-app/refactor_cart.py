import re

with open("lib/services/cart_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace imports
old_imports = """import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';"""

new_imports = """import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';"""

content = content.replace(old_imports, new_imports)

# Rewrite CartService class
new_cart_service = """class CartService {
  // Singleton pattern
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  
  CartService._internal() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        loadCart();
      } else {
        items.value = {}; // Clear on logout
      }
    });
  }

  final ValueNotifier<Map<String, CartItem>> items = ValueNotifier({});
  static const String baseUrl = 'http://localhost:5000/api/v1';

  Future<String?> _getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  Future<void> loadCart() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('$baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null && data['data']['items'] != null) {
          final List<dynamic> itemsJson = data['data']['items'];
          final Map<String, CartItem> loadedItems = {};
          for (var item in itemsJson) {
            loadedItems[item['productId']] = CartItem.fromJson(item);
          }
          items.value = loadedItems;
        }
      }
    } catch (e) {
      debugPrint('Error loading cart from DB: $e');
    }
  }

  Future<void> _syncCart() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final itemsList = items.value.values.map((item) => item.toJson()).toList();
      
      await http.put(
        Uri.parse('$baseUrl/cart'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'items': itemsList}),
      );
    } catch (e) {
      debugPrint('Error syncing cart to DB: $e');
    }
  }

  void addItem(String productId, String variantId, String title, String imagePath, String price, {String? originalPrice, String? unit}) {
    final currentItems = Map<String, CartItem>.from(items.value);
    if (currentItems.containsKey(productId)) {
      currentItems[productId] = currentItems[productId]!.copyWith(
        quantity: currentItems[productId]!.quantity + 1,
      );
    } else {
      currentItems[productId] = CartItem(
        productId: productId,
        variantId: variantId,
        title: title,
        imagePath: imagePath,
        price: price,
        originalPrice: originalPrice,
        unit: unit,
        quantity: 1,
      );
    }
    items.value = currentItems;
    _syncCart();
  }

  void removeItem(String productId) {
    final currentItems = Map<String, CartItem>.from(items.value);
    if (currentItems.containsKey(productId)) {
      if (currentItems[productId]!.quantity > 1) {
        currentItems[productId] = currentItems[productId]!.copyWith(
          quantity: currentItems[productId]!.quantity - 1,
        );
      } else {
        currentItems.remove(productId);
      }
      items.value = currentItems;
      _syncCart();
    }
  }

  int getQuantity(String productId) {
    return items.value[productId]?.quantity ?? 0;
  }

  int getTotalItems() {
    return items.value.values.fold(0, (sum, item) => sum + item.quantity);
  }
  
  void clear() {
    items.value = {};
    _syncCart();
  }
}"""

content = re.sub(r'class CartService \{.*\}', new_cart_service, content, flags=re.DOTALL)

with open("lib/services/cart_service.dart", "w", encoding="utf-8") as f:
    f.write(content)
