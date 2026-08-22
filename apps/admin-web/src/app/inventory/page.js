"use client";

import { Upload, Download, Plus } from "lucide-react";
import InventoryKPIs from "@/components/inventory/InventoryKPIs";
import InventoryTable from "@/components/inventory/InventoryTable";
import InventorySummary from "@/components/inventory/InventorySummary";
import InventoryListModal from "@/components/inventory/InventoryListModal";
import InventoryFormModal from "@/components/inventory/InventoryFormModal";
import { useState, useEffect } from "react";
import { fetchWithAuth } from "@/lib/api";

export default function InventoryPage() {
  const [modalFilter, setModalFilter] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("detail");
  const [selectedItem, setSelectedItem] = useState(null);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [itemToEdit, setItemToEdit] = useState(null);
  const [items, setItems] = useState([]);
  const [kpi, setKpi] = useState({ total: 0, inStock: 0, lowStock: 0, outOfStock: 0 });
  const [isLoading, setIsLoading] = useState(true);

  const fetchInventory = async () => {
    try {
      setIsLoading(true);
      const res = await fetchWithAuth('/admin/inventory');
      if (res.success) {
        setItems(res.data.items);
        setKpi(res.data.kpi);
      }
    } catch (err) {
      console.error("Failed to load inventory", err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => { fetchInventory(); }, []);

  const handleImport = () => alert("Import Stock — coming soon");
  const handleExport = () => alert("Export — coming soon");
  const handleAdjust = () => { setItemToEdit(null); setIsFormOpen(true); };
  const handleEditClick = (item) => { setItemToEdit(item); setIsFormOpen(true); };
  const handleRowClick = (item) => { setSelectedItem(item); setModalMode("detail"); setIsModalOpen(true); };

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Inventory</h1>
          <p className="text-sm font-medium text-slate-500">Track stock levels, manage inventory and avoid stockouts</p>
        </div>
        <div className="flex items-center gap-3">
          <button onClick={handleImport} className="flex items-center px-4 py-2.5 bg-white text-slate-600 border border-slate-200 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm">
            <Upload className="w-4 h-4 mr-2" /> Import Stock
          </button>
          <button onClick={handleExport} className="flex items-center px-4 py-2.5 bg-white text-slate-600 border border-slate-200 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm">
            <Download className="w-4 h-4 mr-2" /> Export
          </button>
          <button onClick={handleAdjust} className="flex items-center px-4 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm">
            <Plus className="w-4 h-4 mr-2" /> Adjust Stock
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <InventoryKPIs
        kpiData={kpi}
        modalFilter={modalFilter}
        setModalFilter={setModalFilter}
        setIsModalOpen={setIsModalOpen}
        setModalMode={setModalMode}
      />

      {/* Table */}
      {isLoading ? (
        <div className="py-20 text-center text-slate-500 font-medium">Loading inventory...</div>
      ) : (
        <InventoryTable
          localItems={items}
          onRowClick={handleRowClick}
          onEditClick={handleEditClick}
          onDeleteClick={() => {}}
        />
      )}

      {/* Bottom Summary */}
      <InventorySummary items={items} />

      {/* List / Detail Modal */}
      <InventoryListModal
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setSelectedItem(null); setModalFilter(null); }}
        filterType={modalFilter}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
        setModalMode={setModalMode}
        onEditClick={handleEditClick}
        items={items}
      />

      {/* Form Modal */}
      <InventoryFormModal
        isOpen={isFormOpen}
        onClose={() => setIsFormOpen(false)}
        itemToEdit={itemToEdit}
        onSave={() => { setIsFormOpen(false); fetchInventory(); }}
      />
    </div>
  );
}
