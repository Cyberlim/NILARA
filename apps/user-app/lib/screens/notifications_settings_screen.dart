import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends State<NotificationsSettingsScreen> {
  bool pushNotifications = true;
  bool orderUpdates = true;
  bool promotionalOffers = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        children: [
          _buildToggleItem(
            "Push Notifications",
            "Receive alerts on your device",
            pushNotifications,
            (val) => setState(() => pushNotifications = val),
          ),

          if (pushNotifications) ...[
            _buildToggleItem(
              "Order Updates",
              "Get notified about your delivery status",
              orderUpdates,
              (val) => setState(() => orderUpdates = val),
            ),
            _buildToggleItem(
              "Promotional Offers",
              "Be the first to know about discounts",
              promotionalOffers,
              (val) => setState(() => promotionalOffers = val),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleItem(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
        value: value,
        activeColor: const Color(0xFF168BDB),
        onChanged: onChanged,
      ),
    );
  }
}
