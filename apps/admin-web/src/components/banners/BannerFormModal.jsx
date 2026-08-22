"use client";

import { useState, useEffect, useRef } from "react";
import { X, Upload, Save } from "lucide-react";

export default function BannerFormModal({ isOpen, onClose, bannerToEdit }) {
  const isEditing = !!bannerToEdit;

  const [formData, setFormData] = useState({
    title: "",
    location: "Home Top Banner",
    status: "Active",
    image: null,
  });
  
  const fileInputRef = useRef(null);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      if (bannerToEdit) {
        setFormData({
          title: bannerToEdit.title || "",
          location: bannerToEdit.location || "Home Top Banner",
          status: bannerToEdit.status || "Active",
          image: bannerToEdit.image || null,
        });
      } else {
        setFormData({
          title: "",
          location: "Home Top Banner",
          status: "Active",
          image: null,
        });
      }
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen, bannerToEdit]);

  if (!isOpen) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(p => ({ ...p, [name]: value }));
  };
  
  const handleFileChange = (e) => {
    if (e.target.files && e.target.files[0]) {
      setFormData(p => ({ ...p, image: "🖼️" })); // Placeholder
    }
  };

  const handleUploadClick = () => {
    if (fileInputRef.current) {
      fileInputRef.current.click();
    }
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("Saving banner:", formData);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center p-4 sm:p-6">
      <div 
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      ></div>

      <div className="relative w-full max-w-xl max-h-[90vh] bg-white rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white">
          <div>
            <h2 className="text-xl font-black text-slate-800 tracking-tight">
              {isEditing ? "Edit Banner" : "Add New Banner"}
            </h2>
            <p className="text-xs font-medium text-slate-500 mt-0.5">
              {isEditing ? "Update banner details" : "Enter details for the new banner"}
            </p>
          </div>
          <button 
            onClick={onClose}
            className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          <form id="bannerForm" onSubmit={handleSubmit} className="space-y-6">
            
            {/* Image Upload Section */}
            <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm flex flex-col sm:flex-row gap-6 items-start sm:items-center">
              <input 
                type="file" 
                ref={fileInputRef} 
                onChange={handleFileChange} 
                accept="image/*" 
                className="hidden" 
              />
              <div 
                onClick={handleUploadClick}
                className="w-40 h-24 rounded-2xl border-2 border-dashed border-slate-200 bg-slate-50 flex items-center justify-center flex-shrink-0 group hover:border-teal-400 transition-colors cursor-pointer relative overflow-hidden"
              >
                {formData.image ? (
                  <span className="text-5xl">{formData.image}</span>
                ) : (
                  <Upload className="w-6 h-6 text-slate-400 group-hover:text-teal-500 transition-colors" />
                )}
                <div className="absolute inset-0 bg-slate-900/50 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                  <span className="text-white text-[10px] font-bold">Change</span>
                </div>
              </div>
              <div className="flex-1">
                <h4 className="text-sm font-bold text-slate-800 mb-1">Banner Image</h4>
                <p className="text-xs text-slate-500 mb-3">Upload a banner image. Recommended size 1200x400px. Max size 2MB.</p>
                <button 
                  type="button" 
                  onClick={handleUploadClick}
                  className="px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold text-slate-700 hover:bg-slate-50 hover:border-slate-300 transition-colors"
                >
                  Choose Image
                </button>
              </div>
            </div>

            {/* Basic Info */}
            <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm space-y-4">
              <h4 className="text-sm font-bold text-slate-800 border-b border-slate-50 pb-2 mb-4">Banner Details</h4>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="col-span-1 sm:col-span-2">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Banner Title *</label>
                  <input required name="title" value={formData.title} onChange={handleChange} type="text" placeholder="e.g. Diwali Mega Sale" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800" />
                </div>

                <div className="col-span-1">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Location</label>
                  <select 
                    name="location" 
                    value={formData.location} 
                    onChange={handleChange} 
                    className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800 cursor-pointer"
                  >
                    <option value="Home Top Banner">Home Top Banner</option>
                    <option value="Home Middle Slider">Home Middle Slider</option>
                    <option value="Category Banner">Category Banner</option>
                    <option value="Checkout Page">Checkout Page</option>
                  </select>
                </div>

                <div className="col-span-1">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Status</label>
                  <div className="flex bg-slate-50 p-1 border border-slate-200 rounded-xl w-full">
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, status: "Active" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.status === "Active" ? "bg-white text-teal-700 shadow-sm border border-teal-100" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      Active
                    </button>
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, status: "Paused" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.status === "Paused" ? "bg-white text-orange-700 shadow-sm border border-orange-100" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      Paused
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
            className="px-5 py-2.5 bg-white text-slate-600 border border-slate-200 hover:bg-slate-50 rounded-xl text-sm font-bold transition-colors"
          >
            Cancel
          </button>
          <button 
            type="submit"
            form="bannerForm"
            className="px-6 py-2.5 bg-teal-500 text-white hover:bg-teal-600 rounded-xl text-sm font-bold transition-colors shadow-sm flex items-center"
          >
            <Save className="w-4 h-4 mr-2" />
            {isEditing ? "Save Changes" : "Add Banner"}
          </button>
        </div>

      </div>
    </div>
  );
}
