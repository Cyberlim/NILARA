import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() => _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  final TextEditingController _nameController = TextEditingController(text: "Rahul Sharma");
  final TextEditingController _phoneController = TextEditingController(text: "+91 98765 43210");
  final TextEditingController _emailController = TextEditingController(text: "rahul.sharma@blinkit.com");
  final TextEditingController _dobController = TextEditingController(text: "15 Aug 1996");
  final TextEditingController _emergencyController = TextEditingController(text: "+91 98111 22334");
  final TextEditingController _addressController = TextEditingController(text: "Plot 55, Jubilee Hills, Hyderabad");

  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _emergencyController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Profile details updated successfully!", style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: const Color(0xFF1E9C1C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Personal Information",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined, color: const Color(0xFF1E9C1C)),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E9C1C), Color(0xFF146B12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1E9C1C).withValues(alpha: 0.25), blurRadius: 14, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(Icons.person, size: 40, color: Color(0xFF1E9C1C)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Rahul Sharma",
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, color: Colors.white, size: 18),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Partner ID: #BLK-89042",
                          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Verified Nilara Executive 🟢",
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text("Personal Details", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 14),

            _buildDetailTile(
              label: "Full Name",
              controller: _nameController,
              icon: Icons.person_outline,
              enabled: _isEditing,
            ),
            _buildDetailTile(
              label: "Mobile Number",
              controller: _phoneController,
              icon: Icons.phone_android_outlined,
              enabled: false, // Phone locked for security
              trailingBadge: "Verified",
            ),
            _buildDetailTile(
              label: "Email Address",
              controller: _emailController,
              icon: Icons.email_outlined,
              enabled: _isEditing,
            ),
            _buildDetailTile(
              label: "Date of Birth",
              controller: _dobController,
              icon: Icons.cake_outlined,
              enabled: _isEditing,
            ),

            const SizedBox(height: 24),

            Text("Address & Hub Info", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 14),

            _buildDetailTile(
              label: "Residential Address",
              controller: _addressController,
              icon: Icons.home_outlined,
              enabled: _isEditing,
            ),
            _buildDetailTile(
              label: "Emergency Contact",
              controller: _emergencyController,
              icon: Icons.contact_phone_outlined,
              enabled: _isEditing,
            ),

            const SizedBox(height: 24),

            // Store Assignment Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E9C1C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront, color: Color(0xFF1E9C1C), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Assigned Dark Store", style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(height: 2),
                        Text("Jubilee Hills Hub #104", style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text("Joined: 12 Jan 2024 (1.5 Yrs Active)", style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E9C1C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text("Save Information", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool enabled,
    String? trailingBadge,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: enabled ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: enabled ? const Color(0xFF1E9C1C) : Colors.grey.shade200, width: enabled ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E9C1C), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                enabled
                    ? TextField(
                        controller: controller,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                      )
                    : Text(
                        controller.text,
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                      ),
              ],
            ),
          ),
          if (trailingBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trailingBadge,
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF1E9C1C)),
              ),
            ),
        ],
      ),
    );
  }
}
