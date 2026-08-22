"use client";

import { useState } from "react";
import WithdrawalsKPIs from "@/components/withdrawals/WithdrawalsKPIs";
import WithdrawalsTable from "@/components/withdrawals/WithdrawalsTable";
import WithdrawalsListModal from "@/components/withdrawals/WithdrawalsListModal";

export default function WithdrawalsPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("pending_requests");
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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Withdrawals</h1>
          <p className="text-sm font-medium text-slate-500">Manage rider requests to withdraw their wallet earnings.</p>
        </div>
      </div>

      {/* KPI Cards */}
      <WithdrawalsKPIs onCardClick={handleCardClick} />

      {/* Table */}
      <WithdrawalsTable items={[]} onRowClick={handleRowClick} />

      {/* Modal */}
      <WithdrawalsListModal 
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
