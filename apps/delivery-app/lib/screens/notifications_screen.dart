import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
        title: Text("Notifications", style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationItem(Icons.shopping_bag, Colors.green, "Order Delivered", "You have delivered order\n#CL12345678", "11:30 AM"),
          const SizedBox(height: 24),
          _buildNotificationItem(Icons.workspace_premium, Colors.orange, "Incentive Unlocked", "You have unlocked a new incentive", "10:15 AM"),
          const SizedBox(height: 24),
          _buildNotificationItem(Icons.account_balance_wallet, Colors.green, "Payment Received", "Your payout of ₹1,250 has been\ninitiated", "Yesterday"),
          const SizedBox(height: 24),
          _buildNotificationItem(Icons.receipt_long, Colors.blue, "New Order", "You have a new order", "Yesterday"),
          const SizedBox(height: 24),
          _buildNotificationItem(Icons.system_update, Colors.purple, "System Update", "New update is available", "2 days ago"),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black87,
              side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              "Mark all as read",
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(IconData icon, Color color, String title, String subtitle, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
                  Text(time, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}
