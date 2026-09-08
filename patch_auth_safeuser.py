import re

with open("backend/src/controllers/authController.js", "r", encoding="utf-8") as f:
    content = f.read()

old_safe = """      onboardingComplete: user.onboardingComplete || false,
      deliveryDetails: user.deliveryDetails,
      createdAt: user.createdAt
    };"""

new_safe = """      onboardingComplete: user.onboardingComplete || false,
      deliveryDetails: user.deliveryDetails,
      dob: user.dob,
      address: user.address,
      emergencyContact: user.emergencyContact,
      createdAt: user.createdAt
    };"""

content = content.replace(old_safe, new_safe)

with open("backend/src/controllers/authController.js", "w", encoding="utf-8") as f:
    f.write(content)
