"use client";

import { useState, useRef, useEffect } from "react";
import { 
  Search, Filter, Grid, Trash2, Pencil, 
  ChevronLeft, ChevronRight, SlidersHorizontal 
} from "lucide-react";

const CATEGORIES = ["Water Jars", "Water Bottles", "Accessories", "Glass Bottles", "Filters"];
const PAGE_SIZE = 8;

export default function InventoryTable({ localItems, onRowClick, onEditClick, onDeleteClick }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  
  const [activeDropdown, setActiveDropdown] = useState(null);
  const [selectedCategories, setSelectedCategories] = useState([]);

  const catRef = useRef(null);

  useEffect(() => {
    const handler = (e) => {
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

  const toggleCategory = (val) => {
    setSelectedCategories(prev => prev.includes(val) ? prev.filter(x => x !== val) : [...prev, val]);
    setCurrentPage(1);
  };

  const filtered = localItems.filter(item => {
    // Search
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      if (!item.name.toLowerCase().includes(q) && !item.sku.toLowerCase().includes(q)) return false;
    }

    // Category filter
    if (selectedCategories.length > 0 && !selectedCategories.includes(item.category)) return false;

    return true;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  return (
    <div className="bg-white rounded-3xl border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] flex flex-col mb-6">
      
      {/* Tabs and Actions Row */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-start p-4 sm:p-6 border-b border-slate-50 gap-4">

        {/* Search & Filters */}
        <div className="flex items-center gap-3 w-full lg:w-auto overflow-x-auto hide-scrollbar pb-1 lg:pb-0">
          <div className="relative min-w-[240px] flex-1 lg:flex-none">
            <Search className="w-4 h-4 absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={e => { setSearchQuery(e.target.value); setCurrentPage(1); }}
              placeholder="Search by product name, SKU..."
              className="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all font-medium text-slate-700"
            />
          </div>
          
          <button className="flex items-center px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-slate-600 text-sm font-bold hover:bg-slate-50 transition-colors whitespace-nowrap">
            <Filter className="w-4 h-4 mr-2" />
            Filter
          </button>
          
          <div className="relative" ref={catRef}>
            <button 
              onClick={() => setActiveDropdown(activeDropdown === "category" ? null : "category")}
              className={`flex items-center px-4 py-2.5 rounded-xl border text-sm font-bold transition-all whitespace-nowrap ${
                selectedCategories.length > 0 ? "bg-teal-50 text-teal-700 border-teal-200" : "bg-white text-slate-600 border-slate-200 hover:bg-slate-50"
              }`}
            >
              <Grid className="w-4 h-4 mr-2" />
              Category {selectedCategories.length > 0 && `(${selectedCategories.length})`}
            </button>
            {activeDropdown === "category" && (
              <div className="absolute top-full right-0 mt-2 w-48 bg-white rounded-2xl shadow-[0_10px_40px_rgb(0,0,0,0.12)] border border-slate-100 p-3 z-30 animate-in fade-in slide-in-from-top-2">
                {CATEGORIES.map(c => (
                  <div key={c} onClick={() => toggleCategory(c)}
                    className="flex items-center px-3 py-2.5 hover:bg-slate-50 rounded-xl cursor-pointer transition-colors">
                    <div className={`w-4 h-4 rounded border-2 mr-3 flex items-center justify-center transition-all ${selectedCategories.includes(c) ? "bg-teal-500 border-teal-500" : "border-slate-300"}`}>
                      {selectedCategories.includes(c) && <span className="text-white text-[10px]">✓</span>}
                    </div>
                    <span className="text-sm font-bold text-slate-700">{c}</span>
                  </div>
                ))}
              </div>
            )}
          </div>

          <button className="flex items-center px-4 py-2.5 rounded-xl border border-slate-200 bg-white text-slate-600 text-sm font-bold hover:bg-slate-50 transition-colors whitespace-nowrap">
            <SlidersHorizontal className="w-4 h-4 mr-2" />
            More Filters
          </button>
        </div>
      </div>

      {/* Desktop Table */}
      <div className="hidden xl:block overflow-x-auto min-h-[400px]">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-100">
              <th className="pb-3 pt-4 px-4 pl-6 text-[10px] font-bold text-slate-400 uppercase tracking-wider w-auto">Product</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">SKU</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Category</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Stock</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Status</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Unit Price</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Inventory Value</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Expiry Date</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Updated</th>
              <th className="pb-3 pt-4 px-4 pr-6 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {paginated.length === 0 ? (
              <tr><td colSpan={10} className="py-16 text-center text-slate-400 font-medium text-sm">No inventory items found</td></tr>
            ) : paginated.map((item) => (
              <tr key={item.id} 
                  onClick={() => onRowClick && onRowClick(item)}
                  className="border-b border-slate-50 hover:bg-slate-50/80 transition-colors group cursor-pointer"
              >
                <td className="py-4 px-4 pl-6">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-xl flex-shrink-0">                    {item.image ? (
                      <img src={item.image} alt={item.name} className="w-full h-full object-cover rounded-xl" />
                    ) : (
                      <span className="text-xl">📦</span>
                    )}</div>
                    <div>
                      <p className="text-sm font-bold text-slate-800 leading-tight">{item.name}</p>
                      <p className="text-[11px] text-slate-400 mt-0.5">{item.variant}</p>
                    </div>
                  </div>
                </td>
                <td className="py-4 px-4">
                  <span className="text-xs font-bold text-slate-500 font-mono">{item.sku}</span>
                </td>
                <td className="py-4 px-4">
                  <span className={`inline-flex items-center gap-1.5 text-xs font-bold text-slate-700`}>
                    <span className={`w-1.5 h-1.5 rounded-full bg-${item.categoryColor}-500`}></span>
                    {item.category}
                  </span>
                </td>
                <td className="py-4 px-4">
                  <div>
                    <span className="text-sm font-black text-slate-800">{item.stock.toLocaleString('en-IN')}</span>
                    <p className={`text-[10px] font-bold mt-0.5 ${
                      item.stockStatus === "In Stock" ? "text-green-600" : 
                      item.stockStatus === "Out of Stock" ? "text-red-500" : "text-orange-500"
                    }`}>{item.stockStatus}</p>
                  </div>
                </td>
                <td className="py-4 px-4">
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[10px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-600`}>
                    <span className={`w-1.5 h-1.5 rounded-full bg-${item.statusColor}-500 mr-1.5`}></span>
                    {item.status}
                  </span>
                </td>
                <td className="py-4 px-4">
                  <span className="text-sm font-bold text-slate-800">₹{item.unitPrice}</span>
                </td>
                <td className="py-4 px-4">
                  <span className="text-sm font-bold text-slate-800">₹{item.inventoryValue}</span>
                </td>
                <td className="py-4 px-4">
                  {item.expiryDate !== "-" ? (
                    <div>
                      <span className="text-xs font-bold text-slate-700">{item.expiryDate}</span>
                      <p className="text-[10px] font-bold text-orange-500 mt-0.5">{item.expiryDaysLeft} days left</p>
                    </div>
                  ) : (
                    <span className="text-slate-300 font-bold">-</span>
                  )}
                </td>
                <td className="py-4 px-4">
                  <div>
                    <p className="text-xs font-bold text-slate-600">{item.updatedDate}</p>
                    <p className="text-[10px] font-medium text-slate-400 mt-0.5">{item.updatedTime}</p>
                  </div>
                </td>
                <td className="py-4 px-4 pr-6 text-right" onClick={e => e.stopPropagation()}>
                  <div className="flex items-center justify-end gap-1">
                    <button onClick={() => onEditClick && onEditClick(item)} className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-slate-100 text-slate-400 hover:text-teal-600 transition-colors">
                      <Pencil className="w-3.5 h-3.5" />
                    </button>
                    <button onClick={() => onDeleteClick && onDeleteClick(item.id)} className="w-8 h-8 flex items-center justify-center rounded-lg hover:bg-red-50 text-slate-400 hover:text-red-500 transition-colors">
                      <Trash2 className="w-4 h-4" />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Mobile Card View (for smaller screens) */}
      <div className="xl:hidden p-4 space-y-3">
        {paginated.length === 0 ? (
          <div className="py-10 text-center text-slate-400 font-medium text-sm">No items found</div>
        ) : paginated.map((item) => (
          <div key={item.id} 
               onClick={() => onRowClick && onRowClick(item)}
               className="bg-white rounded-2xl p-4 border transition-shadow cursor-pointer border-slate-100 hover:shadow-md"
          >
            <div className="flex items-start gap-3 mb-3 relative">
              <div className="w-12 h-12 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-2xl flex-shrink-0">                    {item.image ? (
                      <img src={item.image} alt={item.name} className="w-full h-full object-cover rounded-xl" />
                    ) : (
                      <span className="text-xl">📦</span>
                    )}</div>
              <div className="flex-1 min-w-0 pr-6">
                <p className="text-sm font-bold text-slate-800 leading-tight truncate">{item.name}</p>
                <p className="text-[11px] text-slate-500 mt-1">{item.sku}</p>
              </div>
              <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-600 absolute right-0 top-0`}>
                <span className={`w-1.5 h-1.5 rounded-full bg-${item.statusColor}-500 mr-1`}></span>
                {item.status}
              </span>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2 pt-3 border-t border-slate-50">
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Stock</p>
                <p className="text-sm font-black text-slate-800 mt-0.5">{item.stock}</p>
              </div>
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Value</p>
                <p className="text-sm font-black text-slate-800 mt-0.5">₹{item.inventoryValue}</p>
              </div>
              <div className="col-span-2">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Expiry</p>
                <p className="text-sm font-bold text-slate-800 mt-0.5">{item.expiryDate !== "-" ? `${item.expiryDate} (${item.expiryDaysLeft}d)` : "-"}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Pagination */}
      <div className="flex flex-col sm:flex-row items-center justify-between px-6 py-4 border-t border-slate-50 gap-3">
        <p className="text-xs font-medium text-slate-500">
          Showing {filtered.length === 0 ? 0 : (currentPage - 1) * PAGE_SIZE + 1} to {Math.min(currentPage * PAGE_SIZE, filtered.length)} of {filtered.length} inventory items
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
