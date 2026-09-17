import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bulk_delivery_details_screen.dart';

class BulkCartonScreen extends StatefulWidget {
  const BulkCartonScreen({super.key});

  @override
  State<BulkCartonScreen> createState() => _BulkCartonScreenState();
}

class _BulkCartonScreenState extends State<BulkCartonScreen> {
  int _quantity = 10;
  String _selectedSize = '500ml';
  
  final Map<String, Map<String, dynamic>> _sizeDetails = {
    '250ml': {
      'info': '24 Bottles / Carton',
      'price': 150.0,
    },
    '500ml': {
      'info': '24 Bottles / Carton',
      'price': 180.0,
    },
    '1L': {
      'info': '12 Bottles / Carton',
      'price': 160.0,
    },
    '2L': {
      'info': '9 Bottles / Carton',
      'price': 190.0,
    },
  };

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _sizeDetails[_selectedSize]!;
    final double cartonPrice = details['price'];
    final double totalPrice = _quantity * cartonPrice;

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
          "Premium Bottle Cartons",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          // Background Product Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: Image.asset(
                'assets/images/bulk_carton_splash_v3.jpg',
                fit: BoxFit.contain,
                height: 280,
              ),
            ),
          ),
          
          // Foreground Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                const SizedBox(height: 250),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Choose Bottle Size
                      Text(
                        "Choose Bottle Size",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: _sizeDetails.keys.map((size) {
                          final isSelected = _selectedSize == size;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedSize = size),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF0258C9) : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF0258C9) : Colors.grey.shade200,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  size,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Number of Cartons
                      Text(
                        "Number of Cartons",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  iconSize: 18,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.remove),
                                  onPressed: _quantity > 1 ? _decrementQuantity : null,
                                  color: _quantity > 1 ? Colors.black87 : Colors.grey,
                                ),
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    "$_quantity",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  iconSize: 18,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.add),
                                  onPressed: _incrementQuantity,
                                  color: Colors.black87,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "Cartons",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),

                      // Bottles per Carton Info
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "Bottles per Carton",
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            ..._sizeDetails.entries.map((entry) {
                              final size = entry.key;
                              final info = entry.value['info'] as String;
                              final isSelected = _selectedSize == size;
                              
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      size,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      info,
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom + 8 : 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "₹${totalPrice.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "Total",
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => BulkDeliveryDetailsScreen(
                                productName: "$_selectedSize Premium Carton",
                                quantity: _quantity,
                                totalPrice: totalPrice,
                              ),
                            )
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0258C9),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Continue",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
