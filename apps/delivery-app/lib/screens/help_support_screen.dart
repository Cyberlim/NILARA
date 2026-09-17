import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'ticket_list_screen.dart';
import '../services/user_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  String get _apiUrl => UserService.baseUrl;

  String _bannerTitle = 'Partner Support Desk';
  String _bannerSubtitle =
      '24x7 Dedicated assistance for delivery issues, payouts, app bugs, and emergency rider safety.';
  String _statusText = 'Support Live';
  bool _isLive = true;
  String _helplineNumber = '1800-102-9999';
  String _helplineTiming = 'Toll Free 24x7';
  String _supportEmail = 'partner-support@nilara.com';
  String _emergencyNumber = '1800-102-9999';
  String _emergencyDescription = 'Immediate on-road safety assistance';

  List<Map<String, String>> _faqs = [
    {
      'question': 'When will my daily delivery earnings be credited?',
      'answer':
          'Your daily delivery fees, tips, and distance incentives are settled every night at 11:59 PM and automatically credited to your registered primary bank account or UPI ID by the next morning.',
    },
    {
      'question': 'What should I do if a customer is unreachable?',
      'answer':
          'Call the customer using the in-app call button. If the customer does not respond after 3 attempts or 5 minutes, tap "Customer Unreachable" in the order details or raise a quick support ticket to safely return the order to your dark store hub.',
    },
    {
      'question': 'How can I update my Vehicle RC or Driving License?',
      'answer':
          'Go to your Profile tab > Vehicle Information. You can view your registered details and upload a clear photo of your updated Registration Certificate (RC) anytime.',
    },
    {
      'question': 'How does the Online / Offline shift toggle work?',
      'answer':
          'Toggle the shift status on the top right of your home dashboard. When you are "Online", the system automatically assigns nearby orders from your dark store hub. Switch to "Offline" when you wish to take a break.',
    },
    {
      'question': 'Do I keep 100% of customer tips?',
      'answer':
          'Yes! Nilara passes 100% of customer tips directly to delivery partners with zero platform commission. Tips are credited with your daily order settlement.',
    },
    {
      'question': 'How are daily incentives and peak bonuses calculated?',
      'answer':
          'You earn extra bonuses by completing daily milestones (e.g. 15 orders for ₹150 extra, 25 orders for ₹300 extra) during lunch and dinner peak hours. Check the "Incentives & Bonuses" section in the drawer for active schemes.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchDeliverySupport();
  }

  Future<void> _fetchDeliverySupport() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiUrl/settings/delivery-support'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final s = data['data'];
          if (mounted) {
            setState(() {
              _bannerTitle = s['bannerTitle'] ?? _bannerTitle;
              _bannerSubtitle = s['bannerSubtitle'] ?? _bannerSubtitle;
              _statusText = s['statusText'] ?? _statusText;
              _isLive = s['isLive'] ?? _isLive;
              _helplineNumber = s['helplineNumber'] ?? _helplineNumber;
              _helplineTiming = s['helplineTiming'] ?? _helplineTiming;
              _supportEmail = s['supportEmail'] ?? _supportEmail;
              _emergencyNumber = s['emergencyNumber'] ?? _emergencyNumber;
              _emergencyDescription =
                  s['emergencyDescription'] ?? _emergencyDescription;
              if (s['faqs'] != null && s['faqs'] is List && (s['faqs'] as List).isNotEmpty) {
                _faqs = (s['faqs'] as List).map<Map<String, String>>((item) {
                  return {
                    'question': (item['question'] ?? '').toString(),
                    'answer': (item['answer'] ?? '').toString(),
                  };
                }).toList();
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Failed to load delivery support settings: $e");
    }
  }

  Future<void> _launchPhone(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri uri = Uri(scheme: 'tel', path: clean);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showCopySnackbar("Helpline: $phone");
      }
    } catch (_) {
      _showCopySnackbar("Helpline: $phone");
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'Nilara Delivery Partner Support Request'},
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showCopySnackbar("Email: $email");
      }
    } catch (_) {
      _showCopySnackbar("Email: $email");
    }
  }

  void _showCopySnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.outfit(color: Colors.white)),
          backgroundColor: const Color(0xFF1E9C1C),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSosDialog() {
    final cleanPhone = _emergencyNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFFFEBEE), shape: BoxShape.circle),
              child: const Icon(Icons.sos, color: Colors.redAccent, size: 28),
            ),
            const SizedBox(width: 12),
            Text(
              "Emergency SOS",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          "$_emergencyDescription\n\nAre you in an accident or critical emergency during delivery?\n\nOur 24x7 dedicated emergency safety unit will connect with you immediately.",
          style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _launchPhone(cleanPhone.isNotEmpty ? cleanPhone : "18001029999");
            },
            icon: const Icon(Icons.phone, color: Colors.white, size: 16),
            label: Text("Call SOS ($_emergencyNumber)", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Help & Delivery Support",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchDeliverySupport,
        color: const Color(0xFF1E9C1C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Status Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.support_agent, color: Color(0xFF4ADE80), size: 28),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isLive 
                                ? const Color(0xFF1E9C1C).withValues(alpha: 0.2) 
                                : Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isLive 
                                  ? const Color(0xFF4ADE80).withValues(alpha: 0.4) 
                                  : Colors.grey.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _isLive ? const Color(0xFF4ADE80) : Colors.grey, 
                                  shape: BoxShape.circle
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isLive ? _statusText : "Offline",
                                style: GoogleFonts.outfit(
                                  color: _isLive ? const Color(0xFF4ADE80) : Colors.grey.shade400,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _bannerTitle,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bannerSubtitle,
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Quick Support Channels
              Text(
                "Support Channels",
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),

              // 1. My Support Tickets (Real-time chat)
              _buildSupportOption(
                icon: Icons.confirmation_number_outlined,
                iconBgColor: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF1E9C1C),
                title: "My Support Tickets & Chat",
                subtitle: "Raise a ticket or chat live with an executive",
                badgeText: "Real-time",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TicketListScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 2. Toll-Free Helpline
              _buildSupportOption(
                icon: Icons.phone_in_talk_outlined,
                iconBgColor: const Color(0xFFE0F2FE),
                iconColor: const Color(0xFF0284C7),
                title: "Partner Helpline",
                subtitle: "$_helplineNumber • $_helplineTiming",
                onTap: () => _launchPhone(_helplineNumber),
              ),

              const SizedBox(height: 12),

              // 3. Email Support Desk
              _buildSupportOption(
                icon: Icons.email_outlined,
                iconBgColor: const Color(0xFFF3E8FF),
                iconColor: const Color(0xFF9333EA),
                title: "Email Partner Desk",
                subtitle: _supportEmail,
                onTap: () => _launchEmail(_supportEmail),
              ),

              const SizedBox(height: 12),

              // 4. Emergency SOS
              _buildSupportOption(
                icon: Icons.sos_outlined,
                iconBgColor: const Color(0xFFFFEBEE),
                iconColor: Colors.redAccent,
                title: "Emergency SOS / Accident Helpline",
                subtitle: _emergencyDescription,
                badgeText: "Emergency",
                badgeColor: Colors.redAccent,
                onTap: _showSosDialog,
              ),

              const SizedBox(height: 28),

              // Frequently Asked Questions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Partner FAQs",
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                  ),
                  Text(
                    "${_faqs.length} Answers",
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ..._faqs.map((faq) => _buildFaqItem(faq['question'] ?? '', faq['answer'] ?? '')),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportOption({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (badgeColor ?? const Color(0xFF1E9C1C)).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badgeText,
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor ?? const Color(0xFF1E9C1C),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
        title: Text(
          question,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF0F172A)),
        ),
        iconColor: const Color(0xFF1E9C1C),
        collapsedIconColor: Colors.grey.shade500,
        shape: const Border(),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
