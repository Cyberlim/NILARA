"use client";

import { useState } from "react";
import WalletsKPIs from "@/components/wallets/WalletsKPIs";
import WalletsTable from "@/components/wallets/WalletsTable";
import WalletsListModal from "@/components/wallets/WalletsListModal";

export default function WalletsPage() {
  const [activeFilter, setActiveFilter] = useState("total_wallet_balance");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [modalMode, setModalMode] = useState("list");
  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Wallets</h1>
          <p className="text-sm font-medium text-slate-500">Manage customer wallet balances and transactions.</p>
        </div>
      </div>

      {/* KPI Cards */}
      <WalletsKPIs 
        activeFilter={activeFilter} 
        setActiveFilter={setActiveFilter} 
        setIsModalOpen={setIsModalOpen} 
        setModalMode={setModalMode}
      />

      {/* Table */}
      <WalletsTable 
        items={[]} 
        setSelectedItem={setSelectedItem}
        setIsModalOpen={setIsModalOpen}
        setModalMode={setModalMode}
      />

      <WalletsListModal 
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
