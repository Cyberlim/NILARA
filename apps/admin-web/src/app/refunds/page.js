"use client";

import { useState } from "react";
import RefundsKPIs from "@/components/refunds/RefundsKPIs";
import RefundsTable from "@/components/refunds/RefundsTable";
import RefundsListModal from "@/components/refunds/RefundsListModal";

export default function RefundsPage() {
  const [activeFilter, setActiveFilter] = useState("total_refunded");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [modalMode, setModalMode] = useState("list");
  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Refunds</h1>
          <p className="text-sm font-medium text-slate-500">Manage and process customer refund requests.</p>
        </div>
      </div>

      {/* KPI Cards */}
      <RefundsKPIs 
        activeFilter={activeFilter} 
        setActiveFilter={setActiveFilter} 
        setIsModalOpen={setIsModalOpen} 
        setModalMode={setModalMode}
      />

      {/* Table */}
      <RefundsTable 
        items={[]} 
        setSelectedItem={setSelectedItem}
        setIsModalOpen={setIsModalOpen}
        setModalMode={setModalMode}
      />

      <RefundsListModal 
        isOpen={isModalOpen} 
        onClose={() => {
          setIsModalOpen(false);
          setSelectedItem(null);
        }} 
        filterType={activeFilter} 
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
      />

    </div>
  );
}
