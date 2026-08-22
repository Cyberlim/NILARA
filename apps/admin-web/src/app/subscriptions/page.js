"use client";

import { useState } from "react";
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

  const handleExport = () => alert("Export clicked");
  


  const handleEditClick = (item) => {
    setItemToEdit(item);
    setIsFormOpen(true);
  };

  const handleToggleSuspend = (item) => {
    setLocalItems(prev => prev.map(i => {
      if (i.id === item.id) {
        if (i.status === "Suspended") {
          return { ...i, status: "Active", statusColor: "green" };
        } else {
          return { ...i, status: "Suspended", statusColor: "orange" };
        }
      }
      return i;
    }));
  };

  const handleDeleteClick = (itemId) => {
    setLocalItems(prev => prev.filter(i => i.id !== itemId));
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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Subscriptions</h1>
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
