import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import 'home_screen.dart';
import 'subscriptions_screen.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'nilara_hub_screen.dart';
import '../services/settings_service.dart' as import_settings;

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    import_settings.SettingsService().fetchSettings();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const SubscriptionsScreen(),
    const CategoryScreen(),
    const ProfileScreen(),
    const NilaraHubScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _bottomNavIndex,
            children: _screens,
          ),
          // Persistent Floating Bottom UI
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_bottomNavIndex == 2)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: _buildCategoryCartPill(),
                      ),
                    ],
                  )
                else
                  _buildCartBanner(),
                const SizedBox(height: 12),
                _buildCustomBottomNav(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBanner() {
    return ValueListenableBuilder<Map<String, CartItem>>(
      valueListenable: CartService().items,
      builder: (context, cartItems, child) {
        if (cartItems.isEmpty) return const SizedBox.shrink();

        final totalItems = CartService().getTotalItems();
        final firstItemImage = cartItems.values.first.imagePath;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF00875A), // Premium Nilara green
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: firstItemImage.startsWith('http')
                      ? Image.network(firstItemImage, fit: BoxFit.cover)
                      : Image.asset(
                          firstItemImage,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.water_drop, color: Color(0xFF0288D1)),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$totalItems ${totalItems > 1 ? 'items' : 'item'} in cart",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "View Cart",
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF00875A),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF00875A),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCartPill() {
    return ValueListenableBuilder<Map<String, CartItem>>(
      valueListenable: CartService().items,
      builder: (context, cartItems, child) {
        if (cartItems.isEmpty) return const SizedBox.shrink();

        final totalItems = CartService().getTotalItems();
        final images = cartItems.values.take(3).map((e) => e.imagePath).toList();

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00875A),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: images.length * 16.0 + 12,
                  child: Stack(
                    children: List.generate(images.length, (index) {
                      return Positioned(
                        left: index * 16.0,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: images[index].startsWith('http')
                                ? Image.network(images[index], fit: BoxFit.cover)
                                : Image.asset(images[index], fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.water_drop, size: 14)),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "$totalItems items",
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomBottomNav() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: "Home", isSelected: _bottomNavIndex == 0, index: 0)),
                Expanded(child: _buildNavItem(icon: Icons.water_drop_outlined, selectedIcon: Icons.water_drop, label: "Subscribe", isSelected: _bottomNavIndex == 1, index: 1)),
                Expanded(child: _buildNavItem(icon: Icons.grid_view_outlined, selectedIcon: Icons.grid_view, label: "Categories", isSelected: _bottomNavIndex == 2, index: 2)),
                Expanded(child: _buildNavItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: "Profile", isSelected: _bottomNavIndex == 3, index: 3)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required int index,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _bottomNavIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade600,
              size: 22,
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 10.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0288D1) : Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
