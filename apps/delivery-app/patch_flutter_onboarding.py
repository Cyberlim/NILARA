import re

with open("lib/screens/onboarding_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add File state variables
content = content.replace("  File? _drivingLicenseImage;", "  File? _drivingLicenseImage;\n  File? _vehicleFrontImage;\n  File? _vehicleBackImage;")

# 2. Add pick logic for vehicle images (we'll just use 3=front, 4=back since it's currently a boolean. Let's change the parameter to an enum or int)
old_pick = """  Future<void> _pickImage(bool isAadhar) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isAadhar) {
          _aadharImage = File(pickedFile.path);
        } else {
          _drivingLicenseImage = File(pickedFile.path);
        }
      });
    }
  }"""

new_pick = """  Future<void> _pickImage(int type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 1) _aadharImage = File(pickedFile.path);
        else if (type == 2) _drivingLicenseImage = File(pickedFile.path);
        else if (type == 3) _vehicleFrontImage = File(pickedFile.path);
        else if (type == 4) _vehicleBackImage = File(pickedFile.path);
      });
    }
  }"""
content = content.replace(old_pick, new_pick)

# Update existing usages
content = content.replace("_pickImage(true)", "_pickImage(1)")
content = content.replace("_pickImage(false)", "_pickImage(2)")

# 3. Add validation for new images
content = content.replace("    if (_aadharImage == null || _drivingLicenseImage == null) {", "    if (_aadharImage == null || _drivingLicenseImage == null || _vehicleFrontImage == null || _vehicleBackImage == null) {")
content = content.replace("const SnackBar(content: Text('Please upload both Aadhar and Driving License images.')),", "const SnackBar(content: Text('Please upload all required images including vehicle photos.')),")

# 4. Add files to MultipartRequest
old_files = """      request.files.add(await http.MultipartFile.fromPath('aadharImage', _aadharImage!.path));
      request.files.add(await http.MultipartFile.fromPath('drivingLicenseImage', _drivingLicenseImage!.path));"""
      
new_files = """      request.files.add(await http.MultipartFile.fromPath('aadharImage', _aadharImage!.path));
      request.files.add(await http.MultipartFile.fromPath('drivingLicenseImage', _drivingLicenseImage!.path));
      request.files.add(await http.MultipartFile.fromPath('vehicleFrontImage', _vehicleFrontImage!.path));
      request.files.add(await http.MultipartFile.fromPath('vehicleBackImage', _vehicleBackImage!.path));"""

content = content.replace(old_files, new_files)

# 5. Add UI rows
old_ui = """                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  
                  const SizedBox(height: 32),"""

new_ui = """                  TextFormField(
                    controller: _vehicleNumberController,
                    decoration: InputDecoration(
                      labelText: 'Vehicle Number',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (val) => val!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildImagePickerRow(
                    title: "Vehicle Front Image", 
                    imageFile: _vehicleFrontImage, 
                    onTap: () => _pickImage(3)
                  ),
                  const SizedBox(height: 12),
                  _buildImagePickerRow(
                    title: "Vehicle Back Image", 
                    imageFile: _vehicleBackImage, 
                    onTap: () => _pickImage(4)
                  ),
                  
                  const SizedBox(height: 32),"""

content = content.replace(old_ui, new_ui)

with open("lib/screens/onboarding_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
