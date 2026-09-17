import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'user_service.dart';

class WalletService {
  static final WalletService instance = WalletService._internal();
  factory WalletService() => instance;
  WalletService._internal();

  String get baseUrl => '${UserService.baseUrl}/delivery';

  final ValueNotifier<double> balanceNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> lastPayoutAmountNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<String> lastPayoutDateNotifier = ValueNotifier<String>("Never");
  final ValueNotifier<double> todaysEarningsNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<double> weeklyEarningsNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<int> todayDeliveredOrdersNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> totalDeliveredOrdersNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<List<Map<String, dynamic>>> transactionsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

  Future<void> fetchWalletData() async {
    final token = await UserService().getFreshToken();
    if (token == null) return;

    try {
      isLoadingNotifier.value = true;
      final response = await http.get(
        Uri.parse('$baseUrl/wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        balanceNotifier.value = (data['balance'] as num?)?.toDouble() ?? 0.0;
        todaysEarningsNotifier.value = (data['todaysEarnings'] as num?)?.toDouble() ?? 0.0;
        weeklyEarningsNotifier.value = (data['weeklyEarnings'] as num?)?.toDouble() ?? 0.0;
        todayDeliveredOrdersNotifier.value = (data['todayDeliveredOrders'] as num?)?.toInt() ?? 0;
        totalDeliveredOrdersNotifier.value = (data['totalDeliveredOrders'] as num?)?.toInt() ?? 0;
        
        final List<dynamic> rawTx = data['transactions'] ?? [];
        
        // Find last payout for UI
        final payouts = rawTx.where((t) => t['type'] == 'debit').toList();
        if (payouts.isNotEmpty) {
          lastPayoutAmountNotifier.value = (payouts.first['amount'] as num?)?.toDouble() ?? 0.0;
          final date = DateTime.parse(payouts.first['createdAt']).toLocal();
          lastPayoutDateNotifier.value = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
        } else {
          lastPayoutAmountNotifier.value = 0.0;
          lastPayoutDateNotifier.value = "Never";
        }
        
        // Map to UI format
        transactionsNotifier.value = rawTx.map((tx) {
          final isCredit = tx['type'] == 'credit';
          final num amount = (tx['amount'] as num?) ?? 0;
          return {
            "id": tx['_id']?.toString() ?? '',
            "title": tx['description'] ?? 'Transaction',
            "time": DateTime.parse(tx['createdAt']).toLocal().toString().split('.')[0],
            "amount": "${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}",
            "isCredit": isCredit,
            "type": (tx['description']?.toString().contains('Incentive') ?? false)
                ? "Incentive"
                : (isCredit ? "Order" : "Withdrawal"),
            "status": tx['status'] == 'pending_payout' ? "Pending" : "Completed"
          };
        }).toList();
      } else {
        debugPrint("fetchWalletData failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error fetching wallet data: $e");
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<Map<String, dynamic>?> withdraw(double amount, String bankName) async {
    final token = await UserService().getFreshToken();
    if (token == null) return null;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/payout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'amount': amount, 'bankName': bankName}),
      );

      if (response.statusCode == 200) {
        final resData = json.decode(response.body);
        await fetchWalletData();
        return resData['data'];
      } else {
        debugPrint("Withdrawal failed: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("Error requesting payout: $e");
    }
    return null;
  }
}
