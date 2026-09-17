"use client";

import { Zap, Calendar, Target, Trophy, Clock, Sparkles, Plus } from "lucide-react";

export default function IncentivesGrid({ items = [], onGridClick, onNewCampaign }) {
  if (items.length === 0) {
    return (
      <div className="bg-white/80 backdrop-blur-xl rounded-3xl p-12 text-center border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.02)]">
        <div className="w-16 h-16 rounded-full bg-teal-50 border border-teal-100 flex items-center justify-center mx-auto mb-4 text-teal-600">
          <Sparkles className="w-8 h-8" />
        </div>
        <h3 className="text-lg font-black text-slate-800 mb-1">No Incentive Campaigns Defined</h3>
        <p className="text-sm font-medium text-slate-500 max-w-md mx-auto mb-6">
          Set up order target milestones, peak hour bonuses, or weekend rush rewards for delivery partners.
        </p>
        <button
          onClick={onNewCampaign}
          className="inline-flex items-center px-5 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm"
        >
          <Plus className="w-4 h-4 mr-2" />
          Create First Incentive
        </button>
      </div>
    );
  }

  const getCategoryBadge = (category) => {
    switch (category) {
      case "Daily Goal":
        return { color: "emerald", icon: Zap };
      case "Peak Hour":
        return { color: "orange", icon: Clock };
      case "Weekend Rush":
        return { color: "blue", icon: Calendar };
      case "Order Target":
      default:
        return { color: "amber", icon: Target };
    }
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4 sm:gap-6">
      {items.map((item) => {
        const catInfo = getCategoryBadge(item.category || item.type);
        const CatIcon = catInfo.icon;

        return (
          <div
            key={item.id || item._id}
            onClick={() => onGridClick && onGridClick(item)}
            className="bg-white rounded-3xl p-6 border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] transition-all duration-300 flex flex-col cursor-pointer group relative overflow-hidden hover:-translate-y-1"
          >
            <div className="flex items-start justify-between mb-4">
              <div className="w-10 h-10 rounded-xl flex items-center justify-center bg-teal-50 text-teal-600">
                <CatIcon className="w-5 h-5" />
              </div>
              <span
                className={`inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold ${
                  item.status === "Active"
                    ? "bg-emerald-50 text-emerald-700 border border-emerald-100"
                    : item.status === "Paused"
                    ? "bg-amber-50 text-amber-700 border border-amber-100"
                    : "bg-slate-50 text-slate-600 border border-slate-200"
                }`}
              >
                {item.status}
              </span>
            </div>

            <div className="mb-4">
              <span className="text-[10px] font-extrabold uppercase tracking-wider text-teal-600 bg-teal-50/60 px-2 py-0.5 rounded-md">
                {item.category || item.type || "Milestone"}
              </span>
              <h3 className="text-lg font-black text-slate-800 tracking-tight leading-tight mt-1.5 group-hover:text-teal-700 transition-colors">
                {item.title}
              </h3>
              {item.description && (
                <p className="text-xs font-medium text-slate-500 mt-1 line-clamp-2">
                  {item.description}
                </p>
              )}
            </div>

            <div className="space-y-3 mb-5 flex-1 pt-2 border-t border-slate-50">
              <div className="flex items-center text-sm font-bold text-slate-700">
                <Target className="w-4 h-4 mr-2.5 text-slate-400" />
                Target: {item.target || `${item.targetOrders} Orders`}
              </div>
              <div className="flex items-center text-sm font-black text-emerald-600">
                <Trophy className="w-4 h-4 mr-2.5 text-amber-500" />
                Reward: {item.reward || `₹${item.rewardAmount}`}
              </div>
              <div className="flex items-center text-xs font-medium text-slate-500">
                <Calendar className="w-4 h-4 mr-2.5 text-slate-400" />
                {item.startDate} - {item.endDate}
              </div>
              {item.startTime && item.endTime && (
                <div className="flex items-center text-xs font-bold text-orange-600 bg-orange-50/70 px-2 py-1 rounded-lg">
                  <Clock className="w-3.5 h-3.5 mr-2 text-orange-500" />
                  Peak Window: {item.startTime} - {item.endTime}
                </div>
              )}
            </div>

            <div className="pt-3 border-t border-slate-50 flex items-center justify-between text-xs font-bold text-slate-400 group-hover:text-teal-600 transition-colors">
              <span>View Details & Actions</span>
              <span>&rarr;</span>
            </div>
          </div>
        );
      })}
    </div>
  );
}
