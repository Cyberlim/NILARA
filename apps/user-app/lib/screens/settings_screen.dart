import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/settings_service.dart';
import 'login_screen.dart';
import 'notifications_settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Settings & Support",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: SettingsService().pushNotificationsEnabled,
                    builder: (context, pushNotifications, child) {
                      return SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        title: Text("Notifications", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text("Manage your alerts", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
                        value: pushNotifications,
                        activeColor: const Color(0xFF168BDB),
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.notifications_none, color: Colors.black87),
                        ),
                        onChanged: (val) {
                          SettingsService().pushNotificationsEnabled.value = val;
                        },
                      );
                    }
                  ),
                  const Divider(height: 1),
                  _buildListTile(context, Icons.support_agent, "Help & Support", "Chat or call our support team", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
                  }),
                  const Divider(height: 1),
                  _buildListTile(context, Icons.privacy_tip_outlined, "Privacy Policy", "Terms & conditions", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
                  }),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.info_outline, color: Colors.black87),
                    ),
                    title: Text("About Nilara", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text("Version 1.0.0", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: Text(
                    "Logout",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }
}
