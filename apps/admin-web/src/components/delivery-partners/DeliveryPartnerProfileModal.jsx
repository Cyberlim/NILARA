"use client";

import { useEffect } from "react";
import { X, ArrowLeft, Star, Phone, Activity } from "lucide-react";

// Fallback to find a partner if only a name or ID is passed
const findPartner = (query) => {
  if (!query) return null;
  if (typeof query === 'object') return query;
  return [].find(p => 
    p.id === query || p.name === query || p.phone === query
  ) || {
    id: "DP-999",
    name: query,
    phone: "+91 99999 99999",
    vehicle: "Unknown Vehicle",
    rating: 0.0,
    status: "Unknown",
    statusColor: "slate",
    totalDeliveries: 0,
    joinDate: "N/A"
  };
};

export default function DeliveryPartnerProfileModal({ isOpen, onClose, partnerQuery }) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  const selectedItem = findPartner(partnerQuery);
  if (!selectedItem) return null;

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/50 backdrop-blur-sm transition-opacity" onClick={onClose}></div>

      <div className="relative w-full max-w-2xl bg-white rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="p-6 border-b border-slate-100 flex justify-between items-center bg-white">
          <div className="flex items-center">
            <button 
              onClick={onClose}
              className="w-10 h-10 flex items-center justify-center rounded-xl bg-slate-50 text-slate-500 hover:bg-slate-100 hover:text-slate-700 transition-colors mr-4"
            >
              <ArrowLeft className="w-5 h-5" />
            </button>
            <div>
              <h2 className="text-xl font-black text-slate-800 tracking-tight">Partner Details</h2>
              <p className="text-sm font-medium text-slate-500 mt-1">{selectedItem.id}</p>
            </div>
          </div>
          <button onClick={onClose} className="w-10 h-10 flex items-center justify-center rounded-full border border-slate-200 bg-white text-slate-500 hover:bg-slate-50 hover:text-slate-800 transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-white space-y-4">
          
          {/* Main Info Card */}
          <div className="bg-slate-50/80 rounded-2xl p-6 border border-slate-100 flex items-center justify-between">
            <div className="flex items-center">
              <div className="w-16 h-16 rounded-full border-2 border-teal-100 bg-teal-50 flex items-center justify-center text-2xl font-black text-teal-600 mr-5">
                {selectedItem.name.charAt(0)}
              </div>
              <div>
                <h3 className="text-xl font-black text-slate-800">{selectedItem.name}</h3>
                <p className="text-sm font-medium text-slate-500 mt-1 flex items-center">
                  <Phone className="w-4 h-4 mr-1.5" />
                  {selectedItem.phone}
                </p>
              </div>
            </div>
            <div>
              <span className={`inline-flex items-center px-3 py-1.5 rounded-full text-xs font-bold bg-${selectedItem.statusColor}-50 text-${selectedItem.statusColor}-700`}>
                <span className={`w-1.5 h-1.5 rounded-full bg-${selectedItem.statusColor}-500 mr-2`}></span>
                {selectedItem.status}
              </span>
            </div>
          </div>

          {/* Stats Grid */}
          <div className="grid grid-cols-2 gap-4">
            <div className="border border-slate-100 rounded-2xl p-6 flex flex-col items-center justify-center">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Rating</p>
              <div className="flex items-center text-amber-500">
                <Star className="w-6 h-6 mr-1.5 fill-current" />
                <span className="text-3xl font-black">{selectedItem.rating}</span>
              </div>
            </div>
            
            <div className="border border-slate-100 rounded-2xl p-6 flex flex-col items-center justify-center">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-2">Total Deliveries</p>
              <span className="text-3xl font-black text-slate-800">{selectedItem.totalDeliveries}</span>
            </div>
          </div>

          {/* Vehicle and Join Date */}
          <div className="border border-slate-100 rounded-2xl p-6 flex justify-between items-center">
            <div>
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Vehicle</p>
              <p className="text-base font-black text-slate-800">{selectedItem.vehicle}</p>
            </div>
            <div className="text-right">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Join Date</p>
              <p className="text-base font-black text-slate-800">{selectedItem.joinDate}</p>
            </div>
          </div>

        </div>
        
        {/* Footer */}
        <div className="px-6 py-5 border-t border-slate-100 bg-white flex justify-end gap-3">
          <button onClick={onClose} className="px-8 py-3 bg-white border border-slate-200 text-slate-700 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm">
            Close
          </button>
          <button className="px-8 py-3 bg-slate-800 text-white rounded-xl text-sm font-bold hover:bg-slate-900 transition-colors shadow-sm flex items-center">
            <Activity className="w-4 h-4 mr-2" />
            View Activity
          </button>
        </div>

      </div>
    </div>
  );
}
