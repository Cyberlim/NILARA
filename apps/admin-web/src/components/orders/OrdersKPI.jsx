"use client";

import { ShoppingBag, Clock, Package, CheckCircle2, XCircle, IndianRupee } from "lucide-react";

export default function OrdersKPI({ activeFilter, setActiveFilter, setIsModalOpen, setModalMode, ordersData = [] }) {
  const getIcon = (iconName, color) => {
    const className = `w-5 h-5 text-${color}-600`;
    switch(iconName) {
      case "bag": return <ShoppingBag className={className} />;
      case "clock": return <Clock className={className} />;
      case "package": return <Package className={className} />;
      case "check": return <CheckCircle2 className={className} />;
      case "x": return <XCircle className={className} />;
      case "rupee": return <IndianRupee className={className} />;
      default: return null;
    }
  };

  const totalOrders = ordersData.length;
  const pendingOrders = ordersData.filter(o => o.status === 'Pending').length;
  const processingOrders = ordersData.filter(o => o.status === 'Processing').length;
  const completedOrders = ordersData.filter(o => o.status === 'Completed').length;
  const cancelledOrders = ordersData.filter(o => o.status === 'Cancelled').length;
  const revenueStr = `₹${ordersData.reduce((acc, o) => {
    const val = parseFloat(o.amount?.replace(/[^0-9.-]+/g, "") || 0);
    return acc + val;
  }, 0).toLocaleString('en-IN')}`;

  const ordersKPIs = [
    { id: "total", title: "Total Orders", value: totalOrders.toString(), iconName: "bag", iconColor: "blue", trend: "+12.5%", trendUp: true, comparison: "vs last week" },
    { id: "pending", title: "Pending", value: pendingOrders.toString(), iconName: "clock", iconColor: "orange", trend: "-2.4%", trendUp: false, comparison: "vs last week" },
    { id: "processing", title: "Processing", value: processingOrders.toString(), iconName: "package", iconColor: "purple", trend: "+4.1%", trendUp: true, comparison: "vs last week" },
    { id: "completed", title: "Completed", value: completedOrders.toString(), iconName: "check", iconColor: "green", trend: "+18.2%", trendUp: true, comparison: "vs last week" },
    { id: "cancelled", title: "Cancelled", value: cancelledOrders.toString(), iconName: "x", iconColor: "red", trend: "-1.2%", trendUp: true, comparison: "vs last week" },
    { id: "revenue", title: "Total Revenue", value: revenueStr, iconName: "rupee", iconColor: "teal", trend: "+24.8%", trendUp: true, comparison: "vs last week" },
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-6">
      {ordersKPIs.map((kpi, idx) => (
        <div 
          key={idx} 
          onClick={() => {
            setActiveFilter(kpi.id);
            setModalMode("list");
            setIsModalOpen(true);
          }}
          className="cursor-pointer bg-white/80 backdrop-blur-xl rounded-3xl border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-5 flex flex-col justify-between transition-all duration-300 hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] hover:-translate-y-1 hover:bg-white/95"
        >
          <div className="flex items-start space-x-3 mb-4">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-${kpi.iconColor}-50 border border-${kpi.iconColor}-100 shrink-0`}>
              {getIcon(kpi.iconName, kpi.iconColor)}
            </div>
            <div className="flex-1 pt-0.5">
              <p className="text-[11px] sm:text-xs font-bold text-slate-500 mb-0.5 leading-tight break-words">{kpi.title}</p>
              <h3 className="text-lg font-black text-slate-800 tracking-tight">{kpi.value}</h3>
            </div>
          </div>
          <div className="flex items-center">
            <span className={`text-[10px] font-bold ${kpi.trendUp ? 'text-green-600' : 'text-red-600'}`}>
              {kpi.trend}
            </span>
            <span className="text-[10px] text-slate-400 font-medium ml-1.5">{kpi.comparison}</span>
          </div>
        </div>
      ))}
    </div>
  );
}
