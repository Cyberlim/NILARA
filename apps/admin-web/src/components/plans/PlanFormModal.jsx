"use client";

import { useState, useEffect } from "react";
import { X, Plus, Trash2 } from "lucide-react";

export default function PlanFormModal({ isOpen, onClose, itemToEdit, onSave, availableProducts = [] }) {
  const [formData, setFormData] = useState({
    name: "",
    description: "",
    price: "",
    frequency: "Daily",
    discountPercentage: "",
    durationMonths: 1,
    isActive: true,
    includedProducts: [],
    features: []
  });

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      if (itemToEdit) {
        setFormData({
          name: itemToEdit.name || "",
          description: itemToEdit.description || "",
          price: itemToEdit.price !== undefined ? itemToEdit.price : "",
          frequency: itemToEdit.frequency || "Daily",
          discountPercentage: itemToEdit.discountPercentage !== undefined ? itemToEdit.discountPercentage : "",
          durationMonths: itemToEdit.durationMonths !== undefined ? itemToEdit.durationMonths : 1,
          isActive: itemToEdit.isActive !== false,
          includedProducts: itemToEdit.includedProducts || [],
          features: itemToEdit.features || []
        });
      } else {
        setFormData({
          name: "",
          description: "",
          price: "",
          frequency: "Daily",
          discountPercentage: "",
          durationMonths: 1,
          isActive: true,
          includedProducts: [],
          features: []
        });
      }
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen, itemToEdit]);

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (formData.includedProducts.length === 0) {
      alert("Please select at least one product to include in this plan.");
      return;
    }
    onSave && onSave({
      ...formData,
      id: itemToEdit ? itemToEdit.id : undefined,
    });
    onClose();
  };

  const toggleProduct = (productName) => {
    setFormData(prev => {
      const current = prev.includedProducts || [];
      if (current.includes(productName)) {
        return { ...prev, includedProducts: current.filter(n => n !== productName) };
      } else {
        return { ...prev, includedProducts: [...current, productName] };
      }
    });
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
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Price / Month (₹)</label>
                  <input type="number" required min="0" placeholder="0" value={formData.price} onChange={(e) => setFormData({...formData, price: e.target.value === '' ? '' : parseInt(e.target.value)})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Discount Percentage (%)</label>
                  <input type="number" required min="0" max="100" placeholder="0" value={formData.discountPercentage} onChange={(e) => setFormData({...formData, discountPercentage: e.target.value === '' ? '' : parseInt(e.target.value)})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Duration (Months)</label>
                  <input type="number" required min="1" placeholder="1" value={formData.durationMonths} onChange={(e) => setFormData({...formData, durationMonths: e.target.value === '' ? '' : parseInt(e.target.value)})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Frequency</label>
                  <select value={formData.frequency} onChange={(e) => setFormData({...formData, frequency: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all appearance-none cursor-pointer">
                    <option value="Daily">Daily</option>
                    <option value="Alternate Days">Alternate Days</option>
                    <option value="Weekly">Weekly</option>
                    <option value="Monthly">Monthly</option>
                  </select>
                </div>
              </div>
            </div>

            <div className="space-y-4 mt-6">
              <h3 className="text-sm font-bold text-slate-800 border-b border-slate-200 pb-2">Included Products</h3>
              {availableProducts.length === 0 ? (
                <p className="text-sm text-slate-500 italic">No water products available.</p>
              ) : (
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                  {availableProducts.map(product => {
                    const isChecked = (formData.includedProducts || []).includes(product.name);
                    return (
                      <label key={product._id || product.id} className={`flex items-start p-3 border rounded-xl cursor-pointer transition-colors ${isChecked ? 'border-teal-500 bg-teal-50/50' : 'border-slate-200 bg-white hover:border-slate-300'}`}>
                        <input 
                          type="checkbox"
                          className="mt-1 w-4 h-4 text-teal-600 rounded border-slate-300 focus:ring-teal-500"
                          checked={isChecked}
                          onChange={() => toggleProduct(product.name)}
                        />
                        <div className="ml-3 flex-1">
                          <p className="text-sm font-bold text-slate-800">{product.name}</p>
                          {product.description && <p className="text-xs text-slate-500 mt-0.5 line-clamp-1">{product.description}</p>}
                        </div>
                      </label>
                    );
                  })}
                </div>
              )}
            </div>

            <div className="space-y-4 mt-6">
              <h3 className="text-sm font-bold text-slate-800 border-b border-slate-200 pb-2">Plan Features (Benefits)</h3>
              <div className="space-y-2">
                {(formData.features || []).map((feature, index) => (
                  <div key={index} className="flex gap-2">
                    <input 
                      type="text" 
                      required
                      value={feature} 
                      onChange={(e) => {
                        const newFeatures = [...formData.features];
                        newFeatures[index] = e.target.value;
                        setFormData({...formData, features: newFeatures});
                      }}
                      className="flex-1 px-4 py-2 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" 
                      placeholder="e.g. Free Delivery" 
                    />
                    <button 
                      type="button" 
                      onClick={() => {
                        const newFeatures = formData.features.filter((_, i) => i !== index);
                        setFormData({...formData, features: newFeatures});
                      }}
                      className="p-2 text-red-500 hover:bg-red-50 rounded-xl transition-colors"
                    >
                      <Trash2 className="w-5 h-5" />
                    </button>
                  </div>
                ))}
                <button 
                  type="button" 
                  onClick={() => setFormData({...formData, features: [...(formData.features || []), ""]})}
                  className="flex items-center gap-2 text-sm font-bold text-teal-600 hover:text-teal-700 py-2"
                >
                  <Plus className="w-4 h-4" /> Add Feature
                </button>
              </div>
            </div>

          </div>
          
          <div className="px-6 py-4 border-t border-slate-200/60 bg-white/50 flex justify-end gap-3 mt-6">
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
