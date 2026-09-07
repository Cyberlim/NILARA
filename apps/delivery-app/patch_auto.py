import re

with open("lib/screens/onboarding_screen.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("['Bike', 'Scooter', 'Cycle'].map((type)", "['Bike', 'Scooter', 'Cycle', 'Auto (Loader)'].map((type)")

with open("lib/screens/onboarding_screen.dart", "w", encoding="utf-8") as f:
    f.write(content)
