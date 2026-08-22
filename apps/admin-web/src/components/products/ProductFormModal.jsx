"use client";

import { useState, useEffect, useRef } from "react";
import { X, Upload, Save, AlertCircle, Plus, Trash2, Loader2 } from "lucide-react";
import { fetchWithAuth } from "@/lib/api";

export default function ProductFormModal({ isOpen, onClose, productToEdit, onSuccess }) {
  const isEditing = !!productToEdit;
  const fileInputRef = useRef(null);

  const [categories, setCategories] = useState([]);
  const [newFiles, setNewFiles] = useState([]);
  const [isSaving, setIsSaving] = useState(false);

  const [formData, setFormData] = useState({
    name: "",
    variant: "",
    sku: "",
    category: "", // will hold the category ID
    price: "",
    mrp: "",
    stock: "",
    status: "Active",
    description: "",
    tags: "",
    images: [], // holds string URLs
  });

  useEffect(() => {
    // Fetch categories on mount
    fetchWithAuth('/categories')
      .then(res => setCategories(res.data))
      .catch(err => console.error("Failed to load categories", err));
  }, []);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      setNewFiles([]);
      if (productToEdit) {
        // Find category ID by name, since the table passes category name
        const cat = categories.find(c => c.name === productToEdit.category);
        setFormData({
          name: productToEdit.name,
          variant: productToEdit.variant,
          sku: productToEdit.sku,
          category: cat ? cat._id : (categories.length > 0 ? categories[0]._id : ""),
          price: productToEdit.price,
          mrp: productToEdit.mrp || "",
          stock: productToEdit.stock,
          status: productToEdit.status,
          description: productToEdit.description || "",
          tags: productToEdit.tags || "",
          images: productToEdit.images || (productToEdit.image ? [productToEdit.image] : []),
        });
      } else {
        setFormData({
          name: "",
          variant: "",
          sku: "",
          category: categories.length > 0 ? categories[0]._id : "",
          price: "",
          mrp: "",
          stock: "",
          status: "Active",
          description: "",
          tags: "",
          images: [],
        });
      }
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen, productToEdit, categories]);

  if (!isOpen) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(p => ({ ...p, [name]: value }));
  };

  const handleFileSelect = (e) => {
    if (e.target.files && e.target.files.length > 0) {
      const filesArray = Array.from(e.target.files);
      setNewFiles(prev => [...prev, ...filesArray]);
    }
  };

  const removeExistingImage = (idx) => {
    const arr = [...formData.images];
    arr.splice(idx, 1);
    setFormData({ ...formData, images: arr });
  };

  const removeNewFile = (idx) => {
    const arr = [...newFiles];
    arr.splice(idx, 1);
    setNewFiles(arr);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.category) {
      alert("Please select a category.");
      return;
    }

    setIsSaving(true);
    try {
      let finalImageUrls = [...formData.images];

      // 1. Upload new files if any
      if (newFiles.length > 0) {
        const uploadData = new FormData();
        newFiles.forEach(f => uploadData.append('images', f));
        
        const uploadRes = await fetchWithAuth('/uploads/images', {
          method: 'POST',
          body: uploadData
        });
        
        // uploadRes should return array of URLs in res.data or res.urls (check controller if needed)
        // Assuming it's in uploadRes.data
        if (uploadRes.data && Array.isArray(uploadRes.data)) {
           finalImageUrls = [...finalImageUrls, ...uploadRes.data];
        }
      }

      const [weightOrVolume, parsedUnit] = formData.variant.split(' ');
      let unitStr = (parsedUnit || 'piece').toLowerCase();
      if (unitStr === 'litre' || unitStr === 'litres') unitStr = 'l';
      if (!['piece', 'ml', 'l', 'g', 'kg', 'pack'].includes(unitStr)) unitStr = 'piece';

      const payload = {
        name: formData.name,
        description: formData.description,
        category: formData.category,
        images: finalImageUrls,
        isActive: formData.status === "Active",
        variants: [{
          sku: formData.sku,
          pricePaise: Math.round(parseFloat(formData.price) * 100),
          stockQuantity: parseInt(formData.stock),
          unit: unitStr,
          weightOrVolume: parseFloat(weightOrVolume) || 1,
          isActive: formData.status === "Active"
        }]
      };

      if (formData.mrp) {
         payload.variants[0].pricePaise = Math.round(parseFloat(formData.mrp) * 100);
         payload.variants[0].discountPricePaise = Math.round(parseFloat(formData.price) * 100);
      }

      // 3. Save Product
      if (isEditing) {
        await fetchWithAuth(`/products/${productToEdit.id}`, {
          method: 'PATCH',
          body: JSON.stringify(payload)
        });
      } else {
        await fetchWithAuth('/products', {
          method: 'POST',
          body: JSON.stringify(payload)
        });
      }
      
      if (onSuccess) onSuccess();
      else onClose();
      
    } catch (err) {
      alert("Error saving product: " + err.message);
      console.error(err);
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center p-4 sm:p-6">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      ></div>

      {/* Modal Container */}
      <div className="relative w-full max-w-3xl max-h-[90vh] bg-white rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white">
          <div>
            <h2 className="text-xl font-black text-slate-800 tracking-tight">
              {isEditing ? "Edit Product" : "Add New Product"}
            </h2>
            <p className="text-xs font-medium text-slate-500 mt-0.5">
              {isEditing ? "Update product details and inventory" : "Enter details for the new product"}
            </p>
          </div>
          <button 
            onClick={onClose}
            className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Form Content */}
        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          <form id="productForm" onSubmit={handleSubmit} className="space-y-6">
            
            {/* Media Gallery Section */}
            <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm space-y-4">
              <div className="flex justify-between items-end border-b border-slate-50 pb-2 mb-4">
                <div>
                  <h4 className="text-sm font-bold text-slate-800">Media Gallery</h4>
                  <p className="text-xs text-slate-500 mt-0.5">Upload images or paste a Cloudinary URL</p>
                </div>
                <button type="button" onClick={() => fileInputRef.current?.click()} className="text-xs font-bold text-teal-600 hover:text-teal-700 flex items-center">
                  <Plus className="w-3.5 h-3.5 mr-1" /> Upload Image
                </button>
                <input type="file" ref={fileInputRef} hidden multiple accept="image/*" onChange={handleFileSelect} />
              </div>

              {/* Paste URL input */}
              <div className="flex gap-2 mb-3">
                <input
                  id="imageUrlInput"
                  type="url"
                  placeholder="Paste image URL (e.g. https://res.cloudinary.com/...)" 
                  className="flex-1 border border-slate-200 rounded-xl px-3 py-2 text-xs text-slate-700 focus:outline-none focus:ring-2 focus:ring-teal-500/30 focus:border-teal-400 transition-all"
                />
                <button
                  type="button"
                  onClick={() => {
                    const input = document.getElementById('imageUrlInput');
                    const url = input.value.trim();
                    if (url && (url.startsWith('http://') || url.startsWith('https://'))) {
                      setFormData(prev => ({ ...prev, images: [...prev.images, url] }));
                      input.value = '';
                    } else {
                      alert('Please enter a valid URL starting with http:// or https://');
                    }
                  }}
                  className="px-3 py-2 bg-slate-800 text-white text-xs font-bold rounded-xl hover:bg-slate-900 transition-colors whitespace-nowrap"
                >
                  Add URL
                </button>
              </div>
              
              <div className="flex flex-wrap gap-4">
                {/* Existing Images */}
                {formData.images.map((img, idx) => (
                  <div key={`old-${idx}`} className="relative w-24 h-24 rounded-2xl border border-slate-200 bg-slate-50 flex items-center justify-center group overflow-hidden shadow-sm">
                    {img.startsWith('http') || img.startsWith('/') ? (
                      <img src={img} alt="Product" className="w-full h-full object-cover" />
                    ) : (
                      <span className="text-5xl">{img}</span>
                    )}
                    <div className="absolute inset-0 bg-slate-900/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                      <button type="button" className="w-7 h-7 rounded-lg bg-white/90 text-red-600 flex items-center justify-center hover:bg-white transition-colors"
                        onClick={() => removeExistingImage(idx)}
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                    {idx === 0 && <div className="absolute bottom-0 left-0 right-0 bg-teal-500 text-white text-[9px] font-bold text-center py-0.5 uppercase tracking-wider">Primary</div>}
                  </div>
                ))}
                
                {/* New Files */}
                {newFiles.map((file, idx) => {
                  const url = URL.createObjectURL(file);
                  return (
                    <div key={`new-${idx}`} className="relative w-24 h-24 rounded-2xl border border-teal-300 bg-teal-50 flex items-center justify-center group overflow-hidden shadow-sm">
                      <img src={url} alt="New" className="w-full h-full object-cover" />
                      <div className="absolute inset-0 bg-slate-900/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                        <button type="button" className="w-7 h-7 rounded-lg bg-white/90 text-red-600 flex items-center justify-center hover:bg-white transition-colors"
                          onClick={() => removeNewFile(idx)}
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>
                      <div className="absolute top-1 right-1 bg-teal-500 w-4 h-4 rounded-full flex items-center justify-center">
                        <span className="text-white text-[8px]">New</span>
                      </div>
                    </div>
                  );
                })}
                
                <div className="w-24 h-24 rounded-2xl border-2 border-dashed border-slate-200 bg-slate-50 flex flex-col items-center justify-center group hover:border-teal-400 hover:bg-teal-50/30 transition-colors cursor-pointer relative overflow-hidden"
                  onClick={() => fileInputRef.current?.click()}
                >
                  <Upload className="w-6 h-6 text-slate-400 group-hover:text-teal-500 mb-1 transition-colors" />
                  <span className="text-[10px] font-bold text-slate-400 group-hover:text-teal-600">Upload</span>
                </div>
              </div>
            </div>

            {/* Basic Info */}
            <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm space-y-4">
              <h4 className="text-sm font-bold text-slate-800 border-b border-slate-50 pb-2 mb-4">Basic Information</h4>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="col-span-1 sm:col-span-2">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Product Name *</label>
                  <input required name="name" value={formData.name} onChange={handleChange} type="text" placeholder="e.g. Nilara 500 ml" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800" />
                </div>
                
                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Variant/Unit Size</label>
                  <input name="variant" value={formData.variant} onChange={handleChange} type="text" placeholder="e.g. 500 ml" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800" />
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">SKU Code *</label>
                  <input required name="sku" value={formData.sku} onChange={handleChange} type="text" placeholder="e.g. NIL-500ML" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-mono font-bold text-slate-700 uppercase" />
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Category *</label>
                  <select required name="category" value={formData.category} onChange={handleChange} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800 appearance-none cursor-pointer">
                    <option value="" disabled>Select Category</option>
                    {categories.map(c => (
                      <option key={c._id} value={c._id}>{c.name}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Tags/Badges (Comma separated)</label>
                  <input name="tags" value={formData.tags} onChange={handleChange} type="text" placeholder="e.g. WATER, NEW" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800 uppercase" />
                </div>

                <div className="col-span-1 sm:col-span-2">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">About / Description</label>
                  <textarea name="description" value={formData.description} onChange={handleChange} rows="3" placeholder="Fresh and premium quality directly sourced from farms..." className="w-full px-4 py-3 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800 resize-none"></textarea>
                </div>
              </div>
            </div>

            {/* Pricing & Inventory */}
            <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm space-y-4">
              <h4 className="text-sm font-bold text-slate-800 border-b border-slate-50 pb-2 mb-4">Pricing & Inventory</h4>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Selling Price (₹) *</label>
                  <input required name="price" value={formData.price} onChange={handleChange} type="number" min="0" step="0.01" placeholder="0.00" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-black text-slate-800" />
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">MRP (₹)</label>
                  <input name="mrp" value={formData.mrp} onChange={handleChange} type="number" min="0" step="0.01" placeholder="0.00" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-bold text-slate-500" />
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Current Stock *</label>
                  <input required name="stock" value={formData.stock} onChange={handleChange} type="number" min="0" placeholder="0" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-bold text-slate-800" />
                </div>

                <div>
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Status</label>
                  <div className="flex bg-slate-50 p-1 border border-slate-200 rounded-xl">
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, status: "Active" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.status === "Active" ? "bg-white text-teal-700 shadow-sm border border-teal-100" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      Active
                    </button>
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, status: "Inactive" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.status === "Inactive" ? "bg-white text-red-700 shadow-sm border border-red-100" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      Inactive
                    </button>
                  </div>
                </div>
              </div>
            </div>

          </form>
        </div>
        
        {/* Footer */}
        <div className="px-6 py-4 border-t border-slate-100 bg-white flex justify-end space-x-3 items-center">
          <button 
            type="button"
            onClick={onClose}
            disabled={isSaving}
            className="px-5 py-2.5 bg-white text-slate-600 border border-slate-200 hover:bg-slate-50 rounded-xl text-sm font-bold transition-colors disabled:opacity-50"
          >
            Cancel
          </button>
          <button 
            type="submit"
            form="productForm"
            disabled={isSaving}
            className="px-6 py-2.5 bg-teal-500 text-white hover:bg-teal-600 rounded-xl text-sm font-bold transition-colors shadow-sm flex items-center disabled:opacity-50"
          >
            {isSaving ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : <Save className="w-4 h-4 mr-2" />}
            {isSaving ? "Saving..." : isEditing ? "Save Changes" : "Create Product"}
          </button>
        </div>

      </div>
    </div>
  );
}
