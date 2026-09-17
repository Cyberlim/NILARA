import 'dart:convert';

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
}

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
