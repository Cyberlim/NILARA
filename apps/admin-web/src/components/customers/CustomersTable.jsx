"use client";

import { useState } from "react";
import { 
  Search, Ban, Undo2, 
  ChevronLeft, ChevronRight, Crown
} from "lucide-react";

const PAGE_SIZE = 8;

export default function CustomersTable({ localItems, onRowClick, onEditClick, onDeleteClick, onToggleSuspend }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const [statusFilter, setStatusFilter] = useState("All");

  const filtered = localItems.filter(item => {
    if (statusFilter !== "All" && item.status !== statusFilter) return false;

    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      if (!item.name.toLowerCase().includes(q) && 
          !item.phone.includes(q) && 
          !item.email.toLowerCase().includes(q)) return false;
    }
    return true;
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paginated = filtered.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  return (
    <div className="bg-white rounded-3xl border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] flex flex-col mb-6">
      
      {/* Search and Filters Row */}
      <div className="flex flex-col lg:flex-row lg:items-center justify-between p-4 sm:p-6 border-b border-slate-50 gap-4">
        
        <div className="flex items-center gap-2 w-full lg:w-auto">
          <div className="relative flex-1 min-w-[140px] lg:w-[280px]">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search customers..."
              value={searchQuery}
              onChange={(e) => { setSearchQuery(e.target.value); setCurrentPage(1); }}
              className="w-full pl-9 pr-3 py-2 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all placeholder:text-slate-400 truncate"
            />
          </div>
          
          <select 
            value={statusFilter}
            onChange={(e) => { setStatusFilter(e.target.value); setCurrentPage(1); }}
            className="px-3 py-2 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-600 focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all cursor-pointer flex-shrink-0"
          >
            <option value="All">All Status</option>
            <option value="Active">Active</option>
            <option value="Inactive">Inactive</option>
            <option value="New">New</option>
            <option value="Churned">Churned</option>
          </select>
        </div>
      </div>

      {/* Desktop Table */}
      <div className="hidden xl:block overflow-x-auto min-h-[400px]">
        <table className="w-full text-left border-collapse">
          <thead>
            <tr className="border-b border-slate-100">
              <th className="pb-3 pt-4 px-4 pl-6 text-[10px] font-bold text-slate-400 uppercase tracking-wider w-auto">Customer Details</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Contact Info</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-center">Total Orders</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">Wallet Bal.</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Status</th>
              <th className="pb-3 pt-4 px-4 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Joined</th>
              <th className="pb-3 pt-4 px-4 pr-6 text-[10px] font-bold text-slate-400 uppercase tracking-wider text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {paginated.length === 0 ? (
              <tr><td colSpan={7} className="py-16 text-center text-slate-400 font-medium text-sm">No customers found</td></tr>
            ) : paginated.map((item) => (
              <tr key={item.id} 
                  onClick={() => onRowClick && onRowClick(item)}
                  className="border-b border-slate-50 hover:bg-slate-50/80 transition-colors group cursor-pointer"
              >
                <td className="py-4 px-4 pl-6">
                  <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-xl flex-shrink-0 relative border border-slate-200">
                      {item.avatar && item.avatar.includes('/') ? (
                        <img src={item.avatar} alt={item.name} className="w-full h-full object-cover rounded-full" />
                      ) : (
                        <span className="text-sm font-bold text-slate-500">{item.name.charAt(0).toUpperCase()}</span>
                      )}
                      {item.isPremium && (
                        <div className="absolute -top-1 -right-1 bg-amber-400 text-white rounded-full p-0.5 border-2 border-white shadow-sm">
                          <Crown className="w-3 h-3" />
                        </div>
                      )}
                    </div>
                    <div>
                      <p className="text-sm font-bold text-slate-800 leading-tight">{item.name}</p>
                      <p className="text-[10px] text-slate-400 mt-0.5">{item.id}</p>
                    </div>
                  </div>
                </td>
                <td className="py-4 px-4">
                  <p className="text-sm font-medium text-slate-700">{item.phone}</p>
                  <p className="text-[10px] text-slate-400 mt-0.5">{item.email}</p>
                </td>
                <td className="py-4 px-4 text-center">
                  <span className="text-sm font-black text-slate-800 bg-slate-100 px-3 py-1 rounded-full">{item.totalOrders}</span>
                </td>
                <td className="py-4 px-4 text-right">
                  <p className="text-sm font-black text-slate-800">₹{item.walletBalance.toLocaleString('en-IN')}</p>
                </td>
                <td className="py-4 px-4">
                  <span className={`inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 border border-${item.statusColor}-100/50`}>
                    {item.status}
                  </span>
                </td>
                <td className="py-4 px-4">
                  <p className="text-sm font-bold text-slate-700">{item.joinDate}</p>
                  <p className="text-[10px] text-slate-400 mt-0.5">{item.lastActive}</p>
                </td>
                <td className="py-4 px-4 pr-6 text-right" onClick={e => e.stopPropagation()}>
                  <div className="flex items-center justify-end gap-1">
                    <button 
                      onClick={() => onToggleSuspend && onToggleSuspend(item)} 
                      className={`px-3 py-1.5 flex items-center justify-center rounded-lg text-xs font-bold transition-colors ${item.status === 'Suspended' ? 'bg-green-50 text-green-600 hover:bg-green-100' : 'bg-red-50 text-red-600 hover:bg-red-100'}`}
                      title={item.status === 'Suspended' ? 'Revoke Suspension' : 'Suspend Customer'}
                    >
                      {item.status === 'Suspended' ? (
                        <><Undo2 className="w-3.5 h-3.5 mr-1.5" /> Revoke</>
                      ) : (
                        <><Ban className="w-3.5 h-3.5 mr-1.5" /> Suspend</>
                      )}
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Mobile Card View */}
      <div className="xl:hidden p-4 space-y-3">
        {paginated.length === 0 ? (
          <div className="py-10 text-center text-slate-400 font-medium text-sm">No customers found</div>
        ) : paginated.map((item) => (
          <div key={item.id} 
               onClick={() => onRowClick && onRowClick(item)}
               className="bg-white rounded-2xl p-4 border transition-shadow cursor-pointer border-slate-100 hover:shadow-md"
          >
            <div className="flex items-start gap-3 mb-3 relative">
              <div className="w-12 h-12 rounded-full bg-slate-50 border border-slate-100 flex items-center justify-center text-2xl flex-shrink-0 relative">
                {item.avatar && item.avatar.includes('/') ? (
                  <img src={item.avatar} alt={item.name} className="w-full h-full object-cover rounded-full" />
                ) : (
                  <span className="text-lg font-bold text-slate-500">{item.name.charAt(0).toUpperCase()}</span>
                )}
                {item.isPremium && (
                  <div className="absolute -top-1 -right-1 bg-amber-400 text-white rounded-full p-0.5 border-2 border-white shadow-sm">
                    <Crown className="w-3 h-3" />
                  </div>
                )}
              </div>
              <div className="flex-1 min-w-0 pr-6">
                <p className="text-sm font-bold text-slate-800 leading-tight truncate">{item.name}</p>
                <p className="text-[10px] text-slate-400 mt-0.5">{item.phone}</p>
                <div className="flex items-center gap-2 mt-2">
                  <span className={`inline-flex px-2 py-0.5 rounded-md text-[9px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700`}>
                    {item.status}
                  </span>
                  <span className="text-[10px] font-bold text-slate-400">{item.totalOrders} Orders</span>
                </div>
              </div>
            </div>
            
            <div className="grid grid-cols-2 gap-2 mt-3 pt-3 border-t border-slate-50">
              <div className="bg-slate-50 p-2 rounded-xl">
                <p className="text-[9px] font-bold text-slate-400 uppercase mb-0.5">Wallet Bal.</p>
                <p className="text-xs font-black text-slate-800">₹{item.walletBalance.toLocaleString('en-IN')}</p>
              </div>
              <div className="bg-slate-50 p-2 rounded-xl text-right">
                <p className="text-[9px] font-bold text-slate-400 uppercase mb-0.5">Joined</p>
                <p className="text-xs font-bold text-slate-700">{item.joinDate}</p>
              </div>
            </div>

            <div className="flex justify-end gap-2 mt-3 pt-3 border-t border-slate-50" onClick={e => e.stopPropagation()}>
              <button 
                onClick={() => onToggleSuspend && onToggleSuspend(item)} 
                className={`px-3 py-1.5 flex items-center justify-center rounded-lg text-xs font-bold transition-colors flex-1 ${item.status === 'Suspended' ? 'bg-green-50 text-green-600 hover:bg-green-100' : 'bg-red-50 text-red-600 hover:bg-red-100'}`}
              >
                {item.status === 'Suspended' ? (
                  <><Undo2 className="w-3 h-3 mr-1.5" /> Revoke</>
                ) : (
                  <><Ban className="w-3 h-3 mr-1.5" /> Suspend</>
                )}
              </button>
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
