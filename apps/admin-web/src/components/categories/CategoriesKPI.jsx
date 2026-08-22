"use client";

import { Folder, Package, AlertTriangle, EyeOff, Box, Tag } from "lucide-react";

export default function CategoriesKPI({ modalFilter, setModalFilter, setIsModalOpen }) {
  const getIcon = (iconName, color) => {
    const cls = `w-5 h-5 text-${color}-600`;
    switch (iconName) {
      case "folder": return <Folder className={cls} />;
      case "box": return <Box className={cls} />;
      case "eye-off": return <EyeOff className={cls} />;
      case "package": return <Package className={cls} />;
      case "tag": return <Tag className={cls} />;
      case "alert": return <AlertTriangle className={cls} />;
      default: return null;
    }
  };

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-6">
      {categoriesKPIs.map((kpi, idx) => (
        <div
          key={idx}
          onClick={() => {
            if (setModalFilter) setModalFilter(kpi.id);
            if (setIsModalOpen) setIsModalOpen(true);
          }}
          className={`cursor-pointer bg-white/80 backdrop-blur-xl rounded-3xl border shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-5 flex flex-col justify-between transition-all duration-300 hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] hover:-translate-y-1 hover:bg-white/95 ${
            modalFilter === kpi.id
              ? "ring-2 ring-teal-500/30 border-teal-200 bg-teal-50/30"
              : "border-white/60"
          }`}
        >
          <div className="flex items-start space-x-3 mb-4">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-${kpi.color}-50 border border-${kpi.color}-100 shrink-0`}>
              {getIcon(kpi.icon, kpi.color)}
            </div>
            <div className="flex-1 pt-0.5">
              <p className="text-[11px] sm:text-xs font-bold text-slate-500 mb-0.5 leading-tight">{kpi.label}</p>
              <h3 className="text-lg font-black text-slate-800 tracking-tight leading-tight">{kpi.value}</h3>
            </div>
          </div>
          <div className="flex items-center flex-wrap gap-1">
            <span className={`text-[10px] font-bold ${kpi.trendUp === true ? "text-green-600" : kpi.trendUp === false ? "text-red-500" : "text-slate-400"}`}>
              {kpi.trend}
            </span>
          </div>
        </div>
      ))}
    </div>
  );
}
