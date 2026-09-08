import re

with open("src/controllers/deliveryController.js", "r", encoding="utf-8") as f:
    content = f.read()

# Add new variables
content = content.replace("    let drivingLicenseImageUrl = null;", "    let drivingLicenseImageUrl = null;\n    let vehicleFrontImageUrl = null;\n    let vehicleBackImageUrl = null;")

# Add upload logic
upload_logic = """    if (req.files && req.files['drivingLicenseImage']) {
      const result = await cloudinary.uploader.upload(req.files['drivingLicenseImage'][0].path, { folder: 'kyc' });
      drivingLicenseImageUrl = result.secure_url;
      fs.unlinkSync(req.files['drivingLicenseImage'][0].path);
    }
    
    if (req.files && req.files['vehicleFrontImage']) {
      const result = await cloudinary.uploader.upload(req.files['vehicleFrontImage'][0].path, { folder: 'kyc' });
      vehicleFrontImageUrl = result.secure_url;
      fs.unlinkSync(req.files['vehicleFrontImage'][0].path);
    }
    
    if (req.files && req.files['vehicleBackImage']) {
      const result = await cloudinary.uploader.upload(req.files['vehicleBackImage'][0].path, { folder: 'kyc' });
      vehicleBackImageUrl = result.secure_url;
      fs.unlinkSync(req.files['vehicleBackImage'][0].path);
    }"""

content = content.replace("""    if (req.files && req.files['drivingLicenseImage']) {
      const result = await cloudinary.uploader.upload(req.files['drivingLicenseImage'][0].path, { folder: 'kyc' });
      drivingLicenseImageUrl = result.secure_url;
      fs.unlinkSync(req.files['drivingLicenseImage'][0].path);
    }""", upload_logic)

# Save to deliveryDetails
old_details = """      drivingLicenseImage: drivingLicenseImageUrl,
      vehicleType,
      vehicleNumber
    };"""

new_details = """      drivingLicenseImage: drivingLicenseImageUrl,
      vehicleType,
      vehicleNumber,
      vehicleFrontImage: vehicleFrontImageUrl,
      vehicleBackImage: vehicleBackImageUrl
    };"""

content = content.replace(old_details, new_details)

with open("src/controllers/deliveryController.js", "w", encoding="utf-8") as f:
    f.write(content)
