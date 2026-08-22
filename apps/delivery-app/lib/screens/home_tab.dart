import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/wallet_service.dart';
import 'new_order_screen.dart';
import 'incentives_screen.dart';

class HomeTab extends StatelessWidget {
  final Function(int)? onSelectTab;

  const HomeTab({super.key, this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hello, Rider 👋", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text("Ready for your next delivery?", style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Earnings Card with Live Shared Wallet Balance!
          ValueListenableBuilder<double>(
            valueListenable: WalletService.instance.balanceNotifier,
            builder: (context, currentBalance, child) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF7B1FA2).withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 4, offset: const Offset(0, 8)),
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
                            Text("Today's Earning Balance", style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text("₹${currentBalance.toStringAsFixed(2)}", style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => onSelectTab?.call(1), // Go to Earnings tab
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withValues(alpha: 0.2), thickness: 1),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildPurpleStatColumn(
                            "6",
                            "Orders Delivered",
                            onTap: () => onSelectTab?.call(2), // Go to Orders tab
                          ),
                        ),
                        Container(height: 35, width: 1, color: Colors.white.withValues(alpha: 0.2)),
                        Expanded(child: _buildPurpleStatColumn("12.4 km", "Distance")),
                        Container(height: 35, width: 1, color: Colors.white.withValues(alpha: 0.2)),
                        Expanded(child: _buildPurpleStatColumn("4h 25m", "Online Time")),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          
          // Quick Actions
          Text("Quick Actions", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionBox(Icons.shopping_bag, "New Order", Colors.green, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NewOrderScreen()));
              }),
              _buildActionBox(Icons.receipt_long, "My Orders", Colors.blue, onTap: () {
                onSelectTab?.call(2); // Take partner to Orders tab in navbar!
              }),
              _buildActionBox(Icons.account_balance_wallet, "Earnings", Colors.purple, onTap: () {
                onSelectTab?.call(1); // Take partner to Earnings tab in navbar!
              }),
              _buildActionBox(Icons.person_outline, "Profile", Colors.orange, onTap: () {
                onSelectTab?.call(3); // Take partner to Profile tab in navbar!
              }),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Incentives Banner
          Text("Incentives", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const IncentivesScreen()));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.green.withValues(alpha: 0.1), blurRadius: 15, spreadRadius: 0, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Incentives", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Text("Complete 5 more orders\nand earn ₹200 extra", style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87, height: 1.4)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: const LinearProgressIndicator(
                                  value: 0.5,
                                  backgroundColor: Colors.white,
                                  color: Color(0xFF1E9C1C),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text("5 / 10", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    ),
                    child: Image.asset(
                      'assets/images/gift_box.png',
                      width: 45,
                      height: 45,
                      errorBuilder: (c, e, s) => const Icon(Icons.card_giftcard, color: Color(0xFF1E9C1C), size: 36),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Performance Box
          Text("Performance", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, spreadRadius: 0, offset: const Offset(0, 8)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Rating", style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text("4.8 ", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const Icon(Icons.star, color: Colors.amber, size: 22),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.grey.shade200),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Completion Rate", style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text("95%", style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(width: 4),
                            const Icon(Icons.trending_up, color: Color(0xFF1E9C1C), size: 22),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPurpleStatColumn(String val, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(val, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildActionBox(IconData icon, String label, Color iconColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: iconColor.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
