import re

with open("src/controllers/deliveryController.js", "r", encoding="utf-8") as f:
    content = f.read()

# Add new variable
content = content.replace("    let drivingLicenseImageUrl = null;", "    let profileImageUrl = null;\n    let drivingLicenseImageUrl = null;")

# Add upload logic
upload_logic = """    if (req.files && req.files['profileImage']) {
      const result = await cloudinary.uploader.upload(req.files['profileImage'][0].path, { folder: 'kyc' });
      profileImageUrl = result.secure_url;
      fs.unlinkSync(req.files['profileImage'][0].path);
    }
    
    if (req.files && req.files['drivingLicenseImage']) {"""

content = content.replace("    if (req.files && req.files['drivingLicenseImage']) {", upload_logic)

# Save to photoUrl in User
old_save = """    user.deliveryDetails = {"""

new_save = """    if (profileImageUrl) {
      user.photoUrl = profileImageUrl;
    }
    
    user.deliveryDetails = {"""

content = content.replace(old_save, new_save)

with open("src/controllers/deliveryController.js", "w", encoding="utf-8") as f:
    f.write(content)
