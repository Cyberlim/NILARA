"use client";

import { useEffect } from "react";
import { X, ExternalLink, ArrowLeft, Users, Pencil, Wallet, Package, MapPin, Ban, Undo2 } from "lucide-react";

export default function CustomersListModal({ isOpen, onClose, filterType, selectedItem, setSelectedItem, modalMode, setModalMode, onEditClick, onToggleSuspend }) {
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  const getTitle = () => {
    switch(filterType) {
      case "total_customers": return "Total Customers";
      case "active_customers": return "Active Customers";
      case "new_this_month": return "New Customers (30d)";
      case "premium_members": return "Premium Members";
      case "churned": return "Churned Customers";
      case "wallet_balance": return "Wallet Balances";
      default: return "Customers Overview";
    }
  };

  const filteredItems = [].filter(item => {
    if (filterType === "total_customers" || filterType === "wallet_balance") return true;
    if (filterType === "active_customers") return item.status === "Active";
    if (filterType === "new_this_month") return item.status === "New";
    if (filterType === "premium_members") return item.isPremium === true;
    if (filterType === "churned") return item.status === "Churned";
    return true;
  });

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity" onClick={onClose}></div>

      <div className="relative w-full max-w-3xl max-h-[85vh] bg-white/90 backdrop-blur-xl rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <div className="flex items-center space-x-3">
            {selectedItem && modalMode === "detail" && (
              <button 
                onClick={() => { setSelectedItem(null); setModalMode("list"); }}
                className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-500 hover:bg-slate-100 hover:text-slate-700 transition-colors mr-2"
              >
                <ArrowLeft className="w-4 h-4" />
              </button>
            )}
            <div>
              <h2 className="text-xl font-black text-slate-800 tracking-tight">
                {modalMode === "detail" ? "Customer Details" : getTitle()}
              </h2>
              {modalMode === "list" && (
                <p className="text-xs font-bold text-teal-600 mt-0.5">{filteredItems.length} customers found</p>
              )}
            </div>
          </div>
          
          <div className="flex items-center gap-3">

            <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          {modalMode === "list" ? (
            filteredItems.length === 0 ? (
              <div className="text-center py-12">
                <Users className="w-12 h-12 text-slate-200 mx-auto mb-4" />
                <h3 className="text-lg font-bold text-slate-700">No customers found</h3>
                <p className="text-sm text-slate-500 mt-1">Try adjusting your filters.</p>
              </div>
            ) : (
              <div className="space-y-3 animate-in slide-in-from-bottom-4 duration-300">
                {filteredItems.map((item, idx) => (
                  <div key={idx} onClick={() => { setSelectedItem(item); setModalMode("detail"); }}
                    className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm hover:shadow-md hover:border-teal-100 transition-all cursor-pointer flex flex-col sm:flex-row sm:items-center justify-between group"
                  >
                    <div className="flex items-center space-x-4 mb-4 sm:mb-0">
                      <div className="w-12 h-12 rounded-full border border-slate-200 bg-slate-50 flex items-center justify-center text-2xl flex-shrink-0">
                        {item.avatar}
                      </div>
                      <div>
                        <h4 className="text-sm font-black text-slate-800 leading-tight">{item.name}</h4>
                        <p className="text-xs font-medium text-slate-500 mt-0.5">{item.phone}</p>
                        <p className="text-[10px] font-mono text-slate-400 mt-0.5">{item.email}</p>
                      </div>
                    </div>

                    <div className="flex items-center space-x-6">
                      <div className="hidden sm:block text-right">
                        <p className="text-xs font-bold text-slate-700">{item.totalOrders} Orders</p>
                        <p className="text-[10px] font-medium text-slate-400 mt-0.5">Joined {item.joinDate}</p>
                      </div>
                      <span className={`inline-flex px-3 py-1 rounded-full text-[10px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 border border-${item.statusColor}-100/50`}>
                        {item.status}
                      </span>
                    </div>

                    <div className="flex items-center justify-between w-full sm:w-auto sm:space-x-6 pt-3 sm:pt-0 border-t border-slate-50 sm:border-0 mt-2 sm:mt-0">
                      <div className="text-right">
                        <p className="text-xs font-bold text-slate-500 mb-0.5">Wallet Bal.</p>
                        <p className="text-sm font-black text-slate-800">₹{item.walletBalance.toLocaleString('en-IN')}</p>
                      </div>
                      <button className="w-8 h-8 flex items-center justify-center rounded-xl bg-teal-50 text-teal-600 group-hover:bg-teal-600 group-hover:text-white transition-colors">
                        <ExternalLink className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )
          ) : (
            <div className="space-y-4 animate-in slide-in-from-right-4 duration-300">
              <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm flex flex-col sm:flex-row gap-6 items-start relative">
                
                {/* Top Right Actions */}
                <div className="absolute top-5 right-5 z-10">
                  <button 
                    onClick={() => onToggleSuspend && onToggleSuspend(selectedItem)} 
                    className={`px-3 py-1.5 flex items-center justify-center rounded-lg text-xs font-bold transition-colors shadow-sm ${selectedItem.status === 'Suspended' ? 'bg-green-50 text-green-600 hover:bg-green-100 border border-green-200' : 'bg-red-50 text-red-600 hover:bg-red-100 border border-red-200'}`}
                    title={selectedItem.status === 'Suspended' ? 'Revoke Suspension' : 'Suspend Customer'}
                  >
                    {selectedItem.status === 'Suspended' ? (
                      <><Undo2 className="w-3.5 h-3.5 mr-1.5" /> Revoke</>
                    ) : (
                      <><Ban className="w-3.5 h-3.5 mr-1.5" /> Suspend</>
                    )}
                  </button>
                </div>

                <div className="w-24 h-24 rounded-full border-4 border-slate-50 bg-slate-100 flex items-center justify-center text-5xl flex-shrink-0 relative shadow-inner">
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
                    
                    <div className="bg-slate-50 rounded-xl p-4 border border-slate-100 min-w-[140px]">
                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Wallet Balance</p>
                      <p className="text-2xl font-black text-slate-800">₹{selectedItem.walletBalance.toLocaleString('en-IN')}</p>
                      <p className="text-xs font-medium text-teal-600 mt-0.5 cursor-pointer hover:underline">Top Up Wallet</p>
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
          )}
        </div>
        
        {/* Footer */}
        <div className="px-6 py-4 border-t border-slate-100 bg-white/50 flex justify-end">
          <button onClick={onClose} className="px-6 py-2.5 bg-slate-800 text-white rounded-xl text-sm font-bold hover:bg-slate-900 transition-colors shadow-sm">
            Close
          </button>
        </div>

      </div>
    </div>
  );
}
