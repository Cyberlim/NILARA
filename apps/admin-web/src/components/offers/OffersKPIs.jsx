"use client";

import { Tag, ShoppingBag, TrendingDown, IndianRupee } from "lucide-react";

const iconMap = {
  "tag": Tag,
  "shopping-bag": ShoppingBag,
  "trending-down": TrendingDown,
  "indian-rupee": IndianRupee
};

export default function OffersKPIs({ onCardClick }) {
  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      {[].map((kpi) => {
        const Icon = iconMap[kpi.icon] || Tag;
        return (
          <div 
            key={kpi.id} 
            onClick={() => onCardClick && onCardClick(kpi.id)}
            className="cursor-pointer bg-white/80 backdrop-blur-xl rounded-3xl border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-5 flex flex-col justify-between transition-all duration-300 hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] hover:-translate-y-1 hover:bg-white/95"
          >
            <div className="flex items-start space-x-3 mb-4">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-${kpi.iconColor}-50 border border-${kpi.iconColor}-100 shrink-0`}>
                <Icon className={`w-5 h-5 text-${kpi.iconColor}-600`} />
              </div>
              <div className="flex-1 pt-0.5">
                <p className="text-[11px] sm:text-xs font-bold text-slate-500 mb-0.5 leading-tight break-words">{kpi.title}</p>
                <h3 className="text-lg font-black text-slate-800 tracking-tight">{kpi.value}</h3>
              </div>
            </div>
            <div className="flex items-center">
              <span className={`text-[10px] font-bold ${kpi.isPositive ? 'text-green-600' : 'text-red-600'}`}>
                {kpi.trend}
              </span>
            </div>
          </div>
        );
      })}
    </div>
  );
}
