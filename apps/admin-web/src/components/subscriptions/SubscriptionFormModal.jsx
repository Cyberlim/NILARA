"use client";

import { useState, useEffect } from "react";
import { X } from "lucide-react";

export default function SubscriptionFormModal({ isOpen, onClose, itemToEdit, onSave }) {
  const [formData, setFormData] = useState({
    customerName: "",
    phone: "",
    planName: "Daily 20L Water Jar",
    frequency: "Daily",
    price: 60,
    address: "",
    status: "Active",
    driver: "-",
  });

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      if (itemToEdit) {
        setFormData({
          customerName: itemToEdit.customerName,
          phone: itemToEdit.phone,
          planName: itemToEdit.planName,
          frequency: itemToEdit.frequency,
          price: itemToEdit.price,
          address: itemToEdit.address || "",
          status: itemToEdit.status,
          driver: itemToEdit.driver || "-",
        });
      } else {
        setFormData({
          customerName: "",
          phone: "",
          planName: "Daily 20L Water Jar",
          frequency: "Daily",
          price: 60,
          address: "",
          status: "New",
          driver: "-",
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
      id: itemToEdit ? itemToEdit.id : `SUB-${Math.floor(Math.random() * 1000)}`,
      statusColor: formData.status === "Active" ? "green" : formData.status === "Paused" ? "orange" : formData.status === "New" ? "blue" : "red",
      startDate: itemToEdit ? itemToEdit.startDate : "Today",
      nextDelivery: formData.status === "Paused" || formData.status === "Cancelled" ? "None" : "Tomorrow, 7:00 AM",
    });
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity" onClick={onClose}></div>

      <div className="relative w-full max-w-2xl bg-white rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <h2 className="text-xl font-black text-slate-800 tracking-tight">
            {itemToEdit ? "Edit Subscriber" : "Add Subscriber"}
          </h2>
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
            <X className="w-4 h-4" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          <div className="space-y-6">
            
            <div className="space-y-4">
              <h3 className="text-sm font-bold text-slate-800 border-b border-slate-200 pb-2">Customer Info</h3>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Customer Name</label>
                  <input type="text" required value={formData.customerName} onChange={(e) => setFormData({...formData, customerName: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" placeholder="Customer Name" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Phone Number</label>
                  <input type="tel" required value={formData.phone} onChange={(e) => setFormData({...formData, phone: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-mono" placeholder="+91 98765 43210" />
                </div>
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-700 mb-1.5">Delivery Address</label>
                <textarea rows={2} required value={formData.address} onChange={(e) => setFormData({...formData, address: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all resize-none" placeholder="Enter delivery address" />
              </div>
            </div>

            <div className="space-y-4">
              <h3 className="text-sm font-bold text-slate-800 border-b border-slate-200 pb-2 mt-6">Subscription Plan</h3>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Select Plan</label>
                  <select value={formData.planName} onChange={(e) => setFormData({...formData, planName: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all appearance-none cursor-pointer">
                    <option value="Daily 20L Water Jar">Daily 20L Water Jar</option>
                    <option value="Weekly Family Pack (3 Jars)">Weekly Family Pack (3 Jars)</option>
                    <option value="Monthly Office Supply (50 Jars)">Monthly Office Supply (50 Jars)</option>
                    <option value="Alternate Days 20L Jar">Alternate Days 20L Jar</option>
                  </select>
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
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Price Per Delivery (₹)</label>
                  <input type="number" required min="0" value={formData.price} onChange={(e) => setFormData({...formData, price: parseInt(e.target.value) || 0})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" />
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Status</label>
                  <select value={formData.status} onChange={(e) => setFormData({...formData, status: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all appearance-none cursor-pointer">
                    <option value="Active">Active</option>
                    <option value="Paused">Paused</option>
                    <option value="Cancelled">Cancelled</option>
                    <option value="New">New</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-700 mb-1.5">Assign Driver (Optional)</label>
                  <input type="text" value={formData.driver} onChange={(e) => setFormData({...formData, driver: e.target.value})} className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all" placeholder="Leave empty for auto-assign" />
                </div>
              </div>
            </div>

          </div>
          
          <div className="mt-8 flex justify-end gap-3 border-t border-slate-200/60 pt-5">
            <button type="button" onClick={onClose} className="px-5 py-2.5 bg-white border border-slate-200 text-slate-600 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors">
              Cancel
            </button>
            <button type="submit" className="px-5 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm">
              {itemToEdit ? "Save Changes" : "Add Subscriber"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
