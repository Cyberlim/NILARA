"use client";

import { useState, useEffect } from "react";
import { X, Plus, Trash2 } from "lucide-react";

export default function PlanFormModal({ isOpen, onClose, itemToEdit, onSave }) {
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    price: 0,
    frequency: "Daily",
    status: "Active",
    features: [""]
  });

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      if (itemToEdit) {
        setFormData({
          name: itemToEdit.name,
          description: itemToEdit.description,
          price: itemToEdit.price,
          frequency: itemToEdit.frequency,
          status: itemToEdit.status,
          features: [...itemToEdit.features],
        });
      } else {
        setFormData({
          name: "",
          description: "",
          price: 0,
          frequency: "Daily",
          status: "Active",
          features: [""]
        });
      }
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen, itemToEdit]);

  if (!isOpen) return null;

  const handleFeatureChange = (index, value) => {
    const newFeatures = [...formData.features];
    newFeatures[index] = value;
    setFormData({ ...formData, features: newFeatures });
  };

  const addFeature = () => {
    setFormData({ ...formData, features: [...formData.features, ""] });
  };

  const removeFeature = (index) => {
    if (formData.features.length > 1) {
      const newFeatures = formData.features.filter((_, i) => i !== index);
      setFormData({ ...formData, features: newFeatures });
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave && onSave({
      ...formData,
      id: itemToEdit ? itemToEdit.id : `PLN-${Math.floor(Math.random() * 1000)}`,
      subscribers: itemToEdit ? itemToEdit.subscribers : 0,
      statusColor: formData.status === "Active" ? "green" : formData.status === "Archived" ? "slate" : "blue",
      features: formData.features.filter(f => f.trim() !== "")
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity" onClick={onClose}></div>

      <div className="relative w-full max-w-2xl max-h-[85vh] bg-white rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <h2 className="text-xl font-black text-slate-800 tracking-tight">
            {itemToEdit ? "Edit Plan" : "Create New Plan"}
          </h2>
          <button type="button" onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
            <X className="w-4 h-4" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          <div className="space-y-6">
            
            <div className="space-y-4">
              <h3 className="text-sm font-bold text-slate-800 border-b border-slate-200 pb-2">Plan Details</h3>
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">Plan Name</label>
                <input type="text" required value={formData.name} onChange={(e) => setFormData({...formData, name: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" placeholder="e.g. Daily 20L Water Jar" />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">Description</label>
                <textarea rows={2} required value={formData.description} onChange={(e) => setFormData({...formData, description: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all resize-none" placeholder="Short description of the plan" />
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Price / Delivery (₹)</label>
                  <input type="number" required min="0" value={formData.price} onChange={(e) => setFormData({...formData, price: parseInt(e.target.value) || 0})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Frequency</label>
                  <select value={formData.frequency} onChange={(e) => setFormData({...formData, frequency: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all appearance-none cursor-pointer">
                    <option value="Daily">Daily</option>
                    <option value="Weekly">Weekly</option>
                    <option value="Monthly">Monthly</option>
                    <option value="Custom">Custom</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Status</label>
                  <select value={formData.status} onChange={(e) => setFormData({...formData, status: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all appearance-none cursor-pointer">
                    <option value="Active">Active</option>
                    <option value="New">New</option>
                    <option value="Archived">Archived</option>
                  </select>
                </div>
              </div>
            </div>

            <div className="space-y-4">
              <div className="flex items-center justify-between border-b border-slate-200 pb-2 mt-6">
                <h3 className="text-sm font-bold text-slate-800">Features List</h3>
                <button type="button" onClick={addFeature} className="text-xs font-bold text-teal-600 hover:text-teal-700 flex items-center">
                  <Plus className="w-3.5 h-3.5 mr-1" /> Add Feature
                </button>
              </div>
              
              <div className="space-y-3">
                {formData.features.map((feature, idx) => (
                  <div key={idx} className="flex items-center gap-2">
                    <input 
                      type="text" 
                      value={feature} 
                      onChange={(e) => handleFeatureChange(idx, e.target.value)} 
                      className="flex-1 px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                      placeholder={`Feature ${idx + 1}`} 
                      required
                    />
                    {formData.features.length > 1 && (
                      <button type="button" onClick={() => removeFeature(idx)} className="w-10 h-10 flex items-center justify-center rounded-xl bg-red-50 text-red-400 hover:bg-red-100 hover:text-red-500 transition-colors shrink-0">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    )}
                  </div>
                ))}
              </div>
            </div>

          </div>
          
          <div className="px-6 py-4 border-t border-slate-200/60 bg-white/50 flex justify-end gap-3">
            <button type="button" onClick={onClose} className="px-5 py-2.5 bg-white border border-slate-200 text-slate-600 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors">
              Cancel
            </button>
            <button type="submit" className="px-5 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm">
              {itemToEdit ? "Save Changes" : "Create Plan"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
