import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/bulk_order_service.dart';

class TokenPaymentScreen extends StatefulWidget {
  final String orderId;
  final String productName;
  final num advancePayment;
  final String rawOrderId;

  const TokenPaymentScreen({
    super.key,
    required this.orderId,
    required this.productName,
    required this.advancePayment,
    required this.rawOrderId,
  });

  @override
  State<TokenPaymentScreen> createState() => _TokenPaymentScreenState();
}

class _TokenPaymentScreenState extends State<TokenPaymentScreen> {
  String _selectedPaymentMethod = 'upi';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'upi',
      'title': 'UPI',
      'subtitle': 'Pay using any UPI app',
      'icon': Icons.qr_code_scanner,
    },
    {
      'id': 'card',
      'title': 'Credit / Debit Card',
      'subtitle': 'Visa, Mastercard, Rupay, etc.',
      'icon': Icons.credit_card,
    },
    {
      'id': 'wallet',
      'title': 'Nilara Wallet',
      'subtitle': 'Available Balance ₹245.00',
      'icon': Icons.account_balance_wallet,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Pay Advance Token",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order ID: ${widget.orderId}",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.productName,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Advance Token Amount",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "₹${widget.advancePayment.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0258C9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Payment Method",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            
            // Payment Methods
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _paymentMethods.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final method = _paymentMethods[index];
                  final isSelected = _selectedPaymentMethod == method['id'];
                  
                  return InkWell(
                    onTap: () => setState(() => _selectedPaymentMethod = method['id']),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      color: isSelected ? Colors.blue.shade50.withOpacity(0.5) : Colors.transparent,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(method['icon'], color: Colors.black87, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['title'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  method['subtitle'],
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: Color(0xFF0288D1))
                          else
                            Icon(Icons.radio_button_unchecked, color: Colors.grey.shade300),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () async {
                setState(() {
                  _isLoading = true;
                });
                
                final success = await BulkOrderService().payTokenAdvance(widget.rawOrderId);
                
                setState(() {
                  _isLoading = false;
                });
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment Successful! Order is now Processing.')),
                  );
                  Navigator.pop(context, true); // true indicates success
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment failed. Please try again.')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0288D1),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    "Pay ₹${widget.advancePayment.toStringAsFixed(2)}",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
