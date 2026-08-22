"use client";

import { useState } from "react";
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";

export default function OrdersBarChart({ chartData }) {
  const [timeRange, setTimeRange] = useState("Week");

  const data = chartData ? chartData.labels.map((label, index) => ({
    name: label,
    orders: chartData.data[index]
  })) : [];

  const total = chartData ? chartData.data.reduce((a, b) => a + b, 0) : 0;

  return (
    <div className="bg-white/80 backdrop-blur-xl rounded-3xl border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-6 h-full flex flex-col hover:shadow-lg transition-all duration-300 relative overflow-hidden group">
      <div className="flex justify-between items-start mb-2 relative z-10">
        <div>
          <h3 className="text-lg font-bold text-slate-800 tracking-tight">Orders Overview</h3>
          <div className="mt-4 flex items-end">
            <span className="text-3xl font-black text-slate-800 tracking-tight">{total.toLocaleString()}</span>
            <span className="ml-3 text-sm font-bold text-teal-600 mb-1 flex items-center">
              ▲ 0% <span className="text-slate-400 font-medium ml-1">vs last week</span>
            </span>
          </div>
        </div>
        <div className="flex space-x-1 bg-slate-100/80 backdrop-blur-sm p-1 rounded-xl">
          {["Today", "Week", "Month"].map(range => (
            <button
              key={range}
              onClick={() => setTimeRange(range)}
              className={`px-3 py-1.5 text-xs font-bold rounded-lg transition-all ${timeRange === range ? 'bg-cyan-500 text-white shadow-md' : 'text-slate-500 hover:text-slate-700'}`}
            >
              {range}
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 w-full min-h-[220px] mt-4 relative z-10">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={data} margin={{ top: 10, right: 0, left: -20, bottom: 0 }}>
            <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fill: '#94a3b8', fontSize: 11, fontWeight: 'bold'}} dy={10} />
            <YAxis axisLine={false} tickLine={false} tick={{fill: '#94a3b8', fontSize: 11, fontWeight: 'bold'}} dx={-10} />
            <CartesianGrid vertical={false} stroke="#f1f5f9" />
            <Tooltip 
              cursor={{fill: '#f8fafc'}}
              contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)', padding: '12px 16px' }}
              itemStyle={{ color: '#06b6d4', fontWeight: 'bold' }}
              labelStyle={{ color: '#64748b', fontWeight: '600', marginBottom: '4px' }}
            />
            <Bar dataKey="orders" fill="#22d3ee" radius={[6, 6, 6, 6]} barSize={32} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
