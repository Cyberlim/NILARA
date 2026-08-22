"use client";

import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';
import { AlertTriangle } from 'lucide-react';

export default function InventorySummary({ items = [] }) {
  const lowStockItems = items.filter(i => i.stockStatus === 'Low Stock' || i.stockStatus === 'Out of Stock');

  // Derive chart data from real items
  const inStockVal = items.filter(i => i.stockStatus === 'In Stock').reduce((s, i) => s + i.stock * i.price, 0);
  const lowStockVal = items.filter(i => i.stockStatus === 'Low Stock').reduce((s, i) => s + i.stock * i.price, 0);
  const outVal = items.filter(i => i.stockStatus === 'Out of Stock').reduce((s, i) => s + i.stock * i.price, 0);
  const totalVal = inStockVal + lowStockVal + outVal;

  const chartData = [
    { name: 'In Stock', value: Math.round(inStockVal), color: '#0d9488' },
    { name: 'Low Stock', value: Math.round(lowStockVal), color: '#f97316' },
    { name: 'Out of Stock', value: Math.round(outVal), color: '#ef4444' },
  ].filter(d => d.value > 0);

  return (
    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-6">
      {/* Low Stock Alerts */}
      <div className="bg-white rounded-3xl p-6 border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] flex flex-col">
        <div className="flex justify-between items-center mb-6">
          <h3 className="text-[15px] font-black text-slate-800 tracking-tight">Low Stock & Out of Stock Alerts</h3>
          <span className="text-[11px] font-bold text-orange-500 bg-orange-50 px-2 py-1 rounded-full border border-orange-100">{lowStockItems.length} items</span>
        </div>
        {lowStockItems.length === 0 ? (
          <div className="flex-1 flex flex-col items-center justify-center text-slate-400 py-10">
            <AlertTriangle className="w-8 h-8 mb-2 opacity-30" />
            <p className="text-sm font-medium">All products are well-stocked!</p>
          </div>
        ) : (
          <div className="flex-1 flex flex-col gap-4 overflow-y-auto max-h-64">
            {lowStockItems.map((item, idx) => (
              <div key={idx} className="flex items-center justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-xl bg-slate-50 flex items-center justify-center border border-slate-100 overflow-hidden">
                    {item.image ? <img src={item.image} alt={item.name} className="w-full h-full object-cover" /> : <span className="text-slate-300 text-xs">IMG</span>}
                  </div>
                  <p className="text-xs font-bold text-slate-800 w-40 truncate">{item.name}</p>
                </div>
                <span className={`text-[11px] font-bold px-2 py-1 rounded-md border ${item.stockStatus === 'Out of Stock' ? 'text-red-500 bg-red-50 border-red-100' : 'text-orange-500 bg-orange-50 border-orange-100'}`}>
                  {item.stock} units left
                </span>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Inventory Value Summary */}
      <div className="bg-white rounded-3xl p-6 border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] flex flex-col">
        <h3 className="text-[15px] font-black text-slate-800 tracking-tight mb-2">Inventory Value Summary</h3>
        {chartData.length === 0 ? (
          <div className="flex-1 flex items-center justify-center text-slate-400 py-10">
            <p className="text-sm font-medium">No inventory data yet</p>
          </div>
        ) : (
          <div className="flex-1 flex flex-col sm:flex-row items-center">
            <div className="w-[180px] h-[180px] relative flex-shrink-0">
              <ResponsiveContainer width="100%" height="100%">
                <PieChart>
                  <Pie data={chartData} cx="50%" cy="50%" innerRadius={60} outerRadius={80} paddingAngle={2} dataKey="value" stroke="none">
                    {chartData.map((entry, index) => <Cell key={index} fill={entry.color} />)}
                  </Pie>
                  <Tooltip formatter={(value) => "₹" + value.toLocaleString('en-IN')} contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 20px rgba(0,0,0,0.08)' }} />
                </PieChart>
              </ResponsiveContainer>
              <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                <p className="text-[10px] font-bold text-slate-400">Total Value</p>
                <p className="text-[13px] font-black text-slate-800">₹{Math.round(totalVal).toLocaleString('en-IN')}</p>
              </div>
            </div>
            <div className="flex-1 flex flex-col justify-center ml-0 sm:ml-4 mt-6 sm:mt-0 gap-3 w-full">
              {chartData.map((item, index) => (
                <div key={index} className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <span className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: item.color }}></span>
                    <span className="text-[11px] font-bold text-slate-600">{item.name}</span>
                  </div>
                  <span className="text-[11px] font-black text-slate-800">₹{item.value.toLocaleString('en-IN')}</span>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
