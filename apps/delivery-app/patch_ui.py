import re

with open("lib/screens/onboarding_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Build the new UI code
new_build = """  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 8, bottom: 8),
          child: Container(
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Complete KYC", style: GoogleFonts.outfit(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20)),
            Text("Help us verify your identity for a safe and trusted experience.", style: GoogleFonts.outfit(color: Colors.black54, fontSize: 12)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user, color: Color(0xFF1E9C1C), size: 24),
            ),
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E9C1C)))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    icon: Icons.person,
                    title: "Your Photo",
                    subtitle: "Upload your clear profile photo",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImagePickerRow(
                          title: "Profile Photo", 
                          imageFile: _profileImage, 
                          onTap: () => _pickImage(5)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSectionCard(
                    icon: Icons.directions_car,
                    title: "Vehicle Details",
                    subtitle: "Provide your vehicle information",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Vehicle Type", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _vehicleType,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                          items: ['Bike', 'Scooter', 'Cycle'].map((type) {
                            return DropdownMenuItem(value: type, child: Text(type, style: GoogleFonts.outfit()));
                          }).toList(),
                          onChanged: (val) => setState(() => _vehicleType = val!),
                        ),
                        const SizedBox(height: 16),
                        
                        Text("Vehicle Number", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _vehicleNumberController,
                          decoration: InputDecoration(
                            hintText: 'Vehicle Number',
                            hintStyle: GoogleFonts.outfit(color: Colors.black38),
                            prefixIcon: const Icon(Icons.directions_car_outlined, color: Colors.black54),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        
                        Text("Vehicle Front Image", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        _buildImagePickerRow(
                          title: "Vehicle Front Image", 
                          imageFile: _vehicleFrontImage, 
                          onTap: () => _pickImage(3)
                        ),
                        const SizedBox(height: 16),
                        
                        Text("Vehicle Back Image", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        _buildImagePickerRow(
                          title: "Vehicle Back Image", 
                          imageFile: _vehicleBackImage, 
                          onTap: () => _pickImage(4)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSectionCard(
                    icon: Icons.badge_outlined,
                    title: "Identity Verification",
                    subtitle: "Verify your identity documents",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Aadhar Number", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _aadharNumberController,
                          decoration: InputDecoration(
                            hintText: 'Aadhar Number',
                            hintStyle: GoogleFonts.outfit(color: Colors.black38),
                            prefixIcon: const Icon(Icons.badge_outlined, color: Colors.black54),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildImagePickerRow(
                          title: "Aadhar Card Image", 
                          imageFile: _aadharImage, 
                          onTap: () => _pickImage(1)
                        ),
                        const SizedBox(height: 24),
                        
                        Text("Driving License Number", style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _drivingLicenseController,
                          decoration: InputDecoration(
                            hintText: 'Driving License Number',
                            hintStyle: GoogleFonts.outfit(color: Colors.black38),
                            prefixIcon: const Icon(Icons.badge_outlined, color: Colors.black54),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                          ),
                          validator: (val) => val!.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildImagePickerRow(
                          title: "Driving License Image", 
                          imageFile: _drivingLicenseImage, 
                          onTap: () => _pickImage(2)
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E9C1C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Submit Details", style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildSectionCard({required IconData icon, required String title, required String subtitle, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: Icon(icon, color: const Color(0xFF1E9C1C), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(subtitle, style: GoogleFonts.outfit(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildImagePickerRow({required String title, File? imageFile, required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF1E9C1C).withOpacity(0.3), style: BorderStyle.none), // Wait, dashed border requires a package, we'll use a soft green border
            ),
            child: Icon(imageFile == null ? Icons.image_outlined : Icons.check_circle, color: const Color(0xFF1E9C1C), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.outfit(fontSize: 14, color: Colors.black54))),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(imageFile == null ? Icons.upload_file : Icons.check, color: Colors.white, size: 16),
            label: Text(imageFile == null ? "Upload" : "Done", style: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: imageFile == null ? const Color(0xFF4285F4) : const Color(0xFF1E9C1C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
"""

start_idx = content.find("  @override\n  Widget build(BuildContext context) {")
if start_idx != -1:
    content = content[:start_idx] + new_build

with open("lib/screens/onboarding_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
