"use client";

import { useState } from "react";
import { Plus } from "lucide-react";
import IncentivesKPIs from "@/components/incentives/IncentivesKPIs";
import IncentivesGrid from "@/components/incentives/IncentivesGrid";
import IncentivesListModal from "@/components/incentives/IncentivesListModal";

export default function IncentivesPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("active_campaigns");
  const [selectedItem, setSelectedItem] = useState(null);

  const handleCardClick = (filter) => {
    setFilterType(filter);
    setModalMode("list");
    setSelectedItem(null);
    setIsModalOpen(true);
  };

  const handleGridClick = (item) => {
    setSelectedItem(item);
    setModalMode("direct_detail");
    setIsModalOpen(true);
  };

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Incentives</h1>
          <p className="text-sm font-medium text-slate-500">Create performance bonuses and surge campaigns.</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center px-4 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm">
            <Plus className="w-4 h-4 mr-2" />
            New Campaign
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <IncentivesKPIs onCardClick={handleCardClick} />

      {/* Campaign Grid */}
      <IncentivesGrid items={[]} onGridClick={handleGridClick} />

      {/* Modal */}
      <IncentivesListModal 
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
