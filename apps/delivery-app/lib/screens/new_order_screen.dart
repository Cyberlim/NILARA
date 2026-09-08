import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'active_delivery_screen.dart';
import '../services/delivery_service.dart';

class NewOrderScreen extends StatelessWidget {
  const NewOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("New Order", style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_outlined, color: Colors.black87),
            onPressed: () {},
          )
        ],
      ),
      body: ValueListenableBuilder<List<dynamic>>(
        valueListenable: DeliveryService().availableOrders,
        builder: (context, orders, child) {
          if (orders.isEmpty) {
            return Center(
              child: Text("No available orders right now.", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 16)),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              await DeliveryService().fetchAvailableOrders();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final address = order['deliveryAddress'] ?? {};
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Deliver to", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(address['fullName'] ?? "Customer", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("${address['streetAddress'] ?? ''}, ${address['city'] ?? ''}", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey.shade200),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Amount to Collect", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text("\$${order['totalAmount']}", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final success = await DeliveryService().acceptOrder(order['_id']);
                              if (success && context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ActiveDeliveryScreen()),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E9C1C),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: Text("Accept Order", style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
