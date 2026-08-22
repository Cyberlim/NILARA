"use client";

import { Download, Plus } from "lucide-react";
import { useState } from "react";
import ExportModal from "./ExportModal";

export default function OrdersHeader() {
  const [isExportOpen, setIsExportOpen] = useState(false);

  return (
    <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center mb-6 gap-4">
      <div>
        <h1 className="text-2xl font-black text-slate-800 tracking-tight">Orders</h1>
        <p className="text-sm font-medium text-slate-500 mt-1">Manage and track all customer orders</p>
      </div>
      
      <div className="flex items-center space-x-3 w-full sm:w-auto">
        <button 
          onClick={() => setIsExportOpen(true)}
          className="flex-1 sm:flex-none flex items-center justify-center px-6 py-2.5 bg-teal-600 text-white border border-transparent rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm"
        >
          <Download className="w-4 h-4 mr-2" />
          Export
        </button>
      </div>

      <ExportModal isOpen={isExportOpen} onClose={() => setIsExportOpen(false)} />
    </div>
  );
}
