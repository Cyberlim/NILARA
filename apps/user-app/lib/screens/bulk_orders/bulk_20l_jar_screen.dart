import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bulk_delivery_details_screen.dart';

class Bulk20LJarScreen extends StatefulWidget {
  const Bulk20LJarScreen({super.key});

  @override
  State<Bulk20LJarScreen> createState() => _Bulk20LJarScreenState();
}

class _Bulk20LJarScreenState extends State<Bulk20LJarScreen> {
  int _quantity = 10;
  final double jarPrice = 130.0;
  
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 2) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double totalPrice = _quantity * jarPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Hero Image with Overlay Design
                Container(
                  width: double.infinity,
                  height: 440,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE3F2FD),
                    image: DecorationImage(
                      image: AssetImage('assets/images/bulk_20l_premium_header.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 50.0, right: 120.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "20L Water Jars",
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0B1957),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Fresh, safe & purified\ndrinking water in\nreusable 20L jars.",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: const Color(0xFF0B1957),
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildOverlayFeature(Icons.water_drop_outlined, "Fresh Purified\nWater"),
                          const SizedBox(height: 10),
                          _buildOverlayFeature(Icons.recycling, "Reusable Jar"),
                          const SizedBox(height: 10),
                          _buildOverlayFeature(Icons.local_shipping_outlined, "Daily Delivery\nAvailable"),
                          const SizedBox(height: 10),
                          _buildOverlayFeature(Icons.lock_outline, "Deposit\nApplicable"),
                        ],
                      ),
                    ),
                  ),
                ),
                // Overlapping rounded container effect
                Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nilara 20L Water Jar",
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "₹${jarPrice.toStringAsFixed(2)}",
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            " / Jar",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "(Min. order 2 Jars)",
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPill("Purified"),
                          _buildPill("Safe"),
                          _buildPill("Healthy"),
                          _buildPill("Essential"),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "Product Highlights",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHighlightItem("Advanced 7 Stage Purification"),
                      _buildHighlightItem("Mineral Enriched"),
                      _buildHighlightItem("BIS Certified"),
                      _buildHighlightItem("Food Grade Quality"),
                      _buildHighlightItem("Perfect for daily drinking"),
                      const SizedBox(height: 24),
                      Text(
                        "Customer Ratings & Reviews",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("4.8", style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: List.generate(5, (index) => Icon(
                                  index < 4 || index == 4 ? Icons.star : Icons.star_border, 
                                  color: Colors.amber, 
                                  size: 18,
                                )),
                              ),
                              Text("Based on 2.4k reviews", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildReviewItem("Ravi K.", "Great taste and on-time delivery! The reusable jars are very sturdy."),
                      _buildReviewItem("Priya M.", "Excellent service. I subscribe to daily delivery and it's perfect."),
                    ],
                  ),
                ),
                ), // Close the new overlapping Container
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleIconButton(Icons.arrow_back, () => Navigator.pop(context)),
                Row(
                  children: [
                    _buildCircleIconButton(Icons.favorite_border, () {}),
                    const SizedBox(width: 12),
                    _buildCircleIconButton(Icons.share_outlined, () {}),
                  ],
                ),
              ],
            ),
          ),
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
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "₹${totalPrice.toStringAsFixed(2)}",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
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
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          iconSize: 18,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.remove),
                          onPressed: _quantity > 2 ? _decrementQuantity : null,
                          color: _quantity > 2 ? Colors.black87 : Colors.grey,
                        ),
                        SizedBox(
                          width: 30,
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.add),
                          onPressed: _incrementQuantity,
                          color: Colors.black87,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => BulkDeliveryDetailsScreen(
                                productName: "Nilara 20L Water Jar",
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
                          "Add to Order",
                          style: GoogleFonts.outfit(
                            fontSize: 15,
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

  Widget _buildPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildHighlightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.black54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF0B1957)),
      ),
    );
  }

  Widget _buildOverlayFeature(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0288D1).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0288D1), size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0B1957),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(String name, String review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                child: const Icon(Icons.person, size: 14, color: Colors.black54),
              ),
              const SizedBox(width: 8),
              Text(name, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),
          Text(review, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
