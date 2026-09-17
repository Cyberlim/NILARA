import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/settings_service.dart';
import 'category_screen.dart';
import 'bulk_orders/bulk_orders_screen.dart';

// --- DYNAMIC BANNERS CAROUSEL ---
Widget buildDynamicBanners(String tabName) {
  return DynamicBannerCarousel(tabName: tabName);
}

class DynamicBannerCarousel extends StatefulWidget {
  final String tabName;
  const DynamicBannerCarousel({super.key, required this.tabName});

  @override
  State<DynamicBannerCarousel> createState() => _DynamicBannerCarouselState();
}

class _DynamicBannerCarouselState extends State<DynamicBannerCarousel> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total padding horizontally is 32 (16 left + 16 right)
    // We want 3 cards visible. Each card has a right margin of 12 (except maybe the last one).
    // Let's make exactly 3 cards fit on screen.
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - (12 * 2)) / 3.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: ValueListenableBuilder<List<Map<String, dynamic>>>(
        valueListenable: SettingsService().homeBanners,
        builder: (context, banners, child) {
          final items = banners.where((b) => (b['tabName'] ?? 'Water') == widget.tabName).toList();
          
          if (items.isEmpty) return const SizedBox.shrink();

          return SizedBox(
            height: cardWidth,
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () {
                    final actionType = item['actionType'] as String?;
                    if (actionType == 'bulk_order' || (actionType == null && index == 1)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BulkOrdersScreen()),
                      );
                    } else {
                      String? searchQuery = item['searchQuery'] as String?;
                      if (searchQuery == null) {
                        if (index == 0) searchQuery = 'bottle';
                        if (index == 2) searchQuery = '20l|can';
                        if (index == 3) searchQuery = 'carton';
                      }
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategoryScreen(initialSearchQuery: searchQuery, initialCategoryIndex: 0)),
                      );
                    }
                  },
                  child: Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: item['img'].toString().startsWith('http')
                            ? Image.network(
                                item["img"]!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.lightBlue.shade50,
                                  child: const Icon(Icons.water_drop, color: Color(0xFF0288D1), size: 36),
                                ),
                              )
                            : Image.asset(
                                item["img"]!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.lightBlue.shade50,
                                  child: const Icon(Icons.water_drop, color: Color(0xFF0288D1), size: 36),
                                ),
                              ),
                      ),
                    ),
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


// --- 2. OILS HEADER & UI ---
Widget buildOilsHeader(BuildContext context) {
  final oilTypes = [
    {
      "title": "Mustard Oil",
      "subtitle": "Kachi Ghani 1L",
      "img": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?q=80&w=400&auto=format&fit=crop"
    },
    {
      "title": "Sunflower Oil",
      "subtitle": "Refined 1L",
      "img": "https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=400&auto=format&fit=crop"
    },
    {
      "title": "Soybean Oil",
      "subtitle": "Pure Healthy 1L",
      "img": "https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1?q=80&w=400&auto=format&fit=crop"
    },
    {
      "title": "Groundnut Oil",
      "subtitle": "Cold Pressed 1L",
      "img": "https://images.unsplash.com/photo-1589927986076-2558976b34f6?q=80&w=400&auto=format&fit=crop"
    },
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Premium Cooking Oils",
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Healthy oils for every kitchen.",
          style: GoogleFonts.outfit(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: SettingsService().homeBanners,
            builder: (context, banners, child) {
              final itemsToUse = banners.where((b) => (b['tabName'] ?? '') == 'Oils').toList();
              
              if (itemsToUse.isEmpty) return const SizedBox.shrink();

              return Row(
              children: itemsToUse.take(4).map((oil) {
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  final actionType = oil['actionType'] as String?;
                  if (actionType == 'bulk_order') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BulkOrdersScreen()),
                    );
                  } else {
                    String? searchQuery = oil['searchQuery'] as String?;
                    if (searchQuery == null || searchQuery.isEmpty) {
                      searchQuery = oil['title']?.toString().toLowerCase().split(' ').first ?? '';
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScreen(initialSearchQuery: searchQuery, initialCategoryIndex: 1)),
                    );
                  }
                },
                child: Container(
                  height: 110,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        oil["img"].toString().startsWith("http")
                            ? Image.network(
                                oil["img"]!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.amber.shade100,
                                  child: const Icon(Icons.opacity, color: Colors.orange, size: 30),
                                ),
                              )
                            : Image.asset(
                                oil["img"]!,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: Colors.amber.shade100,
                                  child: const Icon(Icons.opacity, color: Colors.orange, size: 30),
                                ),
                              ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.7],
                            ),
                          ),
                        ),
                        if (oil["title"] != null)
                          Positioned(
                            bottom: 8,
                            left: 4,
                            right: 4,
                            child: Text(
                              oil["title"]!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.amberAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    ),
      ],
    ),
  );
}


// --- 3. ALL HEADER & UI ---
Widget buildAllHeader() {
  final allItems = [
    {"name": "Water", "img": "assets/images/soda.png"}, // Need an icon/image
    {"name": "Oils", "img": "assets/images/pcard2.jpg"},
    {"name": "Dairy", "img": "assets/images/milk.png"},
    {"name": "Grocery", "img": "assets/images/pcard1.jpg"},
  ];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                  "Everything You Need 🚀",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  "All your essentials in one place.",
                  style: GoogleFonts.outfit(
                    color: Colors.cyanAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.cyan.shade900.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent, width: 1),
              ),
              child: Text(
                "ALL",
                style: GoogleFonts.outfit(
                  color: Colors.cyanAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Grid/Row displaying all categories
        SizedBox(
          height: 105,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: allItems.length,
            itemBuilder: (context, index) {
              final drink = allItems[index];
              return Container(
                width: 85,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          drink["img"]!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => const Icon(Icons.local_drink, color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      drink["name"]!,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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


// --- 4. DAIRY & DRINKS HEADER & UI ---
Widget buildDairyHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                  "Dairy & Drinks Everyday",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF004D40),
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Milk, paneer, curd and more delivered fresh.",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00796B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Icon(Icons.egg_alt_outlined, color: Color(0xFF004D40), size: 30),
          ],
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: SettingsService().homeBanners,
            builder: (context, banners, child) {
              final itemsToUse = banners.where((b) => (b['tabName'] ?? '') == 'Dairy').toList();
              
              if (itemsToUse.isEmpty) return const SizedBox.shrink();

              return Row(
              children: itemsToUse.take(4).map((item) {
            return Expanded(
              child: GestureDetector(
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
                      searchQuery = item['title']?.toString().toLowerCase().split(' ').first ?? '';
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScreen(initialSearchQuery: searchQuery, initialCategoryIndex: 2)),
                    );
                  }
                },
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyan.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: item["img"].toString().startsWith('http') ? Image.network(
                        item["img"]!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.egg_alt, color: Colors.blue),
                      ) : Image.asset(
                        item["img"]!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.egg_alt, color: Colors.blue),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    ),
      ],
    ),
  );
}


// --- 5. GROCERY HEADER & UI ---
Widget buildGroceryHeader(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
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
                  "Daily Essentials 🌾",
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Everything your kitchen needs.",
                  style: GoogleFonts.outfit(
                    color: Colors.lightGreenAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.lightGreenAccent, width: 1),
              ),
              child: Text(
                "FRESH",
                style: GoogleFonts.outfit(
                  color: Colors.lightGreenAccent,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: SettingsService().homeBanners,
            builder: (context, banners, child) {
              final itemsToUse = banners.where((b) => (b['tabName'] ?? '') == 'Grocery').toList();
              
              if (itemsToUse.isEmpty) return const SizedBox.shrink();

              return Row(
              children: itemsToUse.take(4).map((item) {
            return Expanded(
              child: GestureDetector(
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
                      searchQuery = item['title']?.toString().toLowerCase().split(' ').first ?? '';
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScreen(initialSearchQuery: searchQuery, initialCategoryIndex: 3)),
                    );
                  }
                },
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        item["img"].toString().startsWith("http")
                            ? Image.network(item["img"]!, fit: BoxFit.cover)
                            : Image.asset(item["img"]!, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.green.shade900.withOpacity(0.9),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.6],
                            ),
                          ),
                        ),
                        if (item["title"] != null)
                          Positioned(
                            bottom: 8,
                            left: 4,
                            right: 4,
                            child: Text(
                              item["title"]!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    ),
      ],
    ),
  );
}
