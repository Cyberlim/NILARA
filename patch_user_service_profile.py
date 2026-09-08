import re

with open("apps/delivery-app/lib/services/user_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add fields to UserProfile
old_class = """class UserProfile {
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

new_class = """class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  bool onboardingComplete;
  final Map<String, dynamic>? deliveryDetails;
  final String? dob;
  final String? address;
  final String? emergencyContact;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.onboardingComplete = false,
    this.deliveryDetails,
    this.dob,
    this.address,
    this.emergencyContact,
  });
}"""

content = content.replace(old_class, new_class)

# 2. Add them to instantiation in syncUser
old_inst = """          currentUser.value = UserProfile(
            id: userData['id'] ?? '',
            name: userData['displayName'] ?? '',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            role: userData['role'],
            onboardingComplete: userData['onboardingComplete'] ?? false,
            deliveryDetails: userData['deliveryDetails'],
          );"""

new_inst = """          currentUser.value = UserProfile(
            id: userData['id'] ?? '',
            name: userData['displayName'] ?? '',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            role: userData['role'],
            onboardingComplete: userData['onboardingComplete'] ?? false,
            deliveryDetails: userData['deliveryDetails'],
            dob: userData['dob'],
            address: userData['address'],
            emergencyContact: userData['emergencyContact'],
          );"""

content = content.replace(old_inst, new_inst)

# 3. Add updateProfile method
new_method = """
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final tkn = token.value;
    if (tkn == null) return false;
    
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/delivery/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $tkn',
        },
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        // Re-sync with backend to get the updated fields securely
        await _syncWithBackend(tkn);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }
"""

content = content.replace("  Future<void> logout() async {", new_method + "\n  Future<void> logout() async {")

with open("apps/delivery-app/lib/services/user_service.dart", "w", encoding="utf-8") as f:
    f.write(content)
