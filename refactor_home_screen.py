import re

with open('apps/user-app/lib/screens/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace _buildNilaraProductsSection
nilara_regex = re.compile(r'Widget _buildNilaraProductsSection\(\) \{.*?return Container\(', re.DOTALL)
nilara_replacement = '''Widget _buildNilaraProductsSection() {
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

    return Container('''
content = nilara_regex.sub(nilara_replacement, content)

# Update ProductCard inside _buildNilaraProductsSection
# It maps item["image"]! etc.
# Actually, let's just do a blanket replacement of ProductCard in ListView.builder for these sections.
old_product_card_mapping = '''ProductCard(
                    imagePath: item["image"]!,
                    tags: [item["category"]!],
                    title: item["title"]!,
                    price: item["price"]!,
                    originalPrice: item["originalPrice"]!,
                    category: item["category"]!,
                  )'''
new_product_card_mapping = '''ProductCard(
                    productId: item.id,
                    variantId: item.variantId,
                    imagePath: item.displayImage.isEmpty ? "assets/images/1L.png" : item.displayImage,
                    tags: item.displayTags,
                    title: item.name,
                    price: item.displayPrice,
                    originalPrice: item.originalPrice,
                    category: item.categoryName ?? 'Nilara',
                  )'''
content = content.replace(old_product_card_mapping, new_product_card_mapping)

# Same for the other sections:
# _buildNilaraWaterSection
water_regex = re.compile(r'Widget _buildNilaraWaterSection\(\{String title = "Nilara Pure Water Range"\}\) \{.*?return Container\(', re.DOTALL)
water_replacement = '''Widget _buildNilaraWaterSection({String title = "Nilara Pure Water Range"}) {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final waterProducts = _allProducts.where((p) => p.categoryName == 'Water').take(4).toList();
    if (waterProducts.isEmpty) return const SizedBox.shrink();
    return Container('''
content = water_regex.sub(water_replacement, content)

# _buildOilsSection
oils_regex = re.compile(r'Widget _buildOilsSection\(\) \{.*?return Container\(', re.DOTALL)
oils_replacement = '''Widget _buildOilsSection() {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final oilsProducts = _allProducts.where((p) => p.categoryName == 'Oil' || (p.categoryName != null && p.categoryName!.contains('Oil'))).take(4).toList();
    if (oilsProducts.isEmpty) return const SizedBox.shrink();
    return Container('''
content = oils_regex.sub(oils_replacement, content)

# _buildColdDrinksSection
drinks_regex = re.compile(r'Widget _buildColdDrinksSection\(\) \{.*?return Container\(', re.DOTALL)
drinks_replacement = '''Widget _buildColdDrinksSection() {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final drinkProducts = _allProducts.where((p) => p.categoryName == 'Dairy' || p.categoryName == 'Drinks' || (p.categoryName != null && p.categoryName!.contains('Drink'))).take(4).toList();
    if (drinkProducts.isEmpty) return const SizedBox.shrink();
    return Container('''
content = drinks_regex.sub(drinks_replacement, content)

# _buildGrocerySection
grocery_regex = re.compile(r'Widget _buildGrocerySection\(\) \{.*?return Container\(', re.DOTALL)
grocery_replacement = '''Widget _buildGrocerySection() {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final groceryProducts = _allProducts.where((p) => p.categoryName == 'Grocery').take(4).toList();
    if (groceryProducts.isEmpty) return const SizedBox.shrink();
    return Container('''
content = grocery_regex.sub(grocery_replacement, content)

# _buildBulkProductsSection
bulk_regex = re.compile(r'Widget _buildBulkProductsSection\(\) \{.*?return Container\(', re.DOTALL)
bulk_replacement = '''Widget _buildBulkProductsSection() {
    if (_isLoadingProducts) return const SizedBox.shrink();
    final bulkProducts = _allProducts.where((p) => p.categoryName == 'Bulk').take(4).toList();
    if (bulkProducts.isEmpty) return const SizedBox.shrink();
    return Container('''
content = bulk_regex.sub(bulk_replacement, content)

# Also fix the ProductCard mapping inside these sections:
# the variable might be named differently (e.g. inal item = waterProducts[index];) but it maps the same way: imagePath: item["image"]!
# We can just replace the old mappings with the new one we defined. We did content.replace(old, new). But wait, in other sections, tags might be hardcoded like 	ags: item.containsKey("tags") ? item["tags"] as List<String> : ["SALE"],.

content = re.sub(r'ProductCard\(\s*imagePath:\s*item\["image"\][^\)]+category:\s*item\["category"\].*?\)', new_product_card_mapping, content)

with open('apps/user-app/lib/screens/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Done")
