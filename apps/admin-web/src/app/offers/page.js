"use client";

import { useState } from "react";
import { Plus } from "lucide-react";
import OffersKPIs from "@/components/offers/OffersKPIs";
import OffersTable from "@/components/offers/OffersTable";
import OffersListModal from "@/components/offers/OffersListModal";

export default function OffersPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("active_offers");
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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Offers & Coupons</h1>
          <p className="text-sm font-medium text-slate-500">Create discount codes and promotional offers.</p>
        </div>
        <div className="flex items-center gap-3">
          <button className="flex items-center px-4 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm">
            <Plus className="w-4 h-4 mr-2" />
            Create Coupon
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <OffersKPIs onCardClick={handleCardClick} />

      {/* Table */}
      <OffersTable items={[]} onRowClick={handleRowClick} />

      {/* Modal */}
      <OffersListModal 
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
