"use client";

import { useState, useRef, useEffect } from "react";
import { Search, Filter, Pencil, ChevronLeft, ChevronRight, Trash2, ListFilter } from "lucide-react";

const PAGE_SIZE = 8;
const STATUSES = ["Active", "Inactive", "Low Stock"];
const PRODUCT_RANGES = ["0-50", "51-150", "150+"];

export default function CategoriesTable({ onRowClick, onEditClick }) {
  const [localCategories, setLocalCategories] = useState([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [activeDropdown, setActiveDropdown] = useState(null);
  const [selectedStatuses, setSelectedStatuses] = useState([]);
  const [selectedRanges, setSelectedRanges] = useState([]);
  const filterRef = useRef(null);
  const moreRef = useRef(null);

  useEffect(() => {
    const handler = (e) => {
      if (activeDropdown === "filter" && filterRef.current && !filterRef.current.contains(e.target)) {
        setActiveDropdown(null);
      }
      if (activeDropdown === "more" && moreRef.current && !moreRef.current.contains(e.target)) {
        setActiveDropdown(null);
      }
    };
    document.addEventListener("mousedown", handler);
    document.addEventListener("touchstart", handler);
    return () => {
      document.removeEventListener("mousedown", handler);
      document.removeEventListener("touchstart", handler);
    };
  }, [activeDropdown]);

  const toggleFilter = (arr, setArr, val) => {
    setArr(prev => prev.includes(val) ? prev.filter(x => x !== val) : [...prev, val]);
    setCurrentPage(1);
  };

  const handleDelete = (id) => {
    setLocalCategories(prev => prev.filter(c => c.id !== id));
  };

  const filtered = localCategories.filter(c => {
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      if (!c.name.toLowerCase().includes(q) && !c.description.toLowerCase().includes(q)) return false;
    }
    if (selectedStatuses.length > 0 && !selectedStatuses.includes(c.status)) return false;
    if (selectedRanges.length > 0) {
      const p = c.products;
      const matchesRange = selectedRanges.some(range => {
        if (range === "0-50" && p >= 0 && p <= 50) return true;
        if (range === "51-150" && p >= 51 && p <= 150) return true;
        if (range === "150+" && p > 150) return true;
        return false;
      });
      if (!matchesRange) return false;
    }
    return true;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  const hasActiveFilters = selectedStatuses.length > 0 || selectedRanges.length > 0;

  return (
    <div className="bg-white/80 backdrop-blur-xl rounded-3xl border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)]">
      
      {/* Search + Filters */}
      <div className="flex flex-col sm:flex-row gap-3 p-4 sm:p-6 border-b border-slate-50 items-center justify-start">
        <div className="relative w-full sm:w-[320px]">
          <Search className="w-4 h-4 absolute left-4 top-1/2 -translate-y-1/2 text-slate-400" />
          <input
            type="text"
            value={searchQuery}
            onChange={e => { setSearchQuery(e.target.value); setCurrentPage(1); }}
            placeholder="Search category..."
            className="w-full pl-11 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all"
          />
        </div>
        <div className="flex gap-2 flex-wrap">
          <div className="relative" ref={filterRef}>
            <button
              onClick={() => setActiveDropdown(activeDropdown === "filter" ? null : "filter")}
              className={`flex items-center px-4 py-2.5 rounded-xl border text-sm font-semibold transition-all ${
                selectedStatuses.length > 0 ? "bg-teal-50 text-teal-700 border-teal-200" : "bg-white text-slate-600 border-slate-200 hover:border-teal-300"
              }`}
            >
              <Filter className="w-4 h-4 mr-2" />
              Filter {selectedStatuses.length > 0 && `(${selectedStatuses.length})`}
            </button>
            {activeDropdown === "filter" && (
              <div className="absolute top-full left-0 mt-2 w-56 bg-white rounded-2xl shadow-[0_10px_40px_rgb(0,0,0,0.12)] border border-slate-100 p-3 z-30 animate-in fade-in slide-in-from-top-2">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider px-2 mb-2">Status</p>
                {STATUSES.map(s => (
                  <div key={s} onClick={() => toggleFilter(selectedStatuses, setSelectedStatuses, s)}
                    className="flex items-center px-3 py-2.5 hover:bg-slate-50 rounded-xl cursor-pointer transition-colors">
                    <div className={`w-4 h-4 rounded border-2 mr-3 flex items-center justify-center transition-all ${selectedStatuses.includes(s) ? "bg-teal-500 border-teal-500" : "border-slate-300"}`}>
                      {selectedStatuses.includes(s) && <span className="text-white text-[10px]">✓</span>}
                    </div>
                    <span className="text-sm font-semibold text-slate-700">{s}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
          
          <div className="relative" ref={moreRef}>
            <button
              onClick={() => setActiveDropdown(activeDropdown === "more" ? null : "more")}
              className={`flex items-center px-4 py-2.5 rounded-xl border text-sm font-semibold transition-all ${
                selectedRanges.length > 0 ? "bg-teal-50 text-teal-700 border-teal-200" : "bg-white text-slate-600 border-slate-200 hover:border-teal-300"
              }`}
            >
              <ListFilter className="w-4 h-4 mr-2" />
              Products {selectedRanges.length > 0 && `(${selectedRanges.length})`}
            </button>
            {activeDropdown === "more" && (
              <div className="absolute top-full left-0 mt-2 w-56 bg-white rounded-2xl shadow-[0_10px_40px_rgb(0,0,0,0.12)] border border-slate-100 p-3 z-30 animate-in fade-in slide-in-from-top-2">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider px-2 mb-2">Product Count</p>
                {PRODUCT_RANGES.map(r => (
                  <div key={r} onClick={() => toggleFilter(selectedRanges, setSelectedRanges, r)}
                    className="flex items-center px-3 py-2.5 hover:bg-slate-50 rounded-xl cursor-pointer transition-colors">
                    <div className={`w-4 h-4 rounded border-2 mr-3 flex items-center justify-center transition-all ${selectedRanges.includes(r) ? "bg-teal-500 border-teal-500" : "border-slate-300"}`}>
                      {selectedRanges.includes(r) && <span className="text-white text-[10px]">✓</span>}
                    </div>
                    <span className="text-sm font-semibold text-slate-700">{r} items</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Active filter chips */}
      {hasActiveFilters && (
        <div className="flex flex-wrap gap-2 px-6 pb-3 pt-1">
          {[...selectedStatuses.map(x => ({ label: x, type: "status" })), ...selectedRanges.map(x => ({ label: `${x} items`, val: x, type: "range" }))].map((chip, i) => (
            <span key={i} className="inline-flex items-center bg-teal-50 text-teal-700 border border-teal-100 rounded-full px-3 py-1 text-xs font-bold gap-1">
              {chip.label}
              <button onClick={() => {
                if (chip.type === "status") setSelectedStatuses(p => p.filter(x => x !== chip.label));
                if (chip.type === "range") setSelectedRanges(p => p.filter(x => x !== chip.val));
              }} className="ml-1 text-teal-500 hover:text-teal-800">✕</button>
            </span>
          ))}
          <button onClick={() => { setSelectedStatuses([]); setSelectedRanges([]); }} className="text-xs font-bold text-slate-400 hover:text-red-500 transition-colors">Clear all</button>
        </div>
      )}

      {/* Desktop Table */}
      <div className="hidden lg:block overflow-x-auto custom-scrollbar min-h-[400px]">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-100">
              <th className="pb-3 pt-2 px-6 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Category</th>
              <th className="pb-3 pt-2 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Description</th>
              <th className="pb-3 pt-2 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-center">Subcategories</th>
              <th className="pb-3 pt-2 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-center">Products</th>
              <th className="pb-3 pt-2 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Inventory Value</th>
              <th className="pb-3 pt-2 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Status</th>
              <th className="pb-3 pt-2 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Added On</th>
              <th className="pb-3 pt-2 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody>
            {paginated.length === 0 ? (
              <tr><td colSpan={8} className="py-16 text-center text-slate-400 font-medium text-sm">No categories found</td></tr>
            ) : paginated.map((c, idx) => (
              <tr key={idx} 
                  onClick={() => onRowClick && onRowClick(c)}
                  className="border-b border-slate-50 last:border-0 hover:bg-slate-50/50 transition-colors group cursor-pointer"
              >
                <td className="py-4 px-6">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-xl flex-shrink-0">{c.image}</div>
                    <span className="text-sm font-bold text-slate-800">{c.name}</span>
                  </div>
                </td>
                <td className="py-4 px-4">
                  <p className="text-xs text-slate-500 w-48 leading-relaxed">{c.description}</p>
                </td>
                <td className="py-4 px-4 text-center">
                  <div className="flex flex-col items-center justify-center">
                    <span className="text-sm font-bold text-teal-700">{c.subcategories}</span>
                    <button onClick={e => e.stopPropagation()} className="text-[10px] font-bold text-teal-500 hover:text-teal-600">View</button>
                  </div>
                </td>
                <td className="py-4 px-4 text-center">
                  <div className="flex flex-col items-center justify-center">
                    <span className="text-sm font-bold text-teal-700">{c.products}</span>
                    <button onClick={e => e.stopPropagation()} className="text-[10px] font-bold text-teal-500 hover:text-teal-600">View</button>
                  </div>
                </td>
                <td className="py-4 px-4">
                  <span className="text-sm font-bold text-slate-800">₹{c.value}</span>
                </td>
                <td className="py-4 px-4">
                  <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${c.statusColor}-50 text-${c.statusColor}-700 border border-${c.statusColor}-100/50`}>
                    <span className={`w-1.5 h-1.5 rounded-full bg-${c.statusColor}-500 mr-1.5`}></span>
                    {c.status}
                  </span>
                </td>
                <td className="py-4 px-4">
                  <div>
                    <p className="text-xs font-semibold text-slate-600">{c.addedDate}</p>
                    <p className="text-[10px] text-slate-400 mt-0.5">{c.addedTime}</p>
                  </div>
                </td>
                <td className="py-4 px-4" onClick={e => e.stopPropagation()}>
                  <div className="flex items-center gap-1">
                    <button 
                      onClick={() => onEditClick && onEditClick(c)}
                      className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-slate-100 text-slate-500 hover:text-teal-600 transition-colors"
                    >
                      <Pencil className="w-3.5 h-3.5" />
                    </button>
                    <button 
                      onClick={() => handleDelete(c.id)}
                      className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-red-50 text-slate-500 hover:text-red-600 transition-colors"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* ─── Mobile Card View ─── */}
      <div className="lg:hidden p-4 space-y-3">
        {paginated.length === 0 ? (
          <div className="py-10 text-center text-slate-400 font-medium text-sm">No categories found</div>
        ) : paginated.map((c, idx) => (
          <div key={idx} 
               onClick={() => onRowClick && onRowClick(c)}
               className="bg-slate-50 rounded-2xl p-4 border border-slate-100 hover:shadow-md transition-shadow cursor-pointer"
          >
            <div className="flex items-start gap-3 mb-3">
              <div className="w-12 h-12 rounded-xl bg-white border border-slate-100 flex items-center justify-center text-2xl flex-shrink-0">{c.image}</div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-bold text-slate-800 leading-tight truncate">{c.name}</p>
                <p className="text-[11px] text-slate-500 mt-1 line-clamp-2">{c.description}</p>
              </div>
              <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-${c.statusColor}-50 text-${c.statusColor}-700 border border-${c.statusColor}-100/50 flex-shrink-0`}>
                <span className={`w-1 h-1 rounded-full bg-${c.statusColor}-500 mr-1`}></span>
                {c.status}
              </span>
            </div>
            <div className="grid grid-cols-3 gap-2 pt-3 border-t border-slate-100">
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Subcategories</p>
                <p className="text-sm font-black text-slate-800 mt-0.5">{c.subcategories}</p>
              </div>
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Products</p>
                <p className="text-sm font-black text-slate-800 mt-0.5">{c.products}</p>
              </div>
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Inv. Value</p>
                <p className="text-sm font-black text-green-600 mt-0.5">₹{c.value}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Pagination */}
      <div className="flex flex-col sm:flex-row items-center justify-between px-6 py-4 border-t border-slate-100 gap-3">
        <p className="text-xs font-medium text-slate-500">
          Showing {filtered.length === 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1} to {Math.min(currentPage * PAGE_SIZE, filtered.length)} of {filtered.length} categories
        </p>
        <div className="flex items-center gap-1">
          <button onClick={() => setCurrentPage(p => Math.max(1, p - 1))} disabled={currentPage === 1}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
            <ChevronLeft className="w-4 h-4" />
          </button>
          {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
            const page = i + 1;
            return (
              <button
                key={page}
                onClick={() => setCurrentPage(page)}
                className={`w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold transition-all ${
                  currentPage === page
                    ? "bg-teal-600 text-white shadow-sm border border-teal-500"
                    : "text-slate-600 hover:bg-slate-50 border border-transparent"
                }`}
              >
                {page}
              </button>
            );
          })}
          <button onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))} disabled={currentPage === totalPages || totalPages === 0}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
