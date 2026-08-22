"use client";

import { useState } from "react";
import AssignmentsKPIs from "@/components/assignments/AssignmentsKPIs";
import AssignmentsTable from "@/components/assignments/AssignmentsTable";
import AssignmentsListModal from "@/components/assignments/AssignmentsListModal";

export default function AssignmentsPage() {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("list"); // 'list' | 'direct_detail'
  const [filterType, setFilterType] = useState("total_assignments");
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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Assignments</h1>
          <p className="text-sm font-medium text-slate-500">View and manage how orders are dispatched to riders.</p>
        </div>
      </div>

      {/* KPI Cards */}
      <AssignmentsKPIs onCardClick={handleCardClick} />

      {/* Table */}
      <AssignmentsTable items={[]} onRowClick={handleRowClick} />

      {/* Modal */}
      <AssignmentsListModal 
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
