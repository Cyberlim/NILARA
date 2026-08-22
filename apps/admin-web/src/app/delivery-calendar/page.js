"use client";

import { useState } from "react";
import { Download, Calendar as CalendarIcon } from "lucide-react";
import CalendarKPIs from "@/components/delivery-calendar/CalendarKPIs";
import DeliveriesTable from "@/components/delivery-calendar/DeliveriesTable";
import DeliveryDetailModal from "@/components/delivery-calendar/DeliveryDetailModal";
import FullCalendarModal from "@/components/delivery-calendar/FullCalendarModal";

export default function DeliveryCalendarPage() {
  const [modalFilter, setModalFilter] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("detail");
  const [selectedItem, setSelectedItem] = useState(null);
  const [isCalendarOpen, setIsCalendarOpen] = useState(false);

  const handleExport = () => {
    // Generate simple CSV
    const headers = ["ID,Date,Time Window,Customer,Phone,Address,Items,Driver,Route,Status"];
    const rows = [].map(item => 
      `${item.id},"${item.date}","${item.timeWindow}","${item.customerName}","${item.phone}","${item.address}","${item.items}","${item.driver}","${item.route}","${item.status}"`
    );
    const csvContent = "data:text/csv;charset=utf-8," + headers.concat(rows).join("\n");
    
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement("a");
    link.setAttribute("href", encodedUri);
    link.setAttribute("download", "delivery_schedule.csv");
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
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
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Delivery Calendar</h1>
          <p className="text-sm font-medium text-slate-500">Track and manage daily delivery schedules</p>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={handleExport}
            className="flex items-center px-4 py-2.5 bg-white text-slate-600 border border-slate-200 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm"
          >
            <Download className="w-4 h-4 mr-2" />
            Export Schedule
          </button>
          <button 
            onClick={() => setIsCalendarOpen(true)}
            className="flex items-center px-4 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm"
          >
            <CalendarIcon className="w-4 h-4 mr-2" />
            View Full Calendar
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <CalendarKPIs 
        modalFilter={modalFilter}
        setModalFilter={setModalFilter}
        setIsModalOpen={setIsModalOpen}
        setModalMode={setModalMode}
      />

      {/* Table */}
      <DeliveriesTable 
        localItems={[]}
        onRowClick={handleRowClick} 
      />

      {/* List / Detail Modal */}
      <DeliveryDetailModal
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setSelectedItem(null); setModalFilter(null); }}
        filterType={modalFilter}
        selectedItem={selectedItem}
        setSelectedItem={setSelectedItem}
        modalMode={modalMode}
        setModalMode={setModalMode}
      />

      {/* Full Calendar Modal */}
      <FullCalendarModal 
        isOpen={isCalendarOpen} 
        onClose={() => setIsCalendarOpen(false)} 
      />
    </div>
  );
}
