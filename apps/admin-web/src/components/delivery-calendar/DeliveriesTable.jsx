"use client";

import { useState } from "react";
import { 
  Search, ChevronLeft, ChevronRight, ExternalLink
} from "lucide-react";

const PAGE_SIZE = 10;

export default function DeliveriesTable({ localItems, onRowClick, timeSlots = [] }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [dateFilter, setDateFilter] = useState("Today");
  const [statusFilter, setStatusFilter] = useState("All");
  const [timeFilter, setTimeFilter] = useState("All");

  const uniqueTimeSlots = ["All", ...timeSlots];

  const filtered = localItems.filter(item => {
    if (dateFilter !== "All" && item.date !== dateFilter) return false;
    if (statusFilter !== "All" && item.status !== statusFilter) return false;
    if (timeFilter !== "All" && item.timeWindow !== timeFilter) return false;

    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      if (!item.customerName.toLowerCase().includes(q) && 
          !item.route.toLowerCase().includes(q) && 
          !item.driver.toLowerCase().includes(q)) return false;
    }
    return true;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  return (
    <div className="bg-white rounded-3xl border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] flex flex-col mb-6">
      
      {/* Search and Filters Row */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-start p-4 sm:p-6 border-b border-slate-50 gap-4">
        <div className="flex items-center gap-3 w-full lg:w-auto overflow-x-auto hide-scrollbar pb-1 lg:pb-0">
          <div className="relative min-w-[240px] flex-1 lg:flex-none">
            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search driver, route, customer..."
              value={searchQuery}
              onChange={(e) => { setSearchQuery(e.target.value); setCurrentPage(1); }}
              className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all placeholder:text-slate-400"
            />
          </div>
          
          <select 
            value={dateFilter}
            onChange={(e) => { setDateFilter(e.target.value); setCurrentPage(1); }}
            className="px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-600 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all cursor-pointer"
          >
            <option value="All">All Dates</option>
            <option value="Today">Today</option>
            <option value="Tomorrow">Tomorrow</option>
          </select>

          <select 
            value={statusFilter}
            onChange={(e) => { setStatusFilter(e.target.value); setCurrentPage(1); }}
            className="px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-600 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all cursor-pointer"
          >
            <option value="All">All Status</option>
            <option value="Pending">Pending</option>
            <option value="Completed">Completed</option>
            <option value="Exception">Exception</option>
            <option value="Scheduled">Scheduled</option>
          </select>
          
          <select 
            value={timeFilter}
            onChange={(e) => { setTimeFilter(e.target.value); setCurrentPage(1); }}
            className="px-4 py-2.5 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-600 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all cursor-pointer"
          >
            {uniqueTimeSlots.map(slot => (
              <option key={slot} value={slot}>{slot === "All" ? "All Time Slots" : slot}</option>
            ))}
          </select>
        </div>
      </div>

      {/* Desktop Table */}
      <div className="hidden xl:block overflow-x-auto min-h-[400px]">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-100">
              <th className="pb-3 pt-4 px-4 pl-6 text-[10px] font-bold text-slate-400 uppercase tracking-wider w-auto">Route & Time</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Driver</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Customer & Delivery</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-center">Items</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Status</th>
              <th className="pb-3 pt-4 px-4 pr-6 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">Details</th>
            </tr>
          </thead>
          <tbody>
            {paginated.length === 0 ? (
              <tr><td colSpan={6} className="py-16 text-center text-slate-400 font-medium text-sm">No deliveries found</td></tr>
            ) : paginated.map((item) => (
              <tr key={item.id} 
                  onClick={() => onRowClick && onRowClick(item)}
                  className="border-b border-slate-50 hover:bg-slate-50/80 transition-colors group cursor-pointer"
              >
                <td className="py-4 px-4 pl-6">
                  <p className="text-sm font-black text-slate-800">{item.route}</p>
                  <p className="text-[10px] font-bold text-slate-500 mt-0.5">{item.date} • {item.timeWindow}</p>
                </td>
                <td className="py-4 px-4">
                  <div className="flex items-center gap-2">
                    <div className="w-7 h-7 rounded-full bg-slate-100 flex items-center justify-center text-[10px] font-bold text-slate-500">
                      {item.driver.charAt(0)}
                    </div>
                    <p className="text-sm font-bold text-slate-700">{item.driver}</p>
                  </div>
                </td>
                <td className="py-4 px-4">
                  <p className="text-sm font-bold text-slate-800">{item.customerName}</p>
                  <p className="text-[10px] text-slate-500 mt-0.5 truncate max-w-[200px]">{item.address}</p>
                </td>
                <td className="py-4 px-4 text-center">
                  <span className="inline-flex px-2 py-1 rounded bg-slate-100 text-slate-700 text-[10px] font-bold">
                    {item.items}
                  </span>
                </td>
                <td className="py-4 px-4">
                  <span className={`inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 border border-${item.statusColor}-100/50`}>
                    {item.status}
                  </span>
                  {item.notes && <p className="text-[10px] text-red-500 font-medium mt-1 w-32 truncate">{item.notes}</p>}
                </td>
                <td className="py-4 px-4 pr-6 text-right">
                  <button className="w-8 h-8 inline-flex items-center justify-center rounded-lg hover:bg-teal-50 text-slate-400 hover:text-teal-600 transition-colors">
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
        {paginated.length === 0 ? (
          <div className="py-10 text-center text-slate-400 font-medium text-sm">No deliveries found</div>
        ) : paginated.map((item) => (
          <div key={item.id} 
               onClick={() => onRowClick && onRowClick(item)}
               className="bg-white rounded-2xl p-4 border transition-shadow cursor-pointer border-slate-100 hover:shadow-md"
          >
            <div className="flex justify-between items-start mb-3">
              <div>
                <span className={`inline-flex px-2 py-0.5 rounded-md text-[9px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 mb-1.5`}>
                  {item.status}
                </span>
                <h4 className="text-sm font-black text-slate-800">{item.customerName}</h4>
              </div>
              <div className="text-right">
                <p className="text-[10px] font-black text-slate-800">{item.route}</p>
                <p className="text-[9px] font-bold text-slate-400 mt-0.5">{item.timeWindow}</p>
              </div>
            </div>
            
            <p className="text-[11px] text-slate-500 mb-3 truncate">{item.address}</p>

            <div className="grid grid-cols-2 gap-2 mt-3 pt-3 border-t border-slate-50">
              <div className="bg-slate-50 p-2 rounded-xl flex items-center">
                <div className="w-6 h-6 rounded-full bg-white flex items-center justify-center text-[10px] font-bold text-slate-500 mr-2 shadow-sm">
                  {item.driver.charAt(0)}
                </div>
                <div>
                  <p className="text-[9px] font-bold text-slate-400 uppercase">Driver</p>
                  <p className="text-xs font-bold text-slate-700">{item.driver}</p>
                </div>
              </div>
              <div className="bg-slate-50 p-2 rounded-xl">
                <p className="text-[9px] font-bold text-slate-400 uppercase mb-0.5">Items</p>
                <p className="text-xs font-bold text-slate-700 truncate">{item.items}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="px-4 sm:px-6 py-4 border-t border-slate-50 flex items-center justify-between bg-slate-50/50 rounded-b-3xl">
          <p className="text-xs font-medium text-slate-500">
            Showing <span className="font-bold text-slate-700">{((currentPage - 1) * PAGE_SIZE) + 1}</span> to <span className="font-bold text-slate-700">{Math.min(currentPage * PAGE_SIZE, filtered.length)}</span> of <span className="font-bold text-slate-700">{filtered.length}</span> entries
          </p>
          <div className="flex items-center gap-2">
            <button 
              onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
              disabled={currentPage === 1}
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <div className="flex items-center gap-1">
              {[...Array(totalPages)].map((_, i) => (
                <button
                  key={i}
                  onClick={() => setCurrentPage(i + 1)}
                  className={`w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold transition-colors ${
                    currentPage === i + 1 
                      ? "bg-teal-600 text-white border-transparent" 
                      : "border border-slate-200 text-slate-600 hover:bg-slate-50"
                  }`}
                >
                  {i + 1}
                </button>
              ))}
            </div>
            <button 
              onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
              disabled={currentPage === totalPages}
              className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
