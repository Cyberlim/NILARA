import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_picked_up_screen.dart';
import 'active_delivery_screen.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Pick up the order from", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 8),
              Text("Cyberlim Store", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("Sector 62, Noida, Uttar Pradesh", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                    child: Text("1.2 km", style: GoogleFonts.outfit(color: const Color(0xFF1E9C1C), fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 20),
              
              Text("Deliver to", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 8),
              Text("Rohit Kumar", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text("A-1204, Supertech Eco Village 1,\nNoida, Uttar Pradesh", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 13)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                    child: Text("4.6 km", style: GoogleFonts.outfit(color: const Color(0xFF1E9C1C), fontSize: 12, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              
              const SizedBox(height: 20),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 20),
              
              _buildOrderDetailRow("Order ID", "#CL12345678"),
              const SizedBox(height: 16),
              _buildOrderDetailRow("Order Amount", "₹345"),
              const SizedBox(height: 16),
              _buildOrderDetailRow("Payment", "Prepaid"),
              const SizedBox(height: 16),
              _buildOrderDetailRow("Items", "6 items"),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, color: Colors.black54, size: 20),
                const SizedBox(width: 8),
                Text("Accept order in", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            Text("00:25", style: GoogleFonts.outfit(color: const Color(0xFF1E9C1C), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OrderPickedUpScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E9C1C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text("Accept Order", style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Reject Order", style: GoogleFonts.outfit(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.black54, fontSize: 14)),
        Text(value, style: GoogleFonts.outfit(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
