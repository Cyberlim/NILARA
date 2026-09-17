import 'dart:convert';
import 'lib/services/subscription_service.dart';

void main() {
  final jsonString = '''{
      "_id": "6a899ba2115aacdf0042f924",
      "user": "6a89377a27d7d1b81d6a900d",
      "planName": "Premium",
      "frequency": "Weekly",
      "productName": "Nilara 20L Water Jar",
      "quantity": 1,
      "price": 499,
      "discountedPrice": 449.1,
      "deliveryTime": "Early Morning (6 AM - 8 AM)",
      "startDate": "2026-08-23T12:48:43.350Z",
      "address": {
        "type": "Home",
        "street": "A30 chipyana Buzurg",
        "apartment": "",
        "floor": "",
        "landmark": "Ghaziabad, up 201009",
        "notes": ""
      },
      "paymentMethod": "UPI (Google Pay / PhonePe)",
      "status": "Suspended",
      "specialInstructions": "",
      "createdAt": "2026-08-22T12:52:50.849Z",
      "updatedAt": "2026-08-24T11:58:30.783Z",
      "__v": 7,
      "skippedDeliveries": [],
      "leaveAtDoor": true,
      "callBeforeDelivery": true
  }''';

  final map = json.decode(jsonString);
  try {
    final sub = Subscription.fromJson(map);
    print('Success: \${sub.id}');
  } catch (e, stack) {
    print('Error: \$e\\n\$stack');
  }
}
