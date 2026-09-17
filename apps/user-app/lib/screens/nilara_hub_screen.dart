import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NilaraHubScreen extends StatelessWidget {
  const NilaraHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Light background to make white cards pop
      body: Stack(
        children: [
          // Background Header with Splash Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F2FB), // Very light blue
                image: DecorationImage(
                  image: AssetImage('assets/images/bulk_20l_splash_v2.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "NILARA",
                        style: GoogleFonts.outfit(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0258C9),
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        "Pure Water. Trusted Delivery.",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0258C9),
                        ),
                      ),
                      const SizedBox(height: 60), // Space for overlay
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                const SizedBox(height: 240), // Push down to overlap banner
                
                // Main Content Card
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F6F9),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Greeting
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("👋", style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Text(
                            "Hello, Harshit",
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "How can we help you today?",
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Grid of Services
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildGrid(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Support Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: _buildSupportCard(),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildGrid() {
    final List<Map<String, dynamic>> items = [
      {'title': 'Contact Support', 'subtitle': 'Get help from our support team', 'icon': Icons.support_agent, 'color': Colors.blue},
      {'title': 'WhatsApp Support', 'subtitle': 'Chat with us', 'icon': Icons.chat, 'color': Colors.green},
      {'title': 'Call Customer Care', 'subtitle': 'Direct phone support', 'icon': Icons.phone, 'color': Colors.blue.shade700},
      {'title': 'Live Chat', 'subtitle': 'Instant assistance', 'icon': Icons.mark_chat_unread, 'color': Colors.orange},
      {'title': 'Water Services', 'subtitle': 'Explore our products', 'icon': Icons.water_drop, 'color': Colors.lightBlue},
      {'title': 'Bulk Orders', 'subtitle': 'Order for events & offices', 'icon': Icons.local_shipping, 'color': Colors.indigo},
      {'title': 'Water Subscription', 'subtitle': 'Manage regular deliveries', 'icon': Icons.calendar_month, 'color': Colors.teal},
      {'title': 'Track Delivery', 'subtitle': 'Live order status', 'icon': Icons.map, 'color': Colors.redAccent},
      {'title': 'Delivery Areas', 'subtitle': 'Check service availability', 'icon': Icons.location_on, 'color': Colors.green.shade600},
      {'title': 'Offers & Rewards', 'subtitle': 'Coupons & loyalty points', 'icon': Icons.card_giftcard, 'color': Colors.pink},
      {'title': 'Find Distributor', 'subtitle': 'Nearest Nilara partners', 'icon': Icons.storefront, 'color': Colors.purple},
      {'title': 'About Nilara', 'subtitle': 'Our story & quality', 'icon': Icons.info_outline, 'color': Colors.cyan},
      {'title': 'Privacy Policy', 'subtitle': 'Your data security', 'icon': Icons.privacy_tip, 'color': Colors.blueGrey},
      {'title': 'Terms & Conditions', 'subtitle': 'Service terms', 'icon': Icons.description, 'color': Colors.brown},
      {'title': 'Rate the App', 'subtitle': 'Share your feedback', 'icon': Icons.star, 'color': Colors.amber},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95, // Adjust for nice card proportions
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildServiceCard(
          title: item['title'],
          subtitle: item['subtitle'],
          icon: item['icon'],
          iconColor: item['color'],
        );
      },
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade400),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2FB), // Light blue background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade100),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            "Need Water Urgently?",
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF1A1A24),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "We're here for you 24/7",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.call, size: 18, color: Color(0xFF0258C9)),
                  label: Text(
                    "Call Now",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0258C9),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF0258C9)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.wechat, size: 18, color: Colors.green),
                  label: Text(
                    "WhatsApp",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
