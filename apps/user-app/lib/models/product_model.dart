class ProductVariant {
  final String id;
  final String sku;
  final int pricePaise;
  final int discountPricePaise;
  final int stockQuantity;
  final String unit;
  final double weightOrVolume;

  ProductVariant({
    required this.id,
    required this.sku,
    required this.pricePaise,
    required this.discountPricePaise,
    required this.stockQuantity,
    required this.unit,
    required this.weightOrVolume,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['_id'] ?? '',
      sku: json['sku'] ?? '',
      pricePaise: json['pricePaise'] ?? 0,
      discountPricePaise: json['discountPricePaise'] ?? json['pricePaise'] ?? 0,
      stockQuantity: json['stockQuantity'] ?? 0,
      unit: json['unit'] ?? 'piece',
      weightOrVolume: (json['weightOrVolume'] ?? 1).toDouble(),
    );
  }
}

class ProductModel {
  final String id;
  final String name;
  final String slug;
  final String description;
  final List<String> images;
  final List<ProductVariant> variants;
  final bool isActive;
  final String? categoryName;
  final String? categorySlug;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.images,
    required this.variants,
    required this.isActive,
    this.categoryName,
    this.categorySlug,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    List<ProductVariant> parsedVariants = [];
    if (json['variants'] != null) {
      json['variants'].forEach((v) {
        parsedVariants.add(ProductVariant.fromJson(v));
      });
    }

    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      variants: parsedVariants,
      isActive: json['isActive'] ?? true,
      categoryName: json['category'] != null ? json['category']['name'] : null,
      categorySlug: json['category'] != null ? json['category']['slug'] : null,
    );
  }

  // Getters for UI convenience
  String get displayPrice => '₹${((variants.isNotEmpty ? variants.first.discountPricePaise : 0) / 100).toStringAsFixed(0)}';
  String get originalPrice => '₹${((variants.isNotEmpty ? variants.first.pricePaise : 0) / 100).toStringAsFixed(0)}';
  String get displayImage => images.isNotEmpty ? images.first : '';
  
  // Tags/badges logic based on name/category/stock for now, since tags are not directly in schema
  List<String> get displayTags {
    if (categoryName?.toLowerCase() == 'water') return ['WATER'];
    if (categoryName?.toLowerCase() == 'oil') return ['OIL'];
    if (categoryName?.toLowerCase() == 'dairy') return ['DAIRY'];
    return ['NEW'];
  }
  
  String get variantId => variants.isNotEmpty ? variants.first.id : '';
}
