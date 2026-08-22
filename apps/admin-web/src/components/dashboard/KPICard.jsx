"use client";

import { LineChart, Line, ResponsiveContainer } from "recharts";
import { IndianRupee, ShoppingCart, Calendar, Bike, User, AlertTriangle } from "lucide-react";

export default function KPICard({ data }) {
  // Determine icon based on id
  const renderIcon = () => {
    switch(data.id) {
      case "revenue": return <IndianRupee className="w-5 h-5 text-teal-600" />;
      case "orders": return <ShoppingCart className="w-5 h-5 text-cyan-600" />;
      case "subscriptions": return <Calendar className="w-5 h-5 text-blue-600" />;
      case "deliveries": return <Bike className="w-5 h-5 text-orange-600" />;
      case "riders": return <User className="w-5 h-5 text-teal-600" />;
      case "stock": return <AlertTriangle className="w-5 h-5 text-red-600" />;
      default: return null;
    }
  };

  const getIconBgColor = () => {
    switch(data.iconColor) {
      case "teal": return "bg-teal-50";
      case "cyan": return "bg-cyan-50";
      case "blue": return "bg-blue-50";
      case "orange": return "bg-orange-50";
      case "red": return "bg-red-50";
      default: return "bg-slate-50";
    }
  };

  const getSparklineColor = () => {
    if (data.iconColor === 'teal') return '#0d9488';
    if (data.iconColor === 'cyan') return '#0891b2';
    if (data.iconColor === 'blue') return '#2563eb';
    if (data.iconColor === 'orange') return '#ea580c';
    if (data.iconColor === 'red') return '#dc2626';
    return '#94a3b8';
  };

  const getCardBgGradient = () => {
    switch(data.iconColor) {
      case "teal": return "bg-gradient-to-br from-teal-50/50 to-white hover:from-teal-100/50";
      case "cyan": return "bg-gradient-to-br from-cyan-50/50 to-white hover:from-cyan-100/50";
      case "blue": return "bg-gradient-to-br from-blue-50/50 to-white hover:from-blue-100/50";
      case "orange": return "bg-gradient-to-br from-orange-50/50 to-white hover:from-orange-100/50";
      case "red": return "bg-gradient-to-br from-red-50/50 to-white hover:from-red-100/50";
      default: return "bg-gradient-to-br from-slate-50/50 to-white";
    }
  };

  const getTextColor = () => {
    switch(data.iconColor) {
      case "teal": return "text-teal-900";
      case "cyan": return "text-cyan-900";
      case "blue": return "text-blue-900";
      case "orange": return "text-orange-900";
      case "red": return "text-red-900";
      default: return "text-slate-800";
    }
  };

  return (
    <div className={`rounded-3xl border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)] backdrop-blur-xl p-5 flex flex-col justify-between h-full transition-all duration-300 hover:shadow-[0_8px_30px_rgb(0,0,0,0.06)] hover:-translate-y-1 ${getCardBgGradient()}`}>
      <div className="flex justify-between items-start mb-2 relative z-10">
        <div className="w-12 h-12 rounded-2xl flex items-center justify-center border border-white/50 mb-2 shadow-sm bg-white/50">
           <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${getIconBgColor()} shadow-inner`}>
             {renderIcon()}
           </div>
        </div>
        <div className="text-right">
          <p className="text-xs font-bold text-slate-500 mb-1">{data.title}</p>
          <h3 className={`text-2xl font-black tracking-tight ${getTextColor()}`}>{data.value}</h3>
        </div>
      </div>
      
      <div className="flex items-center justify-between mt-auto">
        <div className="flex items-center">
          <span className={`text-[10px] font-bold ${data.trendUp ? 'text-teal-600' : 'text-red-600'}`}>
            {data.trend}
          </span>
          <span className="text-[10px] text-slate-400 font-medium ml-1">{data.comparison}</span>
        </div>
      </div>
      
      <div className="h-10 mt-3 w-full opacity-60">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={data.sparkline}>
            <Line 
              type="monotone" 
              dataKey="value" 
              stroke={getSparklineColor()} 
              strokeWidth={2} 
              dot={false}
              isAnimationActive={false}
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
