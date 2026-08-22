"use client";

import { useState, useEffect } from "react";
import { fetchWithAuth } from "@/lib/api";
import BulkOrdersTable from "@/components/bulk-orders/BulkOrdersTable";
import BulkOrdersListModal from "@/components/bulk-orders/BulkOrdersListModal";
import { Layers, Clock, CheckCircle2, Truck, XCircle } from "lucide-react";

export default function BulkOrdersPage() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeFilter, setActiveFilter] = useState("Total"); 
  const [isListModalOpen, setIsListModalOpen] = useState(false);

  const loadOrders = async () => {
    try {
      setLoading(true);
      const response = await fetchWithAuth('/bulk-orders');
      if (response.success && response.data) {
        setOrders(response.data);
      }
    } catch (err) {
      console.error('Error fetching bulk orders:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadOrders();
  }, []);

  const filteredOrders = orders.filter(o => {
    if (activeFilter === "Total") return true;
    return o.status === activeFilter;
  });

  const getKPIs = () => {
    const totalOrders = orders.length;
    const pendingOrders = orders.filter(o => o.status === 'Pending').length;
    const confirmedOrders = orders.filter(o => o.status === 'Confirmed').length;
    const deliveredOrders = orders.filter(o => o.status === 'Delivered').length;
    const cancelledOrders = orders.filter(o => o.status === 'Cancelled').length;

    return [
      { id: "Total", title: "Total Requests", value: totalOrders, icon: Layers, color: "blue" },
      { id: "Pending", title: "Pending", value: pendingOrders, icon: Clock, color: "orange" },
      { id: "Confirmed", title: "Confirmed", value: confirmedOrders, icon: CheckCircle2, color: "purple" },
      { id: "Delivered", title: "Delivered", value: deliveredOrders, icon: Truck, color: "green" },
      { id: "Cancelled", title: "Cancelled", value: cancelledOrders, icon: XCircle, color: "red" },
    ];
  };

  return (
    <div className="max-w-[1600px] mx-auto pb-10 p-6">
      <div className="mb-6 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-2xl font-black text-slate-800 tracking-tight">Bulk Orders</h1>
          <p className="text-sm font-medium text-slate-500 mt-1">Manage and track bulk water delivery requests.</p>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-4 mb-6">
        {getKPIs().map((kpi) => {
          const isActive = activeFilter === kpi.id;
          const Icon = kpi.icon;
          return (
            <div 
              key={kpi.id} 
              onClick={() => {
                setActiveFilter(kpi.id);
                setIsListModalOpen(true);
              }}
              className={`cursor-pointer backdrop-blur-xl rounded-3xl p-5 flex flex-col justify-between transition-all duration-300 ${
                isActive 
                  ? `bg-${kpi.color}-50/80 border border-${kpi.color}-200 shadow-[0_8px_30px_rgb(0,0,0,0.08)] -translate-y-1`
                  : 'bg-white/80 border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] hover:-translate-y-1 hover:bg-white/95'
              }`}
            >
              <div className="flex items-start space-x-3 mb-4">
                <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-${kpi.color}-50 border border-${kpi.color}-100 shrink-0`}>
                  <Icon className={`w-5 h-5 text-${kpi.color}-600`} />
                </div>
                <div className="flex-1 pt-0.5">
                  <p className="text-[11px] sm:text-xs font-bold text-slate-500 mb-0.5 leading-tight">{kpi.title}</p>
                  <h3 className="text-lg font-black text-slate-800 tracking-tight">{kpi.value}</h3>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      <BulkOrdersTable orders={filteredOrders} loading={loading} onRefresh={loadOrders} />

      <BulkOrdersListModal 
        isOpen={isListModalOpen}
        onClose={() => setIsListModalOpen(false)}
        filterType={activeFilter}
        ordersData={orders}
        onRefresh={loadOrders}
      />
    </div>
  );
}
