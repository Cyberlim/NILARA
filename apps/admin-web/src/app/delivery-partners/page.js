"use client";

import { useState, useEffect } from "react";
import { useAuth } from "@/context/AuthContext";
import PartnersKPIs from "@/components/delivery-partners/PartnersKPIs";
import PartnersTable from "@/components/delivery-partners/PartnersTable";
import DeliveryPartnersListModal from "@/components/delivery-partners/DeliveryPartnersListModal";
import AddPartnerModal from "@/components/delivery-partners/AddPartnerModal";

export default function DeliveryPartnersPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isAddPartnerModalOpen, setIsAddPartnerModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("total_partners");
  const [selectedItem, setSelectedItem] = useState(null);

  const { token } = useAuth();
  const [localItems, setLocalItems] = useState([]);

  const fetchPartners = () => {
    if (!token) return;
    fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1'}/admin/delivery-partners`, {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        setLocalItems(data.data);
      }
    })
    .catch(err => console.error("Failed to fetch delivery partners", err));
  };

  useEffect(() => {
    fetchPartners();
  }, [token]);

  // Handle partner added from modal
  const handlePartnerAdded = () => {
    fetchPartners();
  };


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
        <button
          onClick={() => setIsAddPartnerModalOpen(true)}
          className="bg-indigo-600 hover:bg-indigo-700 text-white px-5 py-2.5 rounded-xl font-semibold transition-all shadow-md shadow-indigo-600/20 active:scale-95"
        >
          + Add Partner
        </button>
      </div>

      {/* KPI Cards */}
      <PartnersKPIs onCardClick={handleCardClick} />

      {/* Table */}
      <PartnersTable items={localItems} onRowClick={handleRowClick} />

      {/* Modal */}
      <DeliveryPartnersListModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        filterType={filterType}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
      />

      <AddPartnerModal 
        isOpen={isAddPartnerModalOpen}
        onClose={() => setIsAddPartnerModalOpen(false)}
        onPartnerAdded={handlePartnerAdded}
      />
    </div>
  );
}
