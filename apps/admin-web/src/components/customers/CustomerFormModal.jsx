"use client";

import { useState, useEffect } from "react";
import { X, User } from "lucide-react";

export default function CustomerFormModal({ isOpen, onClose, itemToEdit, onSave }) {
  const [formData, setFormData] = useState({
    name: "",
    phone: "",
    email: "",
    address: "",
    walletBalance: 0,
    status: "Active",
    isPremium: false,
  });

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      if (itemToEdit) {
        setFormData({
          name: itemToEdit.name,
          phone: itemToEdit.phone,
          email: itemToEdit.email,
          address: itemToEdit.address || "",
          walletBalance: itemToEdit.walletBalance,
          status: itemToEdit.status,
          isPremium: itemToEdit.isPremium || false,
        });
      } else {
        setFormData({
          name: "",
          phone: "",
          email: "",
          address: "",
          walletBalance: 0,
          status: "New",
          isPremium: false,
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
    onSave && onSave({
      ...formData,
      id: itemToEdit ? itemToEdit.id : `CUST-${Math.floor(Math.random() * 1000)}`,
      avatar: itemToEdit ? itemToEdit.avatar : "👤",
      totalOrders: itemToEdit ? itemToEdit.totalOrders : 0,
      statusColor: formData.status === "Active" ? "green" : formData.status === "Inactive" ? "slate" : formData.status === "New" ? "blue" : "red",
      joinDate: itemToEdit ? itemToEdit.joinDate : "Today",
      lastActive: "Just now",
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity" onClick={onClose}></div>

      <div className="relative w-full max-w-2xl bg-white rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <h2 className="text-xl font-black text-slate-800 tracking-tight">
            {itemToEdit ? "Edit Customer Details" : "Add New Customer"}
          </h2>
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
            <X className="w-4 h-4" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          <div className="space-y-6">
            
            <div className="flex flex-col sm:flex-row gap-6">
              {/* Avatar Placeholder */}
              <div className="flex flex-col items-center justify-center w-32 h-32 bg-white border-2 border-slate-100 rounded-full shrink-0 group relative overflow-hidden shadow-inner mx-auto sm:mx-0">
                <div className="text-5xl">{itemToEdit ? itemToEdit.avatar : "👤"}</div>
              </div>

              {/* Basic Info */}
              <div className="flex-1 space-y-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Full Name</label>
                  <input type="text" required value={formData.name} onChange={(e) => setFormData({...formData, name: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" placeholder="Enter customer name" />
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Phone Number</label>
                    <input type="tel" required value={formData.phone} onChange={(e) => setFormData({...formData, phone: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-mono" placeholder="+91 98765 43210" />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-slate-700 mb-1.5">Email Address</label>
                    <input type="email" value={formData.email} onChange={(e) => setFormData({...formData, email: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" placeholder="customer@example.com" />
                  </div>
                </div>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">Primary Address</label>
                <textarea rows={2} value={formData.address} onChange={(e) => setFormData({...formData, address: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all resize-none" placeholder="Enter full address" />
              </div>
              
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Status</label>
                  <select value={formData.status} onChange={(e) => setFormData({...formData, status: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all appearance-none cursor-pointer">
                    <option value="Active">Active</option>
                    <option value="Inactive">Inactive</option>
                    <option value="New">New</option>
                    <option value="Churned">Churned</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Wallet Balance (₹)</label>
                  <input type="number" min="0" value={formData.walletBalance} onChange={(e) => setFormData({...formData, walletBalance: parseInt(e.target.value) || 0})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" />
                </div>
                <div className="flex flex-col justify-end pb-1">
                  <label className="flex items-center space-x-3 cursor-pointer group">
                    <div className="relative">
                      <input type="checkbox" className="sr-only" checked={formData.isPremium} onChange={(e) => setFormData({...formData, isPremium: e.target.checked})} />
                      <div className={`block w-10 h-6 rounded-full transition-colors ${formData.isPremium ? 'bg-amber-400' : 'bg-slate-300'}`}></div>
                      <div className={`absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform ${formData.isPremium ? 'translate-x-4' : ''}`}></div>
                    </div>
                    <span className="text-sm font-bold text-slate-700 group-hover:text-amber-600 transition-colors">Premium Member</span>
                  </label>
                </div>
              </div>
            </div>

          </div>
          
          <div className="mt-8 flex justify-end gap-3 border-t border-slate-200/60 pt-5">
            <button type="button" onClick={onClose} className="px-5 py-2.5 bg-white border border-slate-200 text-slate-600 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors">
              Cancel
            </button>
            <button type="submit" className="px-5 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm">
              {itemToEdit ? "Save Changes" : "Add Customer"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
