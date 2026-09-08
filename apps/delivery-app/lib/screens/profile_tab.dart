import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import 'profile_information_screen.dart';
import 'vehicle_information_screen.dart';
import 'bank_details_screen.dart';
import 'help_support_screen.dart';
import 'settings_preferences_screen.dart';
import 'login_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  String _formatJoinedDate(UserProfile? user) {
    if (user == null) return "";
    DateTime? dt;
    final deliveryDetails = user.deliveryDetails;
    if (deliveryDetails != null &&
        deliveryDetails['joinedDate'] != null &&
        deliveryDetails['joinedDate'].toString().trim().isNotEmpty) {
      dt = DateTime.tryParse(deliveryDetails['joinedDate'].toString().trim());
    }
    if (dt == null && user.createdAt != null && user.createdAt!.isNotEmpty) {
      dt = DateTime.tryParse(user.createdAt!);
    }
    if (dt != null) {
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return "Joined ${dt.day} ${months[dt.month - 1]} ${dt.year}";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              child: Text(
                "Profile",
                style: GoogleFonts.outfit(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ),
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
                    ValueListenableBuilder<UserProfile?>(
                      valueListenable: UserService().currentUser,
                      builder: (context, user, _) {
                        final hasPhoto = user?.photoUrl != null && user!.photoUrl!.isNotEmpty;
                        return Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Color(0xFF1E9C1C), shape: BoxShape.circle),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: const Color(0xFFE8F5E9),
                            backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
                            child: hasPhoto ? null : const Icon(Icons.person, size: 40, color: Color(0xFF1E9C1C)),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueListenableBuilder(
                            valueListenable: UserService().currentUser,
                            builder: (context, user, _) {
                              final shortId = (user != null && user.id.length > 6)
                                  ? user.id.substring(user.id.length - 6).toUpperCase()
                                  : (user?.id ?? '000000');
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(user?.name ?? "", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, color: Color(0xFF1E9C1C), size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text("Partner ID: #$shortId", style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                                  const SizedBox(height: 2),
                                  Text(user?.phone ?? "", style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                                  if (_formatJoinedDate(user).isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(_formatJoinedDate(user), style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF1E9C1C), fontWeight: FontWeight.w600)),
                                  ],
                                ],
                              );
                            }
                          ),
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
              subtitle: "Vehicle category, registration & RC status",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VehicleInformationScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.account_balance_outlined,
              title: "Bank & Payout Details",
              subtitle: "Linked bank accounts & UPI IDs",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BankDetailsScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.help_outline,
              title: "Help & Delivery Support",
              subtitle: "24x7 helpline & partner FAQs",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: "Settings & Preferences",
              subtitle: "Navigation maps & order alert tones",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPreferencesScreen(),
                  ),
                );
              },
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
}
