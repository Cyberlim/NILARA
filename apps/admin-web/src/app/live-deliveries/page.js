"use client";

import { useState } from "react";
import LiveDeliveriesKPIs from "@/components/live-deliveries/LiveDeliveriesKPIs";
import LiveDeliveriesTable from "@/components/live-deliveries/LiveDeliveriesTable";
import LiveDeliveriesListModal from "@/components/live-deliveries/LiveDeliveriesListModal";

export default function LiveDeliveriesPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("all_live");
  const [selectedItem, setSelectedItem] = useState(null);

  const handleCardClick = (filter) => {
    setFilterType(filter);
    setModalMode("list");
    setSelectedItem(null);
    setIsModalOpen(true);
  };

  const handleRowClick = (item) => {
    setSelectedItem(item);
    setModalMode("direct_detail");
    setIsModalOpen(true);
  };

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Live Deliveries</h1>
          <p className="text-sm font-medium text-slate-500">Track ongoing delivery assignments and rider locations in real-time.</p>
        </div>
      </div>

      {/* KPI Cards */}
      <LiveDeliveriesKPIs onCardClick={handleCardClick} />

      {/* Table */}
      <LiveDeliveriesTable items={[]} onRowClick={handleRowClick} />

      {/* Modal */}
      <LiveDeliveriesListModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        filterType={filterType}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
      />
    </div>
  );
}
