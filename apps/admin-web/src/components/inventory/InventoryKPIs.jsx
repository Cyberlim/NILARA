"use client";

import { Package, AlertTriangle, XCircle, CheckCircle } from "lucide-react";

export default function InventoryKPIs({ kpiData, modalFilter, setModalFilter, setIsModalOpen, setModalMode }) {
  const data = kpiData || { total: 0, inStock: 0, lowStock: 0, outOfStock: 0 };

  const kpis = [
    { id: "total", title: "Total Products", value: data.total, icon: <Package className="w-5 h-5 text-teal-600" />, iconColor: "teal" },
    { id: "inStock", title: "In Stock", value: data.inStock, icon: <CheckCircle className="w-5 h-5 text-green-600" />, iconColor: "green" },
    { id: "lowStock", title: "Low Stock", value: data.lowStock, icon: <AlertTriangle className="w-5 h-5 text-orange-600" />, iconColor: "orange" },
    { id: "outOfStock", title: "Out of Stock", value: data.outOfStock, icon: <XCircle className="w-5 h-5 text-red-600" />, iconColor: "red" },
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
      {kpis.map((kpi) => (
        <div
          key={kpi.id}
          onClick={() => { if (setModalFilter) { setModalFilter(kpi.id); setModalMode("list"); setIsModalOpen(true); } }}
          className={`cursor-pointer bg-white/80 backdrop-blur-xl rounded-3xl border shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-5 flex flex-col justify-between transition-all duration-300 hover:shadow-lg hover:-translate-y-1 ${modalFilter === kpi.id ? "ring-2 ring-teal-500/30 border-teal-200" : "border-white/60"}`}
        >
          <div className="flex items-center space-x-3 mb-3">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-${kpi.iconColor}-50 border border-${kpi.iconColor}-100 shrink-0`}>
              {kpi.icon}
            </div>
            <div>
              <p className="text-xs font-bold text-slate-500">{kpi.title}</p>
              <h3 className="text-2xl font-black text-slate-800">{kpi.value}</h3>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
