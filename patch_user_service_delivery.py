import re

with open("apps/delivery-app/lib/services/user_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

old_profile_class = """class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  bool onboardingComplete;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.onboardingComplete = false,
  });
}"""

new_profile_class = """class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  bool onboardingComplete;
  final Map<String, dynamic>? deliveryDetails;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.onboardingComplete = false,
    this.deliveryDetails,
  });
}"""

content = content.replace(old_profile_class, new_profile_class)

old_creation = """          currentUser.value = UserProfile(
            id: userData['id'] ?? '',
            name: userData['displayName'] ?? '',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            role: userData['role'],
            onboardingComplete: userData['onboardingComplete'] ?? false,
          );"""

new_creation = """          currentUser.value = UserProfile(
            id: userData['id'] ?? '',
            name: userData['displayName'] ?? '',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            role: userData['role'],
            onboardingComplete: userData['onboardingComplete'] ?? false,
            deliveryDetails: userData['deliveryDetails'],
          );"""

content = content.replace(old_creation, new_creation)

with open("apps/delivery-app/lib/services/user_service.dart", "w", encoding="utf-8") as f:
    f.write(content)
