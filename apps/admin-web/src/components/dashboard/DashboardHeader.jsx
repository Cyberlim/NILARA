"use client";

import { Droplets, Calendar as CalendarIcon } from "lucide-react";

export default function DashboardHeader() {
  return (
    <div className="flex flex-col md:flex-row justify-between items-start md:items-center mb-8 gap-4">
      <div className="flex items-center space-x-4">
        <div className="w-12 h-14 flex items-center justify-center relative">
           <div className="absolute inset-0 bg-teal-600 rounded-full" style={{ borderRadius: '50% 50% 0 50%', transform: 'rotate(-45deg)'}}></div>
           <Droplets className="w-6 h-6 text-white relative z-10" />
        </div>
        <div>
          <h1 className="text-2xl font-black text-slate-800 tracking-tight">Welcome back, Admin!</h1>
          <p className="text-sm font-medium text-slate-500 mt-1">Here's what's happening with your Nilara business today.</p>
        </div>
      </div>
      
      <div className="flex items-center space-x-4">
        <div className="bg-white border border-slate-200 px-4 py-2 rounded-xl flex items-center shadow-sm">
          <span className="text-sm font-bold text-slate-700 mr-3">Online Store</span>
          <div className="flex items-center">
            <span className="w-2 h-2 bg-emerald-500 rounded-full mr-1.5 animate-pulse"></span>
            <span className="text-xs font-bold text-emerald-600">Live</span>
          </div>
        </div>
        
        <div className="bg-slate-50 border border-slate-200 px-4 py-2 rounded-xl flex items-center">
          <CalendarIcon className="w-4 h-4 text-slate-500 mr-2" />
          <div className="flex flex-col">
            <span className="text-xs font-bold text-slate-700">Thu, 22 Aug 2024</span>
            <span className="text-[10px] font-bold text-slate-500">11:42 AM</span>
          </div>
        </div>
      </div>
    </div>
  );
}
