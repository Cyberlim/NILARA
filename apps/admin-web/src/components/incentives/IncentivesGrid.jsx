"use client";

import { useState } from "react";
import { Zap, ExternalLink, Calendar, Target, Trophy } from "lucide-react";

export default function IncentivesGrid({ items, onGridClick }) {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4 sm:gap-6">
      {items.map((item) => (
        <div key={item.id} onClick={() => onGridClick && onGridClick(item)} className="bg-white rounded-3xl p-6 border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] hover:shadow-[0_4px_25px_rgb(0,0,0,0.06)] transition-all duration-300 flex flex-col cursor-pointer group relative overflow-hidden">
          
          <div className="flex items-start justify-between mb-4">
            <div className={`w-10 h-10 rounded-xl flex items-center justify-center bg-${item.statusColor}-50 text-${item.statusColor}-500`}>
              <Zap className="w-5 h-5" />
            </div>
            <span className={`inline-flex px-2.5 py-1 rounded-full text-[10px] font-bold bg-${item.statusColor}-50 text-${item.statusColor}-700 border border-${item.statusColor}-100/50`}>
              {item.status}
            </span>
          </div>

          <div className="mb-6">
            <h3 className="text-lg font-black text-slate-800 tracking-tight leading-tight">{item.title}</h3>
            <p className="text-sm font-medium text-slate-500 mt-1">{item.type} Campaign</p>
          </div>

          <div className="space-y-3 mb-6 flex-1">
            <div className="flex items-center text-sm font-medium text-slate-600">
              <Target className="w-4 h-4 mr-3 text-slate-400" />
              {item.target}
            </div>
            <div className="flex items-center text-sm font-bold text-teal-600">
              <Trophy className="w-4 h-4 mr-3 text-teal-500" />
              {item.reward}
            </div>
            <div className="flex items-center text-xs font-medium text-slate-500">
              <Calendar className="w-4 h-4 mr-3 text-slate-400" />
              {item.startDate} - {item.endDate}
            </div>
          </div>
          
        </div>
      ))}
    </div>
  );
}
