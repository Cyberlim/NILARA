import re

with open("src/routes/deliveryRoutes.js", "r", encoding="utf-8") as f:
    content = f.read()

# Add multer to routes
import_multer = "const multer = require('multer');\nconst upload = multer({ dest: 'uploads/' });\n"
content = content.replace("const express = require('express');", "const express = require('express');\n" + import_multer)

# Update onboarding route to accept files
content = content.replace(
    "router.post('/onboarding', completeOnboarding);",
    "router.post('/onboarding', upload.fields([{ name: 'aadharImage', maxCount: 1 }, { name: 'drivingLicenseImage', maxCount: 1 }]), completeOnboarding);"
)

with open("src/routes/deliveryRoutes.js", "w", encoding="utf-8") as f:
    f.write(content)


with open("src/controllers/deliveryController.js", "r", encoding="utf-8") as f:
    controller = f.read()

new_logic = """
const cloudinary = require('../config/cloudinary');
const fs = require('fs');

const completeOnboarding = async (req, res, next) => {
  try {
    const { aadharNumber, drivingLicenseNumber, vehicleType, vehicleNumber } = req.body;
    
    let aadharImageUrl = null;
    let drivingLicenseImageUrl = null;
    
    if (req.files && req.files['aadharImage']) {
      const result = await cloudinary.uploader.upload(req.files['aadharImage'][0].path, { folder: 'kyc' });
      aadharImageUrl = result.secure_url;
      fs.unlinkSync(req.files['aadharImage'][0].path);
    }
    
    if (req.files && req.files['drivingLicenseImage']) {
      const result = await cloudinary.uploader.upload(req.files['drivingLicenseImage'][0].path, { folder: 'kyc' });
      drivingLicenseImageUrl = result.secure_url;
      fs.unlinkSync(req.files['drivingLicenseImage'][0].path);
    }

    const User = require('../models/User');
    const user = await User.findById(req.auth.userId);
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    user.deliveryDetails = {
      aadharNumber,
      aadharImage: aadharImageUrl,
      drivingLicenseNumber,
      drivingLicenseImage: drivingLicenseImageUrl,
      vehicleType,
      vehicleNumber
    };
    user.onboardingComplete = true;
    
    await user.save();
    
    res.status(200).json({ success: true, message: 'Onboarding completed successfully' });
  } catch (error) {
    next(error);
  }
};
"""

# We need to replace the old completeOnboarding function
start = controller.find("const completeOnboarding = async")
end = controller.find("module.exports = {")
if start != -1 and end != -1:
    controller = controller[:start] + new_logic + controller[end:]

with open("src/controllers/deliveryController.js", "w", encoding="utf-8") as f:
    f.write(controller)

