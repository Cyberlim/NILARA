import re

with open("src/controllers/authController.js", "r", encoding="utf-8") as f:
    content = f.read()

old_safe = """    // Sanitize user before returning
    const safeUser = {
      id: user._id,
      email: user.email,
      phone: user.phone,
      displayName: user.displayName,
      role: user.role,
      photoUrl: user.photoUrl,
      isActive: user.isActive,
      createdAt: user.createdAt
    };"""

new_safe = """    // Sanitize user before returning
    const safeUser = {
      id: user._id,
      email: user.email,
      phone: user.phone,
      displayName: user.displayName,
      role: user.role,
      photoUrl: user.photoUrl,
      isActive: user.isActive,
      onboardingComplete: user.onboardingComplete || false,
      createdAt: user.createdAt
    };"""

content = content.replace(old_safe, new_safe)

with open("src/controllers/authController.js", "w", encoding="utf-8") as f:
    f.write(content)
