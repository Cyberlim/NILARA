"use client";

import { Bell, CheckCircle, Package, AlertTriangle, Info } from "lucide-react";
import { useState } from "react";

const mockNotifications = [
  { id: 1, type: "order", title: "New Order Received", message: "Order #ORD-1045 has been placed by Rahul Sharma for ₹850.", time: "10 mins ago", unread: true, icon: Package, color: "teal" },
  { id: 2, type: "system", title: "Server Maintenance", message: "Scheduled maintenance will occur tonight at 2:00 AM IST.", time: "1 hour ago", unread: true, icon: AlertTriangle, color: "amber" },
  { id: 3, type: "delivery", title: "Delivery Delayed", message: "Driver Amit is stuck in traffic. Order #ORD-1022 delayed by 15 mins.", time: "3 hours ago", unread: false, icon: Info, color: "blue" },
  { id: 4, type: "success", title: "Payout Successful", message: "Weekly payout of ₹45,200 has been transferred to your bank.", time: "Yesterday", unread: false, icon: CheckCircle, color: "green" },
  { id: 5, type: "order", title: "Order Cancelled", message: "Customer cancelled Order #ORD-0992.", time: "Yesterday", unread: false, icon: Package, color: "red" },
];

export default function NotificationsPage() {
  const [filter, setFilter] = useState("all");

  const filteredNotifications = mockNotifications.filter(n => {
    if (filter === "all") return true;
    if (filter === "unread") return n.unread;
    return n.type === filter;
  });

  return (
    <div className="max-w-[1000px] mx-auto pb-10">
      
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Notifications</h1>
          <p className="text-sm font-medium text-slate-500">Stay updated with alerts and recent activities.</p>
        </div>
        <button className="flex items-center px-4 py-2 bg-white text-slate-600 border border-slate-200 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm">
          <CheckCircle className="w-4 h-4 mr-2" />
          Mark all as read
        </button>
      </div>

      {/* Filters */}
      <div className="flex overflow-x-auto space-x-2 mb-6 pb-2 custom-scrollbar">
        {['all', 'unread', 'order', 'delivery', 'system'].map((f) => (
          <button
            key={f}
            onClick={() => setFilter(f)}
            className={`px-4 py-2 rounded-xl text-sm font-bold capitalize whitespace-nowrap transition-colors ${
              filter === f 
                ? 'bg-slate-800 text-white shadow-sm' 
                : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-200'
            }`}
          >
            {f}
          </button>
        ))}
      </div>

      {/* List */}
      <div className="bg-white rounded-3xl border border-slate-100 shadow-[0_4px_20px_rgb(0,0,0,0.03)] overflow-hidden">
        {filteredNotifications.length === 0 ? (
          <div className="py-20 text-center flex flex-col items-center">
            <Bell className="w-12 h-12 text-slate-200 mb-4" />
            <p className="text-sm font-bold text-slate-500">No notifications found.</p>
          </div>
        ) : (
          <div className="divide-y divide-slate-50">
            {filteredNotifications.map((notification) => {
              const Icon = notification.icon;
              return (
                <div 
                  key={notification.id} 
                  className={`p-4 sm:p-6 flex items-start space-x-4 transition-colors hover:bg-slate-50 cursor-pointer ${
                    notification.unread ? 'bg-slate-50/50' : 'bg-white'
                  }`}
                >
                  <div className={`w-12 h-12 rounded-full flex items-center justify-center shrink-0 bg-${notification.color}-50 text-${notification.color}-600`}>
                    <Icon className="w-6 h-6" />
                  </div>
                  <div className="flex-1 pt-1">
                    <div className="flex justify-between items-start mb-1">
                      <h3 className={`text-sm font-bold ${notification.unread ? 'text-slate-800' : 'text-slate-600'}`}>
                        {notification.title}
                      </h3>
                      <span className="text-[10px] font-bold text-slate-400 whitespace-nowrap ml-4">
                        {notification.time}
                      </span>
                    </div>
                    <p className={`text-sm ${notification.unread ? 'text-slate-600 font-medium' : 'text-slate-500'}`}>
                      {notification.message}
                    </p>
                  </div>
                  {notification.unread && (
                    <div className="w-2.5 h-2.5 rounded-full bg-teal-500 mt-2 shrink-0"></div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </div>

    </div>
  );
}
