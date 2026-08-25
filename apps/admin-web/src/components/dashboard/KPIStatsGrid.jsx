"use client";

import KPICard from "./KPICard";

export default function KPIStatsGrid({ kpiData }) {
  if (!kpiData) return <div className="animate-pulse flex space-x-4 mb-6"><div className="h-24 bg-slate-200 rounded-xl w-full"></div></div>;

  const kpis = [
    {
      id: "revenue",
      title: "Today's Revenue",
      value: "₹ " + kpiData.todayRevenue.toLocaleString(undefined, { minimumFractionDigits: 0, maximumFractionDigits: 2 }),
      trend: (kpiData.revenueTrend >= 0 ? "↑ " : "↓ ") + Math.abs(kpiData.revenueTrend) + "%",
      trendUp: kpiData.revenueTrend >= 0,
      comparison: "vs yesterday",
      iconColor: "teal",
      sparkline: [{ value: 20 }, { value: 35 }, { value: 25 }, { value: 45 }, { value: 30 }, { value: 55 }, { value: 70 }] // placeholder
    },
    {
      id: "orders",
      title: "Today's Orders",
      value: kpiData.todayOrders.toString(),
      trend: (kpiData.ordersTrend >= 0 ? "↑ " : "↓ ") + Math.abs(kpiData.ordersTrend) + "%",
      trendUp: kpiData.ordersTrend >= 0,
      comparison: "vs yesterday",
      iconColor: "cyan",
      sparkline: [{ value: 10 }, { value: 15 }, { value: 25 }, { value: 22 }, { value: 40 }, { value: 35 }, { value: 50 }] // placeholder
    },
    {
      id: "subscriptions",
      title: "Active Subscribers",
      value: kpiData.activeSubscriptions.toString(),
      trend: "↑ " + Math.abs(kpiData.subscriptionsTrend || 0) + "%",
      trendUp: (kpiData.subscriptionsTrend || 0) >= 0,
      comparison: "vs last week",
      iconColor: "blue",
      sparkline: [{ value: 50 }, { value: 52 }, { value: 51 }, { value: 54 }, { value: 58 }, { value: 60 }, { value: 65 }]
    },
    {
      id: "deliveries",
      title: "Active Deliveries",
      value: kpiData.activeDeliveries.toString(),
      trend: "↑ " + Math.abs(kpiData.deliveriesTrend || 0) + "%",
      trendUp: (kpiData.deliveriesTrend || 0) >= 0,
      comparison: "vs yesterday",
      iconColor: "orange",
      sparkline: [{ value: 45 }, { value: 40 }, { value: 42 }, { value: 35 }, { value: 38 }, { value: 30 }, { value: 28 }]
    },
    {
      id: "riders",
      title: "Online Riders",
      value: kpiData.onlineRiders.toString(),
      trend: "↑ " + Math.abs(kpiData.ridersTrend || 0) + "%",
      trendUp: (kpiData.ridersTrend || 0) >= 0,
      comparison: "vs yesterday",
      iconColor: "teal",
      sparkline: [{ value: 20 }, { value: 22 }, { value: 20 }, { value: 24 }, { value: 25 }, { value: 28 }, { value: 28 }]
    },
    {
      id: "stock",
      title: "Low Stock Products",
      value: kpiData.lowStockProducts.toString(),
      trend: "↑ " + Math.abs(kpiData.lowStockTrend || 0) + "%",
      trendUp: false,
      comparison: "vs yesterday",
      iconColor: "red",
      sparkline: [{ value: 12 }, { value: 10 }, { value: 9 }, { value: 11 }, { value: 8 }, { value: 7 }, { value: 6 }]
    }
  ];

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-6">
      {kpis.map((stat) => (
        <KPICard key={stat.id} data={stat} />
      ))}
    </div>
  );
}
