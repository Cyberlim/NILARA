import re

with open("lib/services/cart_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Add imports
imports = """import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';"""

content = re.sub(r'import \'package:flutter/foundation\.dart\';', imports, content)

# Add to/fromJson to CartItem
cart_item_methods = """  Map<String, dynamic> toJson() => {
    'productId': productId,
    'variantId': variantId,
    'title': title,
    'imagePath': imagePath,
    'price': price,
    'originalPrice': originalPrice,
    'unit': unit,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json['productId'] as String,
    variantId: json['variantId'] as String,
    title: json['title'] as String,
    imagePath: json['imagePath'] as String,
    price: json['price'] as String,
    originalPrice: json['originalPrice'] as String?,
    unit: json['unit'] as String?,
    quantity: json['quantity'] as int,
  );
}"""

content = re.sub(r'\}', cart_item_methods, content, count=1) # Replace the first closing brace (end of CartItem class)

# Add load/save to CartService
cart_service_methods = """  final ValueNotifier<Map<String, CartItem>> items = ValueNotifier({});

  static const String _storageKey = 'cart_items';

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString(_storageKey);
      if (cartString != null) {
        final decoded = jsonDecode(cartString) as Map<String, dynamic>;
        final Map<String, CartItem> loadedItems = {};
        for (var entry in decoded.entries) {
          loadedItems[entry.key] = CartItem.fromJson(entry.value as Map<String, dynamic>);
        }
        items.value = loadedItems;
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(items.value.map((key, value) => MapEntry(key, value.toJson())));
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }"""

content = content.replace("final ValueNotifier<Map<String, CartItem>> items = ValueNotifier({});", cart_service_methods)

# Add _saveCart() to addItem
content = content.replace("items.value = currentItems;", "items.value = currentItems;\n    _saveCart();")

# Add _saveCart() to clear
content = content.replace("items.value = {};", "items.value = {};\n    _saveCart();")

with open("lib/services/cart_service.dart", "w", encoding="utf-8") as f:
    f.write(content)

print("done")
