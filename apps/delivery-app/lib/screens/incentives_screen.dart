import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IncentivesScreen extends StatelessWidget {
  const IncentivesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("Incentives", style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
          bottom: TabBar(
            labelColor: const Color(0xFF1E9C1C), // Cyberlim Green
            unselectedLabelColor: Colors.black54,
            indicatorColor: const Color(0xFF1E9C1C),
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: "Active"),
              Tab(text: "Expired"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveIncentivesList(),
            const Center(child: Text("No expired incentives")),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveIncentivesList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTargetIncentive("Complete 10 orders", "Earn ₹200 extra", 0.6, "2 days left"),
        const SizedBox(height: 16),
        _buildTargetIncentive("Complete 20 orders", "Earn ₹500 extra", 0.4, "4 days left"),
        const SizedBox(height: 16),
        _buildTimeBonus("Peak Hour Bonus", "Earn extra ₹15 per order", "5 PM - 9 PM", Icons.access_time_filled, Colors.orange, true),
        const SizedBox(height: 16),
        _buildTimeBonus("Weekend Bonus", "Earn extra ₹100 on 10 orders", "Sat - Sun", Icons.calendar_month, Colors.blue, false),
      ],
    );
  }

  Widget _buildTargetIncentive(String title, String subtitle, double progress, String timeLeft) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // Pale Yellow
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white,
                    color: const Color(0xFF1E9C1C),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 12),
                Text(timeLeft, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset('assets/images/gift_box.png', width: 50, height: 50),
        ],
      ),
    );
  }

  Widget _buildTimeBonus(String title, String subtitle, String time, IconData icon, Color iconColor, bool isLive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 12),
                Text(time, style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Icon(icon, color: iconColor, size: 40),
              if (isLive) ...[
                const SizedBox(height: 8),
                Text("Live Now", style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E9C1C))),
              ]
            ],
          )
        ],
      ),
    );
  }
}
