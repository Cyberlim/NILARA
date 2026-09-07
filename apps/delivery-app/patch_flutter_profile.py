import re

with open("lib/screens/onboarding_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add File state variable
content = content.replace("  File? _vehicleBackImage;", "  File? _vehicleBackImage;\n  File? _profileImage;")

# 2. Add pick logic for profile image (type 5)
old_pick = "else if (type == 4) _vehicleBackImage = File(pickedFile.path);"
new_pick = "else if (type == 4) _vehicleBackImage = File(pickedFile.path);\n        else if (type == 5) _profileImage = File(pickedFile.path);"
content = content.replace(old_pick, new_pick)

# 3. Add validation for new image
content = content.replace("|| _vehicleBackImage == null)", "|| _vehicleBackImage == null || _profileImage == null)")

# 4. Add file to MultipartRequest
old_files = "      request.files.add(await http.MultipartFile.fromPath('vehicleBackImage', _vehicleBackImage!.path));"
new_files = "      request.files.add(await http.MultipartFile.fromPath('vehicleBackImage', _vehicleBackImage!.path));\n      request.files.add(await http.MultipartFile.fromPath('profileImage', _profileImage!.path));"
content = content.replace(old_files, new_files)

# 5. Add UI row at the top (before Vehicle Details)
old_ui = """                children: [
                  Text("Vehicle Details","""

new_ui = """                children: [
                  Text("Your Photo", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),
                  _buildImagePickerRow(
                    title: "Profile Photo", 
                    imageFile: _profileImage, 
                    onTap: () => _pickImage(5)
                  ),
                  const SizedBox(height: 32),
                  Text("Vehicle Details","""

content = content.replace(old_ui, new_ui)

with open("lib/screens/onboarding_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
