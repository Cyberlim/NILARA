import 'package:flutter/foundation.dart';

class WalletService {
  static final WalletService instance = WalletService._internal();
  WalletService._internal();

  final ValueNotifier<double> balanceNotifier = ValueNotifier<double>(1250.00);
  final ValueNotifier<double> lastPayoutAmountNotifier = ValueNotifier<double>(4500.00);
  final ValueNotifier<String> lastPayoutDateNotifier = ValueNotifier<String>("28 Oct");

  final ValueNotifier<List<Map<String, dynamic>>> transactionsNotifier = ValueNotifier<List<Map<String, dynamic>>>([
    {
      "title": "Order Delivered (#8921)",
      "time": "10:30 AM",
      "amount": "+₹45.00",
      "isCredit": true,
      "type": "Order",
      "status": "Completed"
    },
    {
      "title": "Incentive Bonus (5 Orders)",
      "time": "09:00 AM",
      "amount": "+₹50.00",
      "isCredit": true,
      "type": "Incentive",
      "status": "Completed"
    },
    {
      "title": "Order Delivered (#8920)",
      "time": "08:15 AM",
      "amount": "+₹35.00",
      "isCredit": true,
      "type": "Order",
      "status": "Completed"
    },
    {
      "title": "Order Delivered (#8919)",
      "time": "07:40 AM",
      "amount": "+₹60.00",
      "isCredit": true,
      "type": "Order",
      "status": "Completed"
    },
    {
      "title": "Bank Transfer (HDFC •••• 4321)",
      "time": "Yesterday",
      "amount": "-₹4,500.00",
      "isCredit": false,
      "type": "Withdrawal",
      "status": "Completed"
    },
  ]);

  void withdraw(double amount, String bankName) {
    final double currentBal = balanceNotifier.value;
    final double newBal = (currentBal - amount).clamp(0.0, double.infinity);
    balanceNotifier.value = newBal;
    lastPayoutAmountNotifier.value = amount;
    lastPayoutDateNotifier.value = "Today";

    final List<Map<String, dynamic>> updatedList = List<Map<String, dynamic>>.from(transactionsNotifier.value);
    updatedList.insert(0, {
      "title": "Withdrawal to $bankName",
      "time": "Just now",
      "amount": "-₹${amount.toStringAsFixed(2)}",
      "isCredit": false,
      "type": "Withdrawal",
      "status": "Completed"
    });
    transactionsNotifier.value = updatedList;
  }
}
