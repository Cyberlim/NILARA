"use client";

import { Pencil, Trash2, CheckCircle2 } from "lucide-react";

export default function PlansGrid({ localItems, onEditClick, onDeleteClick, filterType, onToggleStatus, onCardClick }) {
  
  const filtered = localItems.filter(item => {
    if (filterType === "active_plans") return item.isActive;
    if (filterType === "most_popular") return item.subscribers > 100;
    return true;
  });

  if (filtered.length === 0) {
    return (
      <div className="py-20 text-center bg-white rounded-3xl border border-slate-100">
        <h3 className="text-lg font-bold text-slate-700">No plans found</h3>
        <p className="text-sm text-slate-500 mt-1">Try adjusting your filters or create a new plan.</p>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6 mb-8">
      {filtered.map((item) => (
        <div 
          key={item.id} 
          onClick={() => onCardClick && onCardClick(item)}
          className="bg-white rounded-3xl border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] flex flex-col hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all duration-300 cursor-pointer"
        >
          
          <div className="p-3 sm:p-4 border-b border-slate-50">
            <div className="flex justify-between items-start mb-2">
              <div className="flex items-center gap-2">
                <button 
                  onClick={(e) => { e.stopPropagation(); onToggleStatus && onToggleStatus(item); }}
                  className={`relative inline-flex h-5 w-9 items-center rounded-full transition-colors focus:outline-none ${item.isActive !== false ? 'bg-teal-500' : 'bg-slate-300'}`}
                >
                  <span className={`inline-block h-4 w-4 transform rounded-full bg-white shadow-sm transition-transform duration-200 ${item.isActive !== false ? 'translate-x-[18px]' : 'translate-x-[2px]'}`} />
                </button>
                <span className={`text-[10px] font-bold uppercase tracking-wider ${item.isActive !== false ? 'text-teal-600' : 'text-slate-500'}`}>
                  {item.isActive !== false ? "Active" : "Inactive"}
                </span>
              </div>
              <div className="flex gap-1.5">
                <button onClick={(e) => { e.stopPropagation(); onEditClick && onEditClick(item); }} className="w-7 h-7 flex items-center justify-center rounded-lg bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-teal-600 transition-colors">
                  <Pencil className="w-3.5 h-3.5" />
                </button>
                <button onClick={(e) => { e.stopPropagation(); onDeleteClick && onDeleteClick(item.id); }} className="w-7 h-7 flex items-center justify-center rounded-lg bg-slate-50 text-slate-400 hover:bg-red-50 hover:text-red-500 transition-colors">
                  <Trash2 className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
            
            <h3 className="text-lg font-black text-slate-800 leading-tight mb-1">{item.name}</h3>
            <p className="text-xs font-medium text-slate-500 line-clamp-2 leading-snug">{item.description}</p>
          </div>

          <div className="px-3 sm:px-4 py-3 bg-slate-50/50 border-t border-slate-50 flex items-center justify-between rounded-b-3xl">
            <div>
              <div className="flex items-baseline space-x-1">
                <span className="text-2xl font-black text-slate-800">₹{item.price}</span>
                <span className="text-xs font-bold text-slate-500">/ month</span>
              </div>
              <div className="flex items-center gap-2 mt-0.5">
                <p className="text-[10px] font-bold text-teal-600 uppercase tracking-wider">{item.frequency} Plan</p>
                {(item.discountPercentage > 0) && (
                  <span className="px-1.5 py-0.5 bg-green-100 text-green-700 text-[9px] font-bold rounded-sm">
                    {item.discountPercentage}% OFF
                  </span>
                )}
              </div>
            </div>
            
            <div className="text-right">
              <span className="text-[10px] font-semibold text-slate-500 block mb-0.5">Active Subs</span>
              <span className="text-sm font-black text-slate-800">{item.subscribers || "N/A"}</span>
            </div>
          </div>

        </div>
      ))}
    </div>
  );
}
