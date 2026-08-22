"use client";

import { IndianRupee, CheckCircle, XCircle, Clock } from "lucide-react";

export default function PaymentsKPIs({ kpiData, activeFilter, setActiveFilter, setIsModalOpen, setModalMode }) {
  const d = kpiData || { totalRevenue: 0, pending: 0, paid: 0, failed: 0 };

  const kpis = [
    { id: "total_revenue", title: "Total Revenue", value: "₹" + d.totalRevenue.toLocaleString(), icon: IndianRupee, iconColor: "teal" },
    { id: "paid", title: "Paid", value: d.paid, icon: CheckCircle, iconColor: "green" },
    { id: "pending", title: "Pending", value: d.pending, icon: Clock, iconColor: "amber" },
    { id: "failed", title: "Failed", value: d.failed, icon: XCircle, iconColor: "red" },
  ];

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      {kpis.map((kpi) => {
        const Icon = kpi.icon;
        return (
          <div
            key={kpi.id}
            onClick={() => { setActiveFilter(kpi.id); setModalMode("list"); setIsModalOpen(true); }}
            className={`cursor-pointer rounded-3xl p-5 flex flex-col justify-between transition-all duration-300 bg-white/80 backdrop-blur-xl border shadow-[0_4px_20px_rgb(0,0,0,0.03)] hover:shadow-lg hover:-translate-y-1 ${activeFilter === kpi.id ? "border-teal-200 ring-2 ring-teal-500/30" : "border-white/60"}`}
          >
            <div className="flex items-start space-x-3 mb-3">
              <div className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 bg-${kpi.iconColor}-50 border border-${kpi.iconColor}-100`}>
                <Icon className={`w-5 h-5 text-${kpi.iconColor}-600`} />
              </div>
              <div className="flex-1 pt-0.5">
                <p className="text-xs font-bold text-slate-500 mb-0.5">{kpi.title}</p>
                <h3 className="text-2xl font-black text-slate-800">{kpi.value}</h3>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
