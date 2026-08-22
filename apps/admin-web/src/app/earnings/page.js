"use client";

import { useState } from "react";
import EarningsKPIs from "@/components/earnings/EarningsKPIs";
import EarningsTable from "@/components/earnings/EarningsTable";
import EarningsListModal from "@/components/earnings/EarningsListModal";

export default function EarningsPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("total_payouts");
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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Earnings</h1>
          <p className="text-sm font-medium text-slate-500">Track rider payouts and earnings history.</p>
        </div>
      </div>

      {/* KPI Cards */}
      <EarningsKPIs onCardClick={handleCardClick} />

      {/* Table */}
      <EarningsTable items={[]} onRowClick={handleRowClick} />

      {/* Modal */}
      <EarningsListModal 
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
