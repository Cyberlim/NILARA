"use client";

import { useState } from "react";
import PartnersKPIs from "@/components/delivery-partners/PartnersKPIs";
import PartnersTable from "@/components/delivery-partners/PartnersTable";
import DeliveryPartnersListModal from "@/components/delivery-partners/DeliveryPartnersListModal";

export default function DeliveryPartnersPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("total_partners");
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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Delivery Partners</h1>
          <p className="text-sm font-medium text-slate-500">Manage the fleet of delivery riders.</p>
        </div>
      </div>

      {/* KPI Cards */}
      <PartnersKPIs onCardClick={handleCardClick} />

      {/* Table */}
      <PartnersTable items={[]} onRowClick={handleRowClick} />

      {/* Modal */}
      <DeliveryPartnersListModal 
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
