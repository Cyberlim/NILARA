"use client";

import { useEffect } from "react";
import { X, ArrowLeft, CheckCircle2, LayoutGrid, Pencil, Trash2 } from "lucide-react";

export default function PlanListModal({ isOpen, onClose, filterType, selectedItem, setSelectedItem, modalMode, setModalMode, onEditClick, onDeleteClick }) {
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
      case "total_plans": return "All Subscription Plans";
      case "active_plans": return "Active Plans";
      case "most_popular": return "Most Popular Plans";
      case "avg_price": return "Average Price Plans";
      default: return "Plans Overview";
    }
  };

  const filteredItems = [].filter(item => {
    if (filterType === "total_plans" || filterType === "avg_price") return true;
    if (filterType === "active_plans") return item.status === "Active";
    if (filterType === "most_popular") return item.subscribers > 100;
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
                {modalMode === "detail" ? "Plan Details" : getTitle()}
              </h2>
              {modalMode === "list" && (
                <p className="text-xs font-bold text-teal-600 mt-0.5">{filteredItems.length} plans found</p>
              )}
            </div>
          </div>
          
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          {modalMode === "list" ? (
            filteredItems.length === 0 ? (
              <div className="text-center py-12">
                <LayoutGrid className="w-12 h-12 text-slate-200 mx-auto mb-4" />
                <h3 className="text-lg font-bold text-slate-700">No plans found</h3>
                <p className="text-sm text-slate-500 mt-1">Try adjusting your filters.</p>
              </div>
            ) : (
              <div className="space-y-3 animate-in slide-in-from-bottom-4 duration-300">
                {filteredItems.map((item, idx) => (
                  <div key={idx} onClick={() => { setSelectedItem(item); setModalMode("detail"); }}
                    className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm hover:shadow-md hover:border-teal-100 transition-all cursor-pointer flex flex-col sm:flex-row sm:items-center justify-between group"
                  >
                    <div className="flex items-center space-x-4 mb-4 sm:mb-0">
                      <div>
                        <h4 className="text-sm font-black text-slate-800 leading-tight">{item.name}</h4>
                        <p className="text-xs font-medium text-slate-500 mt-0.5 truncate max-w-xs">{item.description}</p>
                      </div>
                    </div>

                    <div className="flex items-center space-x-6">
                      <div className="hidden sm:block text-right">
                        <p className="text-sm font-black text-slate-800">₹{item.price} <span className="text-xs font-bold text-slate-500">/ delivery</span></p>
                        <p className="text-[10px] font-bold text-teal-600 mt-0.5 uppercase">{item.frequency}</p>
                      </div>
                      <span className={`inline-flex px-3 py-1 rounded-full text-[10px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 border border-${item.statusColor}-100/50`}>
                        {item.status}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )
          ) : (
            <div className="space-y-4 animate-in slide-in-from-right-4 duration-300">
              
              <div className="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm">
                
                <div className="flex justify-between items-start mb-2">
                  <span className={`inline-flex px-3 py-1 rounded-full text-[10px] font-bold bg-${selectedItem.statusColor}-50 text-${selectedItem.statusColor}-700 border border-${selectedItem.statusColor}-100/50`}>
                    {selectedItem.status}
                  </span>
                  
                  <div className="flex gap-1.5">
                    <button 
                      onClick={() => onEditClick && onEditClick(selectedItem)}
                      className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-teal-600 transition-colors"
                    >
                      <Pencil className="w-4 h-4" />
                    </button>
                    <button 
                      onClick={() => onDeleteClick && onDeleteClick(selectedItem.id)}
                      className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-red-50 hover:text-red-500 transition-colors"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </div>

                <div className="flex justify-between items-start mb-6">
                  <div>
                    <h3 className="text-2xl font-black text-slate-800">{selectedItem.name}</h3>
                    <p className="text-sm font-medium text-slate-500 mt-2 max-w-md">{selectedItem.description}</p>
                  </div>
                  <div className="bg-slate-50 rounded-xl p-4 border border-slate-100 text-right min-w-[140px] ml-4">
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Per Delivery</p>
                    <p className="text-3xl font-black text-slate-800">₹{selectedItem.price}</p>
                    <p className="text-[10px] font-bold text-teal-600 mt-1 uppercase">{selectedItem.frequency}</p>
                  </div>
                </div>

                <div className="mt-8">
                  <h4 className="text-xs font-bold text-slate-800 mb-4 uppercase tracking-wider">Plan Features</h4>
                  <ul className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    {selectedItem.features.map((feature, idx) => (
                      <li key={idx} className="flex items-start">
                        <CheckCircle2 className="w-5 h-5 text-teal-500 mr-3 shrink-0" />
                        <span className="text-sm font-medium text-slate-600">{feature}</span>
                      </li>
                    ))}
                  </ul>
                </div>

                <div className="mt-8 pt-6 border-t border-slate-100 flex items-center justify-between">
                   <div className="text-left">
                     <p className="text-xs font-semibold text-slate-500 mb-1">Active Subscribers</p>
                     <p className="text-xl font-black text-slate-800">{selectedItem.subscribers}</p>
                   </div>
                   <div className="text-right">
                     <p className="text-xs font-semibold text-slate-500 mb-1">Plan ID</p>
                     <p className="text-sm font-mono text-slate-600">{selectedItem.id}</p>
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
