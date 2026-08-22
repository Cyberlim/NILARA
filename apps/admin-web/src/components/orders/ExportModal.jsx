"use client";

import { useState, useEffect } from "react";
import { X, FileText, FileSpreadsheet, Download, Calendar, CheckCircle2 } from "lucide-react";

export default function ExportModal({ isOpen, onClose }) {
  const [dateRange, setDateRange] = useState("Last 7 Days");
  const [status, setStatus] = useState("All");
  const [format, setFormat] = useState("CSV");
  const [isExporting, setIsExporting] = useState(false);

  // Prevent scrolling on body when modal is open
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  const handleExport = () => {
    setIsExporting(true);
    // Simulate network delay for export generation
    setTimeout(() => {
      setIsExporting(false);
      alert(`Successfully generated ${format} export for ${status} orders (${dateRange}).\nDownloading now...`);
      onClose();
    }, 1500);
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      ></div>

      {/* Modal Container */}
      <div className="relative w-full max-w-md bg-white/90 backdrop-blur-xl rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <div>
            <h2 className="text-lg font-black text-slate-800 tracking-tight">Export Orders</h2>
            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mt-0.5">Generate customized reports</p>
          </div>
          <button 
            onClick={onClose}
            className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-100 hover:bg-slate-200 text-slate-500 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto custom-scrollbar space-y-6">
          
          {/* Date Range Selection */}
          <div>
            <h3 className="text-xs font-bold text-slate-700 uppercase tracking-widest mb-3 flex items-center">
              <Calendar className="w-3.5 h-3.5 mr-1.5 text-slate-400" />
              Date Range
            </h3>
            <div className="grid grid-cols-2 gap-2">
              {["Today", "Last 7 Days", "This Month", "All Time"].map((range) => (
                <button
                  key={range}
                  onClick={() => setDateRange(range)}
                  className={`px-3 py-2 rounded-xl text-sm font-bold border transition-colors ${
                    dateRange === range 
                      ? "bg-teal-50 border-teal-200 text-teal-700" 
                      : "bg-white border-slate-200 text-slate-600 hover:bg-slate-50"
                  }`}
                >
                  {range}
                </button>
              ))}
            </div>
          </div>

          {/* Status Selection */}
          <div>
            <h3 className="text-xs font-bold text-slate-700 uppercase tracking-widest mb-3 flex items-center">
              <CheckCircle2 className="w-3.5 h-3.5 mr-1.5 text-slate-400" />
              Order Status
            </h3>
            <select
              value={status}
              onChange={(e) => setStatus(e.target.value)}
              className="w-full px-4 py-2.5 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 text-sm font-bold text-slate-700 appearance-none cursor-pointer shadow-sm"
            >
              <option value="All">All Orders</option>
              <option value="Delivered">Delivered</option>
              <option value="Cancelled">Cancelled</option>
              <option value="Refunded">Refunded</option>
              <option value="Processing">Processing</option>
              <option value="Pending">Pending</option>
            </select>
          </div>

          {/* Format Selection */}
          <div>
            <h3 className="text-xs font-bold text-slate-700 uppercase tracking-widest mb-3">Export Format</h3>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setFormat("CSV")}
                className={`flex items-center justify-center px-4 py-3 rounded-xl border transition-all ${
                  format === "CSV" 
                    ? "bg-teal-50 border-teal-200 text-teal-700 shadow-sm" 
                    : "bg-white border-slate-200 text-slate-500 hover:bg-slate-50"
                }`}
              >
                <FileSpreadsheet className={`w-5 h-5 mr-2 ${format === "CSV" ? "text-teal-600" : "text-slate-400"}`} />
                <span className="font-black">CSV</span>
              </button>
              <button
                onClick={() => setFormat("PDF")}
                className={`flex items-center justify-center px-4 py-3 rounded-xl border transition-all ${
                  format === "PDF" 
                    ? "bg-rose-50 border-rose-200 text-rose-700 shadow-sm" 
                    : "bg-white border-slate-200 text-slate-500 hover:bg-slate-50"
                }`}
              >
                <FileText className={`w-5 h-5 mr-2 ${format === "PDF" ? "text-rose-600" : "text-slate-400"}`} />
                <span className="font-black">PDF</span>
              </button>
            </div>
          </div>

        </div>

        {/* Footer Actions */}
        <div className="px-6 py-4 border-t border-slate-100 bg-slate-50/50 flex justify-end gap-3">
          <button 
            onClick={onClose}
            className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-200 bg-slate-100 transition-colors"
          >
            Cancel
          </button>
          <button 
            onClick={handleExport}
            disabled={isExporting}
            className="px-5 py-2.5 rounded-xl text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 transition-colors shadow-sm flex items-center disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {isExporting ? (
              <span className="flex items-center">
                <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Generating...
              </span>
            ) : (
              <>
                <Download className="w-4 h-4 mr-2" />
                Download {format}
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
