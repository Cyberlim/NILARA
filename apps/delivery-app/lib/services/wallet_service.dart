import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'user_service.dart';

class WalletService {
  static final WalletService instance = WalletService._internal();
  factory WalletService() => instance;
  WalletService._internal();

  final String baseUrl = 'http://localhost:5000/api/v1/delivery';

  final ValueNotifier<double> balanceNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> lastPayoutAmountNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<String> lastPayoutDateNotifier = ValueNotifier<String>("Never");
  final ValueNotifier<List<Map<String, dynamic>>> transactionsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  Future<void> fetchWalletData() async {
    final token = UserService().token.value;
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        balanceNotifier.value = (data['balance'] as num).toDouble();
        
        final List<dynamic> rawTx = data['transactions'];
        
        // Find last payout for UI
        final payouts = rawTx.where((t) => t['type'] == 'debit').toList();
        if (payouts.isNotEmpty) {
          lastPayoutAmountNotifier.value = (payouts.first['amount'] as num).toDouble();
          final date = DateTime.parse(payouts.first['createdAt']).toLocal();
          lastPayoutDateNotifier.value = "${date.day}/${date.month}/${date.year}";
        }
        
        // Map to UI format
        transactionsNotifier.value = rawTx.map((tx) {
          final isCredit = tx['type'] == 'credit';
          return {
            "title": tx['description'] ?? 'Transaction',
            "time": DateTime.parse(tx['createdAt']).toLocal().toString().split('.')[0],
            "amount": "${isCredit ? '+' : '-'}?${(tx['amount'] as num).toStringAsFixed(2)}",
            "isCredit": isCredit,
            "type": isCredit ? "Order" : "Withdrawal",
            "status": tx['status'] == 'pending_payout' ? "Pending" : "Completed"
          };
        }).toList();
      }
    } catch (e) {
      debugPrint("Error fetching wallet data: $e");
    }
  }

  Future<void> withdraw(double amount, String bankName) async {
    final token = UserService().token.value;
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/payout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'amount': amount}),
      );

      if (response.statusCode == 200) {
        await fetchWalletData();
      }
    } catch (e) {
      debugPrint("Error requesting payout: $e");
    }
  }
}
