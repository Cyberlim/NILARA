import re

with open("backend/src/routes/deliveryRoutes.js", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("const { completeOnboarding,", "const { updateProfile, completeOnboarding,")
content = content.replace("router.post('/onboarding',", "router.put('/profile', updateProfile);\nrouter.post('/onboarding',")

with open("backend/src/routes/deliveryRoutes.js", "w", encoding="utf-8") as f:
    f.write(content)
