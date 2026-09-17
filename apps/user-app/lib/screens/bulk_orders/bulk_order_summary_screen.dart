import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bulk_success_screen.dart';
import '../../services/bulk_order_service.dart';

class BulkOrderSummaryScreen extends StatefulWidget {
  final String productName;
  final int quantity;
  final double totalPrice;
  final String deliveryDate;
  final String timeSlot;
  final Map<String, dynamic>? selectedAddress;
  final String? specialInstructions;
  final Map<String, dynamic>? customDesign;

  const BulkOrderSummaryScreen({
    super.key,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
    required this.deliveryDate,
    required this.timeSlot,
    this.selectedAddress,
    this.specialInstructions,
    this.customDesign,
  });

  @override
  State<BulkOrderSummaryScreen> createState() => _BulkOrderSummaryScreenState();
}

class _BulkOrderSummaryScreenState extends State<BulkOrderSummaryScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final double deliveryCharges = 0.0;
    final double grandTotal = widget.totalPrice + deliveryCharges;
    final bool isJar = widget.productName.contains('Jar');
    final String imagePath = isJar ? 'assets/images/20L daily bulk .png' : 'assets/images/qb4.jpg';

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
          "Order Summary",
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
            // Order Details Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.asset(imagePath, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.image)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productName,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${widget.quantity} items",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "₹${widget.totalPrice.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(),
                  ),
                  _buildSummaryRow("Delivery Frequency", "One Time"),
                  _buildSummaryRow("Delivery Date", widget.deliveryDate),
                  _buildSummaryRow("Time Slot", widget.timeSlot),
                  if (widget.selectedAddress != null)
                    _buildSummaryRow("Delivery Address", "${widget.selectedAddress!['title']}\n${widget.selectedAddress!['addressLine1']}, ${widget.selectedAddress!['city']}, ${widget.selectedAddress!['state']} ${widget.selectedAddress!['postalCode']}"),
                  if (widget.specialInstructions != null && widget.specialInstructions!.isNotEmpty)
                    _buildSummaryRow("Instructions", widget.specialInstructions!),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(),
                  ),
                  
                  _buildPriceRow("Sub Total", widget.totalPrice),
                  _buildPriceRow("Delivery Charges", deliveryCharges, isFree: true),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(),
                  ),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "₹${grandTotal.toStringAsFixed(2)}",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "(incl. all taxes)",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            

            
            const SizedBox(height: 100), // Padding for bottom bar
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    setState(() {
                      _isLoading = true;
                    });
                    
                    final success = await BulkOrderService().createBulkOrder(
                      productName: widget.productName,
                      quantity: widget.quantity,
                      totalPrice: widget.totalPrice,
                      deliveryDate: widget.deliveryDate,
                      timeSlot: widget.timeSlot,
                      paymentMethod: "Pay Later",
                      specialInstructions: widget.specialInstructions,
                      address: widget.selectedAddress,
                      customDesign: widget.customDesign,
                    );
                    
                    setState(() {
                      _isLoading = false;
                    });
                    
                    if (success) {
                      if (!mounted) return;
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => BulkSuccessScreen(
                            deliveryDate: widget.deliveryDate,
                            timeSlot: widget.timeSlot,
                          ),
                        )
                      );
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to place bulk order. Please try again.')),
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
                        "Submit Order Request",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Admin will review and confirm token money",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            isFree ? "Free" : "₹${amount.toStringAsFixed(2)}",
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isFree ? Colors.green.shade600 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
