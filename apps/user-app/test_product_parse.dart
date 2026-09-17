import 'dart:convert';

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
}

void main() {
  final jsonString = '''{
  "_id": "6a89ccb7da279da7548c9fdf",
  "name": "nilara bottle",
  "slug": "nilara-bottle",
  "description": "fresh and premium quality",
  "category": {
    "_id": "6a8990195ae8431cd148b39f",
    "name": "Water",
    "slug": "water"
  },
  "images": [
    "https://res.cloudinary.com/xkzptzzq/image/upload/v1787415725/nilara/ak4kzailoh5hjyk4pwfb.png"
  ],
  "variants": [
    {
      "sku": "NIL-2500 ML",
      "pricePaise": 3488,
      "discountPricePaise": 3000,
      "stockQuantity": 55,
      "unit": "ml",
      "weightOrVolume": 250,
      "isActive": true,
      "_id": "6a89ccb7da279da7548c9fe0"
    }
  ],
  "isActive": true,
  "createdAt": "2026-08-22T16:22:15.111Z",
  "updatedAt": "2026-08-22T16:22:15.111Z"
}''';

  final map = json.decode(jsonString);
  try {
    final prod = ProductModel.fromJson(map);
    print('Success: \${prod.id}');
  } catch (e, stack) {
    print('Error: \$e\\n\$stack');
  }
}
