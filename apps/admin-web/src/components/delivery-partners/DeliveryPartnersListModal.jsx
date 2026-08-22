"use client";

import { X, Search, ChevronRight, User, ArrowLeft, Star, Phone, Activity } from "lucide-react";
import { useState, useEffect } from "react";
import CustomerProfileModal from "@/components/customers/CustomerProfileModal";

export default function DeliveryPartnersListModal({ isOpen, onClose, filterType, selectedItem, setSelectedItem, modalMode }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [profileModalOpen, setProfileModalOpen] = useState(false);
  const [customerToView, setCustomerToView] = useState(null);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [isOpen]);

  if (!isOpen) return null;

  // Render Detail View
  if (modalMode === "direct_detail" || selectedItem) {
    const item = selectedItem;
    return (
      <>
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
        <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={onClose}></div>
        <div className="relative w-full max-w-2xl bg-white rounded-3xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden animate-in fade-in zoom-in-95 duration-200">
          
          <div className="flex items-center justify-between p-6 border-b border-slate-100 bg-slate-50/50">
            <div className="flex items-center">
              {modalMode !== "direct_detail" && (
                <button 
                  onClick={() => setSelectedItem(null)}
                  className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-500 hover:bg-slate-100 hover:text-slate-700 transition-colors mr-3"
                >
                  <ArrowLeft className="w-4 h-4" />
                </button>
              )}
              <div>
                <h2 className="text-xl font-black text-slate-800">Partner Details</h2>
                <p className="text-sm font-medium text-slate-500 mt-1">{item.id}</p>
              </div>
            </div>
            <button 
              onClick={onClose}
              className="w-10 h-10 flex items-center justify-center rounded-full bg-white text-slate-500 hover:text-slate-800 hover:bg-slate-100 shadow-sm transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          <div className="p-6 overflow-y-auto custom-scrollbar">
            <div className="bg-slate-50 rounded-2xl p-6 mb-6">
              <div className="flex flex-col sm:flex-row justify-between sm:items-center gap-4">
                <div className="flex items-center gap-4">
                  <div className="w-16 h-16 rounded-full bg-teal-50 border border-teal-100 flex items-center justify-center text-teal-600 font-bold text-2xl">
                    {item.name.charAt(0)}
                  </div>
                  <div>
                    <h3 className="text-xl font-black text-slate-800">{item.name}</h3>
                    <p className="text-sm font-medium text-slate-500 flex items-center mt-1">
                      <Phone className="w-3 h-3 mr-1" /> {item.phone}
                    </p>
                  </div>
                </div>
                <div className="text-left sm:text-right">
                  <span className={`inline-flex items-center px-3 py-1.5 rounded-xl text-xs font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 border border-${item.statusColor}-100/50`}>
                    <span className={`w-1.5 h-1.5 rounded-full bg-${item.statusColor}-500 mr-2 ${item.status === 'Online' ? 'animate-pulse' : ''}`}></span>
                    {item.status}
                  </span>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-2 gap-4 mb-6">
              <div className="p-4 border border-slate-100 rounded-xl bg-white text-center">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Rating</p>
                <div className="flex items-center justify-center text-amber-500 text-2xl font-black">
                  <Star className="w-5 h-5 mr-1 fill-amber-500" />
                  {item.rating}
                </div>
              </div>
              <div className="p-4 border border-slate-100 rounded-xl bg-white text-center">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Total Deliveries</p>
                <p className="text-2xl font-black text-slate-800">{item.totalDeliveries}</p>
              </div>
            </div>

            <div className="space-y-4">
              <div className="p-4 border border-slate-100 rounded-xl flex justify-between items-center bg-white">
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Vehicle</p>
                  <p className="text-sm font-bold text-slate-800">{item.vehicle}</p>
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1 text-right">Join Date</p>
                  <p className="text-sm font-bold text-slate-800">{item.joinDate}</p>
                </div>
              </div>
            </div>
          </div>
          
          <div className="p-6 border-t border-slate-100 bg-slate-50/50 flex justify-end gap-3">
            <button onClick={onClose} className="px-6 py-2.5 bg-white border border-slate-200 text-slate-700 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm">
              Close
            </button>
            <button className="px-6 py-2.5 bg-slate-800 text-white rounded-xl text-sm font-bold hover:bg-slate-900 transition-colors shadow-sm flex items-center">
              <Activity className="w-4 h-4 mr-2" />
              View Activity
            </button>
          </div>
        </div>
      </div>
      <CustomerProfileModal 
        isOpen={profileModalOpen} 
        onClose={() => setProfileModalOpen(false)} 
        customerQuery={customerToView} 
      />
      </>
    );
  }

  // Render List View
  const listItems = [].filter(item => {
    if (filterType === "online_now" && item.status !== "Online") return false;
    if (filterType === "churned_partners" && item.status !== "Offline") return false;
    if (filterType === "avg_rating" && item.rating < 4.5) return false;
    
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      if (!item.name.toLowerCase().includes(q) && 
          !item.phone.includes(q)) return false;
    }
    return true;
  });

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={onClose}></div>
      <div className="relative w-full max-w-2xl bg-white rounded-3xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        <div className="flex items-center justify-between p-6 border-b border-slate-100 bg-slate-50/50">
          <div>
            <h2 className="text-xl font-black text-slate-800 capitalize">
              {filterType.replace(/_/g, ' ')}
            </h2>
            <p className="text-sm font-medium text-slate-500 mt-1">{listItems.length} records found</p>
          </div>
          <button onClick={onClose} className="w-10 h-10 flex items-center justify-center rounded-full bg-white text-slate-500 hover:text-slate-800 hover:bg-slate-100 shadow-sm transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-4 border-b border-slate-50">
          <div className="relative">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search partners..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all placeholder:text-slate-400"
            />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto custom-scrollbar p-2">
          {listItems.length === 0 ? (
            <div className="py-12 text-center text-slate-400 font-medium text-sm">No items match your filter.</div>
          ) : (
            listItems.map((item) => (
              <div 
                key={item.id}
                onClick={() => setSelectedItem(item)}
                className="flex items-center justify-between p-4 hover:bg-slate-50 rounded-2xl cursor-pointer transition-colors group border border-transparent hover:border-slate-100 mb-1"
              >
                <div className="flex items-center space-x-4">
                  <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-400 group-hover:bg-teal-50 group-hover:text-teal-600 transition-colors">
                    <User className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-800">{item.name}</h4>
                    <p className="text-[10px] font-medium text-slate-500 mt-0.5">{item.vehicle}</p>
                  </div>
                </div>
                <div className="flex items-center space-x-4">
                  <div className="text-right hidden sm:block">
                    <div className="flex items-center justify-end text-amber-500 font-bold text-sm mb-1">
                      <Star className="w-3.5 h-3.5 mr-1 fill-amber-500" />
                      {item.rating}
                    </div>
                    <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[9px] font-bold mt-1 bg-${item.statusColor}-50 text-${item.statusColor}-700`}>
                      {item.status}
                    </span>
                  </div>
                  <ChevronRight className="w-5 h-5 text-slate-300 group-hover:text-teal-500 transition-colors" />
                </div>
              </div>
            ))
          )}
        </div>

      </div>

      <CustomerProfileModal 
        isOpen={profileModalOpen} 
        onClose={() => setProfileModalOpen(false)} 
        customerQuery={customerToView} 
      />
    </div>
  );
}
