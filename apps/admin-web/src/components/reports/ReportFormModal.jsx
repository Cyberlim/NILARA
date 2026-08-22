"use client";

import { useState, useEffect } from "react";
import { X, Save, FileText } from "lucide-react";

export default function ReportFormModal({ isOpen, onClose }) {
  const [formData, setFormData] = useState({
    name: "",
    category: "Sales",
    format: "PDF",
    dateRange: "Last 30 Days",
  });
  
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      setFormData({
        name: "",
        category: "Sales",
        format: "PDF",
        dateRange: "Last 30 Days",
      });
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(p => ({ ...p, [name]: value }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log("Generating report:", formData);
    onClose();
  };

  return (
    <div className="fixed inset-0 z-[110] flex items-center justify-center p-4 sm:p-6">
      <div 
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      ></div>

      <div className="relative w-full max-w-xl max-h-[90vh] bg-white rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white">
          <div>
            <h2 className="text-xl font-black text-slate-800 tracking-tight">Generate New Report</h2>
            <p className="text-xs font-medium text-slate-500 mt-0.5">Configure report parameters</p>
          </div>
          <button 
            onClick={onClose}
            className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          <form id="reportForm" onSubmit={handleSubmit} className="space-y-6">
            
            <div className="bg-white p-5 rounded-2xl border border-slate-100 shadow-sm space-y-4">
              <h4 className="text-sm font-bold text-slate-800 border-b border-slate-50 pb-2 mb-4">Report Details</h4>
              
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="col-span-1 sm:col-span-2">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Report Name *</label>
                  <input required name="name" value={formData.name} onChange={handleChange} type="text" placeholder="e.g. Q3 Sales Summary" className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800" />
                </div>

                <div className="col-span-1">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Category</label>
                  <select 
                    name="category" 
                    value={formData.category} 
                    onChange={handleChange} 
                    className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800 cursor-pointer"
                  >
                    <option value="Sales">Sales</option>
                    <option value="Operations">Operations</option>
                    <option value="Marketing">Marketing</option>
                    <option value="Finance">Finance</option>
                  </select>
                </div>

                <div className="col-span-1">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Date Range</label>
                  <select 
                    name="dateRange" 
                    value={formData.dateRange} 
                    onChange={handleChange} 
                    className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-800 cursor-pointer"
                  >
                    <option value="Today">Today</option>
                    <option value="Last 7 Days">Last 7 Days</option>
                    <option value="Last 30 Days">Last 30 Days</option>
                    <option value="This Month">This Month</option>
                    <option value="Last Month">Last Month</option>
                    <option value="This Year">This Year</option>
                    <option value="Custom">Custom Range</option>
                  </select>
                </div>

                <div className="col-span-1 sm:col-span-2">
                  <label className="text-xs font-bold text-slate-700 uppercase tracking-wider mb-2 block">Export Format</label>
                  <div className="flex bg-slate-50 p-1 border border-slate-200 rounded-xl w-full">
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, format: "PDF" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.format === "PDF" ? "bg-white text-teal-700 shadow-sm border border-teal-100" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      PDF
                    </button>
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, format: "Excel" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.format === "Excel" ? "bg-white text-green-700 shadow-sm border border-green-100" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      Excel (XLSX)
                    </button>
                    <button 
                      type="button"
                      onClick={() => setFormData(p => ({ ...p, format: "CSV" }))}
                      className={`flex-1 py-1.5 rounded-lg text-xs font-bold transition-all ${formData.format === "CSV" ? "bg-white text-slate-700 shadow-sm border border-slate-200" : "text-slate-500 hover:text-slate-700"}`}
                    >
                      CSV
                    </button>
                  </div>
                </div>
              </div>
            </div>

          </form>
        </div>
        
        {/* Footer */}
        <div className="px-6 py-4 border-t border-slate-100 bg-white flex justify-end space-x-3 items-center">
          <button 
            type="button"
            onClick={onClose}
            className="px-5 py-2.5 bg-white text-slate-600 border border-slate-200 hover:bg-slate-50 rounded-xl text-sm font-bold transition-colors"
          >
            Cancel
          </button>
          <button 
            type="submit"
            form="reportForm"
            className="px-6 py-2.5 bg-teal-500 text-white hover:bg-teal-600 rounded-xl text-sm font-bold transition-colors shadow-sm flex items-center"
          >
            <FileText className="w-4 h-4 mr-2" />
            Generate Report
          </button>
        </div>

      </div>
    </div>
  );
}
