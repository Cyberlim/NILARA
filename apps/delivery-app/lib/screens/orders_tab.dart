import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersTab extends StatelessWidget {
  const OrdersTab({super.key});

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
              // Note: If used as a bottom tab, back button might just change to home tab.
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
        body: TabBarView(
          children: [
            _buildOrdersList(),
            _buildOrdersList(filter: "Delivered"),
            _buildOrdersList(filter: "Cancelled"),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList({String? filter}) {
    // Dummy data matching screenshot
    final orders = [
      {"id": "#CL12345678", "status": "Delivered", "date": "Today, 11:30 AM", "items": "6 items", "amount": "₹45.00"},
      {"id": "#CL12345677", "status": "Delivered", "date": "Today, 10:15 AM", "items": "4 items", "amount": "₹38.00"},
      {"id": "#CL12345676", "status": "Cancelled", "date": "Today, 09:20 AM", "items": "-", "amount": "₹0.00"},
      {"id": "#CL12345675", "status": "Delivered", "date": "Yesterday, 08:45 PM", "items": "7 items", "amount": "₹52.00"},
      {"id": "#CL12345674", "status": "Delivered", "date": "Yesterday, 07:30 PM", "items": "3 items", "amount": "₹41.00"},
    ];

    var filtered = orders;
    if (filter != null) {
      filtered = orders.where((o) => o['status'] == filter).toList();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        final isDelivered = order['status'] == "Delivered";
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order['id']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
                  const SizedBox(height: 6),
                  Text(order['date']!, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(order['items']!, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(order['status']!, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: isDelivered ? const Color(0xFF1E9C1C) : Colors.red)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(order['amount']!, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
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
    );
  }
}
