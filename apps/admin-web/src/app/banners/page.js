"use client";

import { useState } from "react";
import { Plus } from "lucide-react";
import BannersKPIs from "@/components/banners/BannersKPIs";
import BannersGrid from "@/components/banners/BannersGrid";
import BannersListModal from "@/components/banners/BannersListModal";
import BannerFormModal from "@/components/banners/BannerFormModal";

export default function BannersPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("active_banners");
  const [selectedItem, setSelectedItem] = useState(null);
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);
  const [bannerToEdit, setBannerToEdit] = useState(null);

  const handleEditBanner = (item) => {
    setBannerToEdit(item);
    setIsFormModalOpen(true);
  };

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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Banners</h1>
          <p className="text-sm font-medium text-slate-500">Manage promotional banners across the app and website.</p>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={() => {
              setBannerToEdit(null);
              setIsFormModalOpen(true);
            }}
            className="flex items-center px-4 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm"
          >
            <Plus className="w-4 h-4 mr-2" />
            Add Banner
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <BannersKPIs onCardClick={handleCardClick} />

      {/* Banner Grid */}
      <BannersGrid items={[]} onGridClick={handleGridClick} />

      {/* Modal */}
      <BannersListModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        filterType={filterType}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
        onEdit={handleEditBanner}
      />

      <BannerFormModal
        isOpen={isFormModalOpen}
        onClose={() => setIsFormModalOpen(false)}
        bannerToEdit={bannerToEdit}
      />
    </div>
  );
}
