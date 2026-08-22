"use client";

import { useState, useEffect } from "react";
import { X, Save, Send } from "lucide-react";

export default function MarketingFormModal({ isOpen, onClose }) {
  const [formData, setFormData] = useState({
    name: "",
    channel: "Push Notification",
    audience: "All Users",
    status: "Draft",
    message: "",
  });
  
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      setFormData({
        name: "",
        channel: "Push Notification",
        audience: "All Users",
        status: "Draft",
        message: "",
      });
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(p => ({ ...p, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("Saving campaign:", formData);
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
            <h2 className="text-xl font-black text-slate-800 tracking-tight">Create New Campaign</h2>
            <p className="text-xs font-medium text-slate-500 mt-0.5">Set up a new marketing campaign</p>
          </div>
          <button 
            onClick={onClose}
            className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          <form id="marketingForm" onSubmit={handleSubmit} className="space-y-6">
            
            {/* Basic Info */}
            <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm space-y-4">
              <h4 className="text-sm font-bold text-slate-800 border-b border-slate-50 pb-2 mb-4">Campaign Details</h4>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="col-span-1 sm:col-span-2">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Campaign Name *</label>
                  <input required name="name" value={formData.name} onChange={handleChange} type="text" placeholder="e.g. Weekend Flash Sale" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800" />
                </div>

                <div className="col-span-1">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Channel</label>
                  <select 
                    name="channel" 
                    value={formData.channel} 
                    onChange={handleChange} 
                    className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800 cursor-pointer"
                  >
                    <option value="Push Notification">Push Notification</option>
                    <option value="SMS">SMS</option>
                    <option value="Email">Email</option>
                  </select>
                </div>

                <div className="col-span-1">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Target Audience</label>
                  <select 
                    name="audience" 
                    value={formData.audience} 
                    onChange={handleChange} 
                    className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800 cursor-pointer"
                  >
                    <option value="All Users">All Users</option>
                    <option value="Active Users">Active Users</option>
                    <option value="Inactive > 30 days">Inactive &gt; 30 days</option>
                    <option value="Premium Users">Premium Users</option>
                  </select>
                </div>
                
                <div className="col-span-1 sm:col-span-2">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Message Content</label>
                  <textarea name="message" value={formData.message} onChange={handleChange} placeholder="Enter your campaign message..." rows={4} className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800 resize-none"></textarea>
                </div>

                <div className="col-span-1 sm:col-span-2">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Status</label>
                  <div className="flex bg-slate-50 p-1 border border-slate-200 rounded-xl w-full">
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, status: "Draft" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.status === "Draft" ? "bg-white text-slate-700 shadow-sm border border-slate-200" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      Draft
                    </button>
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, status: "Scheduled" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.status === "Scheduled" ? "bg-white text-blue-700 shadow-sm border border-blue-100" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      Scheduled
                    </button>
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, status: "Active" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.status === "Active" ? "bg-white text-teal-700 shadow-sm border border-teal-100" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      Active
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
            form="marketingForm"
            className="px-6 py-2.5 bg-teal-500 text-white hover:bg-teal-600 rounded-xl text-sm font-bold transition-colors shadow-sm flex items-center"
          >
            {formData.status === "Active" ? (
              <><Send className="w-4 h-4 mr-2" /> Launch Now</>
            ) : (
              <><Save className="w-4 h-4 mr-2" /> Save Campaign</>
            )}
          </button>
        </div>

      </div>
    </div>
  );
}
