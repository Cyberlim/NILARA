"use client";

import { 
  Calendar, CheckCircle, IndianRupee, PauseCircle, XCircle, TrendingUp 
} from "lucide-react";

export default function SubscriptionsKPIs({ modalFilter, setModalFilter, setIsModalOpen, setModalMode }) {
  const getIcon = (iconName, color) => {
    const cls = `w-5 h-5 text-${color}-600`;
    switch (iconName) {
      case "calendar": return <Calendar className={cls} />;
      case "check-circle": return <CheckCircle className={cls} />;
      case "indian-rupee": return <IndianRupee className={cls} />;
      case "pause-circle": return <PauseCircle className={cls} />;
      case "x-circle": return <XCircle className={cls} />;
      case "trending-up": return <TrendingUp className={cls} />;
      default: return <Calendar className={cls} />;
    }
  };

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-6">
      {[].map((kpi, idx) => (
        <div
          key={idx}
          onClick={() => {
            if (setModalFilter && setModalMode && setIsModalOpen) {
              setModalFilter(kpi.id);
              setModalMode("list");
              setIsModalOpen(true);
            }
          }}
          className={`cursor-pointer bg-white/80 backdrop-blur-xl rounded-3xl border shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-5 flex flex-col justify-between transition-all duration-300 hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] hover:-translate-y-1 hover:bg-white/95 ${
            modalFilter === kpi.id
              ? "ring-2 ring-teal-500/30 border-teal-200 bg-teal-50/30"
              : "border-white/60"
          }`}
        >
          <div className="flex items-start space-x-3 mb-4">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-${kpi.iconColor}-50 border border-${kpi.iconColor}-100 shrink-0`}>
              {getIcon(kpi.icon, kpi.iconColor)}
            </div>
            <div className="flex-1 pt-0.5">
              <p className="text-[11px] sm:text-xs font-bold text-slate-500 mb-0.5 leading-tight break-words">{kpi.title}</p>
              <h3 className="text-lg font-black text-slate-800 tracking-tight leading-tight">{kpi.value}</h3>
            </div>
          </div>
          
          <div className="flex items-center flex-wrap gap-1">
            <span className={`text-[10px] font-bold ${kpi.isPositive ? 'text-green-600' : 'text-red-600'}`}>
              {kpi.trend}
            </span>
          </div>
        </div>
      ))}
    </div>
  );
}
