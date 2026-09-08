import re
import os

with open("src/app/delivery-partners/page.js", "r", encoding="utf-8") as f:
    content = f.read()

# Add AddPartnerModal import
content = content.replace("import DeliveryPartnersListModal from \"@/components/delivery-partners/DeliveryPartnersListModal\";", "import DeliveryPartnersListModal from \"@/components/delivery-partners/DeliveryPartnersListModal\";\nimport AddPartnerModal from \"@/components/delivery-partners/AddPartnerModal\";")

# Add state for the new modal
state_injection = """  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isAddPartnerModalOpen, setIsAddPartnerModalOpen] = useState(false);"""
content = content.replace("  const [isModalOpen, setIsModalOpen] = useState(false);", state_injection)

# Add the Add Partner button in header
header_old = """      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Delivery Partners</h1>
          <p className="text-sm font-medium text-slate-500">Manage the fleet of delivery riders.</p>
        </div>
      </div>"""

header_new = """      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Delivery Partners</h1>
          <p className="text-sm font-medium text-slate-500">Manage the fleet of delivery riders.</p>
        </div>
        <button
          onClick={() => setIsAddPartnerModalOpen(true)}
          className="bg-indigo-600 hover:bg-indigo-700 text-white px-5 py-2.5 rounded-xl font-semibold transition-all shadow-md shadow-indigo-600/20 active:scale-95"
        >
          + Add Partner
        </button>
      </div>"""
content = content.replace(header_old, header_new)

# Add the AddPartnerModal to the render
render_old = """      <DeliveryPartnersListModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        filterType={filterType}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
      />
    </div>
  );
}"""

render_new = """      <DeliveryPartnersListModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        filterType={filterType}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
      />

      <AddPartnerModal 
        isOpen={isAddPartnerModalOpen}
        onClose={() => setIsAddPartnerModalOpen(false)}
      />
    </div>
  );
}"""
content = content.replace(render_old, render_new)

with open("src/app/delivery-partners/page.js", "w", encoding="utf-8") as f:
    f.write(content)

# Now write AddPartnerModal.js
add_partner_code = """import { useState } from 'react';
import { useAuth } from '@/context/AuthContext';
import { toast } from 'react-hot-toast';

export default function AddPartnerModal({ isOpen, onClose }) {
  const { token } = useAuth();
  const [formData, setFormData] = useState({ name: '', email: '', phone: '', password: '' });
  const [loading, setLoading] = useState(false);
  const [successData, setSuccessData] = useState(null);

  if (!isOpen) return null;

  const handleChange = (e) => setFormData({ ...formData, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1'}/admin/delivery-partners`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`
        },
        body: JSON.stringify(formData)
      });
      const data = await res.json();
      if (data.success) {
        toast.success("Delivery Partner created!");
        setSuccessData({ email: formData.email, password: formData.password });
      } else {
        toast.error(data.error?.message || "Failed to create partner");
      }
    } catch (err) {
      toast.error("Network error");
    } finally {
      setLoading(false);
    }
  };

  const handleClose = () => {
    setSuccessData(null);
    setFormData({ name: '', email: '', phone: '', password: '' });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="bg-white rounded-2xl w-full max-w-md p-6 shadow-2xl relative animate-in fade-in zoom-in-95 duration-200">
        <h2 className="text-2xl font-bold text-slate-800 mb-6">
          {successData ? "Partner Created!" : "Add Delivery Partner"}
        </h2>
        
        {successData ? (
          <div className="space-y-4">
            <div className="p-4 bg-green-50 rounded-xl border border-green-200">
              <p className="text-green-800 font-medium mb-2">Successfully created the account. Please securely share these credentials with the delivery partner:</p>
              <div className="bg-white p-3 rounded border border-green-200 font-mono text-sm space-y-2">
                <p><strong>Email:</strong> {successData.email}</p>
                <p><strong>Password:</strong> {successData.password}</p>
              </div>
            </div>
            <button
              onClick={handleClose}
              className="w-full bg-slate-800 hover:bg-slate-900 text-white font-semibold py-3 rounded-xl transition-colors"
            >
              Done
            </button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">Full Name</label>
              <input required name="name" value={formData.name} onChange={handleChange} type="text" className="w-full px-4 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-600 focus:border-transparent outline-none" placeholder="John Doe" />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">Email</label>
              <input required name="email" value={formData.email} onChange={handleChange} type="email" className="w-full px-4 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-600 focus:border-transparent outline-none" placeholder="john@example.com" />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">Phone Number</label>
              <input required name="phone" value={formData.phone} onChange={handleChange} type="tel" className="w-full px-4 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-600 focus:border-transparent outline-none" placeholder="+1234567890" />
            </div>
            <div>
              <label className="block text-sm font-medium text-slate-600 mb-1">Password</label>
              <input required name="password" value={formData.password} onChange={handleChange} minLength="6" type="text" className="w-full px-4 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-indigo-600 focus:border-transparent outline-none" placeholder="At least 6 characters" />
            </div>
            <div className="flex gap-3 mt-6">
              <button type="button" onClick={handleClose} className="flex-1 bg-white border border-slate-300 hover:bg-slate-50 text-slate-700 font-semibold py-2.5 rounded-xl transition-colors">
                Cancel
              </button>
              <button type="submit" disabled={loading} className="flex-1 bg-indigo-600 hover:bg-indigo-700 text-white font-semibold py-2.5 rounded-xl transition-colors disabled:opacity-50 flex items-center justify-center">
                {loading ? "Creating..." : "Create Partner"}
              </button>
            </div>
          </form>
        )}
      </div>
    </div>
  );
}
"""

with open("src/components/delivery-partners/AddPartnerModal.js", "w", encoding="utf-8") as f:
    f.write(add_partner_code)

