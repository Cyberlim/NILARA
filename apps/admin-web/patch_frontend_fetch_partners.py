import re

with open("src/app/delivery-partners/page.js", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Import useEffect and useAuth
content = content.replace("import { useState } from \"react\";", "import { useState, useEffect } from \"react\";\nimport { useAuth } from \"@/context/AuthContext\";")

# 2. Add localItems state and fetch logic
fetch_logic = """  const { token } = useAuth();
  const [localItems, setLocalItems] = useState([]);

  const fetchPartners = () => {
    if (!token) return;
    fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1'}/admin/delivery-partners`, {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        setLocalItems(data.data);
      }
    })
    .catch(err => console.error("Failed to fetch delivery partners", err));
  };

  useEffect(() => {
    fetchPartners();
  }, [token]);

  // Handle partner added from modal
  const handlePartnerAdded = () => {
    fetchPartners();
  };
"""

content = content.replace("  const [selectedItem, setSelectedItem] = useState(null);", "  const [selectedItem, setSelectedItem] = useState(null);\n\n" + fetch_logic)

# 3. Pass localItems to PartnersTable and hook up onPartnerAdded to AddPartnerModal
content = content.replace("<PartnersTable items={[]} onRowClick={handleRowClick} />", "<PartnersTable items={localItems} onRowClick={handleRowClick} />")
content = content.replace("<AddPartnerModal \n        isOpen={isAddPartnerModalOpen}\n        onClose={() => setIsAddPartnerModalOpen(false)}\n      />", "<AddPartnerModal \n        isOpen={isAddPartnerModalOpen}\n        onClose={() => setIsAddPartnerModalOpen(false)}\n        onPartnerAdded={handlePartnerAdded}\n      />")

with open("src/app/delivery-partners/page.js", "w", encoding="utf-8") as f:
    f.write(content)

# 4. Update AddPartnerModal to call onPartnerAdded
with open("src/components/delivery-partners/AddPartnerModal.js", "r", encoding="utf-8") as f:
    modal_content = f.read()

modal_content = modal_content.replace("export default function AddPartnerModal({ isOpen, onClose }) {", "export default function AddPartnerModal({ isOpen, onClose, onPartnerAdded }) {")
modal_content = modal_content.replace("toast.success(\"Delivery Partner created!\");", "toast.success(\"Delivery Partner created!\");\n        if (onPartnerAdded) onPartnerAdded();")

with open("src/components/delivery-partners/AddPartnerModal.js", "w", encoding="utf-8") as f:
    f.write(modal_content)
