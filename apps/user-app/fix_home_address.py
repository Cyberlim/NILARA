import re

with open("lib/screens/home_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add imports
import_str = "import 'package:blinkit_clone/screens/search_screen.dart';\n"
new_imports = """import 'package:blinkit_clone/screens/search_screen.dart';
import '../services/address_service.dart';
import 'saved_addresses_screen.dart';
"""
content = content.replace(import_str, new_imports)

# 2. Replace hardcoded address row
old_row = """                  Row(
                    children: [
                      Text(
                        "HOME",
                        style: GoogleFonts.outfit(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        " - Preetham, Plot number 55",
                        style: GoogleFonts.outfit(
                          color: secondaryTextColor,
                          fontSize: 13,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: secondaryTextColor,
                        size: 18,
                      ),
                    ],
                  ),"""

new_row = """                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SavedAddressesScreen()),
                      );
                    },
                    child: ValueListenableBuilder<List<Address>>(
                      valueListenable: AddressService().addresses,
                      builder: (context, addresses, child) {
                        String label = "LOCATION";
                        String addressText = " - Tap to select address";
                        
                        if (addresses.isNotEmpty) {
                          final defaultAddr = addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
                          label = defaultAddr.title.toUpperCase();
                          if (label.isEmpty) label = "HOME";
                          addressText = " - ${defaultAddr.addressLine1}";
                          if (addressText.length > 25) {
                            addressText = "${addressText.substring(0, 25)}...";
                          }
                        }

                        return Row(
                          children: [
                            Text(
                              label,
                              style: GoogleFonts.outfit(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              addressText,
                              style: GoogleFonts.outfit(
                                color: secondaryTextColor,
                                fontSize: 13,
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: secondaryTextColor,
                              size: 18,
                            ),
                          ],
                        );
                      }
                    ),
                  ),"""

content = content.replace(old_row, new_row)

with open("lib/screens/home_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
