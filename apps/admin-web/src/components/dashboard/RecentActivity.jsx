"use client";

const recentActivityData = [
  { id: 1, text: "Order NIL10231 assigned to Rider #D102", time: "12 mins ago", icon: "truck", color: "teal" },
  { id: 2, text: "New subscription from Priya Sharma", time: "34 mins ago", icon: "user", color: "blue" },
  { id: 3, text: "Coupon NILARA10 used", time: "1 hr ago", icon: "gift", color: "teal" },
  { id: 4, text: "Low stock alert: Milk 1L (12 left)", time: "2 hrs ago", icon: "alert", color: "orange" },
];
import { Truck, User, Gift, AlertTriangle } from "lucide-react";

export default function RecentActivity() {
  const getIcon = (iconStr, color) => {
    switch (iconStr) {
      case "truck": return <Truck className={`w-4 h-4 text-${color}-600`} />;
      case "user": return <User className={`w-4 h-4 text-${color}-600`} />;
      case "gift": return <Gift className={`w-4 h-4 text-${color}-600`} />;
      case "alert": return <AlertTriangle className={`w-4 h-4 text-${color}-600`} />;
      default: return null;
    }
  };

  return (
    <div className="bg-white/80 backdrop-blur-xl rounded-3xl border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-6 h-full flex flex-col hover:shadow-lg transition-all duration-300">
      <div className="flex justify-between items-center mb-6">
        <h3 className="text-lg font-bold text-slate-800 tracking-tight">Recent Activity</h3>
        <button className="text-xs font-bold text-teal-600 hover:text-teal-700 transition-colors">
          View All
        </button>
      </div>

      <div className="flex-1 flex flex-col justify-between space-y-4">
        {recentActivityData.map((activity) => (
          <div key={activity.id} className="flex items-start space-x-4 border-b border-slate-50 pb-4 last:border-0 last:pb-0">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center bg-${activity.color}-50 border border-${activity.color}-100 shrink-0`}>
              {getIcon(activity.icon, activity.color)}
            </div>
            <div className="mt-1">
              <p className="text-sm font-medium text-slate-700 leading-tight">{activity.text}</p>
              <p className="text-[10px] font-bold text-slate-400 mt-1">{activity.time}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
