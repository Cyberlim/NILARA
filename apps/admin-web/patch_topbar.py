import re

with open("src/components/layout/Topbar.jsx", "r", encoding="utf-8") as f:
    content = f.read()

# Add static import
content = content.replace('import ImageModal from "@/components/common/ImageModal";', 'import ImageModal from "@/components/common/ImageModal";\nimport { fetchWithAuth } from "@/lib/api";')

# Remove dynamic import
old_dynamic = """        try {
          const { fetchWithAuth } = await import("@/lib/api");
          const data = await fetchWithAuth('/chat/recent');"""

new_dynamic = """        try {
          const data = await fetchWithAuth('/chat/recent');"""

content = content.replace(old_dynamic, new_dynamic)

with open("src/components/layout/Topbar.jsx", "w", encoding="utf-8") as f:
    f.write(content)
