import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleInformationScreen extends StatefulWidget {
  const VehicleInformationScreen({super.key});

  @override
  State<VehicleInformationScreen> createState() => _VehicleInformationScreenState();
}

class _VehicleInformationScreenState extends State<VehicleInformationScreen> {
  final TextEditingController _vehicleTypeController = TextEditingController(text: "Electric Scooter (EV)");
  final TextEditingController _modelController = TextEditingController(text: "TVS iQube Electric");
  final TextEditingController _regNumberController = TextEditingController(text: "TS 09 EA 4321");
  final TextEditingController _ownershipController = TextEditingController(text: "Self Owned");
  final TextEditingController _batteryCapacityController = TextEditingController(text: "3.04 kWh (100 km range)");

  bool _isEditing = false;

  @override
  void dispose() {
    _vehicleTypeController.dispose();
    _modelController.dispose();
    _regNumberController.dispose();
    _ownershipController.dispose();
    _batteryCapacityController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Vehicle information updated successfully!", style: GoogleFonts.outfit(color: Colors.white)),
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
          "Vehicle Information",
          style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined, color: const Color(0xFF1E9C1C)),
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
      body: SingleChildScrollView(
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
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 14, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E9C1C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "EV ACTIVE ⚡",
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        "Battery: 85% 🔋",
                        style: GoogleFonts.outfit(color: Colors.lightGreenAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.two_wheeler, color: Colors.white, size: 40),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "TVS iQube Electric",
                              style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "TS 09 EA 4321",
                              style: GoogleFonts.outfit(color: const Color(0xFFFFD700), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text("Vehicle Specifications", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 14),

            _buildDetailTile(
              label: "Vehicle Category",
              controller: _vehicleTypeController,
              icon: Icons.electric_scooter,
              enabled: _isEditing,
            ),
            _buildDetailTile(
              label: "Make & Model",
              controller: _modelController,
              icon: Icons.two_wheeler,
              enabled: _isEditing,
            ),
            _buildDetailTile(
              label: "Registration Number",
              controller: _regNumberController,
              icon: Icons.pin_outlined,
              enabled: false, // Locked RC number
              trailingBadge: "Verified RC",
            ),
            _buildDetailTile(
              label: "Ownership Type",
              controller: _ownershipController,
              icon: Icons.person_pin_outlined,
              enabled: _isEditing,
            ),
            _buildDetailTile(
              label: "Battery Capacity & Range",
              controller: _batteryCapacityController,
              icon: Icons.battery_charging_full,
              enabled: _isEditing,
            ),

            const SizedBox(height: 28),

            Text("Document Verification Status", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            const SizedBox(height: 14),

            _buildDocStatusItem(
              title: "Driving License (DL)",
              subtitle: "DL-04202100984 • Valid till Aug 2035",
              isVerified: true,
            ),
            _buildDocStatusItem(
              title: "Registration Certificate (RC)",
              subtitle: "TS 09 EA 4321 • Smartcard Verified",
              isVerified: true,
            ),
            _buildDocStatusItem(
              title: "Motor Vehicle Insurance",
              subtitle: "National Insurance #9847120 • Valid till Nov 2026",
              isVerified: true,
            ),
            _buildDocStatusItem(
              title: "PUC / EV Fitness Certificate",
              subtitle: "EV Vehicle (Exempted from PUC emission test)",
              isVerified: true,
            ),

            const SizedBox(height: 30),

            if (_isEditing)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveVehicle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E9C1C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text("Save Vehicle Info", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildDocStatusItem({
    required String title,
    required String subtitle,
    required bool isVerified,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Color(0xFF1E9C1C), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                Text(subtitle, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Text(
            "Active",
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E9C1C)),
          ),
        ],
      ),
    );
  }
}
