import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../services/settings_service.dart';
import '../services/order_service.dart';
import '../screens/chat_screen.dart';

/// Displays the attractive Nilara styled Create Ticket Popup Dialog.
Future<void> showCreateTicketDialog(
  BuildContext context, {
  VoidCallback? onTicketCreated,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: CreateTicketDialog(
        onTicketCreated: onTicketCreated,
      ),
    ),
  );
}

class CreateTicketDialog extends StatefulWidget {
  final VoidCallback? onTicketCreated;

  const CreateTicketDialog({
    super.key,
    this.onTicketCreated,
  });

  @override
  State<CreateTicketDialog> createState() => _CreateTicketDialogState();
}

class _CreateTicketDialogState extends State<CreateTicketDialog> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _subjectFocusNode = FocusNode();
  final FocusNode _messageFocusNode = FocusNode();

  bool _isSubmitting = false;
  String? _errorMessage;
  int? _selectedTopicIndex;
  String? _selectedOrderNumber;

  final List<Map<String, dynamic>> _topics = [
    {
      'title': 'Delivery Delay',
      'icon': Icons.local_shipping_outlined,
      'subject': 'Delay in Order Delivery',
    },
    {
      'title': 'Quality & Damage',
      'icon': Icons.verified_outlined,
      'subject': 'Damaged, Leaked or Item Quality Issue',
    },
    {
      'title': 'Missing / Wrong Items',
      'icon': Icons.inventory_2_outlined,
      'subject': 'Missing or Incorrect Item in Order',
    },
    {
      'title': 'Subscription Issue',
      'icon': Icons.calendar_month_outlined,
      'subject': 'Subscription Delivery or Schedule Issue',
    },
    {
      'title': 'Payment & Refund',
      'icon': Icons.account_balance_wallet_outlined,
      'subject': 'Payment Deduction or Refund Inquiry',
    },
    {
      'title': 'Address / Slot Change',
      'icon': Icons.location_on_outlined,
      'subject': 'Request to Update Delivery Address or Slot',
    },
    {
      'title': 'General Support',
      'icon': Icons.help_outline_rounded,
      'subject': 'General Customer Support Request',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (OrderService().orders.value.isEmpty) {
      OrderService().fetchMyOrders();
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    _subjectFocusNode.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onSelectTopic(int index) {
    setState(() {
      if (_selectedTopicIndex == index) {
        _selectedTopicIndex = null;
      } else {
        _selectedTopicIndex = index;
        _subjectController.text = _topics[index]['subject'] as String;
        _errorMessage = null;
      }
    });
  }

  Future<void> _submitTicket() async {
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) {
      setState(() {
        _errorMessage = 'Please select a topic or enter an issue subject';
      });
      _subjectFocusNode.requestFocus();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'User not authenticated. Please log in again.';
        _isSubmitting = false;
      });
      return;
    }

    final token = await user.getIdToken();

    final baseUrl = SettingsService.activeBaseUrl.isNotEmpty
        ? SettingsService.activeBaseUrl
        : '${Constants.baseUrl}/api/v1';

    String finalSubject = subject;
    if (_selectedOrderNumber != null && !finalSubject.contains(_selectedOrderNumber!)) {
      finalSubject = "$finalSubject (Order #$_selectedOrderNumber)";
    }

    String initialMsg = _messageController.text.trim();
    if (_selectedOrderNumber != null) {
      initialMsg = initialMsg.isNotEmpty
          ? "[Related Order: #$_selectedOrderNumber]\n$initialMsg"
          : "[Related Order: #$_selectedOrderNumber]";
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'subject': finalSubject,
          'initialMessage': initialMsg,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final ticket = data['ticket'];

        Navigator.pop(context); // Close popup dialog

        // Trigger refresh in parent
        widget.onTicketCreated?.call();

        // Floating success confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ticket created successfully! Opening chat...',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00875A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(seconds: 3),
          ),
        );

        // Open chat screen directly
        if (ticket != null && ticket['_id'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                ticketId: ticket['_id'],
                ticketSubject: ticket['subject'] ?? subject,
                isClosed: false,
              ),
            ),
          ).then((_) {
            widget.onTicketCreated?.call();
          });
        }
      } else {
        final err = jsonDecode(response.body);
        setState(() {
          _errorMessage = err['message'] ?? 'Failed to create ticket. Please try again.';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Connection error. Please check your network and try again.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    final maxHeight = (availableHeight * 0.82).clamp(320.0, mediaQuery.size.height * 0.82);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          maxWidth: 480,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 14, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF168BDB).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Create Support Ticket",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A1D1E),
                              ),
                            ),
                             const SizedBox(height: 2),
                            Text(
                              "Select a category or describe your issue",
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ),
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // Scrollable Content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Topic Selector Label
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF168BDB),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "SELECT ISSUE CATEGORY",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF168BDB),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Quick Topic Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_topics.length, (index) {
                            final isSelected = _selectedTopicIndex == index;
                            final topic = _topics[index];
                            return InkWell(
                              onTap: () => _onSelectTopic(index),
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: isSelected ? null : const Color(0xFFF4F6F9),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF0258C9)
                                        : const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF168BDB).withValues(alpha: 0.25),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      topic['icon'] as IconData,
                                      size: 14,
                                      color: isSelected ? Colors.white : const Color(0xFF475569),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      topic['title'] as String,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? Colors.white : const Color(0xFF334155),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),

                        // Optional Order Selector for production
                        ValueListenableBuilder<List<Order>>(
                          valueListenable: OrderService().orders,
                          builder: (context, orderList, _) {
                            if (orderList.isEmpty) return const SizedBox.shrink();
                            final recentOrders = orderList.take(6).toList();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.receipt_long_outlined, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(
                                      "RELATED ORDER (OPTIONAL)",
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF64748B),
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String?>(
                                      value: _selectedOrderNumber,
                                      isExpanded: true,
                                      hint: Text(
                                        "General Query / No specific order",
                                        style: GoogleFonts.outfit(fontSize: 12.5, color: Colors.grey.shade600),
                                      ),
                                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF64748B)),
                                      items: [
                                        DropdownMenuItem<String?>(
                                          value: null,
                                          child: Text(
                                            "General Query / No specific order",
                                            style: GoogleFonts.outfit(fontSize: 12.5, color: Colors.grey.shade600),
                                          ),
                                        ),
                                        ...recentOrders.map((ord) {
                                          final status = ord.status.isNotEmpty
                                              ? ord.status[0].toUpperCase() + ord.status.substring(1)
                                              : '';
                                          return DropdownMenuItem<String?>(
                                            value: ord.orderNumber,
                                            child: Text(
                                              "Order #${ord.orderNumber} • ₹${ord.total.toStringAsFixed(0)} ($status)",
                                              style: GoogleFonts.outfit(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF1E293B),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }),
                                      ],
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedOrderNumber = val;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Subject / Issue Title field
                        Text(
                          "Issue Subject *",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _subjectController,
                          focusNode: _subjectFocusNode,
                          onChanged: (val) {
                            if (_errorMessage != null) {
                              setState(() => _errorMessage = null);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "e.g. Order delayed, damaged packaging, or refund query",
                            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13),
                            prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF168BDB), size: 22),
                            suffixIcon: _subjectController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                                    onPressed: () {
                                      _subjectController.clear();
                                      setState(() => _selectedTopicIndex = null);
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF168BDB), width: 1.8),
                            ),
                          ),
                          style: GoogleFonts.outfit(fontSize: 13.5, color: const Color(0xFF1A1D1E)),
                        ),

                        const SizedBox(height: 14),

                        // Description field
                        Text(
                          "Detailed Description (Optional)",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _messageController,
                          focusNode: _messageFocusNode,
                          minLines: 3,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Provide any specific details (item name, delivery time, or remarks) to help us resolve faster...",
                            hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 12.5),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 36),
                              child: Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF168BDB), size: 18),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF168BDB), width: 1.8),
                            ),
                          ),
                          style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFF1A1D1E)),
                        ),

                        // Error alert
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: const Color(0xFFDC2626),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // Action Buttons Footer
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.outfit(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF168BDB).withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitTicket,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Submitting...",
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.send_rounded, color: Colors.white, size: 16),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Submit Ticket",
                                        style: GoogleFonts.outfit(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
