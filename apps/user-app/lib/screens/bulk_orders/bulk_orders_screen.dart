import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bulk_20l_jar_screen.dart';
import 'bulk_carton_screen.dart';

class BulkOrdersScreen extends StatelessWidget {
  const BulkOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80), // Taller app bar for subtitle
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bulk Orders",
                style: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                "Order large quantities of water for homes, offices and events.",
                style: GoogleFonts.outfit(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            // Animated/Text Hero Banner instead of milk banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF006DFF), Color(0xFF0258C9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF006DFF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "PREMIUM HYDRATION",
                      style: GoogleFonts.outfit(color: Colors.blue.shade100, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Bulk Water Solutions\nFor Every Need",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.water_drop, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text("Fast Delivery", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 16),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text("Top Quality", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Bulk Water Supply",
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Delivered on your schedule",
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Card 1: 20L Water Jars
            _buildWaterJarHeroCard(
              context: context,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Bulk20LJarScreen()));
              },
            ),
            
            const SizedBox(height: 16),
            
            // Card 2: Premium Bottle Cartons
            _buildCartonHeroCard(
              context: context,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const BulkCartonScreen()));
              },
            ),
            
            const SizedBox(height: 32),
            
            // Bottom Benefits Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Why order in bulk?",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildBenefitCard(Icons.payments_outlined, "Bulk Pricing"),
                  _buildBenefitCard(Icons.calendar_month_outlined, "Scheduled Delivery"),
                  _buildBenefitCard(Icons.support_agent_outlined, "Dedicated Support"),
                  _buildBenefitCard(Icons.local_shipping_outlined, "Priority Dispatch"),
                  _buildBenefitCard(Icons.card_giftcard_outlined, "Free Delivery on Eligible Orders"),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0288D1), size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterJarHeroCard({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "20L Water Jars",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0D47A1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Perfect for homes, offices, apartments and regular delivery.",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: const Color(0xFF0D47A1),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureRow(Icons.water_drop_outlined, "Reusable Jar"),
                  const SizedBox(height: 6),
                  _buildFeatureRow(Icons.water_drop, "Fresh Purified Water"),
                  const SizedBox(height: 6),
                  _buildFeatureRow(Icons.local_shipping_outlined, "Subscription Available"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D47A1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Order 20L Jars",
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Image.asset(
                  'assets/images/bulk_20l_splash_v2.png',
                  fit: BoxFit.cover,
                  height: 250,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.blue.shade200.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0D47A1), size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF0D47A1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartonHeroCard({
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 200,
              color: const Color(0xFFE8F1FC), // Light blue to match the splash background
              child: Image.asset(
                'assets/images/bulk_carton_splash.png',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              left: 16,
              bottom: 12,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(0, 32),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Order Cartons",
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward, size: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
