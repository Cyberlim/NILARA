"use client";

import { useState, useEffect } from "react";
import { fetchWithAuth } from "@/lib/api";
import SubscriptionsKPIs from "@/components/subscriptions/SubscriptionsKPIs";
import SubscriptionsTable from "@/components/subscriptions/SubscriptionsTable";
import SubscriptionListModal from "@/components/subscriptions/SubscriptionListModal";
import SubscriptionFormModal from "@/components/subscriptions/SubscriptionFormModal";

export default function SubscriptionsPage() {
  const [modalFilter, setModalFilter] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("detail");
  const [selectedItem, setSelectedItem] = useState(null);

  const [localItems, setLocalItems] = useState([]);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [itemToEdit, setItemToEdit] = useState(null);
  const [loading, setLoading] = useState(true);

  const mapSubscription = (sub) => ({
    ...sub,
    id: sub._id,
    customerName: sub.user?.displayName || "Unknown",
    phone: sub.user?.phone || "N/A",
    statusColor: sub.status === "Active" ? "teal" : sub.status === "Suspended" ? "orange" : sub.status === "Cancelled" ? "red" : "slate",
    nextDelivery: new Date(sub.nextDeliveryDate || sub.startDate).toLocaleDateString(),
    skippedDeliveries: sub.skippedDeliveries || []
  });

  const loadSubscriptions = async () => {
    try {
      setLoading(true);
      const res = await fetchWithAuth('/subscriptions');
      if (res.success && res.data) {
        const mappedData = res.data.map(mapSubscription);
        setLocalItems(mappedData);
      }
    } catch (err) {
      console.error('Error loading subscriptions:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    loadSubscriptions();
  }, []);

  const handleExport = () => alert("Export clicked");

  const handleEditClick = (item) => {
    setItemToEdit(item);
    setIsFormOpen(true);
  };

  const handleToggleSuspend = async (item) => {
    const newStatus = item.status === "Suspended" ? "Active" : "Suspended";
    try {
      const res = await fetchWithAuth(`/subscriptions/${item._id || item.id}/status`, {
        method: 'PATCH',
        body: JSON.stringify({ status: newStatus }),
      });
      if (res.success && res.data) {
        const mappedSub = mapSubscription(res.data);
        setLocalItems(prev => prev.map(i => (i._id === item._id || i.id === item.id) ? mappedSub : i));
        if (selectedItem && (selectedItem._id === item._id || selectedItem.id === item.id)) {
          setSelectedItem(mappedSub);
        }
      }
    } catch (err) {
      console.error('Error toggling subscription status:', err);
      alert('Failed to update status');
    }
  };

  const handleDeleteClick = async (itemId) => {
    if (!confirm('Are you sure you want to cancel this subscription?')) return;
    try {
      const res = await fetchWithAuth(`/subscriptions/${itemId}/status`, {
        method: 'PATCH',
        body: JSON.stringify({ status: 'Cancelled' }),
      });
      if (res.success && res.data) {
        const mappedSub = mapSubscription(res.data);
        setLocalItems(prev => prev.map(i => (i._id === itemId || i.id === itemId) ? mappedSub : i));
        if (selectedItem && (selectedItem._id === itemId || selectedItem.id === itemId)) {
          setSelectedItem(mappedSub);
        }
      }
    } catch (err) {
      console.error('Error cancelling subscription:', err);
      alert('Failed to cancel subscription');
    }
  };

  const handleSaveItem = (savedItem) => {
    setLocalItems(prev => {
      const exists = prev.find(i => i.id === savedItem.id);
      if (exists) {
        return prev.map(i => i.id === savedItem.id ? savedItem : i);
      }
      return [savedItem, ...prev];
    });
  };

  const handleRowClick = (item) => {
    setSelectedItem(item);
    setModalMode("detail");
    setIsModalOpen(true);
  };

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Subscribers</h1>
          <p className="text-sm font-medium text-slate-500">Manage recurring orders and user subscriptions</p>
        </div>

      </div>

      {/* KPI Cards */}
      <SubscriptionsKPIs 
        modalFilter={modalFilter}
        setModalFilter={setModalFilter}
        setIsModalOpen={setIsModalOpen}
        setModalMode={setModalMode}
      />

      {/* Table */}
      <SubscriptionsTable 
        localItems={localItems}
        onRowClick={handleRowClick} 
        onEditClick={handleEditClick}
        onDeleteClick={handleDeleteClick}
        onToggleSuspend={handleToggleSuspend}
      />

      {/* List / Detail Modal */}
      <SubscriptionListModal
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setSelectedItem(null); setModalFilter(null); }}
        filterType={modalFilter}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
        setModalMode={setModalMode}
        onEditClick={handleEditClick}
      />

      {/* Form Modal */}
      <SubscriptionFormModal
        isOpen={isFormOpen}
        onClose={() => setIsFormOpen(false)}
        itemToEdit={itemToEdit}
        onSave={handleSaveItem}
      />
    </div>
  );
}
