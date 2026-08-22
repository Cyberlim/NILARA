import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_information_screen.dart';
import 'vehicle_information_screen.dart';
import 'login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Profile",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF1E9C1C)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileInformationScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Avatar & Info Header Card
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileInformationScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Color(0xFF1E9C1C), shape: BoxShape.circle),
                      child: const CircleAvatar(
                        radius: 32,
                        backgroundColor: Color(0xFFE8F5E9),
                        child: Icon(Icons.person, size: 40, color: Color(0xFF1E9C1C)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text("Rahul Sharma", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: Color(0xFF1E9C1C), size: 16),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text("Partner ID: #BLK-89042", style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 2),
                          Text("+91 98765 43210", style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black45),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Performance Stats Box
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("4.9 ", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Rating (520+ orders)", style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  Container(height: 40, width: 1, color: Colors.grey.shade200),
                  Expanded(
                    child: Column(
                      children: [
                        Text("95%", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text("Completion Rate", style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 26),
            
            // Profile Navigation Menu Items
            _buildMenuItem(
              icon: Icons.person_outline,
              title: "Personal Information",
              subtitle: "Name, contact, DOB & emergency info",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileInformationScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.directions_car_outlined,
              title: "Vehicle Information",
              subtitle: "EV model, registration & RC status",
              badgeText: "EV Active",
              badgeColor: const Color(0xFF1E9C1C),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehicleInformationScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.description_outlined,
              title: "Documents & Insurance",
              subtitle: "DL, RC, Health & Bike Insurance",
              badgeText: "Verified",
              badgeColor: Colors.blue,
              onTap: () => _showDialogInfo(context, "Documents & Insurance", "✔ Driving License: Active\n✔ Vehicle RC: Verified\n✔ Medical & Health Insurance: Active up to ₹5,000,000"),
            ),
            _buildMenuItem(
              icon: Icons.account_balance_outlined,
              title: "Bank & Payout Details",
              subtitle: "Linked bank accounts & UPI IDs",
              onTap: () => _showDialogInfo(context, "Bank Details", "Primary Account: HDFC Bank (•••• 4321)\nSecondary: ICICI Bank (•••• 8765)\nUPI VPA: rahul@okaxis"),
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: "Help & Delivery Support",
              subtitle: "24x7 helpline & partner FAQs",
              onTap: () => _showDialogInfo(context, "Partner Support", "Support Desk Status: Live 🟢\nHelpline: 1800-102-9999\nEmail: partner-support@blinkit.com"),
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: "Settings & Preferences",
              subtitle: "Navigation maps, language & alert tones",
              onTap: () => _showDialogInfo(context, "Settings", "Default Navigation: Google Maps\nLanguage: English\nAlert Tone: Loud Ring\nOrder Auto Accept: OFF"),
            ),
            _buildMenuItem(
              icon: Icons.logout_outlined,
              title: "Logout",
              subtitle: "Sign out of your partner account",
              isLogout: true,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
    String? badgeText,
    Color badgeColor = Colors.orange,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isLogout ? Colors.red.shade50 : const Color(0xFF1E9C1C).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isLogout ? Colors.red : const Color(0xFF1E9C1C), size: 22),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  color: isLogout ? Colors.red : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (badgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
          ],
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600),
        ),
        trailing: isLogout ? null : const Icon(Icons.chevron_right, color: Colors.black45, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showDialogInfo(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Text(content, style: GoogleFonts.outfit(fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close", style: GoogleFonts.outfit(color: const Color(0xFF1E9C1C), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
