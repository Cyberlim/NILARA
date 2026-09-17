import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../services/settings_service.dart';
import '../widgets/create_ticket_dialog.dart';
import 'chat_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    final token = await user.getIdToken();

    final baseUrl = SettingsService.activeBaseUrl.isNotEmpty
        ? SettingsService.activeBaseUrl
        : '${Constants.baseUrl}/api/v1';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _tickets = data['tickets'] ?? [];
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCreateTicketDialog() {
    showCreateTicketDialog(
      context,
      onTicketCreated: _fetchTickets,
    );
  }

  String _formatTicketDate(dynamic dateString) {
    if (dateString == null) return '';
    final dt = DateTime.tryParse(dateString.toString())?.toLocal();
    if (dt == null) return '';

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');

    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} • $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final openTickets = _tickets.where((t) => (t['status'] ?? 'open') == 'open').toList();
    final closedTickets = _tickets.where((t) => (t['status'] ?? '') == 'closed' || (t['status'] ?? '') == 'history').toList();

    Widget buildEmptyState(String title, String subtitle) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF168BDB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  size: 40,
                  color: Color(0xFF168BDB),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF168BDB).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _showCreateTicketDialog,
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  label: Text(
                    "Create Ticket",
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildTicketList(List<dynamic> list, String emptyTitle, String emptySubtitle) {
      if (list.isEmpty) {
        return buildEmptyState(emptyTitle, emptySubtitle);
      }

      return RefreshIndicator(
        onRefresh: _fetchTickets,
        color: const Color(0xFF168BDB),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final ticket = list[index];
            final isOpen = (ticket['status'] ?? 'open') == 'open';
            final subject = ticket['subject'] ?? 'No Subject';
            final lastMessage = ticket['lastMessage'] != null ? ticket['lastMessage']['text'] : null;
            final createdAt = ticket['createdAt'];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          ticketId: ticket['_id'],
                          ticketSubject: subject,
                          isClosed: !isOpen,
                        ),
                      ),
                    ).then((_) => _fetchTickets());
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row with Subject and Status Pill
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                subject,
                                style: GoogleFonts.outfit(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isOpen
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isOpen
                                      ? const Color(0xFFA7F3D0)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isOpen
                                          ? const Color(0xFF059669)
                                          : const Color(0xFF64748B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    isOpen ? 'Open' : 'Closed',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: isOpen
                                          ? const Color(0xFF059669)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        if (lastMessage != null && lastMessage.toString().trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            lastMessage.toString(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.3,
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),

                        // Timestamp and Chat Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade400),
                                const SizedBox(width: 5),
                                Text(
                                  _formatTicketDate(createdAt),
                                  style: GoogleFonts.outfit(
                                    fontSize: 11.5,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  isOpen ? "Open Chat" : "View History",
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF168BDB),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 12,
                                  color: Color(0xFF168BDB),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: Text(
            "My Support Tickets",
            style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black87),
          bottom: TabBar(
            indicatorColor: const Color(0xFF168BDB),
            indicatorWeight: 3,
            labelColor: const Color(0xFF168BDB),
            unselectedLabelColor: Colors.grey.shade600,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Active Tickets"),
                    if (openTickets.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF168BDB).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "${openTickets.length}",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF168BDB),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(text: "Resolved History"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF168BDB)))
            : TabBarView(
                children: [
                  buildTicketList(
                    openTickets,
                    "No Active Tickets",
                    "Everything is running smoothly! If you need help with deliveries or billing, raise a ticket.",
                  ),
                  buildTicketList(
                    closedTickets,
                    "No Resolved Tickets",
                    "Previously closed and resolved support tickets will appear here.",
                  ),
                ],
              ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF168BDB).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: _showCreateTicketDialog,
            backgroundColor: Colors.transparent,
            elevation: 0,
            highlightElevation: 0,
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            label: Text(
              "New Ticket",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
