const fs = require('fs');
let content = fs.readFileSync('apps/user-app/lib/screens/home_screen.dart', 'utf8');

const targetStr = `                  child: ProductCard(
                    imagePath: item["image"] as String,
                    tags: List<String>.from(item["tags"] as List),
                    title: item["title"] as String,
                    price: item["price"] as String,
                    originalPrice: item["originalPrice"] as String,
                    category: item["category"] as String,
                  ),`;

const replaceStr = `                  child: ProductCard(
                    productId: item.id,
                    variantId: item.variantId,
                    imagePath: item.displayImage.isEmpty ? 'assets/images/1L.png' : item.displayImage,
                    tags: item.displayTags,
                    title: item.name,
                    price: item.displayPrice,
                    originalPrice: item.originalPrice,
                    category: item.categoryName ?? 'Nilara',
                  ),`;

content = content.split(targetStr).join(replaceStr);

fs.writeFileSync('apps/user-app/lib/screens/home_screen.dart', content, 'utf8');
console.log('Replaced occurrences.');
