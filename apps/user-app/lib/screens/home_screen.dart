import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/product_card.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/settings_service.dart';
import 'package:blinkit_clone/screens/wallet_screen.dart';
import 'package:blinkit_clone/screens/home_tabs_ui.dart';
import 'package:blinkit_clone/widgets/animated_backgrounds.dart';
import 'package:blinkit_clone/screens/orders_screen.dart';
import 'package:blinkit_clone/screens/category_screen.dart';
import 'package:blinkit_clone/screens/subscriptions_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:blinkit_clone/screens/bulk_orders/bulk_orders_screen.dart';
import 'package:blinkit_clone/screens/customize_bottle/customize_bottle_screen.dart';
import 'package:blinkit_clone/screens/search_screen.dart';
import '../services/address_service.dart';
import 'saved_addresses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _categoryTabController;
  List<ProductModel> _allProducts = [];
  bool _isLoadingProducts = true;
  bool _isScrolledDown = false;

  @override
  void initState() {
    super.initState();
    _categoryTabController = TabController(length: 4, vsync: this);
    _categoryTabController.addListener(() {
      setState(() {});
    });
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService().getProducts();
      setState(() {
        _allProducts = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  @override
  void dispose() {
    _categoryTabController.dispose();
    super.dispose();
  }

  List<Color> _getTabColors() {
    switch (_categoryTabController.index) {
      case 0: // Water: Sky Blue
        return [const Color(0xFF0288D1), const Color(0xFF00B0FF)];
      case 1: // Oils: Golden Yellow
        return [const Color(0xFFE65100), const Color(0xFFFFB300)];
      case 2: // Dairy & Drinks: White with Light Blue
        return [const Color(0xFFFFFFFF), const Color(0xFFE0F7FA)];
      case 3: // Grocery: Fresh Green
        return [const Color(0xFF1B5E20), const Color(0xFF388E3C)];
      default:
        return [const Color(0xFF0288D1), const Color(0xFF00B0FF)];
    }
  }

  Widget _getTabHeader() {
    switch (_categoryTabController.index) {
      case 0:
        return Column(key: const ValueKey('0'), children: [buildDynamicBanners('Water')]);
      case 1:
        return Column(key: const ValueKey('1'), children: [buildOilsHeader(context)]);
      case 2:
        return Column(key: const ValueKey('2'), children: [buildDairyHeader(context)]);
      case 3:
        return Column(key: const ValueKey('3'), children: [buildGroceryHeader(context)]);
      default:
        return Column(key: const ValueKey('default'), children: [buildDynamicBanners('Water')]);
    }
  }

  Widget _getTabBackground() {
    switch (_categoryTabController.index) {
      case 0:
        return const AnimatedWaterBackground();
      case 1:
        return const AnimatedOilsBackground();
      case 2:
        return const AnimatedDairyBackground();
      case 3:
        return const AnimatedGroceryBackground();
      default:
        return const AnimatedWaterBackground();
    }
  }

  List<Widget> _getTabSlivers() {
    if (_categoryTabController.index == 0) {
      // WATER
      return [
        const SliverToBoxAdapter(child: BannerCarousel(tabName: 'Water')),
        SliverToBoxAdapter(child: _buildQuickActionsSection()),
        SliverToBoxAdapter(child: _buildNilaraProductsSection()),
        SliverToBoxAdapter(child: _buildWaterSubscriptionBanner()),
        const SliverToBoxAdapter(child: FeaturedWaterSection()),
        SliverToBoxAdapter(child: _buildBulkProductsSection()),
        SliverToBoxAdapter(child: _buildWaterAttractiveSection()),
        const SliverToBoxAdapter(child: CustomerReviewsMarquee()),
      ];
    }
    if (_categoryTabController.index == 1) {
      // OILS
      return [
        const SliverToBoxAdapter(child: FeaturedOilSection()),
        SliverToBoxAdapter(child: _buildOilsSection()),
        SliverToBoxAdapter(child: _buildOilAttractiveSection()),
      ];
    }
    if (_categoryTabController.index == 2) {
      // DAIRY & DRINKS
      return [
        const SliverToBoxAdapter(child: BannerCarousel()),
        SliverToBoxAdapter(child: _buildNilaraProductsSection()),
        SliverToBoxAdapter(child: _buildDairySection()),
        const SliverToBoxAdapter(child: FeaturedMilkSection()),
        SliverToBoxAdapter(child: _buildMilkAttractiveSection()),
      ];
    }

    // Grocery (index 3)
    return [
      SliverToBoxAdapter(child: _buildNilaraProductsSection()),
      SliverToBoxAdapter(child: _buildNilaraWaterSection()),
      SliverToBoxAdapter(child: _buildOilsSection()),
      SliverToBoxAdapter(child: _buildPromoBanner()),
      SliverToBoxAdapter(child: _buildCuratedCollections()),
      SliverToBoxAdapter(child: _buildDairySection()),
      SliverToBoxAdapter(child: _buildGrocerySection()),
    ];
  }

  Widget _buildQuickActionsSection() {
    final actions = [
      {
        "title": "Customize Bottle",
        "subtitle": "Your Design",
        "icon": Icons.brush,
        "color": Colors.blue,
      },
      {
        "title": "Bulk Orders",
        "subtitle": "For Business",
        "icon": Icons.inventory_2,
        "color": Colors.green,
      },
      {
        "title": "Track Order",
        "subtitle": "Live Tracking",
        "icon": Icons.location_on,
        "color": Colors.red,
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quick Actions",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: actions.map((action) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (action["title"] == "Customize Bottle") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CustomizeBottleScreen(),
                          ),
                        );
                      } else if (action["title"] == "Track Order") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const OrdersScreen(),
                          ),
                        );
                      } else if (action["title"] == "Bulk Orders") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const BulkOrdersScreen(),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        right: action == actions.last ? 0 : 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (action["color"] as Color).withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              action["icon"] as IconData,
                              color: action["color"] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            action["title"] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            action["subtitle"] as String,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterSubscriptionBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4FE), // Light sky blue matching the image
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Never Run Out of Water!",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Subscribe for regular deliveries\n& save up to 10%",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF2563EB),
                          ], // Blue gradient
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Subscribe Now",
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Right side image (Placeholder using existing 20L bottle, user will replace with exact image)
            Expanded(
              flex: 2,
              child: Image.asset(
                'assets/images/20L daily bulk .png',
                height: 110,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWhiteHeader = _isScrolledDown || _categoryTabController.index == 2;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isWhiteHeader ? Brightness.dark : Brightness.light,
        statusBarBrightness: isWhiteHeader ? Brightness.light : Brightness.dark,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollUpdateNotification) {
                  final isScrolled = notification.metrics.pixels > 120;
                  if (isScrolled != _isScrolledDown) {
                    setState(() {
                      _isScrolledDown = isScrolled;
                    });
                  }
                }
                return false;
              },
              child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: _getTabColors(),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildSearchBar(),
                          _buildCategoriesRow(),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, 0.05),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _getTabHeader(),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top,
                      left: 0,
                      right: 0,
                      height: 250,
                      child: IgnorePointer(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          child: SizedBox(
                            key: ValueKey(_categoryTabController.index),
                            width: double.infinity,
                            height: 250,
                            child: _getTabBackground(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ..._getTabSlivers(),
              const SliverToBoxAdapter(
                child: SizedBox(height: 160),
              ), // Bottom padding
            ],
          ),
        ),
      ],
    ),
  ),
);
}

  Widget _buildHeader() {
    final bool isDairyTab = _categoryTabController.index == 2;
    final Color textColor = isDairyTab ? const Color(0xFF004D40) : Colors.white;
    final Color secondaryTextColor = isDairyTab
        ? const Color(0xFF00796B)
        : Colors.white70;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "MY WATER",
                  style: GoogleFonts.outfit(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "8 minutes",
                  style: GoogleFonts.outfit(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SavedAddressesScreen()),
                    );
                  },
                  child: ValueListenableBuilder<List<Address>>(
                    valueListenable: AddressService().addresses,
                    builder: (context, addresses, child) {
                      String label = "LOCATION";
                      String addressText = " - Tap to select address";
                      
                      if (addresses.isNotEmpty) {
                        final defaultAddr = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
                        label = defaultAddr.title.toUpperCase();
                        if (label.isEmpty) label = "HOME";
                        addressText = " - ${defaultAddr.addressLine1}";
                        if (addressText.length > 25) {
                          addressText = "${addressText.substring(0, 25)}...";
                        }
                      }

                      return Row(
                        children: [
                          Text(
                            label,
                            style: GoogleFonts.outfit(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            addressText,
                            style: GoogleFonts.outfit(
                              color: secondaryTextColor,
                              fontSize: 13,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: secondaryTextColor,
                            size: 18,
                          ),
                        ],
                      );
                    }
                  ),
                ),
              ],
            ),
          ),
          // Wallet Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WalletScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDairyTab
                    ? Colors.teal.shade50
                    : Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.amber,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Orders Icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const OrdersScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDairyTab
                    ? Colors.teal.shade50
                    : Colors.black.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                color: isDairyTab ? const Color(0xFF004D40) : Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final bool isDairyTab = _categoryTabController.index == 2;
    final Color iconColor = isDairyTab
        ? const Color(0xFF004D40)
        : Colors.white70;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchScreen(allProducts: _allProducts),
            ),
          );
        },
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDairyTab
                ? Colors.grey.shade100
                : Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isDairyTab
                  ? Colors.grey.shade300
                  : Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(Icons.search, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search "Nilara water, cooking oil, beverages..."',
                  style: GoogleFonts.outfit(color: iconColor, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Removed mic icon

              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesRow() {
    final bool isDairyTab = _categoryTabController.index == 2;
    final Color activeColor = isDairyTab
        ? const Color(0xFF004D40)
        : Colors.white;
    final Color inactiveColor = isDairyTab ? Colors.black54 : Colors.white70;

    IconData getIconData(String? name) {
      switch (name) {
        case "water_drop_outlined": return Icons.water_drop_outlined;
        case "opacity_outlined": return Icons.opacity_outlined;
        case "egg_alt_outlined": return Icons.egg_alt_outlined;
        case "shopping_basket_outlined": return Icons.shopping_basket_outlined;
        default: return Icons.category_outlined;
      }
    }

    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: SettingsService().categoryTabs,
      builder: (context, dynamicTabs, _) {
        final categories = dynamicTabs.isEmpty ? [
          {"icon": Icons.water_drop_outlined, "name": "Water"},
          {"icon": Icons.opacity_outlined, "name": "Oils"},
          {"icon": Icons.egg_alt_outlined, "name": "Dairy"},
          {"icon": Icons.shopping_basket_outlined, "name": "Grocery"},
        ] : dynamicTabs;

        return TabBar(
          controller: _categoryTabController,
          isScrollable: false,
          indicatorColor: activeColor,
          indicatorWeight: 3.0,
          dividerColor: Colors.transparent,
          labelColor: activeColor,
          unselectedLabelColor: inactiveColor,
          labelStyle: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          tabs: categories.asMap().entries.map((entry) {
            final idx = entry.key;
            final cat = entry.value;
            
            Widget iconWidget;
            if (cat["img"] != null && cat["img"].toString().isNotEmpty) {
              iconWidget = Image.network(
                cat["img"] as String, 
                width: 26, 
                height: 26, 
                color: _categoryTabController.index == idx ? activeColor : inactiveColor
              );
            } else {
              final iconData = cat.containsKey("icon") ? cat["icon"] as IconData : getIconData(cat["iconName"] as String?);
              iconWidget = Icon(iconData, size: 26);
            }

            return Tab(
              icon: iconWidget,
              text: cat["name"] as String,
              iconMargin: const EdgeInsets.only(bottom: 4),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDecorativeLine() {
    return CustomPaint(
      size: const Size(double.infinity, 30),
      painter: ScallopedLinePainter(),
    );
  }

  // NILARA PRODUCTS SECTION (Replaces "Quick Buys")
  // Filtered dynamically based on selected category tab
  Widget _buildNilaraProductsSection() {
    if (_isLoadingProducts) return const Center(child: CircularProgressIndicator());
    
    List<ProductModel> products = [];
    String category = "Water";
    switch (_categoryTabController.index) {
      case 0: category = "Water"; break;
      case 1: category = "Oil"; break;
      case 2: category = "Dairy"; break;
      case 3: category = "Grocery"; break;
    }
    
    products = _allProducts.where((p) => p.categoryName == category || (p.categoryName != null && p.categoryName!.contains(category))).take(4).toList();
    
    if (products.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nilara Products",
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Pure water",
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "SEE ALL",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00875A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Horizontally Scrollable Cards with Bouncing/Snap Scroll Physics
          SizedBox(
            height: 235,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final item = products[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: ProductCard(
                    productId: item.id,
                    variantId: item.variantId,
                    imagePath: item.displayImage.isEmpty ? "assets/images/1L.png" : item.displayImage,
                    tags: item.displayTags,
                    title: item.name,
                    price: item.displayPrice,
                    originalPrice: item.originalPrice,
                    category: item.categoryName ?? 'Nilara',
description: item.description ?? '',
                      images: item.images,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Water Section
  Widget _buildNilaraWaterSection({String title = "Nilara Pure Water Range"}) {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final waterProducts = _allProducts.where((p) => p.categoryName == 'Water').take(4).toList();
    if (waterProducts.isEmpty) return const SizedBox.shrink();
    return Container(
      color: const Color(0xFFF0F8FF),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.water_drop,
                  color: Color(0xFF0288D1),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 235,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: waterProducts.length,
              itemBuilder: (context, index) {
                final item = waterProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: ProductCard(
                    productId: item.id,
                    variantId: item.variantId,
                    imagePath: item.displayImage.isEmpty ? "assets/images/1L.png" : item.displayImage,
                    tags: item.displayTags,
                    title: item.name,
                    price: item.displayPrice,
                    originalPrice: item.originalPrice,
                    category: item.categoryName ?? 'Nilara',
description: item.description ?? '',
                      images: item.images,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Oils Section
  Widget _buildOilsSection() {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final oilsProducts = _allProducts.where((p) => p.categoryName == 'Oil' || (p.categoryName != null && p.categoryName!.contains('Oil'))).take(4).toList();
    if (oilsProducts.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.opacity, color: Color(0xFFE65100), size: 24),
                const SizedBox(width: 8),
                Text(
                  "Premium Cooking Oils",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 235,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: oilsProducts.length,
              itemBuilder: (context, index) {
                final item = oilsProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: ProductCard(
                    productId: item.id,
                    variantId: item.variantId,
                    imagePath: item.displayImage.isEmpty ? "assets/images/1L.png" : item.displayImage,
                    tags: item.displayTags,
                    title: item.name,
                    price: item.displayPrice,
                    originalPrice: item.originalPrice,
                    category: item.categoryName ?? 'Nilara',
description: item.description ?? '',
                      images: item.images,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Cold Drinks Section
  Widget _buildColdDrinksSection() {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final drinkProducts = _allProducts.where((p) => p.categoryName == 'Dairy' || p.categoryName == 'Drinks' || (p.categoryName != null && p.categoryName!.contains('Drink'))).take(4).toList();
    if (drinkProducts.isEmpty) return const SizedBox.shrink();
    return Container(
      color: const Color(0xFFF3F7FF),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.local_drink,
                  color: Color(0xFF0D47A1),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "Chilled Beverages",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 235,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: drinkProducts.length,
              itemBuilder: (context, index) {
                final item = drinkProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: ProductCard(
                    productId: item.id,
                    variantId: item.variantId,
                    imagePath: item.displayImage.isEmpty ? "assets/images/1L.png" : item.displayImage,
                    tags: item.displayTags,
                    title: item.name,
                    price: item.displayPrice,
                    originalPrice: item.originalPrice,
                    category: item.categoryName ?? 'Nilara',
description: item.description ?? '',
                      images: item.images,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Dairy Section
  Widget _buildDairySection() {
    return const SizedBox.shrink();
  }

  // Grocery Section
  Widget _buildGrocerySection() {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final groceryProducts = _allProducts.where((p) => p.categoryName?.toLowerCase() == 'grocery').take(4).toList();
    if (groceryProducts.isEmpty) return const SizedBox.shrink();

    return Container(
      color: const Color(0xFFF4FAF5),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_basket_outlined,
                  color: Color(0xFF1B5E20),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "Daily Grocery Essentials",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 235,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: groceryProducts.length,
              itemBuilder: (context, index) {
                final item = groceryProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: ProductCard(
                    productId: item.id,
                    variantId: item.variantId,
                    imagePath: item.displayImage.isEmpty ? "assets/images/1L.png" : item.displayImage,
                    tags: item.displayTags,
                    title: item.name,
                    price: item.displayPrice,
                    originalPrice: item.originalPrice,
                    category: item.categoryName ?? 'Nilara',
description: item.description ?? '',
                      images: item.images,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF673AB7),
            Color(0xFF3F51B5),
          ], // Purple to Indigo gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF673AB7).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "8 MIN DELIVERY",
                          style: GoogleFonts.outfit(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Nilara Premium Quality",
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Pure Water, Oils & Essentials",
                        style: GoogleFonts.outfit(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.electric_bolt,
                          color: Color(0xFF673AB7),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCuratedCollections() {
    final collections = [
      {
        "title": "Hydration Store",
        "desc": "250ml to 20L Water",
        "color": const Color(0xFFE1F5FE),
      },
      {
        "title": "Healthy Oil Hub",
        "desc": "Mustard, Sunflower & Groundnut",
        "color": const Color(0xFFFFF8E1),
      },
      {
        "title": "Chill Zone",
        "desc": "Chilled Soda & Juices",
        "color": const Color(0xFFE8EAF6),
      },
      {
        "title": "Fresh Farm Dairy",
        "desc": "Milk, Paneer & Curd",
        "color": const Color(0xFFE0F2F1),
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Curated Nilara Collections",
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: collections.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                final item = collections[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item["color"] as Color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item["title"] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item["desc"] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkProductsSection() {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final bulkProducts = _allProducts.where((p) => p.categoryName == 'Bulk').take(4).toList();
    if (bulkProducts.isEmpty) return const SizedBox.shrink();
    return Container(
      color: const Color(0xFFF0F8FF),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(
                  Icons.inventory_2,
                  color: Color(0xFF0288D1),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "Bulk Products",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 235,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: bulkProducts.length,
              itemBuilder: (context, index) {
                final item = bulkProducts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 14.0),
                  child: ProductCard(
                    productId: item.id,
                    variantId: item.variantId,
                    imagePath: item.displayImage.isEmpty ? "assets/images/1L.png" : item.displayImage,
                    tags: item.displayTags,
                    title: item.name,
                    price: item.displayPrice,
                    originalPrice: item.originalPrice,
                    category: item.categoryName ?? 'Nilara',
description: item.description ?? '',
                      images: item.images,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterAttractiveSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.water_drop, size: 48, color: Colors.blue),
          const SizedBox(height: 16),
          Text(
            "Stay Hydrated, Stay Healthy!",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Nilara water is carefully purified to give you the freshest taste every day. Keep smiling! 😊",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.blue.shade800,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOilAttractiveSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.orange.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.spa, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            "Healthy Oils, Happy Hearts!",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Nilara premium cooking oils are carefully extracted to bring out the best flavor in your meals while keeping your family healthy. 😊",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.orange.shade800,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMilkAttractiveSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.teal.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, size: 48, color: Colors.teal),
          const SizedBox(height: 16),
          Text(
            "Pure Dairy, Happy Family!",
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            "Nilara brings you the freshest and highest quality dairy products directly sourced for your loved ones. 😊",
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.teal.shade800,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FeaturedWaterSection extends StatefulWidget {
  const FeaturedWaterSection({super.key});

  @override
  State<FeaturedWaterSection> createState() => _FeaturedWaterSectionState();
}

class _FeaturedWaterSectionState extends State<FeaturedWaterSection> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/water_nilara.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Featured Water",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFeatureItem("100% Pure & Safe"),
                _buildFeatureItem("Multi-stage filtration"),
                _buildFeatureItem("Added essential minerals"),
                _buildFeatureItem("Fresh crisp taste"),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                  setState(() {});
                },
                child: _controller.value.isInitialized
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                          if (!_controller.value.isPlaying)
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white70,
                                size: 48,
                              ),
                            ),
                        ],
                      )
                    : Container(
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.blue, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedOilSection extends StatefulWidget {
  const FeaturedOilSection({super.key});

  @override
  State<FeaturedOilSection> createState() => _FeaturedOilSectionState();
}

class _FeaturedOilSectionState extends State<FeaturedOilSection> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/oil_video.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Premium Cooking Oils",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFeatureItem("Cold-pressed purity"),
                _buildFeatureItem("Rich in nutrients"),
                _buildFeatureItem("No added chemicals"),
                _buildFeatureItem("Perfect for daily meals"),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                  setState(() {});
                },
                child: _controller.value.isInitialized
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                          if (!_controller.value.isPlaying)
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white70,
                                size: 48,
                              ),
                            ),
                        ],
                      )
                    : Container(
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.orange, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.orange.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerReviewsMarquee extends StatefulWidget {
  const CustomerReviewsMarquee({super.key});

  @override
  State<CustomerReviewsMarquee> createState() => _CustomerReviewsMarqueeState();
}

class _CustomerReviewsMarqueeState extends State<CustomerReviewsMarquee>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late ScrollController _scrollController;

  final List<Map<String, String>> reviews = [
    {
      "name": "Rahul S.",
      "review":
          "Nilara water quality is unmatched. Delivery in 8 minutes is a lifesaver!",
    },
    {
      "name": "Priya M.",
      "review":
          "Best cooking oils! The purity is visible and food tastes great.",
    },
    {
      "name": "Amit K.",
      "review": "Subscription feature is so easy. Never run out of water now.",
    },
    {
      "name": "Neha V.",
      "review": "Super fast delivery. Love the new chilled beverages section!",
    },
    {
      "name": "Vikram D.",
      "review": "Premium quality products at very reasonable prices.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..addListener(() {
            if (_scrollController.hasClients) {
              final maxScroll = _scrollController.position.maxScrollExtent;
              final currentScroll = _scrollController.position.pixels;

              if (currentScroll >= maxScroll) {
                _scrollController.jumpTo(0);
              } else {
                _scrollController.jumpTo(currentScroll + 1.0);
              }
            }
          })
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      color: const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  "Loved by Customers",
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 10000,
              itemBuilder: (context, index) {
                final item = reviews[index % reviews.length];
                return Container(
                  width: 280,
                  margin: EdgeInsets.only(
                    left: 16,
                    right: index == 9999 ? 16 : 0,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(
                              0xFF673AB7,
                            ).withValues(alpha: 0.1),
                            radius: 18,
                            child: Text(
                              item["name"]!.substring(0, 1),
                              style: const TextStyle(
                                color: Color(0xFF673AB7),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item["name"]!,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.format_quote,
                            color: Colors.black12,
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          item["review"]!,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BannerCarousel extends StatefulWidget {
  final String tabName;
  const BannerCarousel({super.key, this.tabName = 'Dairy'});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return;
      if (_currentLength <= 1) return; // No need to scroll if 1 or 0 items
      if (_currentPage < _currentLength - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: SettingsService().carouselBanners,
      builder: (context, banners, child) {
        final tabBanners = banners.where((b) => (b['tabName'] ?? '') == widget.tabName).toList();
        
        // Update length so timer knows when to loop
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _currentLength = tabBanners.length;
          }
        });

        if (tabBanners.isEmpty) return const SizedBox.shrink();

        return Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                if (mounted) {
                  setState(() {
                    _currentPage = page;
                  });
                }
              },
              itemCount: tabBanners.length,
              itemBuilder: (context, index) {
                final item = tabBanners[index];
                final imageSource = item['img'].toString();

                Widget imageWidget;
                if (imageSource.startsWith('http')) {
                  imageWidget = Image.network(
                    imageSource,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                    ),
                  );
                } else {
                  imageWidget = Image.asset(
                    imageSource,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
                    ),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    final actionType = item['actionType'] as String?;
                    if (actionType == 'bulk_order') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BulkOrdersScreen()),
                      );
                    } else {
                      String? searchQuery = item['searchQuery'] as String?;
                      if (searchQuery == null || searchQuery.isEmpty) {
                        searchQuery = item['tabName']?.toString().toLowerCase() ?? '';
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategoryScreen(initialSearchQuery: searchQuery, initialCategoryIndex: 2)),
                      );
                    }
                  },
                  child: imageWidget,
                );
              },
            ),
          ),
        );
      }
    );
  }
}

class FeaturedMilkSection extends StatefulWidget {
  const FeaturedMilkSection({super.key});

  @override
  State<FeaturedMilkSection> createState() => _FeaturedMilkSectionState();
}

class _FeaturedMilkSectionState extends State<FeaturedMilkSection> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/milk_video.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0.0);
        _controller.play();
        if (mounted) {
          setState(() {});
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      height: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Farm Fresh Milk",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                _buildFeatureItem("100% Pure & Fresh"),
                _buildFeatureItem("No Preservatives"),
                _buildFeatureItem("Direct from Farms"),
                _buildFeatureItem("Pasteurized safely"),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                child: _controller.value.isInitialized
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _controller.value.size.width,
                              height: _controller.value.size.height,
                              child: VideoPlayer(_controller),
                            ),
                          ),
                          if (!_controller.value.isPlaying)
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white70,
                                size: 48,
                              ),
                            ),
                        ],
                      )
                    : Container(
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.teal, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.teal.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
