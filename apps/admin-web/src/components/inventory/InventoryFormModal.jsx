"use client";

import { useState, useRef, useEffect } from "react";
import { X, Upload, Package } from "lucide-react";

export default function InventoryFormModal({ isOpen, onClose, itemToEdit, onSave }) {
  const [formData, setFormData] = useState({
    name: "",
    variant: "",
    sku: "",
    category: "Water Jars",
    stock: 0,
    unitPrice: 0,
    status: "In Stock",
  });
  
  const [imagePreview, setImagePreview] = useState(null);
  const fileInputRef = useRef(null);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      if (itemToEdit) {
        setFormData({
          name: itemToEdit.name,
          variant: itemToEdit.variant || "",
          sku: itemToEdit.sku,
          category: itemToEdit.category,
          stock: itemToEdit.stock,
          unitPrice: itemToEdit.unitPrice,
          status: itemToEdit.status,
        });
        setImagePreview(itemToEdit.image);
      } else {
        setFormData({
          name: "",
          variant: "",
          sku: "",
          category: "Water Jars",
          stock: 0,
          unitPrice: 0,
          status: "In Stock",
        });
        setImagePreview(null);
      }
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen, itemToEdit]);

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    onSave && onSave({
      ...formData,
      image: imagePreview || "📦",
      id: itemToEdit ? itemToEdit.id : `INV-${Math.floor(Math.random() * 1000)}`,
      inventoryValue: (formData.stock * formData.unitPrice).toLocaleString('en-IN'),
      stockStatus: formData.stock > 100 ? "In Stock" : formData.stock > 0 ? "Low Stock" : "Out of Stock",
      statusColor: formData.status === "In Stock" ? "green" : formData.status === "Low Stock" ? "orange" : "red",
      categoryColor: formData.category === "Water Jars" ? "teal" : "blue",
      expiryDate: "-",
      updatedDate: new Date().toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }),
      updatedTime: new Date().toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity" onClick={onClose}></div>

      <div className="relative w-full max-w-2xl bg-white rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <h2 className="text-xl font-black text-slate-800 tracking-tight">
            {itemToEdit ? "Edit Inventory Item" : "Adjust Stock / Add New Item"}
          </h2>
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
            <X className="w-4 h-4" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          <div className="space-y-6">
            
            <div className="flex flex-col sm:flex-row gap-6">
              {/* Image Upload */}
              <div className="flex flex-col items-center justify-center w-32 h-32 bg-white border-2 border-dashed border-slate-200 rounded-2xl cursor-pointer hover:border-teal-400 hover:bg-teal-50/50 transition-colors shrink-0 group relative overflow-hidden" onClick={() => fileInputRef.current?.click()}>
                {imagePreview ? (
                  <div className="text-5xl">{imagePreview}</div>
                ) : (
                  <>
                    <Upload className="w-6 h-6 text-slate-400 group-hover:text-teal-500 mb-2" />
                    <span className="text-[10px] font-bold text-slate-500 group-hover:text-teal-600 text-center px-2">Upload Image</span>
                  </>
                )}
                <input type="file" ref={fileInputRef} className="hidden" accept="image/*" onChange={(e) => {
                   if (e.target.files && e.target.files[0]) {
                     setImagePreview("📦"); // Simulate image upload with an emoji for mockup
                   }
                }} />
              </div>

              {/* Basic Info */}
              <div className="flex-1 space-y-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Product Name</label>
                  <input type="text" required value={formData.name} onChange={(e) => setFormData({...formData, name: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" placeholder="Enter product name" />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">SKU</label>
                    <input type="text" required value={formData.sku} onChange={(e) => setFormData({...formData, sku: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-mono" placeholder="NIL-001" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Category</label>
                    <select value={formData.category} onChange={(e) => setFormData({...formData, category: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all appearance-none">
                      <option value="Water Jars">Water Jars</option>
                      <option value="Water Bottles">Water Bottles</option>
                      <option value="Accessories">Accessories</option>
                      <option value="Glass Bottles">Glass Bottles</option>
                      <option value="Filters">Filters</option>
                    </select>
                  </div>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
               <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Stock Quantity</label>
                  <input type="number" required min="0" value={formData.stock} onChange={(e) => setFormData({...formData, stock: parseInt(e.target.value) || 0})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Unit Price (₹)</label>
                  <input type="number" required min="0" value={formData.unitPrice} onChange={(e) => setFormData({...formData, unitPrice: parseInt(e.target.value) || 0})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" />
                </div>
            </div>
          </div>
          
          <div className="mt-8 flex justify-end gap-3 border-t border-slate-200/60 pt-5">
            <button type="button" onClick={onClose} className="px-5 py-2.5 bg-white border border-slate-200 text-slate-600 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors">
              Cancel
            </button>
            <button type="submit" className="px-5 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm">
              {itemToEdit ? "Save Changes" : "Add Inventory"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
