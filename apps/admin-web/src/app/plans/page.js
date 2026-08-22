"use client";

import { useState } from "react";
import { Plus } from "lucide-react";
import PlansKPIs from "@/components/plans/PlansKPIs";
import PlansGrid from "@/components/plans/PlansGrid";
import PlanFormModal from "@/components/plans/PlanFormModal";
import PlanListModal from "@/components/plans/PlanListModal";

export default function PlansPage() {
  const [modalFilter, setModalFilter] = useState(null);
  const [isListModalOpen, setIsListModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list");
  const [selectedItem, setSelectedItem] = useState(null);
  
  const [localItems, setLocalItems] = useState([]);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [itemToEdit, setItemToEdit] = useState(null);
  
  const handleAddPlan = () => {
    setItemToEdit(null);
    setIsFormOpen(true);
  };

  const handleEditClick = (item) => {
    setItemToEdit(item);
    setIsFormOpen(true);
  };

  const handleDeleteClick = (itemId) => {
    setLocalItems(prev => prev.filter(i => i.id !== itemId));
  };

  const handleToggleStatus = (item) => {
    setLocalItems(prev => prev.map(i => {
      if (i.id === item.id) {
        if (i.status === "Active") {
          return { ...i, status: "Inactive", statusColor: "slate" };
        } else {
          return { ...i, status: "Active", statusColor: "teal" };
        }
      }
      return i;
    }));
  };

  const handleCardClick = (item) => {
    setSelectedItem(item);
    setModalMode("detail");
    setIsListModalOpen(true);
  };

  const handleSaveItem = (savedItem) => {
    setLocalItems(prev => {
      const exists = prev.find(i => i.id === savedItem.id);
      if (exists) {
        return prev.map(i => i.id === savedItem.id ? savedItem : i);
      }
      return [savedItem, ...prev];
    });
  };

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Subscription Plans</h1>
          <p className="text-sm font-medium text-slate-500">Create and manage pricing plans for your customers</p>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={handleAddPlan}
            className="flex items-center px-4 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm"
          >
            <Plus className="w-4 h-4 mr-2" />
            Create New Plan
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <PlansKPIs 
        modalFilter={modalFilter}
        setModalFilter={setModalFilter}
        setIsListModalOpen={setIsListModalOpen}
        setModalMode={setModalMode}
      />

      {/* Grid of Plans */}
      <PlansGrid 
        localItems={localItems}
        onEditClick={handleEditClick}
        onDeleteClick={handleDeleteClick}
        onToggleStatus={handleToggleStatus}
        onCardClick={handleCardClick}
        filterType={null} 
      />

      {/* Form Modal */}
      <PlanFormModal
        isOpen={isFormOpen}
        onClose={() => setIsFormOpen(false)}
        itemToEdit={itemToEdit}
        onSave={handleSaveItem}
      />

      {/* List / Detail Modal */}
      <PlanListModal
        isOpen={isListModalOpen}
        onClose={() => { setIsListModalOpen(false); setSelectedItem(null); setModalFilter(null); }}
        filterType={modalFilter}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
        setModalMode={setModalMode}
        onEditClick={handleEditClick}
        onDeleteClick={(id) => {
          handleDeleteClick(id);
          setIsListModalOpen(false);
          setSelectedItem(null);
        }}
      />
    </div>
  );
}
