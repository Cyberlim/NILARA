"use client";

import { Package, CheckCircle2, XCircle, AlertTriangle, Tag, IndianRupee, AlertCircle, CheckCircle } from "lucide-react";

export default function ProductsKPI({ products = [], modalFilter, setModalFilter, setIsModalOpen, setModalMode }) {
  // Dynamically compute KPIs
  const totalProducts = products.length;
  const activeProducts = products.filter(p => p.status === "Active").length;
  const outOfStock = products.filter(p => p.stockStatus === "Out of Stock").length;
  const lowStock = products.filter(p => p.stockStatus === "Low Stock").length;

  const productsKPIs = [
    { title: "Total Products", value: totalProducts, change: "+12%", type: "neutral", iconName: "package", iconColor: "teal", filterKey: "total" },
    { title: "Active Products", value: activeProducts, change: "+5%", type: "positive", iconName: "check", iconColor: "green", filterKey: "active" },
    { title: "Out of Stock", value: outOfStock, change: "-2%", type: "positive", iconName: "xcircle", iconColor: "red", filterKey: "outofstock" },
    { title: "Low Stock Alert", value: lowStock, change: "+3%", type: "negative", iconName: "alert", iconColor: "orange", filterKey: "lowstock" },
  ];
  const getIcon = (iconName, color) => {
    const cls = `w-5 h-5 text-${color}-600`;
    switch (iconName) {
      case "package": return <Package className={cls} />;
      case "check": return <CheckCircle2 className={cls} />;
      case "x": return <XCircle className={cls} />;
      case "alert": return <AlertTriangle className={cls} />;
      case "tag": return <Tag className={cls} />;
      case "rupee": return <IndianRupee className={cls} />;
      default: return null;
    }
  };

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-6">
      {productsKPIs.map((kpi, idx) => (
        <div
          key={idx}
          onClick={() => {
            setModalFilter(kpi.id);
            setModalMode("list");
            setIsModalOpen(true);
          }}
          className={`cursor-pointer bg-white/80 backdrop-blur-xl rounded-3xl border shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-5 flex flex-col justify-between transition-all duration-300 hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] hover:-translate-y-1 hover:bg-white/95 ${
            modalFilter === kpi.id
              ? "ring-2 ring-teal-500/30 border-teal-200 bg-teal-50/30"
              : "border-white/60"
          }`}
        >
          <div className="flex items-start space-x-3 mb-4">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-${kpi.iconColor}-50 border border-${kpi.iconColor}-100 shrink-0`}>
              {getIcon(kpi.iconName, kpi.iconColor)}
            </div>
            <div className="flex-1 pt-0.5">
              <p className="text-[11px] sm:text-xs font-bold text-slate-500 mb-0.5 leading-tight">{kpi.title}</p>
              <h3 className="text-lg font-black text-slate-800 tracking-tight leading-tight">{kpi.value}</h3>
            </div>
          </div>
          <div className="flex items-center flex-wrap gap-1">
            {kpi.trendUp === null ? (
              <span className="text-[10px] font-bold text-slate-400">{kpi.trend}</span>
            ) : (
              <>
                <span className={`text-[10px] font-bold ${kpi.trendUp ? "text-green-600" : "text-red-600"}`}>{kpi.trend}</span>
                {kpi.comparison && <span className="text-[10px] text-slate-400 font-medium">{kpi.comparison}</span>}
              </>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}
