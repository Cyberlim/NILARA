"use client";

import { useState, useEffect } from "react";
import { Download, Plus } from "lucide-react";
import CustomersKPIs from "@/components/customers/CustomersKPIs";
import CustomersTable from "@/components/customers/CustomersTable";
import CustomersListModal from "@/components/customers/CustomersListModal";
import CustomerFormModal from "@/components/customers/CustomerFormModal";
import { useAuth } from "@/context/AuthContext";
export default function CustomersPage() {
  const [modalFilter, setModalFilter] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("detail");
  const [selectedItem, setSelectedItem] = useState(null);

  const [localItems, setLocalItems] = useState([]);

  const { token } = useAuth();

  useEffect(() => {
    if (!token) return;
    
    // Fetch real customers from Node.js backend
    fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:5000/api/v1'}/admin/customers`, {
      headers: { 'Authorization': `Bearer ${token}` }
    })
    .then(res => res.json())
    .then(data => {
      if (data.success) {
        setLocalItems(data.data);
      }
    })
    .catch(err => console.error("Failed to fetch customers", err));
  }, [token]);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [itemToEdit, setItemToEdit] = useState(null);

  const handleExport = () => alert("Export clicked");
  
  const handleAddCustomer = () => {
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

  const handleSaveItem = (savedItem) => {
    setLocalItems(prev => {
      const exists = prev.find(i => i.id === savedItem.id);
      if (exists) {
        return prev.map(i => i.id === savedItem.id ? savedItem : i);
      }
      return [savedItem, ...prev];
    });
  };

  const handleToggleSuspend = (item) => {
    setLocalItems(prev => prev.map(i => {
      if (i.id === item.id) {
        if (i.status === "Suspended") {
          return { ...i, status: "Active", statusColor: "teal" };
        } else {
          return { ...i, status: "Suspended", statusColor: "red" };
        }
      }
      return i;
    }));
  };

  const handleRowClick = (item) => {
    setSelectedItem(item);
    setModalMode("detail");
    setIsModalOpen(true);
  };

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Customers</h1>
          <p className="text-sm font-medium text-slate-500">Manage your customers, view their order history and wallets</p>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={handleExport}
            className="flex items-center px-4 py-2.5 bg-white text-slate-600 border border-slate-200 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm"
          >
            <Download className="w-4 h-4 mr-2" />
            Export
          </button>

        </div>
      </div>

      {/* KPI Cards */}
      <CustomersKPIs 
        modalFilter={modalFilter}
        setModalFilter={setModalFilter}
        setIsModalOpen={setIsModalOpen}
        setModalMode={setModalMode}
      />

      {/* Table */}
      <CustomersTable 
        localItems={localItems}
        onRowClick={handleRowClick} 
        onEditClick={handleEditClick}
        onDeleteClick={handleDeleteClick}
        onToggleSuspend={handleToggleSuspend}
      />

      {/* List / Detail Modal */}
      <CustomersListModal
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setSelectedItem(null); setModalFilter(null); }}
        filterType={modalFilter}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
        setModalMode={setModalMode}
        onEditClick={handleEditClick}
        onToggleSuspend={(item) => {
          handleToggleSuspend(item);
          // Also update the selected item in the modal so it reflects immediately
          setSelectedItem(prev => {
            if (!prev) return prev;
            if (prev.status === "Suspended") {
              return { ...prev, status: "Active", statusColor: "teal" };
            } else {
              return { ...prev, status: "Suspended", statusColor: "red" };
            }
          });
        }}
      />

      {/* Form Modal */}
      <CustomerFormModal
        isOpen={isFormOpen}
        onClose={() => setIsFormOpen(false)}
        itemToEdit={itemToEdit}
        onSave={handleSaveItem}
      />
    </div>
  );
}


