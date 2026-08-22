"use client";

import { 
  Users, UserCheck, UserPlus, Crown, UserMinus, Wallet 
} from "lucide-react";

export default function CustomersKPIs({ modalFilter, setModalFilter, setIsModalOpen, setModalMode }) {
  const getIcon = (iconName, color) => {
    const cls = `w-5 h-5 text-${color}-600`;
    switch (iconName) {
      case "users": return <Users className={cls} />;
      case "user-check": return <UserCheck className={cls} />;
      case "user-plus": return <UserPlus className={cls} />;
      case "crown": return <Crown className={cls} />;
      case "user-minus": return <UserMinus className={cls} />;
      case "wallet": return <Wallet className={cls} />;
      default: return <Users className={cls} />;
    }
  };

  return (
    <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4 mb-6">
      {[].map((kpi, idx) => (
        <div
          key={idx}
          onClick={() => {
            if (setModalFilter && setModalMode && setIsModalOpen) {
              setModalFilter(kpi.id);
              setModalMode("list");
              setIsModalOpen(true);
            }
          }}
          className={`cursor-pointer bg-white/80 backdrop-blur-xl rounded-3xl border shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-5 flex flex-col justify-between transition-all duration-300 hover:shadow-[0_8px_30px_rgb(0,0,0,0.08)] hover:-translate-y-1 hover:bg-white/95 ${
            modalFilter === kpi.id
              ? "ring-2 ring-teal-500/30 border-teal-200 bg-teal-50/30"
              : "border-white/60"
          }`}
        >
          <div className="flex items-start space-x-3 mb-4">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-${kpi.iconColor}-50 border border-${kpi.iconColor}-100 shrink-0`}>
              {getIcon(kpi.icon, kpi.iconColor)}
            </div>
            <div>
              <p className="text-[11px] font-bold text-slate-400 uppercase tracking-wider">{kpi.title}</p>
              <h3 className="text-xl font-black text-slate-800 mt-1">{kpi.value}</h3>
            </div>
          </div>
          
          <div className={`inline-flex items-center self-start px-2 py-1 rounded-md text-[10px] font-bold ${kpi.isPositive ? 'bg-green-50 text-green-600' : 'bg-red-50 text-red-500'}`}>
            {kpi.trend}
          </div>
        </div>
      ))}
    </div>
  );
}
