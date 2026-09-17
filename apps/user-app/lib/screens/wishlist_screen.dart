import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/wishlist_service.dart';
import '../models/product_model.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WishlistService().fetchWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          "My Wishlist",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<List<ProductModel>>(
        valueListenable: WishlistService().items,
        builder: (context, items, child) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Your wishlist is empty",
                    style: GoogleFonts.outfit(color: Colors.grey.shade600, fontSize: 18),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final product = items[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: product.images.isNotEmpty && product.images.first.startsWith("http")
                            ? Image.network(product.images.first, height: 60)
                            : const Icon(Icons.broken_image),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${(product.variants.first.pricePaise / 100).toStringAsFixed(0)}",
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF168BDB)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            WishlistService().toggleWishlist(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Removed from wishlist", style: GoogleFonts.outfit())),
                            );
                          },
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (product.variants.isNotEmpty) {
                              WishlistService().moveToCart(product, product.variants.first.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Moved to cart", style: GoogleFonts.outfit()), backgroundColor: Colors.green),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF168BDB),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: Text("Move", style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<List<ProductModel>>(
        valueListenable: WishlistService().items,
        builder: (context, items, child) {
          if (items.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () {
                  final currentItems = List<ProductModel>.from(items);
                  for (var product in currentItems) {
                    if (product.variants.isNotEmpty) {
                      WishlistService().moveToCart(product, product.variants.first.id);
                    }
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("All items moved to cart", style: GoogleFonts.outfit()),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF168BDB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  "Move All to Cart",
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
