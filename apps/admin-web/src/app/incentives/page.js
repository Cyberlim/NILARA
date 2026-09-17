"use client";

import { useState, useEffect, useCallback } from "react";
import { Plus, RefreshCw } from "lucide-react";
import IncentivesKPIs from "@/components/incentives/IncentivesKPIs";
import IncentivesGrid from "@/components/incentives/IncentivesGrid";
import IncentivesListModal from "@/components/incentives/IncentivesListModal";
import CreateIncentiveModal from "@/components/incentives/CreateIncentiveModal";
import { fetchWithAuth } from "@/lib/api";

export default function IncentivesPage() {
  const [campaigns, setCampaigns] = useState([]);
  const [kpis, setKpis] = useState({
    activeCount: 0,
    totalPaid: 0,
    totalClaims: 0,
    participatingPartners: 0
  });
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isCreateModalOpen, setIsCreateModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("active_campaigns");
  const [selectedItem, setSelectedItem] = useState(null);

  const fetchCampaigns = useCallback(async () => {
    try {
      setLoading(true);
      const res = await fetchWithAuth("/admin/incentives");
      if (res && res.data) {
        setCampaigns(res.data.incentives || []);
        setKpis(res.data.kpis || {});
      }
    } catch (err) {
      console.error("Failed to load incentives:", err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchCampaigns();
  }, [fetchCampaigns]);

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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Incentives & Schemes</h1>
          <p className="text-sm font-medium text-slate-500">
            Create performance milestones, peak hour bonuses, and weekend rush schemes for delivery riders.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <button
            onClick={fetchCampaigns}
            disabled={loading}
            className="flex items-center px-3.5 py-2.5 bg-white border border-slate-200 text-slate-600 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm disabled:opacity-50"
            title="Refresh Campaigns"
          >
            <RefreshCw className={`w-4 h-4 mr-1.5 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </button>
          <button
            onClick={() => setIsCreateModalOpen(true)}
            className="flex items-center px-4 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm"
          >
            <Plus className="w-4 h-4 mr-2" />
            New Campaign
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <IncentivesKPIs kpis={kpis} onCardClick={handleCardClick} />

      {/* Campaign Grid */}
      <IncentivesGrid
        items={campaigns}
        onGridClick={handleGridClick}
        onNewCampaign={() => setIsCreateModalOpen(true)}
      />

      {/* Campaign Details / List Modal */}
      <IncentivesListModal 
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        filterType={filterType}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
        items={campaigns}
        onCampaignUpdated={fetchCampaigns}
      />

      {/* Create Campaign Modal */}
      <CreateIncentiveModal
        isOpen={isCreateModalOpen}
        onClose={() => setIsCreateModalOpen(false)}
        onCreated={fetchCampaigns}
      />
    </div>
  );
}
