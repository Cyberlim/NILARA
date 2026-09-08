import re

with open("backend/src/controllers/deliveryController.js", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("  completeOnboarding,", "  updateProfile,\n  completeOnboarding,")

with open("backend/src/controllers/deliveryController.js", "w", encoding="utf-8") as f:
    f.write(content)
