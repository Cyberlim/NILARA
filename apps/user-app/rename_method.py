import re

with open("lib/services/order_service.dart", "r", encoding="utf-8") as f:
    content = f.read()
content = content.replace("Future<bool> hideOrder(String orderId)", "Future<bool> deleteOrder(String orderId)")
content = content.replace("Error hiding order", "Error deleting order")
with open("lib/services/order_service.dart", "w", encoding="utf-8") as f:
    f.write(content)


with open("lib/screens/orders_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()
content = content.replace("OrderService().hideOrder(order.id)", "OrderService().deleteOrder(order.id)")
with open("lib/screens/orders_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
