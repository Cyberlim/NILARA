import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/user_service.dart';

class VehicleInformationScreen extends StatefulWidget {
  const VehicleInformationScreen({super.key});

  @override
  State<VehicleInformationScreen> createState() =>
      _VehicleInformationScreenState();
}

class _VehicleInformationScreenState extends State<VehicleInformationScreen> {
  late TextEditingController _vehicleTypeController;
  late TextEditingController _regNumberController;
  late TextEditingController _ownershipController;
  bool _isUploadingRc = false;

  @override
  void initState() {
    super.initState();
    final details = UserService().currentUser.value?.deliveryDetails;
    final vehicleType = details?['vehicleType'] ?? "N/A";
    final vehicleNumber = (details?['vehicleNumber'] ?? "N/A").toString().toUpperCase();

    _vehicleTypeController = TextEditingController(text: vehicleType);
    _regNumberController = TextEditingController(text: vehicleNumber);
    _ownershipController = TextEditingController(text: "Self Owned");

    // Fetch fresh profile so any new RC or KYC changes immediately reflect
    UserService().refreshProfile();
  }

  bool _isEditing = false;

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _regNumberController.dispose();
    _ownershipController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadRc() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      setState(() => _isUploadingRc = true);
      final bytes = await picked.readAsBytes();
      final result = await UserService().uploadRC(bytes, picked.name);

      if (mounted) {
        setState(() => _isUploadingRc = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.message,
              style: GoogleFonts.outfit(color: Colors.white),
            ),
            backgroundColor: result.success ? const Color(0xFF1E9C1C) : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingRc = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error uploading RC: $e",
                style: GoogleFonts.outfit(color: Colors.white)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _saveVehicle() async {
    final success = await UserService().updateProfile({
      'vehicleType': _vehicleTypeController.text.trim(),
    });
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Vehicle information updated successfully!" : "Vehicle information updated locally",
            style: GoogleFonts.outfit(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E9C1C),
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
          "Vehicle Information",
          style: GoogleFonts.outfit(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit_outlined,
              color: const Color(0xFF1E9C1C),
            ),
            onPressed: () {
              if (_isEditing) {
                _saveVehicle();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<UserProfile?>(
        valueListenable: UserService().currentUser,
        builder: (context, user, _) {
          final deliveryDetails = user?.deliveryDetails;
          final vehicleFrontImage = deliveryDetails?['vehicleFrontImage'] as String?;
          final vehicleBackImage = deliveryDetails?['vehicleBackImage'] as String?;
          final drivingLicenseImage = deliveryDetails?['drivingLicenseImage'] as String?;
          final rcImage = deliveryDetails?['rcImage'] as String?;
          final drivingLicenseNumber = (deliveryDetails?['drivingLicenseNumber'] ?? 'Unknown').toString().toUpperCase();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Hero Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: (vehicleFrontImage != null && vehicleFrontImage.isNotEmpty)
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(25),
                                    child: Image.network(
                                      vehicleFrontImage,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Padding(
                                        padding: EdgeInsets.all(6.0),
                                        child: Icon(Icons.two_wheeler, color: Colors.white, size: 36),
                                      ),
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.all(6.0),
                                    child: Icon(Icons.two_wheeler, color: Colors.white, size: 36),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _vehicleTypeController.text,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _regNumberController.text.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    color: const Color(0xFFFFD700),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Vehicle Photos (from KYC)
                Text(
                  "Vehicle Photos (KYC)",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    _buildVehiclePhotoCard(
                      context: context,
                      title: "Front View",
                      imageUrl: vehicleFrontImage,
                      fallbackIcon: Icons.two_wheeler,
                    ),
                    const SizedBox(width: 12),
                    _buildVehiclePhotoCard(
                      context: context,
                      title: "Back View",
                      imageUrl: vehicleBackImage,
                      fallbackIcon: Icons.two_wheeler,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  "Vehicle Specifications",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                _buildDetailTile(
                  label: "Vehicle Category",
                  controller: _vehicleTypeController,
                  icon: Icons.electric_scooter,
                  enabled: _isEditing,
                ),
                _buildDetailTile(
                  label: "Registration Number",
                  controller: _regNumberController,
                  icon: Icons.pin_outlined,
                  enabled: false, // Locked RC number
                ),
                _buildDetailTile(
                  label: "Ownership Type",
                  controller: _ownershipController,
                  icon: Icons.person_pin_outlined,
                  enabled: _isEditing,
                ),

                const SizedBox(height: 28),

                Text(
                  "Document Verification Status",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 14),

                _buildDocStatusItem(
                  context: context,
                  title: "Driving License (DL)",
                  subtitle: drivingLicenseNumber,
                  icon: Icons.badge_outlined,
                  imageUrl: drivingLicenseImage,
                  onTap: (drivingLicenseImage != null && drivingLicenseImage.isNotEmpty)
                      ? () => _showImagePreview(context, drivingLicenseImage, "Driving License (DL)")
                      : null,
                ),
                _buildDocStatusItem(
                  context: context,
                  title: "Registration Certificate (RC)",
                  subtitle: _regNumberController.text.toUpperCase(),
                  icon: Icons.directions_car_outlined,
                  imageUrl: rcImage,
                  onTap: (rcImage != null && rcImage.isNotEmpty)
                      ? () => _showImagePreview(context, rcImage, "Registration Certificate (RC)")
                      : null,
                  trailingAction: _isUploadingRc
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1E9C1C),
                          ),
                        )
                      : (rcImage != null && rcImage.isNotEmpty)
                          ? null
                          : InkWell(
                              onTap: _pickAndUploadRc,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF1E9C1C).withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.upload_file, size: 15, color: Color(0xFF1E9C1C)),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Upload RC",
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E9C1C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                ),
              ],
            ),
          );
        },
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
        border: Border.all(
          color: enabled ? const Color(0xFF1E9C1C) : Colors.grey.shade200,
          width: enabled ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1E9C1C), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                enabled
                    ? TextField(
                        controller: controller,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      )
                    : Text(
                        (label.contains("Registration") || label.contains("License"))
                            ? controller.text.toUpperCase()
                            : controller.text,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
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
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E9C1C),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocStatusItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    String? imageUrl,
    VoidCallback? onTap,
    Widget? trailingAction,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: const Color(0xFF475569),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasImage) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: onTap,
                    child: Tooltip(
                      message: "Tap to view image",
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: 42,
                              height: 42,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.broken_image, size: 20, color: Colors.grey),
                              ),
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (trailingAction != null) ...[
                  const SizedBox(width: 10),
                  trailingAction,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehiclePhotoCard({
    required BuildContext context,
    required String title,
    required String? imageUrl,
    required IconData fallbackIcon,
  }) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return Expanded(
      child: GestureDetector(
        onTap: hasImage ? () => _showImagePreview(context, imageUrl, title) : null,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: hasImage
                    ? Stack(
                        children: [
                          Image.network(
                            imageUrl,
                            height: 125,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(fallbackIcon),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.fullscreen, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      )
                    : _buildImagePlaceholder(fallbackIcon),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 15, color: Color(0xFF1E9C1C)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(IconData icon) {
    return Container(
      height: 125,
      width: double.infinity,
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 36),
            const SizedBox(height: 4),
            Text(
              "No Image",
              style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF0F172A),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car, color: Color(0xFF1E9C1C), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(color: Color(0xFF1E9C1C)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => const Padding(
                      padding: EdgeInsets.all(40),
                      child: Icon(Icons.broken_image, color: Colors.white54, size: 60),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
