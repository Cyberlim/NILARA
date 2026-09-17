class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String imageUrl;
  final String? bannerTitle;
  final String? iconName;
  final List<String> subcategories;
  final bool isActive;
  final int sortOrder;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    this.bannerTitle,
    this.iconName,
    this.subcategories = const [],
    this.isActive = true,
    this.sortOrder = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      bannerTitle: json['bannerTitle'],
      iconName: json['iconName'],
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}
