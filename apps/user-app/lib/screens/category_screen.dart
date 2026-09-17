import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/product_card.dart';
import 'main_navigation_screen.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'search_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String? initialSearchQuery;
  final int initialCategoryIndex;
  const CategoryScreen({Key? key, this.initialSearchQuery, this.initialCategoryIndex = 0}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late int _selectedCategoryIndex;
  bool _isLoading = true;
  List<ProductModel> _allProducts = [];
  String? _searchQuery;

  final List<Map<String, dynamic>> categories = [
    {
      "name": "Water",
      "icon": Icons.water_drop_outlined,
      "image": "assets/images/1L.png",
      "bannerTitle": "Nilara Pure Water",
      "subcategories": ["250 ml", "500 ml", "1 Litre", "2 Litre", "5 L Jar", "20 L Can"],
    },
    {
      "name": "Oil",
      "icon": Icons.opacity_outlined,
      "image": "assets/images/nilara1lmustardoil.png",
      "bannerTitle": "Nilara Cooking Oils",
      "subcategories": ["Mustard Oil 1L", "Sunflower Oil 1L", "Mustard Oil 5L", "Groundnut Oil 5L"],
    },
    {
      "name": "Dairy",
      "icon": Icons.egg_alt_outlined,
      "image": "assets/images/milk.png",
      "bannerTitle": "Fresh Dairy Every Day",
      "subcategories": ["Fresh Milk", "Paneer & Curd", "Butter & Spread", "Cheese"],
    },
    {
      "name": "Grocery",
      "icon": Icons.shopping_basket_outlined,
      "image": "assets/images/bread.png",
      "bannerTitle": "Daily Essentials",
      "subcategories": ["Basmati Rice", "Chakki Atta", "Dals & Pulses", "Sugar & Salt"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex;
    _searchQuery = widget.initialSearchQuery;
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await ProductService().getProducts();
      setState(() {
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(int index) {
    if (_selectedCategoryIndex == index) return;
    setState(() {
      _selectedCategoryIndex = index;
      _searchQuery = null;
    });
  }

  Widget _buildSkeletonLoader() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(18),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentCat = categories[_selectedCategoryIndex];
    var catProducts = _allProducts.where((p) => 
      p.categoryName?.toLowerCase() == currentCat["name"].toString().toLowerCase()
    ).toList();

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      String normalizedQuery = _searchQuery!.replaceAll(' ', '').toLowerCase();
      List<String> terms = normalizedQuery.split('|');
      catProducts = catProducts.where((p) {
        String pName = p.name.replaceAll(' ', '').toLowerCase();
        return terms.any((term) => pName.contains(term));
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                (route) => false,
              );
            }
          },
        ),
        title: Text(
          "Nilara Categories",
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black, size: 26),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(allProducts: _allProducts),
                ),
              );
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar
          Container(
            width: 85,
            color: Colors.white,
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () => _onCategorySelected(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: isSelected
                        ? const BoxDecoration(
                            color: Color(0xFFE5F3EA),
                            border: Border(left: BorderSide(color: Colors.green, width: 4)),
                          )
                        : null,
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.green.shade100 : const Color(0xFFF4F6F9),
                          ),
                          child: Icon(
                            categories[index]["icon"] as IconData,
                            color: isSelected ? Colors.green.shade800 : Colors.grey.shade700,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          categories[index]["name"] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.green.shade800 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Right Content Area
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: _isLoading
                      ? _buildSkeletonLoader()
                      : ListView(
                          padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 160),
                          children: [
                            // Banner
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.08),
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
                                    currentCat["image"].toString().startsWith('http')
                                        ? Image.network(currentCat["image"], fit: BoxFit.cover)
                                        : Image.asset(currentCat["image"], fit: BoxFit.cover),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            currentCat["bannerTitle"] as String,
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Delivered in 8 mins",
                                            style: GoogleFonts.outfit(
                                              color: Colors.amberAccent,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Subcategories Horizontal Chips
                            SizedBox(
                              height: 36,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: (currentCat["subcategories"] as List).length,
                                itemBuilder: (context, idx) {
                                  final sub = (currentCat["subcategories"] as List)[idx];
                                  final isSelected = _searchQuery == sub;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (_searchQuery == sub) {
                                          _searchQuery = null;
                                        } else {
                                          _searchQuery = sub;
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFE5F3EA) : Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
                                      ),
                                      child: Text(
                                        sub,
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? Colors.green.shade800 : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Product Grid
                            catProducts.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.only(top: 40),
                                    child: Center(child: Text("No products found")),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: catProducts.length,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      childAspectRatio: 0.62,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemBuilder: (context, pIdx) {
                                      final p = catProducts[pIdx];
                                      return ProductCard(
                                        productId: p.id,
                                        variantId: p.variantId,
                                        imagePath: p.displayImage.isEmpty ? "assets/images/1L.png" : p.displayImage,
                                        tags: p.displayTags,
                                        title: p.name,
                                        price: p.displayPrice,
                                        originalPrice: p.originalPrice,
                                        category: p.categoryName ?? 'Nilara',
                                      );
                                    },
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
}
