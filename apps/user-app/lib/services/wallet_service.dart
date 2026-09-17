import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WalletTransaction {
  final String title;
  final String date;
  final double amount;
  final bool isCredit;
  final IconData icon;

  WalletTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.isCredit,
    required this.icon,
  });
}

class WalletState {
  final double balance;
  final int rewardPoints;
  final int coupons;
  final List<WalletTransaction> transactions;

  WalletState({
    required this.balance,
    required this.rewardPoints,
    required this.coupons,
    required this.transactions,
  });

  WalletState copyWith({
    double? balance,
    int? rewardPoints,
    int? coupons,
    List<WalletTransaction>? transactions,
  }) {
    return WalletState(
      balance: balance ?? this.balance,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      coupons: coupons ?? this.coupons,
      transactions: transactions ?? this.transactions,
    );
  }
}

class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  final ValueNotifier<WalletState> wallet = ValueNotifier(
    WalletState(
      balance: 1250.0,
      rewardPoints: 450,
      coupons: 3,
      transactions: [
        WalletTransaction(
          title: 'Added to Wallet',
          date: 'Oct 24, 2023 • 10:30 AM',
          amount: 500.0,
          isCredit: true,
          icon: Icons.account_balance_wallet,
        ),
        WalletTransaction(
          title: 'Nilara Order #1092',
          date: 'Oct 23, 2023 • 08:15 PM',
          amount: 245.0,
          isCredit: false,
          icon: Icons.shopping_bag,
        ),
      ],
    ),
  );

  void addFunds(double amount) {
    final current = wallet.value;
    final newTx = WalletTransaction(
      title: 'Added to Wallet',
      date: 'Just now',
      amount: amount,
      isCredit: true,
      icon: Icons.account_balance_wallet,
    );
    wallet.value = current.copyWith(
      balance: current.balance + amount,
      transactions: [newTx, ...current.transactions],
    );
  }

  bool deductFunds(double amount, String orderId) {
    final current = wallet.value;
    if (current.balance >= amount) {
      final newTx = WalletTransaction(
        title: 'Order $orderId',
        date: 'Just now',
        amount: amount,
        isCredit: false,
        icon: Icons.shopping_bag,
      );
      wallet.value = current.copyWith(
        balance: current.balance - amount,
        transactions: [newTx, ...current.transactions],
      );
      return true;
    }
    return false;
  }
}
