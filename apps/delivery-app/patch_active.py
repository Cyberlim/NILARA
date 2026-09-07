import re

with open("lib/screens/active_delivery_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

import_str = "import '../services/delivery_service.dart';\n"
content = content.replace("import 'order_delivered_screen.dart';", "import 'order_delivered_screen.dart';\n" + import_str)

# Replace the hardcoded store/customer location with order data if available (optional/skip for now to keep map working).
# Let's replace the OTP verification button logic:

old_onpressed = """                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => const OrderDeliveredScreen())
                    );
                  },"""

new_onpressed = """                  onPressed: () async {
                    final order = DeliveryService().activeOrder.value;
                    if (order != null) {
                      final success = await DeliveryService().updateDeliveryStatus(order['_id'], 'delivered');
                      if (success && context.mounted) {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (context) => const OrderDeliveredScreen())
                        );
                      }
                    }
                  },"""

content = content.replace(old_onpressed, new_onpressed)

with open("lib/screens/active_delivery_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
