"use client";

import { useState } from "react";
import { Search, ExternalLink, Download } from "lucide-react";

export default function EarningsTable({ items, onRowClick }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [statusFilter, setStatusFilter] = useState("All");

  const filtered = items.filter(item => {
    if (statusFilter !== "All" && item.status !== statusFilter) return false;
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      if (!item.riderName.toLowerCase().includes(q)) return false;
    }
    return true;
  });

  return (
    <div className="bg-white rounded-3xl border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] flex flex-col mb-6">
      
      {/* Search and Filters */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between p-4 sm:p-6 border-b border-slate-50 gap-4">
        <div className="flex items-center gap-2 w-full lg:w-auto">
          <div className="relative flex-1 min-w-[140px] lg:w-[280px]">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search earnings..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all placeholder:text-slate-400 truncate"
            />
          </div>
          <select 
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
            className="px-3 py-2 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-600 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all cursor-pointer flex-shrink-0"
          >
            <option value="All">All Status</option>
            <option value="Credited">Credited</option>
            <option value="Pending">Pending</option>
          </select>
        </div>
        <button className="flex items-center justify-center px-4 py-2 bg-white text-slate-600 border border-slate-200 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors w-full lg:w-auto">
          <Download className="w-4 h-4 mr-2" />
          Download Statement
        </button>
      </div>

      {/* Desktop Table */}
      <div className="hidden xl:block overflow-x-auto min-h-[400px]">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-100">
              <th className="pb-3 pt-4 px-4 pl-6 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Rider</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-center">Trips</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">Distance Pay</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">Trip Pay</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">Tips</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">Total Earnings</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Status</th>
              <th className="pb-3 pt-4 px-4 pr-6 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {filtered.length === 0 ? (
              <tr><td colSpan={8} className="py-16 text-center text-slate-400 font-medium text-sm">No earnings found</td></tr>
            ) : filtered.map((item) => (
              <tr key={item.id} onClick={() => onRowClick && onRowClick(item)} className="cursor-pointer border-b border-slate-50 hover:bg-slate-50/80 transition-colors group">
                <td className="py-4 px-4 pl-6">
                  <p className="text-sm font-bold text-slate-800">{item.riderName}</p>
                  <p className="text-[10px] text-slate-400">{item.date}</p>
                </td>
                <td className="py-4 px-4 text-center">
                  <span className="text-sm font-bold text-slate-800 bg-slate-100 px-3 py-1 rounded-full">{item.trips}</span>
                </td>
                <td className="py-4 px-4 text-right">
                  <p className="text-sm font-medium text-slate-700">₹{item.distancePay}</p>
                </td>
                <td className="py-4 px-4 text-right">
                  <p className="text-sm font-medium text-slate-700">₹{item.tripPay}</p>
                </td>
                <td className="py-4 px-4 text-right">
                  <p className="text-sm font-medium text-green-600">+₹{item.tips}</p>
                </td>
                <td className="py-4 px-4 text-right">
                  <p className="text-sm font-black text-slate-800">₹{item.total}</p>
                </td>
                <td className="py-4 px-4">
                  <span className={`inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 border border-${item.statusColor}-100/50`}>
                    {item.status}
                  </span>
                </td>
                <td className="py-4 px-4 pr-6 text-right">
                  <button className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-slate-100 text-slate-400 hover:text-teal-600 transition-colors ml-auto">
                    <ExternalLink className="w-4 h-4" />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Mobile Card View */}
      <div className="xl:hidden p-4 space-y-3">
        {filtered.length === 0 ? (
          <div className="py-10 text-center text-slate-400 font-medium text-sm">No earnings found</div>
        ) : filtered.map((item) => (
          <div key={item.id} onClick={() => onRowClick && onRowClick(item)} className="cursor-pointer bg-white rounded-2xl p-4 border border-slate-100 hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-3">
              <div>
                <p className="text-sm font-bold text-slate-800">{item.riderName}</p>
                <p className="text-[10px] text-slate-400 mt-0.5">{item.date}</p>
              </div>
              <span className={`inline-flex items-center px-2 py-1 rounded-full text-[9px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700`}>
                {item.status}
              </span>
            </div>
            
            <div className="grid grid-cols-2 gap-2 mt-3 pt-3 border-t border-slate-50">
              <div className="bg-slate-50 p-2 rounded-xl">
                <p className="text-[9px] font-bold text-slate-400 uppercase mb-0.5">Trips</p>
                <p className="text-xs font-black text-slate-800">{item.trips}</p>
              </div>
              <div className="bg-slate-50 p-2 rounded-xl text-right">
                <p className="text-[9px] font-bold text-slate-400 uppercase mb-0.5">Total</p>
                <p className="text-xs font-black text-slate-800">₹{item.total}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

    </div>
  );
}
