"use client";

import { useState, useEffect } from "react";
import { useSearchParams, useRouter } from "next/navigation";
import OrdersHeader from "@/components/orders/OrdersHeader";
import OrdersKPI from "@/components/orders/OrdersKPI";
import OrdersTable from "@/components/orders/OrdersTable";
import OrdersListModal from "@/components/orders/OrdersListModal";
import { fetchWithAuth } from "@/lib/api";

export default function OrdersPage() {
  const [activeFilter, setActiveFilter] = useState("total");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState(null);
  const [modalMode, setModalMode] = useState("list"); // "list" | "direct_detail"
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  const searchParams = useSearchParams();
  const router = useRouter();

  // Listen for viewOrder in URL to open modal automatically (e.g. from global search)
  useEffect(() => {
    const viewOrderId = searchParams.get('viewOrder');
    if (viewOrderId && orders.length > 0) {
      const order = orders.find(o => o.id === viewOrderId);
      if (order) {
        setSelectedOrder(order);
        setModalMode("direct_detail");
        setIsModalOpen(true);
        // Clean up URL so the same order can be triggered again later
        router.replace('/orders', undefined, { shallow: true });
      }
    }
  }, [searchParams, router, orders]);

  useEffect(() => {
    async function loadOrders() {
      try {
        const response = await fetchWithAuth('/admin/orders');
        if (response.success && response.data) {
          // Map backend orders to UI structure
          const mappedOrders = response.data.map(o => {
            const dateObj = new Date(o.createdAt);
            const items = o.items || [];
            const firstItemName = items.length > 0 ? items[0].name : "Unknown Item";
            
            return {
              id: o.orderNumber || o._id,
              customer: { 
                name: o.user?.displayName || "Guest", 
                phone: o.user?.phone || "-", 
                seed: o.user?.displayName || "Guest" 
              },
              product: { 
                name: firstItemName, 
                more: items.length > 1 ? `+${items.length - 1} more items` : null 
              },
              itemCount: `${items.length} items`,
              status: o.status === "Pending" ? "Pending" : o.status === "Delivered" ? "Completed" : o.status === "Cancelled" ? "Cancelled" : "Processing",
              payment: { 
                status: o.paymentStatus === "Completed" ? "Paid" : o.paymentStatus, 
                method: o.paymentMethod || "UPI", 
                isPaid: o.paymentStatus === "Completed" 
              },
              delivery: { 
                status: o.status === "Delivered" ? "Delivered" : o.status === "Pending" ? "Pending" : "On the way", 
                rider: "Unassigned", 
                iconColor: o.status === "Delivered" ? "green" : o.status === "Pending" ? "orange" : "blue" 
              },
              amount: `₹${(o.totalPaise / 100).toFixed(2)}`,
              date: dateObj.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' }),
              time: dateObj.toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' }),
              raw: o
            };
          });
          setOrders(mappedOrders);
        }
      } catch (err) {
        console.error('Error fetching orders:', err);
      } finally {
        setLoading(false);
      }
    }
    loadOrders();
  }, []);

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      <OrdersHeader />
      <OrdersKPI 
        activeFilter={activeFilter} 
        setActiveFilter={setActiveFilter} 
        setIsModalOpen={setIsModalOpen} 
        setModalMode={setModalMode}
        ordersData={orders}
      />
      <OrdersTable 
        ordersData={orders}
        loading={loading} 
        setSelectedOrder={setSelectedOrder}
        setIsModalOpen={setIsModalOpen}
        setModalMode={setModalMode}
      />
      
      <OrdersListModal 
        isOpen={isModalOpen} 
        onClose={() => {
          setIsModalOpen(false);
          setSelectedOrder(null);
        }} 
        filterType={activeFilter} 
        selectedOrder={selectedOrder}
        setSelectedOrder={setSelectedOrder}
        modalMode={modalMode}
        ordersData={orders}
      />
    </div>
  );
}
