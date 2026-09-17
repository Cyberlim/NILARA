"use client";

import { X, Search, ChevronRight, Zap, ArrowLeft, Calendar, Target, Trophy, Trash2, PauseCircle, PlayCircle, Loader2 } from "lucide-react";
import { useState, useEffect } from "react";
import { fetchWithAuth } from "@/lib/api";

export default function IncentivesListModal({
  isOpen,
  onClose,
  filterType,
  selectedItem,
  setSelectedItem,
  modalMode,
  items = [],
  onCampaignUpdated
}) {
  const [searchQuery, setSearchQuery] = useState("");
  const [loadingAction, setLoadingAction] = useState(false);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "unset";
    }
    return () => {
      document.body.style.overflow = "unset";
    };
  }, [isOpen]);

  if (!isOpen) return null;

  const handleToggleStatus = async (item) => {
    try {
      setLoadingAction(true);
      const nextStatus = item.status === "Active" ? "Paused" : "Active";
      await fetchWithAuth(`/admin/incentives/${item.id || item._id}`, {
        method: "PATCH",
        body: JSON.stringify({ status: nextStatus })
      });
      if (onCampaignUpdated) onCampaignUpdated();
      onClose();
    } catch (err) {
      alert(err.message || "Failed to update campaign status");
    } finally {
      setLoadingAction(false);
    }
  };

  const handleDelete = async (item) => {
    if (!confirm(`Are you sure you want to delete the campaign "${item.title}"?`)) return;
    try {
      setLoadingAction(true);
      await fetchWithAuth(`/admin/incentives/${item.id || item._id}`, {
        method: "DELETE"
      });
      if (onCampaignUpdated) onCampaignUpdated();
      onClose();
    } catch (err) {
      alert(err.message || "Failed to delete campaign");
    } finally {
      setLoadingAction(false);
    }
  };

  // Render Detail View
  if (modalMode === "direct_detail" || selectedItem) {
    const item = selectedItem;
    return (
      <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
        <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={onClose}></div>
        <div className="relative w-full max-w-2xl bg-white rounded-3xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden animate-in fade-in zoom-in-95 duration-200">
          
          <div className="flex items-center justify-between p-6 border-b border-slate-100 bg-slate-50/50">
            <div className="flex items-center">
              {modalMode !== "direct_detail" && (
                <button 
                  onClick={() => setSelectedItem(null)}
                  className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-500 hover:bg-slate-100 hover:text-slate-700 transition-colors mr-3"
                >
                  <ArrowLeft className="w-4 h-4" />
                </button>
              )}
              <div>
                <h2 className="text-xl font-black text-slate-800">Incentive Campaign Details</h2>
                <p className="text-xs font-medium text-slate-500 mt-0.5">{item.id || item._id}</p>
              </div>
            </div>
            <button 
              onClick={onClose}
              className="w-10 h-10 flex items-center justify-center rounded-full bg-white text-slate-500 hover:text-slate-800 hover:bg-slate-100 shadow-sm transition-colors"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          <div className="p-6 overflow-y-auto custom-scrollbar">
            <div className="bg-slate-50 rounded-2xl p-6 mb-6 flex justify-between items-center border border-slate-100">
              <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Reward to Wallet</p>
                <div className="flex items-center">
                  <Trophy className="w-6 h-6 mr-2 text-amber-500" />
                  <p className="text-3xl font-black text-emerald-600">{item.reward || `₹${item.rewardAmount}`}</p>
                </div>
              </div>
              <div className="text-right">
                <span className={`inline-flex px-3 py-1.5 rounded-xl text-xs font-bold ${
                  item.status === "Active"
                    ? "bg-emerald-50 text-emerald-700 border border-emerald-100"
                    : item.status === "Paused"
                    ? "bg-amber-50 text-amber-700 border border-amber-100"
                    : "bg-slate-50 text-slate-600 border border-slate-200"
                }`}>
                  {item.status}
                </span>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mt-2 flex items-center justify-end">
                  <Calendar className="w-3 h-3 mr-1" /> {item.startDate} - {item.endDate}
                </p>
              </div>
            </div>

            <div className="space-y-4">
              <div className="p-4 border border-slate-100 rounded-xl bg-slate-50/30">
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Campaign Title</p>
                <p className="text-lg font-black text-slate-800">{item.title}</p>
                {item.description && (
                  <p className="text-sm font-medium text-slate-500 mt-1">{item.description}</p>
                )}
              </div>

              <div className="grid grid-cols-2 gap-4">
                <div className="p-4 border border-slate-100 rounded-xl bg-slate-50/30">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Category / Type</p>
                  <p className="text-sm font-bold text-slate-800">
                    {item.category || item.type}
                  </p>
                </div>
                <div className="p-4 border border-slate-100 rounded-xl bg-slate-50/30">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Target</p>
                  <p className="text-sm font-bold text-slate-800 flex items-center">
                    <Target className="w-4 h-4 mr-2 text-slate-400" />
                    {item.target || `${item.targetOrders} Orders`}
                  </p>
                </div>
              </div>

              {item.startTime && item.endTime && (
                <div className="p-4 border border-orange-100 rounded-xl bg-orange-50/40">
                  <p className="text-[10px] font-bold text-orange-800 uppercase tracking-wider mb-1">Peak Hour Time Window</p>
                  <p className="text-sm font-bold text-orange-700">
                    {item.startTime} to {item.endTime}
                  </p>
                </div>
              )}
            </div>
          </div>
          
          <div className="p-6 border-t border-slate-100 bg-slate-50/50 flex justify-between items-center gap-3">
            <button
              onClick={() => handleDelete(item)}
              disabled={loadingAction}
              className="flex items-center px-4 py-2.5 bg-red-50 text-red-600 rounded-xl text-sm font-bold hover:bg-red-100 transition-colors disabled:opacity-50"
            >
              <Trash2 className="w-4 h-4 mr-2" />
              Delete Campaign
            </button>
            <div className="flex gap-2">
              <button 
                onClick={onClose} 
                className="px-5 py-2.5 bg-white border border-slate-200 text-slate-700 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm"
              >
                Close
              </button>
              <button 
                onClick={() => handleToggleStatus(item)}
                disabled={loadingAction}
                className={`flex items-center px-5 py-2.5 rounded-xl text-sm font-bold transition-colors shadow-sm text-white disabled:opacity-50 ${
                  item.status === "Active" ? "bg-amber-600 hover:bg-amber-700" : "bg-emerald-600 hover:bg-emerald-700"
                }`}
              >
                {loadingAction ? (
                  <Loader2 className="w-4 h-4 animate-spin mr-2" />
                ) : item.status === "Active" ? (
                  <>
                    <PauseCircle className="w-4 h-4 mr-2" />
                    Pause Campaign
                  </>
                ) : (
                  <>
                    <PlayCircle className="w-4 h-4 mr-2" />
                    Activate Campaign
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // Render List View
  const listItems = items.filter((item) => {
    if (filterType === "active_campaigns" && item.status !== "Active") return false;
    if (searchQuery) {
      const q = searchQuery.toLowerCase();
      if (!item.title.toLowerCase().includes(q) && !(item.id || item._id).toLowerCase().includes(q)) {
        return false;
      }
    }
    return true;
  });

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={onClose} />
      <div className="relative w-full max-w-2xl bg-white rounded-3xl shadow-2xl flex flex-col max-h-[90vh] overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        <div className="flex items-center justify-between p-6 border-b border-slate-100 bg-slate-50/50">
          <div>
            <h2 className="text-xl font-black text-slate-800 capitalize">
              {filterType.replace(/_/g, " ")}
            </h2>
            <p className="text-sm font-medium text-slate-500 mt-1">{listItems.length} records found</p>
          </div>
          <button 
            onClick={onClose} 
            className="w-10 h-10 flex items-center justify-center rounded-full bg-white text-slate-500 hover:text-slate-800 hover:bg-slate-100 shadow-sm transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <div className="p-4 border-b border-slate-50">
          <div className="relative">
            <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" />
            <input 
              type="text" 
              placeholder="Search campaigns..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 transition-all placeholder:text-slate-400"
            />
          </div>
        </div>

        <div className="flex-1 overflow-y-auto custom-scrollbar p-2">
          {listItems.length === 0 ? (
            <div className="py-12 text-center text-slate-400 font-medium text-sm">No items match your filter.</div>
          ) : (
            listItems.map((item) => (
              <div 
                key={item.id || item._id}
                onClick={() => setSelectedItem(item)}
                className="flex items-center justify-between p-4 hover:bg-slate-50 rounded-2xl cursor-pointer transition-colors group border border-transparent hover:border-slate-100 mb-1"
              >
                <div className="flex items-center space-x-4">
                  <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center text-slate-400 group-hover:bg-teal-50 group-hover:text-teal-600 transition-colors">
                    <Zap className="w-5 h-5" />
                  </div>
                  <div>
                    <h4 className="text-sm font-bold text-slate-800">{item.title}</h4>
                    <p className="text-[10px] font-medium text-slate-500 mt-0.5">{item.category || item.type}</p>
                  </div>
                </div>
                <div className="flex items-center space-x-4">
                  <div className="text-right hidden sm:block">
                    <span className="text-sm font-black text-emerald-600 block mb-1">{item.reward || `₹${item.rewardAmount}`}</span>
                    <span className={`inline-flex items-center px-2 py-0.5 rounded-md text-[9px] font-bold mt-1 ${
                      item.status === "Active" ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700"
                    }`}>
                      {item.status}
                    </span>
                  </div>
                  <ChevronRight className="w-5 h-5 text-slate-300 group-hover:text-teal-500 transition-colors" />
                </div>
              </div>
            ))
          )}
        </div>

      </div>
    </div>
  );
}
