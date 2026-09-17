import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../services/order_service.dart';
import 'write_review_screen.dart';

class OrderDetailsScreen extends StatefulWidget {
  final Order order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, bool> _reviewEligibility = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkReviewEligibility();
  }

  Future<void> _checkReviewEligibility() async {
    if (widget.order.status != 'Delivered' && widget.order.status != 'delivered') {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final token = await user.getIdToken();

      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/api/v1/reviews/eligibility/order/${widget.order.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _reviewEligibility = Map<String, bool>.from(data['eligibility']);
          });
        }
      }
    } catch (e) {
      print("Failed to check review eligibility: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isDelivered = order.status == 'Delivered' || order.status == 'delivered';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text("Order Details", style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF168BDB)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSummaryCard(order),
                const SizedBox(height: 24),
                Text("Items in your order", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 12),
                ...order.items.map((item) => _buildItemCard(item, isDelivered)),
              ],
            ),
          ),
    );
  }

  Widget _buildOrderSummaryCard(Order order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order ID:", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
              Text(order.orderNumber, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Date:", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
              Text(order.date, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Status:", style: GoogleFonts.outfit(color: Colors.grey.shade600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  order.status,
                  style: GoogleFonts.outfit(color: Colors.blue.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount:", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(",1${order.total.toStringAsFixed(2)}", style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF168BDB))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(OrderItem item, bool isDelivered) {
    final canReview = _reviewEligibility[item.productId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(width: 60, height: 60, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("Qty: ${item.quantity} | ,1${item.price.toStringAsFixed(2)} each", style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 13)),
                
                if (isDelivered && canReview) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WriteReviewScreen(
                              productId: item.productId,
                              orderId: widget.order.id,
                              productName: item.name,
                              productImage: item.imageUrl,
                            ),
                          ),
                        );
                        if (result == true) {
                          _checkReviewEligibility();
                        }
                      },
                      icon: const Icon(Icons.star_outline, size: 16),
                      label: Text("Write Review", style: GoogleFonts.outfit(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF168BDB),
                        side: const BorderSide(color: Color(0xFF168BDB)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  )
                ] else if (isDelivered && !canReview) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text("Reviewed", style: GoogleFonts.outfit(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w500)),
                    ],
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
