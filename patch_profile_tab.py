import re

with open("apps/delivery-app/lib/screens/profile_tab.dart", "r", encoding="utf-8") as f:
    content = f.read()

import_str = "import '../services/user_service.dart';\nimport 'profile_information_screen.dart';"
content = content.replace("import 'profile_information_screen.dart';", import_str)

old_card = """                        children: [
                          Row(
                            children: [
                              Text("Rahul Sharma", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: Color(0xFF1E9C1C), size: 16),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text("Partner ID: #BLK-89042", style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 2),
                          Text("+91 98765 43210", style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        ],"""

new_card = """                        children: [
                          ValueListenableBuilder(
                            valueListenable: UserService().currentUser,
                            builder: (context, user, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(user?.name ?? "", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.verified, color: Color(0xFF1E9C1C), size: 16),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text("Partner ID: #${user?.id.substring(user.id.length - 6).toUpperCase() ?? '000000'}", style: GoogleFonts.outfit(fontSize: 12, color: Colors.black54)),
                                  const SizedBox(height: 2),
                                  Text(user?.phone ?? "", style: GoogleFonts.outfit(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                                ],
                              );
                            }
                          ),
                        ],"""

content = content.replace(old_card, new_card)

with open("apps/delivery-app/lib/screens/profile_tab.dart", "w", encoding="utf-8") as f:
    f.write(content)
