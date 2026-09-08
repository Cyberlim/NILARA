import re

with open("src/app/layout.js", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("import AuthGuard from \"@/components/layout/AuthGuard\";", "import AuthGuard from \"@/components/layout/AuthGuard\";\nimport { Toaster } from 'react-hot-toast';")

content = content.replace("</AuthProvider>", "  <Toaster position=\"top-right\" />\n        </AuthProvider>")

with open("src/app/layout.js", "w", encoding="utf-8") as f:
    f.write(content)
