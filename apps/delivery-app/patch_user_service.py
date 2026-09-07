import re

with open("lib/services/user_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Update UserProfile
content = content.replace(
"""  final String role;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });""",
"""  final String role;
  bool onboardingComplete;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.onboardingComplete = false,
  });"""
)

# Update sync response mapping
content = content.replace(
"""            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            role: userData['role'],
          );""",
"""            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            role: userData['role'],
            onboardingComplete: userData['onboardingComplete'] ?? false,
          );"""
)

with open("lib/services/user_service.dart", "w", encoding="utf-8") as f:
    f.write(content)
