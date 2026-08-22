"use client";

import { useState, useEffect } from "react";
import KPIStatsGrid from "./KPIStatsGrid";
import RevenueChart from "./RevenueChart";
import OrdersBarChart from "./OrdersBarChart";
import RecentOrdersTable from "./RecentOrdersTable";
import TopProductsList from "./TopProductsList";
import RecentActivity from "./RecentActivity";
import GrowthBanner from "./GrowthBanner";
import { fetchWithAuth } from "@/lib/api";

export default function Dashboard() {
  const [dashboardData, setDashboardData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadDashboard() {
      try {
        const response = await fetchWithAuth('/admin/dashboard');
        if (response.success) {
          setDashboardData(response.data);
        }
      } catch (err) {
        console.error("Failed to load dashboard data", err);
      } finally {
        setLoading(false);
      }
    }
    loadDashboard();
  }, []);

  if (loading) {
    return <div className="max-w-[1600px] mx-auto pb-10 min-h-screen flex items-center justify-center">Loading dashboard...</div>;
  }

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      <KPIStatsGrid kpiData={dashboardData?.kpi} />

      {/* Main Analytics Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
        <div className="lg:col-span-1 min-h-[340px]">
          <RevenueChart chartData={dashboardData?.charts?.revenue} />
        </div>
        <div className="lg:col-span-1 min-h-[340px]">
          <OrdersBarChart chartData={dashboardData?.charts?.orders} />
        </div>
      </div>

      {/* Operations Row */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 mb-6">
        <div className="lg:col-span-2 min-h-[400px]">
          <RecentOrdersTable orders={dashboardData?.recentOrders} />
        </div>
        <div className="lg:col-span-1 min-h-[400px]">
          <TopProductsList products={dashboardData?.topProducts} />
        </div>
        <div className="lg:col-span-1 min-h-[400px]">
          <RecentActivity />
        </div>
      </div>

      <GrowthBanner />
    </div>
  );
}
