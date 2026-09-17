import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/delivery_service.dart';

class OrdersTab extends StatefulWidget {
  const OrdersTab({super.key});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  void initState() {
    super.initState();
    DeliveryService().fetchMyOrders();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.maybePop(context);
            },
          ),
          title: Text("My Orders", style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
          bottom: TabBar(
            labelColor: const Color(0xFF1E9C1C), // Cyberlim Green
            unselectedLabelColor: Colors.black54,
            indicatorColor: const Color(0xFF1E9C1C),
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: "All"),
              Tab(text: "Delivered"),
              Tab(text: "Cancelled"),
            ],
          ),
        ),
        body: ValueListenableBuilder<List<dynamic>>(
          valueListenable: DeliveryService().myOrders,
          builder: (context, orders, child) {
            return TabBarView(
              children: [
                _buildOrdersList(orders),
                _buildOrdersList(orders, filter: "delivered"),
                _buildOrdersList(orders, filter: "cancelled"),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<dynamic> allOrders, {String? filter}) {
    var filtered = allOrders;
    if (filter != null) {
      filtered = allOrders.where((o) => (o['status']?.toString().toLowerCase()) == filter.toLowerCase()).toList();
    }

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delivery_dining_outlined, size: 40, color: Colors.grey.shade400),
              ),
              const SizedBox(height: 16),
              Text(
                filter == null ? "No Orders Yet" : "No ${filter.toUpperCase()} Orders",
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Text(
                "When you accept and deliver orders, they will appear here.",
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF1E9C1C),
      onRefresh: () => DeliveryService().fetchMyOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final order = filtered[index];
          final String status = (order['status'] ?? 'pending').toString();
          final bool isDelivered = status == "delivered";
          final bool isCancelled = status == "cancelled";

          final String orderNum = order['orderNumber'] ?? (order['_id'] != null ? "#${order['_id'].toString().substring(order['_id'].toString().length - 6).toUpperCase()}" : "Order");
          final List items = order['items'] is List ? (order['items'] as List) : [];
          final String itemsCountText = items.isNotEmpty ? "${items.length} ${items.length == 1 ? 'item' : 'items'}" : "Delivery Order";

          String dateText = "Recent";
          if (order['createdAt'] != null) {
            try {
              final dt = DateTime.parse(order['createdAt']).toLocal();
              dateText = "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
            } catch (_) {}
          }

          final double fee = order['deliveryFeePaise'] != null && (order['deliveryFeePaise'] as num) > 0
              ? (order['deliveryFeePaise'] as num) / 100.0
              : 20.0;

          final Color statusColor = isDelivered
              ? const Color(0xFF1E9C1C)
              : (isCancelled ? Colors.redAccent : Colors.orange);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(orderNum, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text(dateText, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(itemsCountText, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.replaceAll('_', ' ').toUpperCase(),
                        style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text("₹${fee.toStringAsFixed(2)}", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, color: Colors.black54, size: 20),
                      ],
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
