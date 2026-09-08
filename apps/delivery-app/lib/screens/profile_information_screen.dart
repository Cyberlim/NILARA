import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/user_service.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() => _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  late TextEditingController _nameController;
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
    _dobController = TextEditingController(text: _formatToDDMMYYYY(user?.dob));
    _emergencyController = TextEditingController(text: user?.emergencyContact ?? "");
    _addressController = TextEditingController(text: user?.address ?? "");
  }

  String _formatToDDMMYYYY(String? raw) {
    if (raw == null || raw.trim().isEmpty) return "";
    final trimmed = raw.trim();
    final ddMmYyyyRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
    if (ddMmYyyyRegex.hasMatch(trimmed)) return trimmed;

    final parsed = DateTime.tryParse(trimmed);
    if (parsed != null) {
      final day = parsed.day.toString().padLeft(2, '0');
      final month = parsed.month.toString().padLeft(2, '0');
      final year = parsed.year.toString();
      return "$day/$month/$year";
    }
    return trimmed;
  }

  Future<void> _pickDob() async {
    DateTime initialDate = DateTime(2000, 1, 1);
    
    if (_dobController.text.isNotEmpty) {
      try {
        final parts = _dobController.text.split('/');
        if (parts.length == 3) {
          final d = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final y = int.parse(parts[2]);
          initialDate = DateTime(y, m, d);
        } else {
          final parsed = DateTime.tryParse(_dobController.text);
          if (parsed != null) initialDate = parsed;
        }
      } catch (_) {}
    }

    final DateTime maxDate = DateTime(DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
    if (initialDate.isAfter(maxDate)) {
      initialDate = maxDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: maxDate,
      helpText: "SELECT DATE OF BIRTH (DD/MM/YYYY)",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E9C1C),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      setState(() {
        _dobController.text = "$day/$month/$year";
      });
    }
  }

  String _formatJoinedDate(UserProfile? user) {
    if (user == null) return "Joined: Recently";
    DateTime? dt;
    final deliveryDetails = user.deliveryDetails;
    if (deliveryDetails != null &&
        deliveryDetails['joinedDate'] != null &&
        deliveryDetails['joinedDate'].toString().trim().isNotEmpty) {
      final raw = deliveryDetails['joinedDate'].toString().trim();
      dt = DateTime.tryParse(raw);
      if (dt == null) return "Joined: $raw";
    }
    if (dt == null && user.createdAt != null && user.createdAt!.isNotEmpty) {
      dt = DateTime.tryParse(user.createdAt!);
    }

    if (dt != null) {
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      final dateFormatted = "${dt.day} ${months[dt.month - 1]} ${dt.year}";
      final diffDays = DateTime.now().difference(dt).inDays;
      String activeDuration;
      if (diffDays >= 365) {
        final yrs = (diffDays / 365).toStringAsFixed(1);
        activeDuration = " ($yrs Yrs Active)";
      } else if (diffDays >= 30) {
        final monthsActive = (diffDays / 30).floor();
        activeDuration = " ($monthsActive Month${monthsActive > 1 ? 's' : ''} Active)";
      } else if (diffDays > 0) {
        activeDuration = " ($diffDays Day${diffDays > 1 ? 's' : ''} Active)";
      } else {
        activeDuration = " (Joined Today)";
      }
      return "Joined: $dateFormatted$activeDuration";
    }
    return "Joined: Recently";
  }

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

  Future<void> _saveProfile() async {
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
                  ValueListenableBuilder<UserProfile?>(
                    valueListenable: UserService().currentUser,
                    builder: (context, user, _) {
                      final hasPhoto = user?.photoUrl != null && user!.photoUrl!.isNotEmpty;
                      return Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xFFE8F5E9),
                          backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
                          child: hasPhoto ? null : const Icon(Icons.person, size: 40, color: Color(0xFF1E9C1C)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ValueListenableBuilder<UserProfile?>(
                      valueListenable: UserService().currentUser,
                      builder: (context, user, _) {
                        final shortId = (user != null && user.id.length > 6)
                            ? user.id.substring(user.id.length - 6).toUpperCase()
                            : (user?.id ?? '000000');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  user?.name ?? "",
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: Colors.white, size: 18),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Partner ID: #$shortId",
                              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatJoinedDate(user),
                              style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
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
                        );
                      },
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
              hintText: "Enter full name",
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
              hintText: "Enter email address",
            ),
            _buildDetailTile(
              label: "Date of Birth (DD/MM/YYYY)",
              controller: _dobController,
              icon: Icons.cake_outlined,
              enabled: _isEditing,
              hintText: "DD/MM/YYYY",
              readOnly: true,
              onTap: _isEditing ? _pickDob : null,
              trailingWidget: _isEditing
                  ? IconButton(
                      icon: const Icon(Icons.calendar_month, color: Color(0xFF1E9C1C), size: 22),
                      onPressed: _pickDob,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  : null,
            ),

            const SizedBox(height: 24),

            ValueListenableBuilder<UserProfile?>(
              valueListenable: UserService().currentUser,
              builder: (context, user, _) {
                final deliveryDetails = user?.deliveryDetails;
                final assignedStore = (deliveryDetails?['assignedStore'] ??
                        deliveryDetails?['assignedHub'] ??
                        deliveryDetails?['darkStore'] ??
                        deliveryDetails?['hubName'])
                    ?.toString()
                    .trim();
                final bool hasStore = assignedStore != null && assignedStore.isNotEmpty;
                final joinedInfo = _formatJoinedDate(user);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasStore ? "Address & Hub Info" : "Address Details",
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildDetailTile(
                      label: "Residential Address",
                      controller: _addressController,
                      icon: Icons.home_outlined,
                      enabled: _isEditing,
                      hintText: "Enter residential address",
                    ),
                    _buildDetailTile(
                      label: "Emergency Contact",
                      controller: _emergencyController,
                      icon: Icons.contact_phone_outlined,
                      enabled: _isEditing,
                      hintText: "Enter emergency phone number",
                    ),

                    if (hasStore) ...[
                      const SizedBox(height: 12),
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
                                  Text(
                                    "Assigned Dark Store",
                                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    assignedStore,
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (joinedInfo.isNotEmpty)
                                    Text(
                                      joinedInfo,
                                      style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
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
                  child: _isSaving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text("Save Information", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
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
    String? hintText,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? trailingWidget,
  }) {
    return GestureDetector(
      onTap: enabled && onTap != null ? onTap : null,
      child: Container(
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
                          readOnly: readOnly,
                          onTap: onTap,
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: hintText,
                            hintStyle: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.grey.shade400),
                          ),
                        )
                      : Text(
                          controller.text.isEmpty ? "Not provided" : controller.text,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: controller.text.isEmpty ? FontWeight.normal : FontWeight.bold,
                            color: controller.text.isEmpty ? Colors.grey.shade400 : const Color(0xFF0F172A),
                            fontStyle: controller.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                          ),
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
            ?trailingWidget,
          ],
        ),
      ),
    );
  }
}
