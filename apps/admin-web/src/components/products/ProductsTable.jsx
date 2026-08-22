"use client";

import { useState, useEffect, useRef } from "react";
import { Search, Filter, Grid, MoreVertical, Pencil, ChevronLeft, ChevronRight, Trash2, Loader2 } from "lucide-react";
import { fetchWithAuth } from "@/lib/api";

const STATUS_COLORS = {
  "Active": "green",
  "Inactive": "red",
};

const STOCK_COLORS = {
  "In Stock": "green",
  "Low Stock": "orange",
  "Out of Stock": "red",
};

const CATEGORIES = ["Water Jars", "Bottles", "Combos", "Accessories"];
const STATUSES = ["Active", "Inactive"];
const STOCK_STATUSES = ["In Stock", "Low Stock", "Out of Stock"];
const PAGE_SIZE = 8;

export default function ProductsTable({ products = [], onRowClick, onEditClick, onRefresh }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [activeDropdown, setActiveDropdown] = useState(null);
  const [selectedCategories, setSelectedCategories] = useState([]);
  const [selectedStatuses, setSelectedStatuses] = useState([]);
  const [selectedStockStatuses, setSelectedStockStatuses] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [isDeleting, setIsDeleting] = useState(null);
  const filterRef = useRef(null);
  const catRef = useRef(null);

  useEffect(() => {
    const handler = (e) => {
      if (activeDropdown === "filter" && filterRef.current && !filterRef.current.contains(e.target)) {
        setActiveDropdown(null);
      }
      if (activeDropdown === "category" && catRef.current && !catRef.current.contains(e.target)) {
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

  // Removed activeTab sync logic

  const toggleFilter = (arr, setArr, val) => {
    setArr(prev => prev.includes(val) ? prev.filter(x => x !== val) : [...prev, val]);
    setCurrentPage(1);
  };

  const handleDelete = async (id, e) => {
    e.stopPropagation();
    if (!confirm("Are you sure you want to delete this product?")) return;
    try {
      setIsDeleting(id);
      await fetchWithAuth(`/products/${id}`, { method: 'DELETE' });
      if (onRefresh) onRefresh();
    } catch (err) {
      alert(err.message || "Failed to delete product");
    } finally {
      setIsDeleting(null);
    }
  };

  const filtered = products.filter(p => {
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      if (!p.name.toLowerCase().includes(q) && !p.sku.toLowerCase().includes(q) && !p.category.toLowerCase().includes(q)) return false;
    }
    if (selectedCategories.length > 0 && !selectedCategories.includes(p.category)) return false;
    if (selectedStatuses.length > 0 && !selectedStatuses.includes(p.status)) return false;
    if (selectedStockStatuses.length > 0 && !selectedStockStatuses.includes(p.stockStatus)) return false;
    return true;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  const hasActiveFilters = selectedCategories.length > 0 || selectedStatuses.length > 0 || selectedStockStatuses.length > 0;

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
            placeholder="Search by product name, SKU..."
            className="w-full pl-11 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all"
          />
        </div>
        <div className="flex gap-2 flex-wrap">
          {/* Filter button */}
          <div className="relative" ref={filterRef}>
            <button
              onClick={() => setActiveDropdown(activeDropdown === "filter" ? null : "filter")}
              className={`flex items-center px-4 py-2.5 rounded-xl border text-sm font-semibold transition-all ${
                hasActiveFilters ? "bg-teal-50 text-teal-700 border-teal-200" : "bg-white text-slate-600 border-slate-200 hover:border-teal-300"
              }`}
            >
              <Filter className="w-4 h-4 mr-2" />
              Filter {hasActiveFilters && `(${selectedCategories.length + selectedStatuses.length + selectedStockStatuses.length})`}
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
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider px-2 mb-2 mt-3">Stock</p>
                {STOCK_STATUSES.map(s => (
                  <div key={s} onClick={() => toggleFilter(selectedStockStatuses, setSelectedStockStatuses, s)}
                    className="flex items-center px-3 py-2.5 hover:bg-slate-50 rounded-xl cursor-pointer transition-colors">
                    <div className={`w-4 h-4 rounded border-2 mr-3 flex items-center justify-center transition-all ${selectedStockStatuses.includes(s) ? "bg-teal-500 border-teal-500" : "border-slate-300"}`}>
                      {selectedStockStatuses.includes(s) && <span className="text-white text-[10px]">✓</span>}
                    </div>
                    <span className="text-sm font-semibold text-slate-700">{s}</span>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Category */}
          <div className="relative" ref={catRef}>
            <button
              onClick={() => setActiveDropdown(activeDropdown === "category" ? null : "category")}
              className={`flex items-center px-4 py-2.5 rounded-xl border text-sm font-semibold transition-all ${
                selectedCategories.length > 0 ? "bg-teal-50 text-teal-700 border-teal-200" : "bg-white text-slate-600 border-slate-200 hover:border-teal-300"
              }`}
            >
              <Grid className="w-4 h-4 mr-2" />
              Category {selectedCategories.length > 0 && `(${selectedCategories.length})`}
            </button>
            {activeDropdown === "category" && (
              <div className="absolute top-full left-0 mt-2 w-48 bg-white rounded-2xl shadow-[0_10px_40px_rgb(0,0,0,0.12)] border border-slate-100 p-3 z-30 animate-in fade-in slide-in-from-top-2">
                {CATEGORIES.map(c => (
                  <div key={c} onClick={() => toggleFilter(selectedCategories, setSelectedCategories, c)}
                    className="flex items-center px-3 py-2.5 hover:bg-slate-50 rounded-xl cursor-pointer transition-colors">
                    <div className={`w-4 h-4 rounded border-2 mr-3 flex items-center justify-center transition-all ${selectedCategories.includes(c) ? "bg-teal-500 border-teal-500" : "border-slate-300"}`}>
                      {selectedCategories.includes(c) && <span className="text-white text-[10px]">✓</span>}
                    </div>
                    <span className="text-sm font-semibold text-slate-700">{c}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Active filter chips */}
      {hasActiveFilters && (
        <div className="flex flex-wrap gap-2 px-6 pb-3">
          {[...selectedCategories.map(x => ({ label: x, type: "cat" })), ...selectedStatuses.map(x => ({ label: x, type: "status" })), ...selectedStockStatuses.map(x => ({ label: x, type: "stock" }))].map((chip, i) => (
            <span key={i} className="inline-flex items-center bg-teal-50 text-teal-700 border border-teal-100 rounded-full px-3 py-1 text-xs font-bold gap-1">
              {chip.label}
              <button onClick={() => {
                if (chip.type === "cat") setSelectedCategories(p => p.filter(x => x !== chip.label));
                if (chip.type === "status") setSelectedStatuses(p => p.filter(x => x !== chip.label));
                if (chip.type === "stock") setSelectedStockStatuses(p => p.filter(x => x !== chip.label));
              }} className="ml-1 text-teal-500 hover:text-teal-800">✕</button>
            </span>
          ))}
          <button onClick={() => { setSelectedCategories([]); setSelectedStatuses([]); setSelectedStockStatuses([]); }} className="text-xs font-bold text-slate-400 hover:text-red-500 transition-colors">Clear all</button>
        </div>
      )}

      {/* ─── Desktop Table ─── */}
      <div className="hidden sm:block overflow-x-auto">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-100">
              <th className="pb-3 pt-2 px-4 text-xs font-medium text-slate-400 uppercase tracking-wider">Product</th>
              <th className="pb-3 pt-2 px-4 text-xs font-medium text-slate-400 uppercase tracking-wider">SKU</th>
              <th className="pb-3 pt-2 px-4 text-xs font-medium text-slate-400 uppercase tracking-wider">Category</th>
              <th className="pb-3 pt-2 px-4 text-xs font-medium text-slate-400 uppercase tracking-wider">Price</th>
              <th className="pb-3 pt-2 px-4 text-xs font-medium text-slate-400 uppercase tracking-wider">Stock</th>
              <th className="pb-3 pt-2 px-4 text-xs font-medium text-slate-400 uppercase tracking-wider">Status</th>
              <th className="pb-3 pt-2 px-4 text-xs font-medium text-slate-400 uppercase tracking-wider">Sales</th>
              <th className="pb-3 pt-2 px-4 text-xs font-medium text-slate-400 uppercase tracking-wider">Updated</th>
              <th className="pb-3 pt-2 px-4 text-xs font-medium text-slate-400 uppercase tracking-wider">Actions</th>
            </tr>
          </thead>
          <tbody>
            {paginated.length === 0 ? (
              <tr><td colSpan={9} className="py-16 text-center text-slate-400 font-medium text-sm">No products found</td></tr>
            ) : paginated.map((p, idx) => {
              const stockColor = STOCK_COLORS[p.stockStatus] || "slate";
              const statusColor = STATUS_COLORS[p.status] || "slate";
              return (
                <tr key={idx} 
                    onClick={() => onRowClick && onRowClick(p)}
                    className="border-b border-slate-50 last:border-0 hover:bg-slate-50/50 transition-colors group cursor-pointer"
                >
                  <td className="py-4 px-4">
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-xl flex-shrink-0">                      {p.image ? (
                        <img src={p.image} alt={p.name} className="w-full h-full object-cover rounded-xl" />
                      ) : (
                        <span className="text-xl">📦</span>
                      )}</div>
                      <div>
                        <p className="text-sm font-bold text-slate-800 leading-tight">{p.name}</p>
                        <p className="text-xs text-slate-400 mt-0.5">{p.variant}</p>
                      </div>
                    </div>
                  </td>
                  <td className="py-4 px-4 text-xs font-mono font-semibold text-slate-500">{p.sku}</td>
                  <td className="py-4 px-4">
                    <span className={`inline-flex items-center gap-1 text-xs font-bold text-${p.categoryColor}-700`}>
                      <span className={`w-1.5 h-1.5 rounded-full bg-${p.categoryColor}-500`}></span>
                      {p.category}
                    </span>
                  </td>
                  <td className="py-4 px-4">
                    <div>
                      <span className="text-sm font-bold text-slate-800">₹{p.price}</span>
                      {p.mrp && <span className="text-xs text-slate-400 line-through ml-1.5">₹{p.mrp}</span>}
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <div>
                      <span className="text-sm font-bold text-slate-800">{p.stock.toLocaleString()}</span>
                      <p className={`text-[10px] font-bold mt-0.5 text-${stockColor}-600`}>{p.stockStatus}</p>
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${statusColor}-50 text-${statusColor}-700 border border-${statusColor}-100/50`}>
                      <span className={`w-1.5 h-1.5 rounded-full bg-${statusColor}-500 mr-1.5`}></span>
                      {p.status}
                    </span>
                  </td>
                  <td className="py-4 px-4">
                    <div>
                      <span className="text-sm font-bold text-slate-800">{p.sales.toLocaleString()}</span>
                      <p className="text-[10px] text-slate-400 mt-0.5">units</p>
                    </div>
                  </td>
                  <td className="py-4 px-4">
                    <div>
                      <p className="text-xs font-semibold text-slate-600">{p.updatedDate}</p>
                      <p className="text-[10px] text-slate-400 mt-0.5">{p.updatedTime}</p>
                    </div>
                  </td>
                  <td className="py-4 px-4" onClick={e => e.stopPropagation()}>
                    <div className="flex items-center gap-1 transition-opacity">
                      <button 
                        onClick={() => onEditClick && onEditClick(p)}
                        className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-slate-100 text-slate-500 hover:text-teal-600 transition-colors"
                      >
                        <Pencil className="w-3.5 h-3.5" />
                      </button>
                      <button 
                        onClick={(e) => handleDelete(p.id, e)}
                        disabled={isDeleting === p.id}
                        className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-red-50 text-slate-500 hover:text-red-600 transition-colors disabled:opacity-50"
                      >
                        {isDeleting === p.id ? <Loader2 className="w-3.5 h-3.5 animate-spin" /> : <Trash2 className="w-3.5 h-3.5" />}
                      </button>
                    </div>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>

      {/* ─── Mobile Card View ─── */}
      <div className="sm:hidden p-4 space-y-3">
        {paginated.length === 0 ? (
          <div className="py-10 text-center text-slate-400 font-medium text-sm">No products found</div>
        ) : paginated.map((p, idx) => {
          const stockColor = STOCK_COLORS[p.stockStatus] || "slate";
          const statusColor = STATUS_COLORS[p.status] || "slate";
          return (
            <div key={idx} 
                 onClick={() => onRowClick && onRowClick(p)}
                 className="bg-slate-50 rounded-2xl p-4 border border-slate-100 hover:shadow-md transition-shadow cursor-pointer"
            >
              <div className="flex items-start gap-3 mb-3">
                <div className="w-10 h-10 rounded-xl bg-white border border-slate-100 flex items-center justify-center text-xl flex-shrink-0">                      {p.image ? (
                        <img src={p.image} alt={p.name} className="w-full h-full object-cover rounded-xl" />
                      ) : (
                        <span className="text-xl">📦</span>
                      )}</div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold text-slate-800 leading-tight truncate">{p.name}</p>
                  <p className="text-xs text-slate-400 mt-0.5">{p.variant}</p>
                </div>
                <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${statusColor}-50 text-${statusColor}-700 border border-${statusColor}-100/50 flex-shrink-0`}>
                  <span className={`w-1.5 h-1.5 rounded-full bg-${statusColor}-500 mr-1`}></span>
                  {p.status}
                </span>
              </div>
              <div className="grid grid-cols-3 gap-2 pt-2 border-t border-slate-100">
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Price</p>
                  <p className="text-sm font-black text-slate-800 mt-0.5">₹{p.price}</p>
                  {p.mrp && <p className="text-[10px] text-slate-400 line-through">₹{p.mrp}</p>}
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Stock</p>
                  <p className="text-sm font-bold text-slate-800 mt-0.5">{p.stock}</p>
                  <p className={`text-[10px] font-bold text-${stockColor}-600`}>{p.stockStatus}</p>
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Category</p>
                  <p className={`text-xs font-bold text-${p.categoryColor}-700 mt-0.5`}>{p.category}</p>
                  <p className="text-[10px] text-slate-400 font-mono">{p.sku}</p>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Pagination */}
      <div className="flex flex-col sm:flex-row items-center justify-between px-6 py-4 border-t border-slate-100 gap-3">
        <p className="text-xs font-medium text-slate-500">
          Showing {filtered.length === 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1} to {Math.min(currentPage * PAGE_SIZE, filtered.length)} of {filtered.length} products
        </p>
        <div className="flex items-center gap-1">
          <button onClick={() => setCurrentPage(p => Math.max(1, p - 1))} disabled={currentPage === 1}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
            <ChevronLeft className="w-4 h-4" />
          </button>
          {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
            const page = i + 1;
            return (
              <button key={page} onClick={() => setCurrentPage(page)}
                className={`w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold transition-colors ${
                  currentPage === page ? "bg-teal-500 text-white shadow-sm" : "border border-slate-200 text-slate-600 hover:bg-slate-50"
                }`}>
                {page}
              </button>
            );
          })}
          {totalPages > 5 && <span className="text-slate-400 text-sm px-1">...</span>}
          {totalPages > 5 && (
            <button onClick={() => setCurrentPage(totalPages)}
              className={`w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors`}>
              {totalPages}
            </button>
          )}
          <button onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))} disabled={currentPage === totalPages || totalPages === 0}
            className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 disabled:opacity-40 disabled:cursor-not-allowed transition-colors">
            <ChevronRight className="w-4 h-4" />
          </button>
        </div>
      </div>
    </div>
  );
}
