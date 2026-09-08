import re

with open("apps/delivery-app/lib/screens/profile_information_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

import_str = "import 'package:google_fonts/google_fonts.dart';\nimport '../services/user_service.dart';"
content = content.replace("import 'package:google_fonts/google_fonts.dart';", import_str)

old_controllers = """  final TextEditingController _nameController = TextEditingController(text: "Rahul Sharma");
  final TextEditingController _phoneController = TextEditingController(text: "+91 98765 43210");
  final TextEditingController _emailController = TextEditingController(text: "rahul.sharma@blinkit.com");
  final TextEditingController _dobController = TextEditingController(text: "15 Aug 1996");
  final TextEditingController _emergencyController = TextEditingController(text: "+91 98111 22334");
  final TextEditingController _addressController = TextEditingController(text: "Plot 55, Jubilee Hills, Hyderabad");"""

new_controllers = """  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _emergencyController;
  late TextEditingController _addressController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = UserService().currentUser.value;
    
    _nameController = TextEditingController(text: user?.name ?? "");
    _phoneController = TextEditingController(text: user?.phone ?? "");
    _emailController = TextEditingController(text: user?.email ?? "");
    _dobController = TextEditingController(text: user?.dob ?? "");
    _emergencyController = TextEditingController(text: user?.emergencyContact ?? "");
    _addressController = TextEditingController(text: user?.address ?? "");
  }"""

content = content.replace(old_controllers, new_controllers)

# Replace the save logic
old_save = """  void _saveProfile() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile details updated successfully!", style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: const Color(0xFF1E9C1C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }"""

new_save = """  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    
    final success = await UserService().updateProfile({
      'displayName': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'dob': _dobController.text.trim(),
      'address': _addressController.text.trim(),
      'emergencyContact': _emergencyController.text.trim(),
    });
    
    if (mounted) {
      setState(() {
        _isSaving = false;
        if (success) _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Profile details updated successfully!" : "Failed to update profile",
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: success ? const Color(0xFF1E9C1C) : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }"""

content = content.replace(old_save, new_save)

# Fix the button to show loader
old_button = """                  child: Text("Save Information", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                ),"""
new_button = """                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Save Information", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                ),"""
content = content.replace(old_button, new_button)

# Fix the Header dynamic text
content = re.sub(r'Text\(\s*"Rahul Sharma",\s*style: GoogleFonts.outfit\(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold\),\s*\),', 
                 r'ValueListenableBuilder(valueListenable: UserService().currentUser, builder: (context, user, _) { return Text(user?.name ?? "", style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)); }),', 
                 content)

with open("apps/delivery-app/lib/screens/profile_information_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
