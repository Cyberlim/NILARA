"use client";

import { MousePointer, Edit2, Trash2 } from "lucide-react";

export default function BannersGrid({ items, onGridClick }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4 sm:gap-6">
      {items.map((item) => (
        <div key={item.id} onClick={() => onGridClick && onGridClick(item)} className="bg-white rounded-3xl border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] hover:shadow-[0_4px_25px_rgb(0,0,0,0.06)] transition-all duration-300 flex flex-col cursor-pointer group overflow-hidden">
          
          {/* Image Container */}
          <div className="relative aspect-[21/9] bg-slate-50 overflow-hidden">
            <img src={item.image} alt={item.title} className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500" />
            <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-end justify-between p-4">
               <div className="flex space-x-2">
                 <button className="w-8 h-8 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center text-white hover:bg-white hover:text-teal-600 transition-colors">
                   <Edit2 className="w-4 h-4" />
                 </button>
                 <button className="w-8 h-8 rounded-full bg-white/20 backdrop-blur-md flex items-center justify-center text-white hover:bg-white hover:text-red-600 transition-colors">
                   <Trash2 className="w-4 h-4" />
                 </button>
               </div>
            </div>
            <div className="absolute top-4 left-4">
              <span className={`inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-${item.statusColor}-500 text-white shadow-sm`}>
                {item.status}
              </span>
            </div>
          </div>

          {/* Details */}
          <div className="p-5">
            <h3 className="text-lg font-black text-slate-800 tracking-tight leading-tight mb-1">{item.title}</h3>
            <p className="text-sm font-medium text-slate-500 mb-4">{item.location}</p>
            
            <div className="flex items-center justify-between pt-4 border-t border-slate-50">
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-0.5">CTR</p>
                <p className="text-sm font-black text-teal-600">{item.ctr}</p>
              </div>
              <div className="text-right flex items-center">
                <MousePointer className="w-4 h-4 mr-2 text-slate-300" />
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-0.5">Clicks</p>
                  <p className="text-sm font-black text-slate-700">{item.clicks}</p>
                </div>
              </div>
            </div>
          </div>
          
        </div>
      ))}
    </div>
  );
}
