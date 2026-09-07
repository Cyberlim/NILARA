import re

with open("lib/services/user_service.dart", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace('debugPrint("Sync response: ${response.body}");', '// Sync successful')

with open("lib/services/user_service.dart", "w", encoding="utf-8") as f:
    f.write(content)
