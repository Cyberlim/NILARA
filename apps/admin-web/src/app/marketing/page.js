"use client";

import { useState } from "react";
import { Plus } from "lucide-react";
import MarketingKPIs from "@/components/marketing/MarketingKPIs";
import MarketingTable from "@/components/marketing/MarketingTable";
import MarketingListModal from "@/components/marketing/MarketingListModal";
import MarketingFormModal from "@/components/marketing/MarketingFormModal";

export default function MarketingPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("active_campaigns");
  const [selectedItem, setSelectedItem] = useState(null);
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);

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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Marketing</h1>
          <p className="text-sm font-medium text-slate-500">Manage push notifications, SMS, and email campaigns.</p>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={() => setIsFormModalOpen(true)}
            className="flex items-center px-4 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm"
          >
            <Plus className="w-4 h-4 mr-2" />
            New Campaign
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <MarketingKPIs onCardClick={handleCardClick} />

      {/* Table */}
      <MarketingTable items={[]} onRowClick={handleRowClick} />

      {/* Modal */}
      <MarketingListModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        filterType={filterType}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
      />

      <MarketingFormModal 
        isOpen={isFormModalOpen}
        onClose={() => setIsFormModalOpen(false)}
      />
    </div>
  );
}
