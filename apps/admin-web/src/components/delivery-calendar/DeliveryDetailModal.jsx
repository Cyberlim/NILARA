"use client";

import { useEffect } from "react";
import { X, ArrowLeft, Truck, MapPin, Package, AlertTriangle, Phone } from "lucide-react";

export default function DeliveryDetailModal({ isOpen, onClose, filterType, selectedItem, setSelectedItem, modalMode, setModalMode }) {
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
      case "deliveries_today": return "Deliveries Today";
      case "pending_deliveries": return "Pending Deliveries";
      case "completed_deliveries": return "Completed Deliveries";
      case "delivery_exceptions": return "Delivery Exceptions";
      default: return "Deliveries Overview";
    }
  };

  const filteredItems = [].filter(item => {
    if (filterType === "deliveries_today") return item.date === "Today";
    if (filterType === "pending_deliveries") return item.status === "Pending";
    if (filterType === "completed_deliveries") return item.status === "Completed";
    if (filterType === "delivery_exceptions") return item.status === "Exception";
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
                {modalMode === "detail" ? "Delivery Details" : getTitle()}
              </h2>
              {modalMode === "list" && (
                <p className="text-xs font-bold text-teal-600 mt-0.5">{filteredItems.length} deliveries found</p>
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
                <Truck className="w-12 h-12 text-slate-200 mx-auto mb-4" />
                <h3 className="text-lg font-bold text-slate-700">No deliveries found</h3>
                <p className="text-sm text-slate-500 mt-1">Try adjusting your filters.</p>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 animate-in slide-in-from-bottom-4 duration-300">
                {filteredItems.map((item, idx) => (
                  <div key={idx} onClick={() => { setSelectedItem(item); setModalMode("detail"); }}
                    className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm hover:shadow-md hover:border-teal-100 transition-all cursor-pointer flex flex-col group"
                  >
                    <div className="flex justify-between items-start mb-3">
                      <div>
                        <span className={`inline-flex px-2 py-0.5 rounded-md text-[9px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 mb-1.5`}>
                          {item.status}
                        </span>
                        <h4 className="text-sm font-black text-slate-800 leading-tight">{item.customerName}</h4>
                      </div>
                      <div className="text-right">
                        <p className="text-[10px] font-black text-slate-800">{item.route}</p>
                        <p className="text-[9px] font-bold text-slate-400 mt-0.5">{item.timeWindow}</p>
                      </div>
                    </div>
                    
                    <p className="text-[11px] text-slate-500 mb-3 truncate">{item.address}</p>

                    <div className="grid grid-cols-2 gap-2 mt-auto pt-3 border-t border-slate-50">
                      <div className="bg-slate-50 p-2 rounded-xl flex items-center">
                        <div className="w-6 h-6 rounded-full bg-white flex items-center justify-center text-[10px] font-bold text-slate-500 mr-2 shadow-sm">
                          {item.driver.charAt(0)}
                        </div>
                        <div>
                          <p className="text-[9px] font-bold text-slate-400 uppercase">Driver</p>
                          <p className="text-xs font-bold text-slate-700 truncate w-20">{item.driver}</p>
                        </div>
                      </div>
                      <div className="bg-slate-50 p-2 rounded-xl">
                        <p className="text-[9px] font-bold text-slate-400 uppercase mb-0.5">Items</p>
                        <p className="text-xs font-bold text-slate-700 truncate">{item.items}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )
          ) : (
            <div className="space-y-4 animate-in slide-in-from-right-4 duration-300">
              <div className="bg-white rounded-2xl p-6 border border-slate-100 shadow-sm flex flex-col sm:flex-row gap-6 items-start">
                <div className="flex-1 w-full">
                  <div className="flex justify-between items-start">
                    <div>
                      <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${selectedItem.statusColor}-50 text-${selectedItem.statusColor}-700 border border-${selectedItem.statusColor}-100/50 mb-3`}>
                        <span className={`w-1.5 h-1.5 rounded-full bg-${selectedItem.statusColor}-500 mr-1.5`}></span>
                        {selectedItem.status}
                      </span>
                      <h3 className="text-2xl font-black text-slate-800 leading-tight">{selectedItem.customerName}</h3>
                      <p className="text-sm font-medium text-slate-500 mt-1 flex items-center">
                        <Phone className="w-3.5 h-3.5 mr-1.5" /> {selectedItem.phone}
                      </p>
                    </div>
                    
                    <div className="bg-slate-50 rounded-xl p-4 border border-slate-100 min-w-[140px] text-right">
                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Time Window</p>
                      <p className="text-sm font-black text-slate-800">{selectedItem.timeWindow}</p>
                      <p className="text-[10px] font-bold text-slate-500 mt-0.5">{selectedItem.date}</p>
                    </div>
                  </div>

                  {selectedItem.status === "Exception" && selectedItem.notes && (
                    <div className="mt-4 p-4 rounded-xl bg-red-50 border border-red-100 flex items-start">
                      <AlertTriangle className="w-5 h-5 text-red-500 mt-0.5 mr-3 shrink-0" />
                      <div>
                        <p className="text-sm font-bold text-red-800">Delivery Exception</p>
                        <p className="text-xs font-medium text-red-600 mt-1">{selectedItem.notes}</p>
                      </div>
                    </div>
                  )}
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm flex flex-col">
                  <h4 className="text-sm font-bold text-slate-800 mb-4 flex items-center">
                    <Truck className="w-4 h-4 mr-2 text-slate-400" /> Logistics
                  </h4>
                  <div className="space-y-4 flex-1">
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Route Code</span>
                      <span className="text-sm font-black text-slate-800 bg-slate-100 px-2 py-1 rounded-lg">{selectedItem.route}</span>
                    </div>
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Driver</span>
                      <div className="flex items-center gap-2">
                        <div className="w-6 h-6 rounded-full bg-slate-100 flex items-center justify-center text-[10px] font-bold text-slate-500">
                          {selectedItem.driver.charAt(0)}
                        </div>
                        <span className="text-xs font-bold text-slate-700">{selectedItem.driver}</span>
                      </div>
                    </div>
                    <div className="pt-2 flex-1">
                      <span className="text-xs font-semibold text-slate-500 block mb-2 flex items-center">
                        <Package className="w-3.5 h-3.5 mr-1.5" /> Items
                      </span>
                      <div className="p-3 bg-slate-50 rounded-xl border border-slate-100 text-center">
                        <p className="text-xs font-bold text-slate-700">{selectedItem.items}</p>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm flex flex-col">
                  <h4 className="text-sm font-bold text-slate-800 mb-4 flex items-center">
                    <MapPin className="w-4 h-4 mr-2 text-slate-400" /> Delivery Address
                  </h4>
                  <div className="p-4 bg-slate-50 rounded-xl border border-slate-100 flex-1 flex flex-col justify-center items-center text-center">
                    <MapPin className="w-8 h-8 text-slate-300 mb-3" />
                    <p className="text-sm font-medium text-slate-700">{selectedItem.address}</p>
                    <button className="mt-4 px-4 py-2 bg-white border border-slate-200 rounded-lg text-xs font-bold text-teal-600 hover:bg-teal-50 transition-colors w-full shadow-sm">
                      View on Map
                    </button>
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
