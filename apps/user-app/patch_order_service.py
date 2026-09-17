import re

with open("lib/services/order_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

hide_order_method = """  Future<bool> hideOrder(String orderId) async {
    try {
      final token = UserService().token.value;
      if (token == null) return false;

      final url = Uri.parse('${Constants.baseUrl}/api/v1/orders/me/$orderId');
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Remove from local list
        final currentOrders = List<OrderModel>.from(orders.value);
        currentOrders.removeWhere((o) => o.id == orderId);
        orders.value = currentOrders;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error hiding order: $e');
      return false;
    }
  }

}"""

content = content.replace("}\n}", hide_order_method)
# Actually, the file probably ends with "  }\n}" for fetchMyOrders and class end.
# Let's be safe.
# Replace the last '}' of the class.
idx = content.rfind("}")
if idx != -1:
    content = content[:idx] + hide_order_method
else:
    content += hide_order_method

with open("lib/services/order_service.dart", "w", encoding="utf-8") as f:
    f.write(content)
