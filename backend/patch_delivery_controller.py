import re

with open("src/controllers/deliveryController.js", "r", encoding="utf-8") as f:
    content = f.read()

new_controller = """
const completeOnboarding = async (req, res, next) => {
  try {
    const { aadharNumber, aadharImage, drivingLicenseNumber, drivingLicenseImage, vehicleType, vehicleNumber } = req.body;
    
    const User = require('../models/User');
    const user = await User.findById(req.auth.userId);
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    user.deliveryDetails = {
      aadharNumber,
      aadharImage,
      drivingLicenseNumber,
      drivingLicenseImage,
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

content = content.replace("module.exports = {", new_controller + "\nmodule.exports = {\n  completeOnboarding,")

with open("src/controllers/deliveryController.js", "w", encoding="utf-8") as f:
    f.write(content)
