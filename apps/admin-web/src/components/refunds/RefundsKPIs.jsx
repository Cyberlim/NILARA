"use client";

import { Banknote, Clock, CheckCircle, TrendingDown } from "lucide-react";

const iconMap = {
  "banknote": Banknote,
  "clock": Clock,
  "check-circle": CheckCircle,
  "trending-down": TrendingDown
};

export default function RefundsKPIs({ activeFilter, setActiveFilter, setIsModalOpen, setModalMode }) {
  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      {[].map((kpi) => {
        const Icon = iconMap[kpi.icon] || Banknote;
        return (
          <div 
            key={kpi.id} 
            onClick={() => {
              setActiveFilter(kpi.id);
              setModalMode("list");
              setIsModalOpen(true);
            }}
            className={`cursor-pointer rounded-3xl p-5 flex flex-col justify-between transition-all duration-300 ${
              activeFilter === kpi.id 
                ? 'bg-slate-800 text-white shadow-xl scale-[1.02] ring-4 ring-teal-500/20' 
                : 'bg-white/80 backdrop-blur-xl border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] hover:-translate-y-1 hover:bg-white/95'
            }`}
          >
            <div className="flex items-start space-x-3 mb-4">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 ${
                activeFilter === kpi.id ? 'bg-white/10 border-white/20' : `bg-${kpi.iconColor}-50 border border-${kpi.iconColor}-100`
              }`}>
                <Icon className={`w-5 h-5 ${activeFilter === kpi.id ? 'text-white' : `text-${kpi.iconColor}-600`}`} />
              </div>
              <div className="flex-1 pt-0.5">
                <p className={`text-[11px] sm:text-xs font-bold mb-0.5 leading-tight break-words ${activeFilter === kpi.id ? 'text-slate-300' : 'text-slate-500'}`}>
                  {kpi.title}
                </p>
                <h3 className={`text-lg font-black tracking-tight ${activeFilter === kpi.id ? 'text-white' : 'text-slate-800'}`}>
                  {kpi.value}
                </h3>
              </div>
            </div>
            <div className="flex items-center">
              <span className={`text-[10px] font-bold ${
                activeFilter === kpi.id 
                  ? (kpi.isPositive ? 'text-emerald-400' : 'text-red-400') 
                  : (kpi.isPositive ? 'text-green-600' : 'text-red-600')
              }`}>
                {kpi.trend}
              </span>
            </div>
          </div>
        );
      })}
    </div>
  );
}
