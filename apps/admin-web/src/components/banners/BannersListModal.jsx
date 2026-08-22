"use client";

import { X, Search, ChevronRight, Image as ImageIcon, ArrowLeft, MousePointer, Edit2, Trash2 } from "lucide-react";
import { useState, useEffect } from "react";

export default function BannersListModal({ isOpen, onClose, filterType, selectedItem, setSelectedItem, modalMode, onEdit }) {
  const [searchQuery, setSearchQuery] = useState("");

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
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
        <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={onClose}></div>
        <div className="relative w-full max-w-xl bg-white rounded-3xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden animate-in fade-in zoom-in-95 duration-200">
          
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
                <h2 className="text-xl font-black text-slate-800">Banner Details</h2>
                <p className="text-sm font-medium text-slate-500 mt-1">{item.id}</p>
              </div>
            </div>
            <div className="flex gap-2">
              <button 
                onClick={() => onEdit && onEdit(item)}
                className="w-10 h-10 flex items-center justify-center rounded-full bg-teal-50 text-teal-600 hover:bg-teal-100 shadow-sm transition-colors"
              >
                <Edit2 className="w-4 h-4" />
              </button>
              <button 
                onClick={onClose}
                className="w-10 h-10 flex items-center justify-center rounded-full bg-white text-slate-500 hover:text-slate-800 hover:bg-slate-100 shadow-sm transition-colors border border-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>
          </div>

          <div className="overflow-y-auto hide-scrollbar">
            <div className="w-full aspect-[21/9] bg-slate-100">
              <img src={item.image} alt={item.title} className="w-full h-full object-cover" />
            </div>
            <div className="p-6">
              <div className="flex justify-between items-start mb-6">
                <div>
                  <h3 className="text-2xl font-black text-slate-800">{item.title}</h3>
                  <p className="text-sm font-bold text-slate-500 mt-1 flex items-center">
                    <ImageIcon className="w-4 h-4 mr-1.5" />
                    {item.location}
                  </p>
                </div>
                <span className={`inline-flex px-3 py-1.5 rounded-xl text-xs font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 border border-${item.statusColor}-100/50`}>
                  {item.status}
                </span>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="p-4 border border-slate-100 rounded-xl bg-slate-50/50">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Click-Through Rate</p>
                  <p className="text-2xl font-black text-teal-600">{item.ctr}</p>
                </div>
                <div className="p-4 border border-slate-100 rounded-xl bg-slate-50/50">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Total Clicks</p>
                  <p className="text-2xl font-black text-slate-800 flex items-center">
                    <MousePointer className="w-5 h-5 mr-2 text-slate-400" />
                    {item.clicks}
                  </p>
                </div>
              </div>
            </div>
          </div>
          
          <div className="p-6 border-t border-slate-100 bg-slate-50/50 flex justify-end gap-3">
            <button onClick={onClose} className="px-6 py-2.5 bg-white border border-slate-200 text-slate-700 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm">
              Close
            </button>
            {item.status === 'Active' ? (
              <button className="px-6 py-2.5 bg-amber-500 text-white rounded-xl text-sm font-bold hover:bg-amber-600 transition-colors shadow-sm">
                Pause Banner
              </button>
            ) : (
              <button className="px-6 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm">
                Activate Banner
              </button>
            )}
          </div>
        </div>
      </div>
    );
  }

  // Render List View
  const listItems = [].filter(item => {
    if (filterType === "active_banners" && item.status !== "Active") return false;
    if (filterType === "paused" && item.status !== "Paused" && item.status !== "Expired") return false;
    
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      if (!item.title.toLowerCase().includes(q) && 
          !item.id.toLowerCase().includes(q)) return false;
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
              placeholder="Search banners..."
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
                  <div className="w-14 h-10 rounded-lg overflow-hidden bg-slate-100">
                    <img src={item.image} alt="" className="w-full h-full object-cover" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-800">{item.title}</h4>
                    <p className="text-[10px] font-medium text-slate-500 mt-0.5">{item.location}</p>
                  </div>
                </div>
                <div className="flex items-center space-x-4">
                  <div className="text-right hidden sm:block">
                    <span className="text-[10px] font-bold text-teal-600 block mb-1">CTR: {item.ctr}</span>
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
    </div>
  );
}
