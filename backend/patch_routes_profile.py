import re

with open("src/routes/deliveryRoutes.js", "r", encoding="utf-8") as f:
    content = f.read()

old_route = "router.post('/onboarding', upload.fields([{ name: 'aadharImage', maxCount: 1 }, { name: 'drivingLicenseImage', maxCount: 1 }, { name: 'vehicleFrontImage', maxCount: 1 }, { name: 'vehicleBackImage', maxCount: 1 }]), completeOnboarding);"
new_route = "router.post('/onboarding', upload.fields([{ name: 'profileImage', maxCount: 1 }, { name: 'aadharImage', maxCount: 1 }, { name: 'drivingLicenseImage', maxCount: 1 }, { name: 'vehicleFrontImage', maxCount: 1 }, { name: 'vehicleBackImage', maxCount: 1 }]), completeOnboarding);"

content = content.replace(old_route, new_route)

with open("src/routes/deliveryRoutes.js", "w", encoding="utf-8") as f:
    f.write(content)
