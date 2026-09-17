import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/cart_service.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final String productId;
  final String variantId;
  final String imagePath;
  final List<String> tags;
  final String title;
  final String price;
  final String originalPrice;
  final String category;
  final String description;
  final List<String> images;

  const ProductCard({
    super.key,
    required this.productId,
    required this.variantId,
    required this.imagePath,
    required this.tags,
    required this.title,
    required this.price,
    required this.originalPrice,
    this.category = '',
    this.description = '',
    this.images = const [],
  });

  Widget _buildProductImage() {
    if (imagePath.startsWith('http')) {
      return Image.network(
        imagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          color: const Color(0xFFF7F9FC),
          child: const Center(
            child: Icon(Icons.water_drop_outlined, color: Colors.blueAccent, size: 36),
          ),
        ),
      );
    }
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => Image.network(
        imagePath,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (c, e, s) => Container(
          color: const Color(0xFFF7F9FC),
          child: const Center(
            child: Icon(Icons.shopping_bag_outlined, color: Colors.blueAccent, size: 36),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, CartItem>>(
      valueListenable: CartService().items,
      builder: (context, cartItems, child) {
        final int quantity = cartItems[productId]?.quantity ?? 0;

        Widget buildAddButton() {
          if (quantity == 0) {
            return InkWell(
              onTap: () {
                CartService().addItem(productId, variantId, title, imagePath, price);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF00875A), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00875A).withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  "ADD",
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF00875A),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            );
          } else {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF00875A),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00875A).withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => CartService().removeItem(productId),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.remove, color: Colors.white, size: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      quantity.toString(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => CartService().addItem(productId, variantId, title, imagePath, price),
                    child: const Padding(
                      padding: EdgeInsets.all(2.0),
                      child: Icon(Icons.add, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            );
          }
        }

        final displayTag = category.isNotEmpty
            ? category
            : (tags.isNotEmpty ? tags.first : 'Nilara');

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  productId: productId,
                  variantId: variantId,
                  title: title,
                  imagePath: imagePath,
                  images: images,
                  price: price,
                  originalPrice: originalPrice,
                  category: category,
                  description: description,
                ),
              ),
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 155,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18), // 18px rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Area with Centered Product & Category Tag
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFAFBFD),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        child: Center(
                          child: _buildProductImage(),
                        ),
                      ),
                      // Small Category Chip
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade200, width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            displayTag.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF00796B),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Product Details Area
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1E293B),
                            height: 1.2,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (originalPrice.isNotEmpty)
                                  Text(
                                    originalPrice,
                                    style: GoogleFonts.outfit(
                                      fontSize: 10,
                                      color: Colors.grey.shade400,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Text(
                                  price,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                            buildAddButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
