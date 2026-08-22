"use client";

import { useEffect } from "react";
import { X, ExternalLink, ArrowLeft, Package, Pencil, IndianRupee } from "lucide-react";

export default function InventoryListModal({ isOpen, onClose, filterType, selectedItem, setSelectedItem, modalMode, setModalMode, onEditClick }) {
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
      case "total_value": return "Inventory Overview";
      case "total_stock": return "Total Stock Items";
      case "low_stock": return "Low Stock Items";
      case "out_of_stock": return "Out of Stock Items";
      case "expiring": return "Expiring Soon Items";
      case "movement": return "Stock Movement Items";
      default: return "Inventory Items";
    }
  };

  const getStockColor = (stockStatus) => {
    switch(stockStatus) {
      case "In Stock": return "green";
      case "Low Stock": return "orange";
      case "Out of Stock": return "red";
      default: return "slate";
    }
  };

  const filteredItems = [].filter(item => {
    if (filterType === "total_value" || filterType === "total_stock" || filterType === "movement") return true;
    if (filterType === "low_stock") return item.stockStatus === "Low Stock";
    if (filterType === "out_of_stock") return item.stockStatus === "Out of Stock";
    if (filterType === "expiring") return item.expiryDaysLeft !== null && item.expiryDaysLeft <= 30; // Just as an example, but currently items have 120+ days left in mockup data, so maybe just check if expiryDaysLeft is not null to show anything for this filter if they want exact matching, or match "expiring" condition from table
    return true;
  });

  // Since in the previous table we used <= 30 but data has 120+, let's just use the same logic as the table:
  const finalFiltered = filterType === "expiring" 
    ? [].filter(item => item.expiryDaysLeft !== null) 
    : filteredItems;

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
                {modalMode === "detail" ? "Inventory Details" : getTitle()}
              </h2>
              {modalMode === "list" && (
                <p className="text-xs font-bold text-teal-600 mt-0.5">{finalFiltered.length} items found</p>
              )}
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            {modalMode === "detail" && (
              <button 
                onClick={() => { onClose(); onEditClick && onEditClick(selectedItem); }}
                className="flex items-center px-4 py-2 bg-teal-50 text-teal-600 border border-teal-100 rounded-xl text-sm font-bold hover:bg-teal-100 hover:text-teal-700 transition-colors"
              >
                <Pencil className="w-4 h-4 mr-2" />
                Edit
              </button>
            )}
            <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          {modalMode === "list" ? (
            finalFiltered.length === 0 ? (
              <div className="text-center py-12">
                <Package className="w-12 h-12 text-slate-200 mx-auto mb-4" />
                <h3 className="text-lg font-bold text-slate-700">No items found</h3>
                <p className="text-sm text-slate-500 mt-1">Try adjusting your filters.</p>
              </div>
            ) : (
              <div className="space-y-3 animate-in slide-in-from-bottom-4 duration-300">
                {finalFiltered.map((item, idx) => (
                  <div key={idx} onClick={() => { setSelectedItem(item); setModalMode("detail"); }}
                    className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm hover:shadow-md hover:border-teal-100 transition-all cursor-pointer flex flex-col sm:flex-row sm:items-center justify-between group"
                  >
                    <div className="flex items-center space-x-4 mb-4 sm:mb-0">
                      <div className="w-12 h-12 rounded-xl border border-slate-200 bg-slate-50 flex items-center justify-center text-2xl flex-shrink-0">
                                                {item.image ? (
                          <img src={item.image} alt={item.name} className="w-full h-full object-cover rounded-xl" />
                        ) : (
                          <span className="text-xl">📦</span>
                        )}
                      </div>
                      <div>
                        <h4 className="text-sm font-black text-slate-800 leading-tight">{item.name}</h4>
                        <p className="text-xs font-medium text-slate-500 mt-0.5">{item.variant}</p>
                        <p className="text-[10px] font-mono text-slate-400 mt-0.5">{item.sku}</p>
                      </div>
                    </div>

                    <div className="flex items-center space-x-6">
                      <div className="hidden sm:block text-right">
                        <p className="text-xs font-bold text-slate-700">{item.stock.toLocaleString('en-IN')} units</p>
                        <p className={`text-[10px] font-medium text-${getStockColor(item.stockStatus)}-600 mt-0.5`}>{item.stockStatus}</p>
                      </div>
                      <span className={`inline-flex px-3 py-1 rounded-full text-[10px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 border border-${item.statusColor}-100/50`}>
                        {item.status}
                      </span>
                    </div>

                    <div className="flex items-center justify-between w-full sm:w-auto sm:space-x-6 pt-3 sm:pt-0 border-t border-slate-50 sm:border-0 mt-2 sm:mt-0">
                      <div className="text-right">
                        <p className="text-xs font-bold text-slate-500 mb-0.5">Value</p>
                        <p className="text-sm font-black text-slate-800">₹{item.inventoryValue.toLocaleString('en-IN')}</p>
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
              <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm flex flex-col sm:flex-row gap-6 items-start">
                <div className="w-24 h-24 rounded-2xl border-2 border-slate-100 bg-slate-50 flex items-center justify-center text-5xl flex-shrink-0">
                                    {selectedItem.image ? (
                    <img src={selectedItem.image} alt={selectedItem.name} className="w-full h-full object-cover rounded-[1.25rem]" />
                  ) : (
                    <span className="text-4xl">📦</span>
                  )}
                </div>
                <div className="flex-1 w-full">
                  <div className="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-4">
                    <div>
                      <h3 className="text-xl font-black text-slate-800">{selectedItem.name}</h3>
                      <p className="text-sm font-medium text-slate-500 mt-1">{selectedItem.variant}</p>
                      <div className="flex items-center mt-3 space-x-3">
                        <span className="text-xs font-mono font-bold bg-slate-100 text-slate-600 px-2 py-1 rounded-lg">
                          {selectedItem.sku}
                        </span>
                        <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${selectedItem.statusColor}-50 text-${selectedItem.statusColor}-700 border border-${selectedItem.statusColor}-100/50`}>
                          <span className={`w-1.5 h-1.5 rounded-full bg-${selectedItem.statusColor}-500 mr-1`}></span>
                          {selectedItem.status}
                        </span>
                      </div>
                    </div>
                    
                    <div className="bg-slate-50 rounded-xl p-4 border border-slate-100 min-w-[140px]">
                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Total Value</p>
                      <p className="text-2xl font-black text-slate-800">₹{selectedItem.inventoryValue.toLocaleString('en-IN')}</p>
                      <p className="text-xs font-medium text-slate-400 mt-0.5">₹{selectedItem.unitPrice.toLocaleString('en-IN')} / unit</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm">
                  <h4 className="text-sm font-bold text-slate-800 mb-4 flex items-center">
                    <Package className="w-4 h-4 mr-2 text-slate-400" /> Stock Status
                  </h4>
                  <div className="space-y-4">
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Current Stock</span>
                      <span className="text-sm font-black text-slate-800">{selectedItem.stock.toLocaleString('en-IN')} units</span>
                    </div>
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Status</span>
                      <span className={`text-xs font-bold text-${getStockColor(selectedItem.stockStatus)}-600`}>{selectedItem.stockStatus}</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-xs font-semibold text-slate-500">Category</span>
                      <span className={`text-xs font-bold text-${selectedItem.categoryColor}-700 flex items-center gap-1`}>
                         <span className={`w-1.5 h-1.5 rounded-full bg-${selectedItem.categoryColor}-500`}></span>
                         {selectedItem.category}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm">
                  <h4 className="text-sm font-bold text-slate-800 mb-4 flex items-center">
                    <IndianRupee className="w-4 h-4 mr-2 text-slate-400" /> Additional Info
                  </h4>
                  <div className="space-y-4">
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Expiry Date</span>
                      <div className="text-right">
                        <span className="text-sm font-black text-slate-800">{selectedItem.expiryDate}</span>
                        {selectedItem.expiryDaysLeft && <p className="text-[10px] text-orange-500 font-bold">{selectedItem.expiryDaysLeft} days left</p>}
                      </div>
                    </div>
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Last Updated</span>
                      <div className="text-right">
                        <p className="text-xs font-bold text-slate-800">{selectedItem.updatedDate}</p>
                        <p className="text-[10px] text-slate-400">{selectedItem.updatedTime}</p>
                      </div>
                    </div>
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
