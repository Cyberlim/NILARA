import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/incentive_service.dart';

class IncentivesScreen extends StatefulWidget {
  const IncentivesScreen({super.key});

  @override
  State<IncentivesScreen> createState() => _IncentivesScreenState();
}

class _IncentivesScreenState extends State<IncentivesScreen> {
  final IncentiveService _incentiveService = IncentiveService();

  @override
  void initState() {
    super.initState();
    _incentiveService.fetchIncentives();
  }

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
          title: Text(
            "Incentives",
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
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
            _buildActiveTab(),
            _buildExpiredTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab() {
    return RefreshIndicator(
      color: const Color(0xFF1E9C1C),
      onRefresh: () => _incentiveService.fetchIncentives(),
      child: ValueListenableBuilder<bool>(
        valueListenable: _incentiveService.isLoadingNotifier,
        builder: (context, isLoading, _) {
          return ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: _incentiveService.activeIncentivesNotifier,
            builder: (context, activeList, _) {
              if (isLoading && activeList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF1E9C1C)),
                );
              }

              if (activeList.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.card_giftcard_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No Active Incentives Right Now",
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "New delivery milestone schemes and peak bonuses will appear here.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: activeList.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = activeList[index];
                  final String category = item['category'] ?? item['type'] ?? 'Order Target';

                  if (category == 'Peak Hour') {
                    return _buildTimeBonus(
                      title: item['title'] ?? 'Peak Hour Bonus',
                      subtitle: item['subtitle'] ?? item['description'] ?? 'Earn extra per order',
                      time: (item['timeRange'] != null && (item['timeRange'] as String).isNotEmpty)
                          ? item['timeRange']
                          : "5 PM - 9 PM",
                      icon: Icons.access_time_filled,
                      iconColor: Colors.orange,
                      isLive: item['isLive'] ?? false,
                    );
                  } else if (category == 'Weekend Rush') {
                    return _buildTimeBonus(
                      title: item['title'] ?? 'Weekend Bonus',
                      subtitle: item['subtitle'] ?? item['description'] ?? 'Earn extra on 10 orders',
                      time: (item['timeRange'] != null && (item['timeRange'] as String).isNotEmpty)
                          ? item['timeRange']
                          : "Sat - Sun",
                      icon: Icons.calendar_month,
                      iconColor: Colors.blue,
                      isLive: false,
                    );
                  } else {
                    // Order Target or Daily Goal
                    final double progress = (item['progress'] as num?)?.toDouble() ?? 0.0;
                    final int current = (item['currentOrders'] as num?)?.toInt() ?? 0;
                    final int target = (item['targetOrders'] as num?)?.toInt() ?? 10;
                    final bool isCompleted = item['isCompleted'] == true || item['isClaimed'] == true;
                    final int rewardAmount = (item['rewardAmount'] as num?)?.toInt() ?? 0;

                    return _buildTargetIncentive(
                      title: item['title'] ?? 'Complete Orders',
                      subtitle: item['subtitle'] ?? item['description'] ?? 'Earn extra cash',
                      progress: progress,
                      timeLeft: item['daysLeft'] ?? '',
                      currentOrders: current,
                      targetOrders: target,
                      isCompleted: isCompleted,
                      rewardAmount: rewardAmount,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildExpiredTab() {
    return RefreshIndicator(
      color: const Color(0xFF1E9C1C),
      onRefresh: () => _incentiveService.fetchIncentives(),
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: _incentiveService.expiredIncentivesNotifier,
        builder: (context, expiredList, _) {
          if (expiredList.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        "No expired incentives",
                        style: GoogleFonts.outfit(fontSize: 16, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: expiredList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = expiredList[index];
              final bool isClaimed = item['isClaimed'] == true;

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
                          Text(
                            item['title'] ?? '',
                            style: GoogleFonts.outfit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['subtitle'] ?? '',
                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isClaimed ? "✓ Reward Credited to Wallet" : "Expired",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isClaimed ? const Color(0xFF1E9C1C) : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${item['rewardAmount'] ?? 0}",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isClaimed ? const Color(0xFF1E9C1C) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTargetIncentive({
    required String title,
    required String subtitle,
    required double progress,
    required String timeLeft,
    required int currentOrders,
    required int targetOrders,
    required bool isCompleted,
    required int rewardAmount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // Pale Yellow
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? const Color(0xFF1E9C1C).withValues(alpha: 0.5) : const Color(0xFFFFE082),
          width: isCompleted ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E9C1C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "✓ Achieved",
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white,
                    color: const Color(0xFF1E9C1C),
                    minHeight: 7,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "$currentOrders / $targetOrders completed",
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E9C1C),
                      ),
                    ),
                    Text(
                      timeLeft,
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF1E9C1C).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Color(0xFF1E9C1C), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          "₹$rewardAmount credited to your wallet balance!",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E9C1C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset('assets/images/gift_box.png', width: 50, height: 50),
        ],
      ),
    );
  }

  Widget _buildTimeBonus({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
    required bool isLive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLive ? const Color(0xFF1E9C1C).withValues(alpha: 0.5) : Colors.grey.shade200,
          width: isLive ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Text(
                  time,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Icon(icon, color: iconColor, size: 40),
              if (isLive) ...[
                const SizedBox(height: 8),
                Text(
                  "Live Now",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E9C1C),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
