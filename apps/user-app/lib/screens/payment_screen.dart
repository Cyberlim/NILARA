import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/wallet_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/address_service.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final double totalAmount;
  final String deliveryAddressId;
  final String? deliveryTimePref;

  const PaymentScreen({
    Key? key,
    required this.totalAmount,
    required this.deliveryAddressId,
    this.deliveryTimePref,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0; // 0=GPay, 1=PhonePe, 2=Paytm, 3=Card, 4=COD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Payment Options",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6FB353), Color(0xFF4CA04B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "To Pay",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "₹",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.totalAmount.toStringAsFixed(0),
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            ValueListenableBuilder<WalletState>(
              valueListenable: WalletService().wallet,
              builder: (context, walletState, child) {
                final bool hasEnoughBalance = walletState.balance >= widget.totalAmount;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nilara Wallet",
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: hasEnoughBalance ? () => setState(() => _selectedMethod = 5) : null, // 5 = Nilara Wallet
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedMethod == 5 ? Colors.blue.withOpacity(0.05) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedMethod == 5 ? const Color(0xFF168BDB) : Colors.grey.shade200,
                            width: _selectedMethod == 5 ? 2 : 1,
                          ),
                          boxShadow: _selectedMethod == 5
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF168BDB).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.account_balance_wallet, color: Color(0xFF168BDB)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Pay using Wallet",
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: hasEnoughBalance ? Colors.black87 : Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Balance: ₹${walletState.balance.toStringAsFixed(0)}",
                                    style: GoogleFonts.outfit(
                                      color: hasEnoughBalance ? Colors.green : Colors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedMethod == 5)
                              const Icon(Icons.check_circle, color: Color(0xFF168BDB)),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
            
            const SizedBox(height: 32),
            
            Text(
              "Preferred UPI Apps",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // GPay
            _buildUpiCard(
              index: 0,
              brandName: "Google Pay",
              accentColor: Colors.blue.shade600,
              iconLetter: "G",
              tagline: "Pay via any bank account",
            ),
            const SizedBox(height: 12),
            
            // PhonePe
            _buildUpiCard(
              index: 1,
              brandName: "PhonePe",
              accentColor: const Color(0xFF5f259f), // PhonePe purple
              iconLetter: "P",
              tagline: "UPI, Wallet & more",
            ),
            const SizedBox(height: 12),
            
            // Paytm
            _buildUpiCard(
              index: 2,
              brandName: "Paytm",
              accentColor: const Color(0xFF00baf2), // Paytm light blue
              iconLetter: "₹",
              tagline: "Wallet or UPI",
            ),
            
            const SizedBox(height: 32),
            Text(
              "More Options",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildGenericOption(
              index: 3,
              icon: Icons.credit_card,
              title: "Credit / Debit Card",
              subtitle: "Visa, MasterCard, RuPay, Maestro",
            ),
            const SizedBox(height: 12),
            _buildGenericOption(
              index: 4,
              icon: Icons.money,
              title: "Cash on Delivery",
              subtitle: "Pay cash at the time of delivery",
            ),
            
            const SizedBox(height: 40), // Bottom padding
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () async {
              // Call API to create order
              String payMethod = _selectedMethod == 4 ? 'cod' : 'online';

              final success = await OrderService().checkout(
                items: CartService().items.value,
                deliveryAddressId: widget.deliveryAddressId,
                paymentMethod: payMethod,
                deliveryTimePref: widget.deliveryTimePref,
              );

              if (success) {
                if (_selectedMethod == 5) {
                  // Deduct from wallet if online and via wallet
                  WalletService().deductFunds(widget.totalAmount, "Order Payment");
                }
                CartService().clear();
                
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaymentSuccessScreen(),
                    ),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to place order. Please try again.")),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6FB353),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              "PAY ₹${widget.totalAmount.toStringAsFixed(0)}",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpiCard({
    required int index,
    required String brandName,
    required Color accentColor,
    required String iconLetter,
    required String tagline,
  }) {
    bool isSelected = _selectedMethod == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  iconLetter,
                  style: GoogleFonts.outfit(
                    color: accentColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brandName,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tagline,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericOption({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    bool isSelected = _selectedMethod == index;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.withOpacity(0.1) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.green : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey.shade400,
                  width: isSelected ? 6 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
