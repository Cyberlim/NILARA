import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/settings_service.dart';
import '../widgets/create_ticket_dialog.dart';
import 'ticket_list_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  @override
  void initState() {
    super.initState();
    SettingsService().fetchSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Help & Support",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ValueListenableBuilder<Map<String, dynamic>>(
        valueListenable: SettingsService().contactSupport,
        builder: (context, contactData, _) {
          return ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: SettingsService().faqs,
            builder: (context, faqsList, _) {
              return RefreshIndicator(
                onRefresh: () => SettingsService().fetchSettings(),
                color: const Color(0xFF168BDB),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "How can we help you?",
                        style: GoogleFonts.outfit(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Our dedicated support team is available to assist you with orders, deliveries, subscriptions, and accounts.",
                        style: GoogleFonts.outfit(fontSize: 13.5, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "Support Options",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildSupportOption(
                        Icons.add_comment_rounded, 
                        "Raise a Support Ticket", 
                        "Start live chat with our team for quick issue resolution",
                        () {
                          showCreateTicketDialog(context);
                        }
                      ),
                      const SizedBox(height: 12),
                      _buildSupportOption(
                        Icons.confirmation_number_outlined, 
                        "My Support Tickets", 
                        contactData['chatResponseTime'] ?? "View your active tickets & chat history",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TicketListScreen()),
                          );
                        }
                      ),
                      const SizedBox(height: 12),
                      _buildSupportOption(
                        Icons.email_outlined, 
                        "Email Us", 
                        contactData['email'] ?? "support@nilara.com",
                        () async {
                          final email = contactData['email'] ?? "support@nilara.com";
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: email,
                          );
                          if (await canLaunchUrl(emailLaunchUri)) {
                            await launchUrl(emailLaunchUri);
                          }
                        }
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Frequently Asked Questions",
                            style: GoogleFonts.outfit(fontSize: 16.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                          ),
                          if (faqsList.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF168BDB).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${faqsList.length} FAQs",
                                style: GoogleFonts.outfit(fontSize: 11.5, fontWeight: FontWeight.w600, color: const Color(0xFF168BDB)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...faqsList.map((faq) => _buildFaqItem(
                        (faq['question'] ?? '').toString(),
                        (faq['answer'] ?? '').toString(),
                      )),
                    ],
                  ),
                ),
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildSupportOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  decoration: BoxDecoration(
                    color: const Color(0xFF168BDB).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF168BDB), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(fontSize: 15.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            question,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF1E293B)),
          ),
          iconColor: const Color(0xFF168BDB),
          collapsedIconColor: Colors.grey.shade500,
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answer,
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
