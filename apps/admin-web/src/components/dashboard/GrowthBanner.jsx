"use client";

import { Droplets, Users, BarChart3, TrendingUp, Star } from "lucide-react";

export default function GrowthBanner() {
  return (
    <div className="bg-teal-50/50 rounded-2xl border border-teal-100 flex items-center justify-between p-4 px-6 mt-6 overflow-hidden relative">
      <div className="absolute top-0 right-0 w-32 h-32 bg-teal-100/50 rounded-full blur-2xl pointer-events-none -translate-y-1/2 translate-x-1/2"></div>
      
      <div className="flex items-center space-x-4 relative z-10">
        <div className="w-10 h-10 flex items-center justify-center relative bg-teal-500 rounded-full" style={{ borderRadius: '50% 50% 0 50%', transform: 'rotate(-45deg)'}}>
           <Droplets className="w-5 h-5 text-white relative z-10" style={{ transform: 'rotate(45deg)'}} />
        </div>
        <div>
          <h3 className="text-sm font-bold text-slate-800">Grow Nilara Together</h3>
          <p className="text-xs font-medium text-slate-500 mt-0.5">More happy customers. More deliveries. A stronger business.</p>
        </div>
      </div>

      <div className="flex items-center space-x-12 relative z-10">
        <div className="flex items-center space-x-3 hidden md:flex">
          <Users className="w-5 h-5 text-teal-600" />
          <div>
            <p className="text-sm font-bold text-slate-800">1,248</p>
            <p className="text-[10px] font-medium text-slate-500">Total Customers</p>
          </div>
        </div>
        
        <div className="flex items-center space-x-3 hidden md:flex">
          <BarChart3 className="w-5 h-5 text-teal-600" />
          <div>
            <p className="text-sm font-bold text-slate-800">₹12.4L</p>
            <p className="text-[10px] font-medium text-slate-500">Total Revenue</p>
          </div>
        </div>

        <div className="flex items-center space-x-3 hidden lg:flex">
          <div className="flex items-center space-x-1">
             <TrendingUp className="w-4 h-4 text-teal-600" />
          </div>
          <div>
            <p className="text-sm font-bold text-slate-800">98%</p>
            <p className="text-[10px] font-medium text-slate-500">Delivery Success</p>
          </div>
        </div>

        <div className="flex items-center space-x-3 hidden lg:flex">
          <Star className="w-5 h-5 text-teal-600" />
          <div>
            <p className="text-sm font-bold text-slate-800">4.8 <span className="text-[10px]">★</span></p>
            <p className="text-[10px] font-medium text-slate-500">Partner Rating</p>
          </div>
        </div>

        <button className="bg-teal-500 hover:bg-teal-600 text-white text-xs font-bold px-5 py-2.5 rounded-xl shadow-sm transition-colors">
          View Reports →
        </button>
      </div>
    </div>
  );
}
