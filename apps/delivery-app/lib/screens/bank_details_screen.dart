import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  late TextEditingController _holderController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscController;
  late TextEditingController _upiController;

  String _accountType = "Savings Account";
  String _payoutFrequency = "Daily";
  bool _isEditing = false;
  bool _isSaving = false;
  bool _showFullAccountNumber = false;

  @override
  void initState() {
    super.initState();
    _loadDetails();
    // Refresh user profile in background
    UserService().refreshProfile();
  }

  void _loadDetails() {
    final user = UserService().currentUser.value;
    final bank = user?.deliveryDetails?['bankDetails'];

    final bool hasAccount = bank != null &&
        bank['accountNumber'] != null &&
        bank['accountNumber'].toString().trim().isNotEmpty;

    _holderController = TextEditingController(
      text: bank?['accountHolderName'] ?? user?.name ?? "",
    );
    _bankNameController = TextEditingController(
      text: bank?['bankName'] ?? "",
    );
    _accountNumberController = TextEditingController(
      text: bank?['accountNumber'] ?? "",
    );
    _ifscController = TextEditingController(
      text: (bank?['ifscCode'] ?? "").toString().toUpperCase(),
    );
    _upiController = TextEditingController(
      text: bank?['upiId'] ?? "",
    );

    _accountType = bank?['accountType'] ?? "Savings Account";
    _payoutFrequency = bank?['payoutFrequency'] ?? "Daily";

    // If no bank details exist yet, open in edit mode directly
    if (!hasAccount) {
      _isEditing = true;
    }
  }

  @override
  void dispose() {
    _holderController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  String _getMaskedAccountNumber(String full) {
    if (full.isEmpty) return "Not provided";
    if (full.length <= 4) return full;
    final lastFour = full.substring(full.length - 4);
    return "•••• •••• •••• $lastFour";
  }

  Future<void> _saveDetails() async {
    if (_holderController.text.trim().isEmpty ||
        _bankNameController.text.trim().isEmpty ||
        _accountNumberController.text.trim().isEmpty ||
        _ifscController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please fill in all mandatory bank details",
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final success = await UserService().updateProfile({
      'bankDetails': {
        'accountHolderName': _holderController.text.trim(),
        'bankName': _bankNameController.text.trim(),
        'accountNumber': _accountNumberController.text.trim(),
        'ifscCode': _ifscController.text.trim().toUpperCase(),
        'accountType': _accountType,
        'upiId': _upiController.text.trim().toLowerCase(),
        'payoutFrequency': _payoutFrequency,
      },
    });

    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Bank & payout details updated successfully!"
                : "Failed to update bank details. Please try again.",
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: success ? const Color(0xFF1E9C1C) : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Bank & Payout Details",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit_outlined,
              color: const Color(0xFF1E9C1C),
            ),
            tooltip: _isEditing ? "Save" : "Edit Details",
            onPressed: () {
              if (_isEditing) {
                _saveDetails();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<UserProfile?>(
        valueListenable: UserService().currentUser,
        builder: (context, user, _) {
          final bank = user?.deliveryDetails?['bankDetails'];
          final currentBankName = (bank?['bankName'] ?? _bankNameController.text).toString().trim();
          final currentAccNum = (bank?['accountNumber'] ?? _accountNumberController.text).toString().trim();
          final currentUpi = (bank?['upiId'] ?? _upiController.text).toString().trim();
          final bool isConfigured = currentAccNum.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Setup banner if not configured and not editing
                if (!_isEditing && !isConfigured) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFD97706), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Add Bank Account to Get Paid",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Your delivery earnings & daily incentives will be credited directly to this account.",
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => setState(() => _isEditing = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: Text("Add Now", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],

                // Hero Bank Payout Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.account_balance,
                              color: isConfigured ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                              size: 26,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isConfigured 
                                  ? const Color(0xFF1E9C1C).withValues(alpha: 0.2)
                                  : const Color(0xFFF59E0B).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isConfigured 
                                    ? const Color(0xFF4ADE80).withValues(alpha: 0.5)
                                    : const Color(0xFFFBBF24).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isConfigured ? Icons.check_circle : Icons.pending_actions_outlined, 
                                  color: isConfigured ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24), 
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isConfigured ? "Payout Ready" : "Setup Required",
                                  style: GoogleFonts.outfit(
                                    color: isConfigured ? const Color(0xFF4ADE80) : const Color(0xFFFBBF24),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        isConfigured 
                            ? (currentBankName.isNotEmpty ? currentBankName : "Bank Account")
                            : "No Bank Account Linked",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isConfigured
                            ? (_showFullAccountNumber
                                ? currentAccNum
                                : _getMaskedAccountNumber(currentAccNum))
                            : "Tap edit icon or fill below to enter bank details",
                        style: GoogleFonts.outfit(
                          color: isConfigured ? const Color(0xFFFFD700) : Colors.white70,
                          fontSize: isConfigured ? 16 : 13,
                          fontWeight: isConfigured ? FontWeight.w600 : FontWeight.normal,
                          letterSpacing: isConfigured ? 1.5 : 0.2,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "SETTLEMENT CYCLE",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "$_payoutFrequency Auto (11:59 PM)",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "PRIMARY UPI",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentUpi.isNotEmpty ? currentUpi : "Not configured",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Primary Bank Account Details
                Text(
                  "Primary Bank Account",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                _buildDetailTile(
                  label: "Account Holder Name",
                  controller: _holderController,
                  icon: Icons.person_outline,
                  enabled: _isEditing,
                  hintText: "Enter full account holder name",
                ),

                _buildDetailTile(
                  label: "Bank Name",
                  controller: _bankNameController,
                  icon: Icons.account_balance_outlined,
                  enabled: _isEditing,
                  hintText: "Enter bank name (e.g. HDFC Bank)",
                ),

                _buildDetailTile(
                  label: "Account Number",
                  controller: _accountNumberController,
                  icon: Icons.credit_card_outlined,
                  enabled: _isEditing,
                  hintText: "Enter bank account number",
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  displayText: (!_isEditing && !_showFullAccountNumber)
                      ? _getMaskedAccountNumber(_accountNumberController.text)
                      : null,
                  trailingWidget: !_isEditing
                      ? IconButton(
                          icon: Icon(
                            _showFullAccountNumber
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _showFullAccountNumber = !_showFullAccountNumber;
                            });
                          },
                        )
                      : null,
                ),

                _buildDetailTile(
                  label: "IFSC Code",
                  controller: _ifscController,
                  icon: Icons.qr_code_2_outlined,
                  enabled: _isEditing,
                  hintText: "e.g. HDFC0001234",
                  textCapitalization: TextCapitalization.characters,
                ),

                // Account Type Selection
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.white : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isEditing ? const Color(0xFF1E9C1C) : Colors.grey.shade200,
                      width: _isEditing ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_tree_outlined, color: Color(0xFF1E9C1C), size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Account Type",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _isEditing
                                ? DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _accountType,
                                      isDense: true,
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0F172A),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: "Savings Account",
                                          child: Text("Savings Account"),
                                        ),
                                        DropdownMenuItem(
                                          value: "Current Account",
                                          child: Text("Current Account"),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => _accountType = val);
                                        }
                                      },
                                    ),
                                  )
                                : Text(
                                    _accountType,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Primary",
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E9C1C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Instant UPI Section
                Text(
                  "Instant UPI Transfer",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                _buildDetailTile(
                  label: "UPI VPA ID",
                  controller: _upiController,
                  icon: Icons.bolt_outlined,
                  enabled: _isEditing,
                  hintText: "e.g. mobile@upi or name@okaxis",
                  trailingBadge: "Fast Transfer",
                ),

                const SizedBox(height: 24),

                // Payout Preferences
                Text(
                  "Payout Preferences",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.schedule, color: Color(0xFF1E9C1C), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Payout Schedule",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          _isEditing
                              ? DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _payoutFrequency,
                                    isDense: true,
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E9C1C),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: "Daily", child: Text("Daily Settlement")),
                                      DropdownMenuItem(value: "Weekly", child: Text("Weekly Settlement")),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) {
                                        setState(() => _payoutFrequency = val);
                                      }
                                    },
                                  ),
                                )
                              : Text(
                                  "$_payoutFrequency Settlement",
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E9C1C),
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.currency_rupee, color: Color(0xFF1E9C1C), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Minimum Threshold",
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          Text(
                            "₹100 (Default)",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Bank-Grade Security Disclaimer
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.security, color: Color(0xFF1E9C1C), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Your account details are secured with 256-bit bank-grade encryption and will strictly be used to credit delivery earnings and daily tips.",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Save button if editing
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E9C1C),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Save Bank Details",
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTile({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    String? hintText,
    String? displayText,
    String? trailingBadge,
    Widget? trailingWidget,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: enabled ? const Color(0xFF1E9C1C) : Colors.grey.shade200,
          width: enabled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E9C1C), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                enabled
                    ? TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        inputFormatters: inputFormatters,
                        textCapitalization: textCapitalization,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: hintText,
                          hintStyle: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.grey.shade400,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        displayText ?? (controller.text.isNotEmpty ? controller.text : "Not provided"),
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: controller.text.isNotEmpty
                              ? const Color(0xFF0F172A)
                              : Colors.grey.shade400,
                        ),
                      ),
              ],
            ),
          ),
          ?trailingWidget,
          if (trailingBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trailingBadge,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E9C1C),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
