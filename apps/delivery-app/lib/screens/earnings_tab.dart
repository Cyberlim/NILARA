import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/wallet_service.dart';
import '../services/user_service.dart';

class EarningsTab extends StatefulWidget {
  const EarningsTab({super.key});

  @override
  State<EarningsTab> createState() => _EarningsTabState();
}

class _EarningsTabState extends State<EarningsTab> {
  @override
  void initState() {
    super.initState();
    WalletService.instance.fetchWalletData();
  }

  void _openWithdrawModal(double currentBalance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WithdrawalFlowBottomSheet(
        availableBalance: currentBalance,
        onWithdrawSuccess: (double withdrawAmount, String bankName) {
          WalletService.instance.withdraw(withdrawAmount, bankName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFF1E9C1C),
      onRefresh: () => WalletService.instance.fetchWalletData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Text(
              "Earnings & Wallet",
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Track daily income and transfer directly to your bank",
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),

            // Available Balance Card listening to central WalletService!
            ValueListenableBuilder<double>(
              valueListenable: WalletService.instance.balanceNotifier,
              builder: (context, currentBalance, child) {
                return Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E9C1C), Color(0xFF146B12)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E9C1C).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Available Balance",
                                style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${currentBalance.toStringAsFixed(2)}",
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ValueListenableBuilder<String>(
                              valueListenable: WalletService.instance.lastPayoutDateNotifier,
                              builder: (context, payoutDate, child) {
                                final payoutAmt = WalletService.instance.lastPayoutAmountNotifier.value;
                                final bool hasLastTransfer = payoutDate.isNotEmpty && payoutDate != "Never" && payoutAmt > 0;
                                if (!hasLastTransfer) {
                                  return const SizedBox.shrink();
                                }
                                return Text(
                                  "Last Transfer: $payoutDate, ₹${payoutAmt.toStringAsFixed(0)}",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                );
                              },
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: currentBalance > 0 ? () => _openWithdrawModal(currentBalance) : null,
                            icon: const Icon(Icons.arrow_upward, size: 16, color: Color(0xFF1E9C1C)),
                            label: Text(
                              "Withdraw",
                              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1E9C1C),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // Daily & Weekly Stats Summary (Dynamic Real Data)
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: WalletService.instance.todayDeliveredOrdersNotifier,
                    builder: (context, todayCount, child) {
                      return _buildSummaryCard(
                        title: "Today's Orders",
                        value: "$todayCount Delivered",
                        icon: Icons.delivery_dining,
                        iconColor: const Color(0xFF1E9C1C),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ValueListenableBuilder<double>(
                    valueListenable: WalletService.instance.weeklyEarningsNotifier,
                    builder: (context, weeklyEarnings, child) {
                      return _buildSummaryCard(
                        title: "Weekly Earnings",
                        value: "₹${weeklyEarnings.toStringAsFixed(2)}",
                        icon: Icons.date_range,
                        iconColor: Colors.purple,
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Transactions Header listening to central WalletService!
            ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: WalletService.instance.transactionsNotifier,
              builder: (context, transactions, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Transaction History",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (transactions.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "${transactions.length} items",
                              style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Transaction List or Empty State
                    if (transactions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.receipt_long_outlined, size: 32, color: Colors.grey.shade400),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No Transactions Yet",
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Your delivery earnings and withdrawals will appear here.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          return _buildTransactionTile(
                            title: tx["title"] as String,
                            time: tx["time"] as String,
                            amount: tx["amount"] as String,
                            isCredit: tx["isCredit"] as bool,
                            type: tx["type"] as String,
                          );
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile({
    required String title,
    required String time,
    required String amount,
    required bool isCredit,
    required String type,
  }) {
    final IconData typeIcon = isCredit
        ? (type == "Incentive" ? Icons.card_giftcard : Icons.arrow_downward)
        : Icons.arrow_upward;
    final Color badgeColor = isCredit ? const Color(0xFF1E9C1C) : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(typeIcon, color: badgeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: isCredit ? const Color(0xFF1E9C1C) : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

// --- WITHDRAWAL MULTI-STEP BOTTOM SHEET (Bank Selection -> Amount -> Success) ---
class _WithdrawalFlowBottomSheet extends StatefulWidget {
  final double availableBalance;
  final Function(double amount, String bankName) onWithdrawSuccess;

  const _WithdrawalFlowBottomSheet({
    required this.availableBalance,
    required this.onWithdrawSuccess,
  });

  @override
  State<_WithdrawalFlowBottomSheet> createState() => _WithdrawalFlowBottomSheetState();
}

class _WithdrawalFlowBottomSheetState extends State<_WithdrawalFlowBottomSheet> {
  int _step = 1; // Step 1: Select Bank & Amount | Step 2: Withdrawal Success
  late TextEditingController _amountController;
  late String _selectedBank;
  late List<Map<String, String>> _banks;
  String _referenceId = "#TXN-PENDING";
  double _lastWithdrawnAmount = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.availableBalance.toInt().toString());
    _banks = _getRealBankAccounts();
    _selectedBank = _banks.isNotEmpty ? _banks.first["name"]! : "Primary Bank Account";
  }

  List<Map<String, String>> _getRealBankAccounts() {
    final user = UserService().currentUser.value;
    final bankDetails = user?.deliveryDetails?['bankDetails'];
    final List<Map<String, String>> list = [];

    if (bankDetails != null) {
      final String? bName = bankDetails['bankName']?.toString();
      final String? accNum = bankDetails['accountNumber']?.toString();
      final String? upi = bankDetails['upiId']?.toString();

      if (accNum != null && accNum.isNotEmpty) {
        final last4 = accNum.length > 4 ? accNum.substring(accNum.length - 4) : accNum;
        final bankTitle = (bName != null && bName.isNotEmpty) ? bName : 'Bank Account';
        list.add({
          "name": "$bankTitle (•••• $last4)",
          "desc": "${bankDetails['accountType'] ?? 'Savings Account'} • ${bankDetails['ifscCode'] ?? 'Verified'}",
          "icon": "🏦",
        });
      }

      if (upi != null && upi.isNotEmpty) {
        list.add({
          "name": "UPI ($upi)",
          "desc": "Instant VPA Payout",
          "icon": "💳",
        });
      }
    }

    if (list.isEmpty) {
      list.add({
        "name": "Primary Bank Account",
        "desc": "Direct Instant Bank Transfer",
        "icon": "🏦",
      });
    }

    return list;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processWithdrawal() async {
    final double? enteredAmount = double.tryParse(_amountController.text.trim());
    if (enteredAmount == null || enteredAmount <= 0) {
      _showSnackBar("Please enter a valid amount");
      return;
    }
    if (enteredAmount > widget.availableBalance) {
      _showSnackBar("Entered amount exceeds available balance (₹${widget.availableBalance.toStringAsFixed(2)})");
      return;
    }

    setState(() => _isLoading = true);
    final result = await WalletService.instance.withdraw(enteredAmount, _selectedBank);
    setState(() => _isLoading = false);

    if (result != null) {
      final tx = result['transaction'];
      final String txId = tx?['_id']?.toString() ?? '';
      _referenceId = txId.isNotEmpty
          ? "#TXN-${txId.length >= 8 ? txId.substring(txId.length - 8).toUpperCase() : txId.toUpperCase()}"
          : "#TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

      setState(() {
        _lastWithdrawnAmount = enteredAmount;
        _step = 2; // Move to Success Screen
      });

      widget.onWithdrawSuccess(_lastWithdrawnAmount, _selectedBank);
    } else {
      _showSnackBar("Withdrawal request failed. Minimum payout is ₹100.");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _step == 1 ? _buildStep1SelectBankAndAmount() : _buildStep2SuccessScreen(),
      ),
    );
  }

  // --- STEP 1: SELECT BANK & ENTER AMOUNT ---
  Widget _buildStep1SelectBankAndAmount() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Handle Pill
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Withdraw Earnings",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        Text(
          "Available for instant transfer: ₹${widget.availableBalance.toStringAsFixed(2)}",
          style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),

        // Amount Input Field
        Text(
          "Enter Withdrawal Amount (₹)",
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E9C1C)),
          decoration: InputDecoration(
            prefixText: "₹ ",
            prefixStyle: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E9C1C)),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF1E9C1C), width: 2)),
          ),
        ),
        const SizedBox(height: 10),

        // Quick Preset Chips
        Row(
          children: [
            _buildPresetChip("₹500", 500),
            const SizedBox(width: 8),
            _buildPresetChip("₹1,000", 1000),
            const SizedBox(width: 8),
            _buildPresetChip("Withdraw All", widget.availableBalance),
          ],
        ),
        const SizedBox(height: 24),

        // Bank Selection Section
        Text(
          "Select Receiving Bank Account",
          style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),

        ..._banks.map((b) {
          final isSelected = _selectedBank == b["name"];
          return GestureDetector(
            onTap: () => setState(() => _selectedBank = b["name"]!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1E9C1C) : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(b["icon"]!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b["name"]!,
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        ),
                        Text(
                          b["desc"]!,
                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_off,
                    color: isSelected ? const Color(0xFF1E9C1C) : Colors.grey.shade400,
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 20),

        // Action Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _processWithdrawal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E9C1C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    "Confirm & Transfer Money",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, double amount) {
    return GestureDetector(
      onTap: () {
        if (amount <= widget.availableBalance) {
          setState(() {
            _amountController.text = amount.toInt().toString();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
    );
  }

  // --- STEP 2: WITHDRAWAL SUCCESS SCREEN ---
  Widget _buildStep2SuccessScreen() {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 76,
          height: 76,
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.check_circle, color: Color(0xFF1E9C1C), size: 54),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          "Withdrawal Successful!",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        Text(
          "Amount has been transferred to your bank account.",
          textAlign: TextAlign.center,
          style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),

        // Transfer Detail Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildDetailRow("Amount Transferred", "₹${_lastWithdrawnAmount.toStringAsFixed(2)}", isBold: true),
              const Divider(height: 16),
              _buildDetailRow("Bank Account", _selectedBank),
              const Divider(height: 16),
              _buildDetailRow("Reference ID", _referenceId),
              const Divider(height: 16),
              _buildDetailRow("Status", "Instant Completed 🟢"),
            ],
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E9C1C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              "Done & Back to Earnings",
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String val, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
        Text(
          val,
          style: GoogleFonts.outfit(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFF1E9C1C) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
