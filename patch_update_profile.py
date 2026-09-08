import re

with open("backend/src/controllers/deliveryController.js", "r", encoding="utf-8") as f:
    content = f.read()

update_func = """const updateProfile = async (req, res, next) => {
  try {
    const { displayName, email, dob, address, emergencyContact } = req.body;
    
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    if (displayName) user.displayName = displayName;
    if (email) user.email = email;
    if (dob) user.dob = dob;
    if (address) user.address = address;
    if (emergencyContact) user.emergencyContact = emergencyContact;
    
    await user.save();
    
    res.status(200).json({ success: true, message: 'Profile updated successfully' });
  } catch (error) {
    next(error);
  }
};

module.exports = {"""

content = content.replace("module.exports = {", update_func)

with open("backend/src/controllers/deliveryController.js", "w", encoding="utf-8") as f:
    f.write(content)
