import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../services/cart_service.dart';
import 'cart_screen.dart';
import '../widgets/product_card.dart';
import '../services/wishlist_service.dart';
import '../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  final String variantId;
  final String title;
  final String imagePath;
  final List<String> images;
  final String price;
  final String originalPrice;
  final String unit;
  final String category;
  final String description;

  const ProductDetailScreen({
    Key? key,
    required this.productId,
    required this.variantId,
    required this.title,
    required this.imagePath,
    this.images = const [],
    required this.price,
    this.originalPrice = '',
    this.unit = 'kg',
    this.category = '',
    this.description =
        'Fresh and premium quality directly sourced from farms. Rich in essential vitamins, minerals, and natural nutrients. Carefully selected and packed to preserve peak freshness and taste.',
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  List<dynamic> _reviews = [];
  double _averageRating = 0.0;
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    WishlistService().fetchWishlist();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      final response = await http.get(Uri.parse('${Constants.baseUrl}/api/v1/reviews/product/${widget.productId}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final fetchedReviews = data['reviews'] as List<dynamic>;
          double avg = 0;
          if (fetchedReviews.isNotEmpty) {
            avg = fetchedReviews.fold(0.0, (sum, item) => sum + (item['rating'] as num)) / fetchedReviews.length;
          }
          if (mounted) {
            setState(() {
              _reviews = fetchedReviews;
              _averageRating = avg;
              _isLoadingReviews = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<Map<String, CartItem>>(
        valueListenable: CartService().items,
        builder: (context, cartItems, child) {
          final int quantity = CartService().getQuantity(widget.variantId);

          // Calculate numeric price for bottom total display
          double unitPrice = double.tryParse(
                  widget.price.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              60.0;
          double totalPrice = (quantity > 0 ? quantity : 1) * unitPrice;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Hero Section with Light Pastel Gradient
                      Container(
                        width: double.infinity,
                        height: 340,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFF5EBFB),
                              Color(0xFFFCF7FF),
                              Colors.white,
                            ],
                          ),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(36),
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Product Image Carousel
                            SizedBox(
                              height: 260,
                              child: PageView.builder(
                                onPageChanged: (index) {
                                  setState(() {
                                    _selectedImageIndex = index;
                                  });
                                },
                                itemCount: widget.images.isNotEmpty ? widget.images.length : 1,
                                itemBuilder: (context, index) {
                                  String currentImage = widget.images.isNotEmpty ? widget.images[index] : widget.imagePath;
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 40.0, bottom: 30),
                                      child: currentImage.startsWith('http')
                                          ? Image.network(
                                              currentImage,
                                              height: 200,
                                              fit: BoxFit.contain,
                                              errorBuilder: (c, e, s) => const Icon(
                                                Icons.image_not_supported,
                                                size: 50,
                                                color: Colors.grey,
                                              ),
                                            )
                                          : Image.asset(
                                              currentImage,
                                              height: 200,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Image.network(
                                                currentImage,
                                                height: 200,
                                                fit: BoxFit.contain,
                                                errorBuilder: (c, e, s) => const Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Back Button
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 12,
                              left: 16,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new,
                                    size: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            // Wishlist Button
                            Positioned(
                              top: MediaQuery.of(context).padding.top + 12,
                              right: 16,
                              child: ValueListenableBuilder<List<ProductModel>>(
                                valueListenable: WishlistService().items,
                                builder: (context, wishlistItems, child) {
                                  final isWishlisted = wishlistItems.any((item) => item.id == widget.productId);
                                  return GestureDetector(
                                    onTap: () {
                                      final dummyProduct = ProductModel(
                                        id: widget.productId,
                                        name: widget.title,
                                        slug: '',
                                        description: widget.description,
                                        images: widget.images.isNotEmpty ? widget.images : [widget.imagePath],
                                        variants: [
                                          ProductVariant(
                                            id: widget.variantId,
                                            sku: '',
                                            pricePaise: int.tryParse(widget.price.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                                            discountPricePaise: 0,
                                            stockQuantity: 100,
                                            unit: widget.unit,
                                            weightOrVolume: 1,
                                          )
                                        ],
                                        isActive: true,
                                      );
                                      WishlistService().toggleWishlist(dummyProduct);
                                      if (!isWishlisted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Added to wishlist', style: GoogleFonts.outfit()),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Removed from wishlist', style: GoogleFonts.outfit()),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(seconds: 1),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 8,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                                        size: 18,
                                        color: isWishlisted ? Colors.red : Colors.black87,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Page Dots Indicator (only show if multiple images)
                            if (widget.images.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(widget.images.length, (index) {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: _selectedImageIndex == index ? 10 : 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _selectedImageIndex == index
                                            ? const Color(0xFF00875A)
                                            : Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Title, Rating & Quantity Counter
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _reviews.isEmpty ? "0.0 " : "${_averageRating.toStringAsFixed(1)} ",
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        "(${_reviews.length})",
                                        style: GoogleFonts.outfit(
                                          color: Colors.grey.shade500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Selector Controls
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Quantity",
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          if (quantity > 0) {
                                            CartService()
                                                .removeItem(widget.variantId);
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.grey.shade400),
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            size: 14,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0),
                                        child: Text(
                                          (quantity > 0 ? quantity : 0)
                                              .toString(),
                                          style: GoogleFonts.outfit(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                            CartService().addItem(
                                                widget.productId,
                                                widget.variantId,
                                                widget.title,
                                                widget.imagePath,
                                                widget.price);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.teal.shade50,
                                            border: Border.all(
                                                color: const Color(0xFF00875A)),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            size: 14,
                                            color: Color(0xFF00875A),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // About Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "About",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.description.isNotEmpty 
                                  ? widget.description 
                                  : 'Fresh and premium quality directly sourced from farms. Rich in essential vitamins, minerals, and natural nutrients. Carefully selected and packed to preserve peak freshness and taste.',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Customer Reviews Section
                      _buildReviewSection(),

                      const SizedBox(height: 24),

                      // Recommended Products
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "Recommended for you",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 260,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: _getRecommendedProducts(widget.category)
                              .map((item) => Padding(
                                    padding: const EdgeInsets.only(right: 14.0),
                                    child: ProductCard(
                                        productId: item["productId"] as String? ?? 'mock-id',
                                        variantId: item["variantId"] as String? ?? 'mock-variant-id',
                                        imagePath: item["image"] as String,
                                      tags: List<String>.from(item["tags"] as List),
                                      title: item["title"] as String,
                                      price: item["price"] as String,
                                      originalPrice: item["originalPrice"] as String,
                                      category: item["category"] as String,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              if (cartItems.isNotEmpty)
                _buildFloatingCartBanner(cartItems, context),

              // Bottom Bar: Add to Cart & Buy
              SafeArea(
                bottom: true,
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 20),
                  decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                            if (quantity == 0) {
                              CartService().addItem(widget.productId, widget.variantId, widget.title, widget.imagePath, widget.price);
                            } else {
                              CartService().addItem(widget.productId, widget.variantId, widget.title, widget.imagePath, widget.price);
                            }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Item added to cart!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00875A),
                          side: const BorderSide(color: Color(0xFF00875A), width: 1.8),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Add to Cart",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00875A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (quantity == 0) {
                            CartService().addItem(widget.productId, widget.variantId, widget.title, widget.imagePath, widget.price);
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CartScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00875A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Buy Now",
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ), // Closes SafeArea
            ],
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getRecommendedProducts(String category) {
    if (category.toLowerCase() == 'water') {
      return [
        {
          "title": "200ml water",
          "image": "assets/images/200ml_normal.png",
          "price": "₹10",
          "originalPrice": "₹15",
          "category": "Water",
          "tags": ["Pure"],
        },
        {
          "title": "500ml water",
          "image": "assets/images/500ml_water.png",
          "price": "₹20",
          "originalPrice": "₹25",
          "category": "Water",
          "tags": ["Mineral"],
        },
        {
          "title": "2L water",
          "image": "assets/images/2L_water.png",
          "price": "₹50",
          "originalPrice": "₹60",
          "category": "Water",
          "tags": ["Family"],
        },
      ];
    } else if (category.toLowerCase() == 'oil') {
      return [
        {
          "title": "Nilara Mustard Oil 1 L",
          "image": "assets/images/nilara1lmustardoil.png",
          "price": "₹165",
          "originalPrice": "₹190",
          "category": "Oil",
          "tags": ["Cold Pressed"],
        },
        {
          "title": "Nilara Sunflower Oil 1 L",
          "image": "assets/images/1lsunfloweroil.png",
          "price": "₹145",
          "originalPrice": "₹170",
          "category": "Oil",
          "tags": ["Refined"],
        },
      ];
    }
    // Default fallback
    return [
      {
        "title": "Fresh Apple",
        "image": "assets/images/pcard3.webp",
        "price": "₹120",
        "originalPrice": "₹150",
        "category": "Grocery",
        "tags": ["Fresh"],
      },
      {
        "title": "Banana",
        "image": "assets/images/pcard2.jpg",
        "price": "₹48",
        "originalPrice": "₹60",
        "category": "Grocery",
        "tags": ["Organic"],
      },
    ];
  }

  Widget _buildReviewSection() {
    if (_isLoadingReviews) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text("No reviews yet.", style: GoogleFonts.outfit(color: Colors.grey.shade500)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Customer Reviews",
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._reviews.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _buildDummyReview(
              r['user']?['displayName'] ?? "Anonymous",
              r['comment'] ?? "",
              r['rating'] ?? 5,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDummyReview(String name, String review, int stars) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: index < stars ? Colors.amber : Colors.grey.shade300,
                  ),
                ),
              ),
            ],
          ),
          if (review.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review,
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFloatingCartBanner(Map<String, CartItem> cartItems, BuildContext context) {
    if (cartItems.isEmpty) return const SizedBox.shrink();

    final totalItems = CartService().getTotalItems();
    final firstItemImage = cartItems.values.first.imagePath;

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12, top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00875A), // Premium Nilara green
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
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
              mainAxisSize: MainAxisSize.min,
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
  }
}
