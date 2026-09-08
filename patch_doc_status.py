import re

with open("apps/delivery-app/lib/screens/vehicle_information_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace DL
content = re.sub(
    r'subtitle:\s*"DL-04202100984 \? Valid till Aug 2035"', 
    r'subtitle: "${UserService().currentUser.value?.deliveryDetails?[\'drivingLicenseNumber\'] ?? \'Unknown\'} • Valid"',
    content
)

# Replace RC
content = re.sub(
    r'subtitle:\s*"TS 09 EA 4321 \? Smartcard Verified"',
    r'subtitle: "${_regNumberController.text} • Verified"',
    content
)

with open("apps/delivery-app/lib/screens/vehicle_information_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
