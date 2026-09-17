import re

with open("lib/screens/product_detail_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# I will find the children list of the Stack.
old_stack = """                        child: Stack(
                          children: [
                            // Back Button
                            Positioned("""

# Actually it's easier to just swap the PageView and the Back Button manually or via a script.
# Let's use a regex to grab the Back Button, Wishlist Button, and PageView, then reorder them.
# The PageView section starts at: // Product Image Carousel
# and ends right before: // Page Dots Indicator

start_carousel = content.find("// Product Image Carousel")
end_carousel = content.find("// Page Dots Indicator", start_carousel)
carousel_code = content[start_carousel:end_carousel]

start_back_btn = content.find("// Back Button")
back_btn_and_wishlist = content[start_back_btn:start_carousel]

# Reconstruct
new_content = content[:start_back_btn] + carousel_code + back_btn_and_wishlist + content[end_carousel:]

with open("lib/screens/product_detail_screen.dart", "w", encoding="utf-8") as f:
    f.write(new_content)
