"use client";

import { useEffect } from "react";
import { X, MapPin, Package, Undo2, Ban, ArrowLeft } from "lucide-react";

// Fallback to find a customer if only a name or ID is passed
const findCustomer = (query) => {
  if (!query) return null;
  if (typeof query === 'object') return query;
  return [].find(c => 
    c.id === query || c.name === query || c.phone === query
  ) || {
    id: "CUST-999",
    name: query,
    email: "unknown@example.com",
    phone: query,
    status: "Active",
    statusColor: "green",
    walletBalance: 0,
    totalOrders: 0,
    joinDate: "N/A",
    lastActive: "N/A",
    avatar: "👤",
    isPremium: false,
    address: "No address provided."
  };
};

export default function CustomerProfileModal({ isOpen, onClose, customerQuery, onToggleSuspend }) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  const selectedItem = findCustomer(customerQuery);
  if (!selectedItem) return null;

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/50 backdrop-blur-sm transition-opacity" onClick={onClose}></div>

      <div className="relative w-full max-w-3xl max-h-[85vh] bg-white/90 backdrop-blur-xl rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <div className="flex items-center">
            <button 
              onClick={onClose}
              className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-500 hover:bg-slate-100 hover:text-slate-700 transition-colors mr-3"
            >
              <ArrowLeft className="w-4 h-4" />
            </button>
            <div>
              <h2 className="text-xl font-black text-slate-800 tracking-tight">Customer Profile</h2>
              <p className="text-xs font-bold text-slate-500 mt-0.5">Full customer information</p>
            </div>
          </div>
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          <div className="space-y-4">
            <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm flex flex-col sm:flex-row gap-6 items-start relative">
              
              <div className="w-24 h-24 rounded-full border-4 border-slate-50 bg-slate-100 flex items-center justify-center text-5xl flex-shrink-0 relative shadow-inner mt-1 sm:mt-0">
                {selectedItem.avatar}
              </div>
              <div className="flex-1 w-full">
                <div className="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-4">
                  <div>
                    <h3 className="text-xl font-black text-slate-800">{selectedItem.name}</h3>
                    <p className="text-sm font-medium text-slate-500 mt-1">{selectedItem.phone} • {selectedItem.email}</p>
                    <div className="flex items-center mt-3 space-x-3">
                      <span className="text-xs font-mono font-bold bg-slate-100 text-slate-600 px-2 py-1 rounded-lg">
                        {selectedItem.id}
                      </span>
                      <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${selectedItem.statusColor}-50 text-${selectedItem.statusColor}-700 border border-${selectedItem.statusColor}-100/50`}>
                        <span className={`w-1.5 h-1.5 rounded-full bg-${selectedItem.statusColor}-500 mr-1`}></span>
                        {selectedItem.status}
                      </span>
                      {selectedItem.isPremium && (
                        <span className="inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-100/50">
                          Premium
                        </span>
                      )}
                    </div>
                  </div>
                  
                  <div className="flex flex-col items-end space-y-3 w-full sm:w-auto">
                    <button 
                      onClick={() => onToggleSuspend && onToggleSuspend(selectedItem)} 
                      className={`px-3 py-1.5 flex items-center justify-center rounded-lg text-xs font-bold transition-colors shadow-sm w-full sm:w-auto ${selectedItem.status === 'Suspended' ? 'bg-green-50 text-green-600 hover:bg-green-100 border border-green-200' : 'bg-red-50 text-red-600 hover:bg-red-100 border border-red-200'}`}
                      title={selectedItem.status === 'Suspended' ? 'Revoke Suspension' : 'Suspend Customer'}
                    >
                      {selectedItem.status === 'Suspended' ? (
                        <><Undo2 className="w-3.5 h-3.5 mr-1.5" /> Revoke</>
                      ) : (
                        <><Ban className="w-3.5 h-3.5 mr-1.5" /> Suspend</>
                      )}
                    </button>
                    <div className="bg-slate-50 rounded-xl p-4 border border-slate-100 min-w-[160px] w-full">
                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Wallet Balance</p>
                      <p className="text-2xl font-black text-slate-800">₹{selectedItem.walletBalance.toLocaleString('en-IN')}</p>
                      <p className="text-xs font-medium text-teal-600 mt-0.5 cursor-pointer hover:underline">Top Up Wallet</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm">
                <h4 className="text-sm font-bold text-slate-800 mb-4 flex items-center">
                  <Package className="w-4 h-4 mr-2 text-slate-400" /> Order History
                </h4>
                <div className="space-y-4">
                  <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                    <span className="text-xs font-semibold text-slate-500">Total Orders</span>
                    <span className="text-sm font-black text-slate-800">{selectedItem.totalOrders}</span>
                  </div>
                  <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                    <span className="text-xs font-semibold text-slate-500">Last Active</span>
                    <span className="text-xs font-bold text-slate-700">{selectedItem.lastActive}</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-xs font-semibold text-slate-500">Joined Date</span>
                    <span className="text-xs font-bold text-slate-700">{selectedItem.joinDate}</span>
                  </div>
                </div>
              </div>

              <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm">
                <h4 className="text-sm font-bold text-slate-800 mb-4 flex items-center">
                  <MapPin className="w-4 h-4 mr-2 text-slate-400" /> Primary Address
                </h4>
                <div className="p-4 bg-slate-50 rounded-xl border border-slate-100 h-[calc(100%-2rem)] flex items-center justify-center text-center">
                  <p className="text-sm font-medium text-slate-600">{selectedItem.address || "No address provided."}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        {/* Footer */}
        <div className="px-6 py-4 border-t border-slate-100 bg-white/50 flex justify-end">
          <button onClick={onClose} className="px-6 py-2.5 bg-slate-800 text-white rounded-xl text-sm font-bold hover:bg-slate-900 transition-colors shadow-sm">
            Close Profile
          </button>
        </div>

      </div>
    </div>
  );
}
