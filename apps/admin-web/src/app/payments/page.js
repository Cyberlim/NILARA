"use client";

import { useState, useEffect } from "react";
import PaymentsKPIs from "@/components/payments/PaymentsKPIs";
import PaymentsTable from "@/components/payments/PaymentsTable";
import PaymentsListModal from "@/components/payments/PaymentsListModal";
import { fetchWithAuth } from "@/lib/api";

export default function PaymentsPage() {
  const [activeFilter, setActiveFilter] = useState("total_revenue");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedItem, setSelectedItem] = useState(null);
  const [modalMode, setModalMode] = useState("list");
  const [items, setItems] = useState([]);
  const [kpi, setKpi] = useState({ totalRevenue: 0, pending: 0, paid: 0, failed: 0 });
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function load() {
      try {
        const res = await fetchWithAuth('/admin/payments');
        if (res.success) {
          setItems(res.data.items);
          setKpi(res.data.kpi);
        }
      } catch (err) {
        console.error("Failed to load payments", err);
      } finally {
        setIsLoading(false);
      }
    }
    load();
  }, []);

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Payments</h1>
          <p className="text-sm font-medium text-slate-500">Track all incoming payments and transaction statuses.</p>
        </div>
      </div>

      {/* KPI Cards */}
      <PaymentsKPIs
        kpiData={kpi}
        activeFilter={activeFilter}
        setActiveFilter={setActiveFilter}
        setIsModalOpen={setIsModalOpen}
        setModalMode={setModalMode}
      />

      {/* Table */}
      {isLoading ? (
        <div className="py-20 text-center text-slate-500 font-medium">Loading payments...</div>
      ) : (
        <PaymentsTable
          items={items}
          setSelectedItem={setSelectedItem}
          setIsModalOpen={setIsModalOpen}
          setModalMode={setModalMode}
        />
      )}

      <PaymentsListModal
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setSelectedItem(null); }}
        filterType={activeFilter}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
        items={items}
      />
    </div>
  );
}
