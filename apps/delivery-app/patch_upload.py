import re

with open("lib/screens/onboarding_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

# Replace fromPath with fromBytes and use readAsBytes
content = re.sub(
    r"await http\.MultipartFile\.fromPath\('([^']+)', ([a-zA-Z_0-9!]+)\.path\)",
    r"http.MultipartFile.fromBytes('\1', await \2.readAsBytes(), filename: \2.name)",
    content
)

with open("lib/screens/onboarding_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
