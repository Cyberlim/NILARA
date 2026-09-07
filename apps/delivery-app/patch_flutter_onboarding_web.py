import re

with open("lib/screens/onboarding_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace File with XFile
old_vars = """  File? _aadharImage;
  File? _drivingLicenseImage;
  File? _vehicleFrontImage;
  File? _vehicleBackImage;
  File? _profileImage;"""

new_vars = """  XFile? _aadharImage;
  XFile? _drivingLicenseImage;
  XFile? _vehicleFrontImage;
  XFile? _vehicleBackImage;
  XFile? _profileImage;"""
content = content.replace(old_vars, new_vars)

old_pick = """  Future<void> _pickImage(int type) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (type == 1) _aadharImage = File(pickedFile.path);
        else if (type == 2) _drivingLicenseImage = File(pickedFile.path);
        else if (type == 3) _vehicleFrontImage = File(pickedFile.path);
        else if (type == 4) _vehicleBackImage = File(pickedFile.path);
        else if (type == 5) _profileImage = File(pickedFile.path);
      });
    }
  }"""

new_pick = """  Future<void> _pickImage(int type) async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          if (type == 1) _aadharImage = pickedFile;
          else if (type == 2) _drivingLicenseImage = pickedFile;
          else if (type == 3) _vehicleFrontImage = pickedFile;
          else if (type == 4) _vehicleBackImage = pickedFile;
          else if (type == 5) _profileImage = pickedFile;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }"""
content = content.replace(old_pick, new_pick)

old_build = "  Widget _buildImagePickerRow({required String title, File? imageFile, required VoidCallback onTap}) {"
new_build = "  Widget _buildImagePickerRow({required String title, XFile? imageFile, required VoidCallback onTap}) {"
content = content.replace(old_build, new_build)

old_upload = """        request.files.add(await http.MultipartFile.fromPath('aadharImage', _aadharImage!.path));
        request.files.add(await http.MultipartFile.fromPath('drivingLicenseImage', _drivingLicenseImage!.path));
        request.files.add(await http.MultipartFile.fromPath('vehicleFrontImage', _vehicleFrontImage!.path));
        request.files.add(await http.MultipartFile.fromPath('vehicleBackImage', _vehicleBackImage!.path));
        request.files.add(await http.MultipartFile.fromPath('profileImage', _profileImage!.path));"""

new_upload = """        request.files.add(http.MultipartFile.fromBytes('aadharImage', await _aadharImage!.readAsBytes(), filename: _aadharImage!.name));
        request.files.add(http.MultipartFile.fromBytes('drivingLicenseImage', await _drivingLicenseImage!.readAsBytes(), filename: _drivingLicenseImage!.name));
        request.files.add(http.MultipartFile.fromBytes('vehicleFrontImage', await _vehicleFrontImage!.readAsBytes(), filename: _vehicleFrontImage!.name));
        request.files.add(http.MultipartFile.fromBytes('vehicleBackImage', await _vehicleBackImage!.readAsBytes(), filename: _vehicleBackImage!.name));
        request.files.add(http.MultipartFile.fromBytes('profileImage', await _profileImage!.readAsBytes(), filename: _profileImage!.name));"""
content = content.replace(old_upload, new_upload)

with open("lib/screens/onboarding_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
