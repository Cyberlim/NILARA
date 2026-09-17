import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';
import '../services/wallet_service.dart';
import '../services/subscription_service.dart';
import '../services/settings_service.dart';
import '../services/order_service.dart';
import 'edit_profile_screen.dart';
import 'wallet_screen.dart';
import 'saved_addresses_screen.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';
import 'subscriptions_screen.dart';
import 'product_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'help_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'about_screen.dart';
import 'login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildTopHeader()),
          SliverToBoxAdapter(child: _buildNilaraPlusCard()),
          SliverToBoxAdapter(child: _buildQuickActions()),
          SliverToBoxAdapter(child: _buildWalletSection()),

          SliverToBoxAdapter(child: _buildDeliveryPreferences()),
          SliverToBoxAdapter(child: _buildMyActivity()),
          SliverToBoxAdapter(child: _buildBuyAgain()),
          SliverToBoxAdapter(child: _buildPaymentsAndDocs()),
          SliverToBoxAdapter(child: _buildReferAndEarn()),
          SliverToBoxAdapter(child: _buildSettingsAndSupport()),
          SliverToBoxAdapter(child: _buildLogout()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding for navbar
        ],
      ),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(String name, double size) {
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '';
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: initial.isNotEmpty
            ? Text(
                initial,
                style: GoogleFonts.outfit(
                  fontSize: size * 0.42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : Icon(
                Icons.person_rounded,
                size: size * 0.55,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return ValueListenableBuilder<UserProfile>(
      valueListenable: UserService().profile,
      builder: (context, profile, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Good Morning 👋",
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Welcome back to Nilara",
                        style: GoogleFonts.outfit(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF168BDB), width: 3),
                      gradient: profile.photoUrl.isEmpty
                          ? const LinearGradient(
                              colors: [Color(0xFF168BDB), Color(0xFF0258C9)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                    ),
                    child: ClipOval(
                      child: profile.photoUrl.isNotEmpty
                          ? Image.network(
                              profile.photoUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(profile.name, 80),
                            )
                          : _buildDefaultAvatar(profile.name, 80),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              profile.name,
                              style: GoogleFonts.outfit(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (profile.isPremium)
                              const Icon(Icons.verified, color: Color(0xFF168BDB), size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.phone,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.email,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (profile.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF168BDB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "PREMIUM MEMBER",
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF168BDB),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Edit Profile",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNilaraPlusCard() {
    return ValueListenableBuilder<Subscription?>(
      valueListenable: SubscriptionService().activeSubscription,
      builder: (context, sub, child) {
        if (sub == null) return const SizedBox(); // Hide if no active subscription
        
        int deliveriesThisMonth = 0;
        if (sub.completedDeliveries.isNotEmpty) {
          final now = DateTime.now();
          deliveriesThisMonth = sub.completedDeliveries
              .where((d) => d.month == now.month && d.year == now.year)
              .length;
        }
        final double savingsPerDelivery = sub.price - sub.discountedPrice;
        final double moneySaved = deliveriesThisMonth * (savingsPerDelivery > 0 ? savingsPerDelivery : 0);

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF203A43).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(Icons.water_drop, size: 100, color: Colors.white.withOpacity(0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.workspace_premium, color: Colors.amber, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    sub.planName,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                sub.productName,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Orders This Month",
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.white60),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$deliveriesThisMonth Deliveries",
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 40, color: Colors.white24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Money Saved",
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.white60),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹$moneySaved",
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF203A43),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Manage Subscription",
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
      }
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {"icon": Icons.shopping_bag_outlined, "title": "My Orders", "color": Colors.orange},
      {"icon": Icons.event_repeat_outlined, "title": "Subscriptions", "color": Colors.blue},
      {"icon": Icons.favorite_border, "title": "Wishlist", "color": Colors.pink},
      {"icon": Icons.location_on_outlined, "title": "Addresses", "color": Colors.green},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.2,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (action["title"] == "Addresses") {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedAddressesScreen()));
                  } else if (action["title"] == "Wishlist") {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen()));
                  } else if (action["title"] == "My Orders") {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen()));
                  } else if (action["title"] == "Subscriptions") {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionsScreen()));
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (action["color"] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(action["icon"] as IconData, color: action["color"] as Color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          action["title"] as String,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
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

  Widget _buildWalletSection() {
    return ValueListenableBuilder<WalletState>(
      valueListenable: WalletService().wallet,
      builder: (context, walletState, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF168BDB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Color(0xFF168BDB)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nilara Wallet",
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          "₹${walletState.balance.toStringAsFixed(0)}",
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF168BDB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    child: Text("Recharge", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildWalletInfo(Icons.stars, "Reward Points", "${walletState.rewardPoints} pts", Colors.amber),
                  Container(width: 1, height: 30, color: Colors.grey.shade200),
                  _buildWalletInfo(Icons.local_offer, "Coupons", "${walletState.coupons} Available", Colors.green),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWalletInfo(IconData icon, String title, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
            Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveSubscription() {
    return ValueListenableBuilder<Subscription?>(
      valueListenable: SubscriptionService().activeSubscription,
      builder: (context, subscription, child) {
        if (subscription == null) {
          return const SizedBox.shrink();
        }
        final isActive = subscription.status == "Active";
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Active Subscription"),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? Colors.blue.shade100 : Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(child: Image.network("https://cdn-icons-png.flaticon.com/512/3248/3248983.png", width: 40)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  subscription.status.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 10, 
                                    fontWeight: FontWeight.bold, 
                                    color: isActive ? Colors.green : Colors.orange
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subscription.planName,
                                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                subscription.nextDelivery,
                                style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              SubscriptionService().toggleStatus();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: isActive ? Colors.orange : Colors.green,
                              side: BorderSide(color: isActive ? Colors.orange : Colors.green),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(isActive ? "Pause" : "Resume", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text("Skip Next", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildDeliveryPreferences() {
    return ValueListenableBuilder<Subscription?>(
      valueListenable: SubscriptionService().activeSubscription,
      builder: (context, subscription, child) {
        if (subscription == null) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Delivery Preferences"),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text("Preferred Delivery Time", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text(subscription.deliveryTimePref, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          final times = SettingsService().deliveryTimeSlots.value;
                          return Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            backgroundColor: Colors.white,
                            surfaceTintColor: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "Select Delivery Time", 
                                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...times.map((time) {
                                    final isSelected = subscription.deliveryTimePref == time;
                                    return InkWell(
                                      onTap: () {
                                        SubscriptionService().updatePreferences(deliveryTimePref: time);
                                        Navigator.pop(context);
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        margin: const EdgeInsets.only(bottom: 4),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFF168BDB).withOpacity(0.08) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                time, 
                                                style: GoogleFonts.outfit(
                                                  fontSize: 15, 
                                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                                  color: isSelected ? const Color(0xFF168BDB) : Colors.black87
                                                )
                                              )
                                            ),
                                            if (isSelected)
                                              const Icon(Icons.check, color: Color(0xFF168BDB), size: 20),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    "Leave at Door",
                    "Contactless delivery for safety",
                    subscription.leaveAtDoor,
                    (val) => SubscriptionService().updatePreferences(leaveAtDoor: val),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    "Call Before Delivery",
                    "Driver will call you when nearby",
                    subscription.callBeforeDelivery,
                    (val) => SubscriptionService().updatePreferences(callBeforeDelivery: val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.edit_note, color: Colors.black87),
                    ),
                    title: Text("Delivery Instructions", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text(
                      subscription.specialInstructions.isNotEmpty ? subscription.specialInstructions : "Leave at security gate if not home", 
                      style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      final controller = TextEditingController(text: subscription.specialInstructions);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            backgroundColor: Colors.white,
                            surfaceTintColor: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "Delivery Instructions", 
                                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: controller,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "E.g. Leave at security gate if not home",
                                      hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey.shade300),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF168BDB)),
                                      ),
                                      contentPadding: const EdgeInsets.all(12),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text("Cancel", style: GoogleFonts.outfit(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          SubscriptionService().updatePreferences(specialInstructions: controller.text.trim());
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF168BDB),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: Text("Save", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
      value: value,
      activeColor: const Color(0xFF168BDB),
      onChanged: onChanged,
    );
  }

  Widget _buildMyActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("My Activity"),
        ValueListenableBuilder<List<Order>>(
          valueListenable: OrderService().orders,
          builder: (context, orders, child) {
            final deliveredOrders = orders.where((o) => o.status == 'delivered').toList();
            
            int totalItemsDelivered = 0;
            for (var order in deliveredOrders) {
              for (var item in order.items) {
                final regExp = RegExp(r'(\d+)\s*L', caseSensitive: false);
                final match = regExp.firstMatch(item.name);
                int litersPerItem = 0;
                if (match != null && match.group(1) != null) {
                  litersPerItem = int.parse(match.group(1)!);
                }
                totalItemsDelivered += (litersPerItem * item.quantity);
              }
            }
            final waterLiters = totalItemsDelivered;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _buildActivityCard("Orders", "${deliveredOrders.length}", Icons.shopping_bag, Colors.blue)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActivityCard("Water (L)", "$waterLiters", Icons.water_drop, Colors.cyan)),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<List<Order>>(
          valueListenable: OrderService().orders,
          builder: (context, orders, child) {
            final deliveredOrders = orders.where((o) => o.status == 'delivered').toList();
            final totalOrders = orders.length;
            final successRate = totalOrders == 0 ? 100 : ((deliveredOrders.length / totalOrders) * 100).round();
            
            double moneySaved = 0;
            for (var order in deliveredOrders) {
              moneySaved += order.discount;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _buildActivityCard("Saved", "₹${moneySaved.toStringAsFixed(0)}", Icons.savings, Colors.green)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildActivityCard("Success", "$successRate%", Icons.verified, Colors.amber)),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600)),
              Icon(icon, size: 20, color: color.withOpacity(0.8)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyAgain() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Buy Again"),
        ValueListenableBuilder<List<Order>>(
          valueListenable: OrderService().orders,
          builder: (context, orders, child) {
            final uniqueItemsMap = <String, OrderItem>{};
            for (var order in orders) {
              if (order.status == 'delivered' || order.status == 'completed') {
                for (var item in order.items) {
                  if (item.productId.isNotEmpty) {
                    uniqueItemsMap[item.productId] = item;
                  }
                }
              }
            }
            
            final products = uniqueItemsMap.values.toList();
            
            if (products.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "No previous orders yet. Start shopping to see recommendations!",
                  style: GoogleFonts.outfit(color: Colors.grey.shade600),
                ),
              );
            }

            return SizedBox(
              height: 180,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(
                            productId: product.productId,
                            variantId: product.variantId,
                            title: product.name,
                            imagePath: product.imageUrl,
                            price: "₹${product.price.toStringAsFixed(0)}",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              child: Center(
                                child: product.imageUrl.startsWith("http")
                                    ? Image.network(product.imageUrl, height: 80)
                                    : Image.asset(product.imageUrl, height: 80, errorBuilder: (c, e, s) => const Icon(Icons.water_drop, color: Colors.blue, size: 40)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "₹${product.price.toStringAsFixed(0)}",
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF168BDB)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF168BDB),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentsAndDocs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Payments & Documents"),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _buildListTile(Icons.credit_card, "Saved Cards", "Manage your saved credit/debit cards"),
              const Divider(height: 1),
              _buildListTile(Icons.account_balance, "UPI & Bank Accounts", "Manage linked UPI IDs"),
              const Divider(height: 1),
              _buildListTile(Icons.history, "Payment History", "View all your past transactions"),
              const Divider(height: 1),
              _buildListTile(Icons.receipt_long, "Invoices & Bills", "Download monthly statements"),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleShare(BuildContext context, int bonusAmount) async {
    final String shareText =
        "Hey! Use Nilara to get fresh water & dairy delivered daily! Register and get ₹$bonusAmount in your wallet on your first order. Download now: https://nilara.com";

    // 1. Try native system share chooser first
    try {
      const platform = MethodChannel('com.nilara.user/share');
      final bool? success = await platform.invokeMethod<bool>('shareText', {
        'text': shareText,
        'subject': 'Join Nilara & Earn ₹$bonusAmount!',
      });
      if (success == true) return;
    } catch (_) {
      // Fall through to in-app share sheet
    }

    if (context.mounted) {
      _showInviteBottomSheet(context, bonusAmount, shareText);
    }
  }

  void _showInviteBottomSheet(BuildContext context, int bonusAmount, String shareText) {
    final String inviteLink = "https://nilara.com/invite?ref=NILARA$bonusAmount";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: const Icon(Icons.card_giftcard, color: Colors.amber, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Invite Friends & Earn ₹$bonusAmount",
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Earn ₹$bonusAmount wallet cash for every friend who joins!",
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "YOUR INVITE LINK",
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade500,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            inviteLink,
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF168BDB),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: shareText));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("🎉 Invite link copied to clipboard!"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF168BDB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text("Copy", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final encoded = Uri.encodeComponent(shareText);
                        final whatsappNative = Uri.parse("whatsapp://send?text=$encoded");
                        final whatsappWeb = Uri.parse("https://api.whatsapp.com/send?text=$encoded");
                        try {
                          await launchUrl(whatsappNative, mode: LaunchMode.externalApplication);
                        } catch (_) {
                          try {
                            await launchUrl(whatsappWeb, mode: LaunchMode.externalApplication);
                          } catch (_) {
                            await Clipboard.setData(ClipboardData(text: shareText));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('WhatsApp not found. Link copied to clipboard!')),
                              );
                            }
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.chat, color: Color(0xFF25D366), size: 28),
                            const SizedBox(height: 6),
                            Text(
                              "WhatsApp",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF075E54),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final smsUri = Uri.parse("sms:?body=${Uri.encodeComponent(shareText)}");
                        try {
                          await launchUrl(smsUri);
                        } catch (_) {
                          await Clipboard.setData(ClipboardData(text: shareText));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not open SMS. Link copied to clipboard!')),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.sms, color: Colors.blue, size: 28),
                            const SizedBox(height: 6),
                            Text(
                              "SMS Message",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        Navigator.pop(ctx);
                        try {
                          const platform = MethodChannel('com.nilara.user/share');
                          await platform.invokeMethod('shareText', {
                            'text': shareText,
                            'subject': 'Join Nilara & Earn ₹$bonusAmount!',
                          });
                        } catch (_) {
                          await Clipboard.setData(ClipboardData(text: shareText));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invite link copied to clipboard!')),
                            );
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.share, color: Colors.purple, size: 28),
                            const SizedBox(height: 6),
                            Text(
                              "More",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReferAndEarn() {
    return ValueListenableBuilder<int>(
      valueListenable: SettingsService().referralBonusAmount,
      builder: (context, bonusAmount, child) {
        return GestureDetector(
          onTap: () => _handleShare(context, bonusAmount),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.amber.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "REFER & EARN",
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Invite Friends & Earn ₹$bonusAmount",
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Get ₹$bonusAmount in your Nilara Wallet for every friend who places their first order.",
                        style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _handleShare(context, bonusAmount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.share, size: 20),
                  label: Text(
                    "Share",
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSettingsAndSupport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Settings & Support"),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: SettingsService().pushNotificationsEnabled,
                builder: (context, pushNotifications, child) {
                  return SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    title: Text("Notifications", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                    subtitle: Text("Manage your alerts", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
                    value: pushNotifications,
                    activeColor: const Color(0xFF168BDB),
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.notifications_none, color: Colors.black87),
                    ),
                    onChanged: (val) {
                      SettingsService().pushNotificationsEnabled.value = val;
                    },
                  );
                }
              ),
              const Divider(height: 1),
              _buildListTile(Icons.support_agent, "Help & Support", "Chat or call our support team", onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()));
              }),
              const Divider(height: 1),
              _buildListTile(Icons.privacy_tip_outlined, "Privacy Policy", "Terms & conditions", onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
              }),
              const Divider(height: 1),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.info_outline, color: Colors.black87),
                ),
                title: Text("About Nilara", style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text("Version 1.0.0", style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600)),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogout() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          },
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          label: Text(
            "Logout",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: const BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}

