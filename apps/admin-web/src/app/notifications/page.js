"use client";

import React, { useState, useEffect, useMemo } from "react";
import { 
  Bell, CheckCircle, Package, AlertTriangle, Info, 
  Bike, Headphones, MessageSquare, ArrowRight, RefreshCw 
} from "lucide-react";
import { fetchWithAuth } from "@/lib/api";
import { useRouter } from "next/navigation";

const formatTimeAgo = (dateString) => {
  if (!dateString) return "";
  const date = new Date(dateString);
  const now = new Date();
  const diffSecs = Math.floor((now - date) / 1000);
  
  if (diffSecs < 60) return "Just now";
  const diffMins = Math.floor(diffSecs / 60);
  if (diffMins < 60) return `${diffMins} min${diffMins > 1 ? 's' : ''} ago`;
  const diffHours = Math.floor(diffMins / 60);
  if (diffHours < 24) return `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`;
  const diffDays = Math.floor(diffHours / 24);
  if (diffDays === 1) return "Yesterday";
  if (diffDays < 7) return `${diffDays} days ago`;
  return date.toLocaleDateString(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
};

const getTypeConfig = (type) => {
  switch (type) {
    case 'order':
      return { icon: Package, bg: 'bg-blue-50', text: 'text-blue-600', border: 'border-blue-100', label: 'Order' };
    case 'delivery':
      return { icon: Bike, bg: 'bg-amber-50', text: 'text-amber-600', border: 'border-amber-100', label: 'Delivery' };
    case 'support':
      return { icon: Headphones, bg: 'bg-teal-50', text: 'text-teal-600', border: 'border-teal-100', label: 'Support' };
    case 'system':
    default:
      return { icon: Info, bg: 'bg-slate-100', text: 'text-slate-600', border: 'border-slate-200', label: 'System' };
  }
};

export default function NotificationsPage() {
  const [notifications, setNotifications] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState("all");
  const router = useRouter();

  useEffect(() => {
    loadNotifications();
  }, []);

  const loadNotifications = async () => {
    try {
      setLoading(true);
      const data = await fetchWithAuth('/notifications');
      if (data && data.success) {
        setNotifications(data.notifications || []);
      }
    } catch (err) {
      console.error("Failed to load notifications", err);
    } finally {
      setLoading(false);
    }
  };

  const markAllAsRead = async () => {
    try {
      await fetchWithAuth('/notifications/read-all', { method: 'PATCH' });
      setNotifications(prev => prev.map(n => ({ ...n, isRead: true })));
    } catch (err) {
      console.error("Failed to mark all notifications read", err);
    }
  };

  const handleNotificationClick = async (notification) => {
    if (!notification.isRead) {
      try {
        await fetchWithAuth(`/notifications/${notification._id}/read`, { method: 'PATCH' });
        setNotifications(prev => prev.map(n => n._id === notification._id ? { ...n, isRead: true } : n));
      } catch (err) {
        console.error("Failed to mark notification as read", err);
      }
    }

    if (notification.link) {
      router.push(notification.link);
    }
  };

  // Filter Counts
  const counts = useMemo(() => {
    return {
      all: notifications.length,
      unread: notifications.filter(n => !n.isRead).length,
      order: notifications.filter(n => n.type === 'order').length,
      delivery: notifications.filter(n => n.type === 'delivery').length,
      support: notifications.filter(n => n.type === 'support').length,
      system: notifications.filter(n => n.type === 'system').length,
    };
  }, [notifications]);

  const filteredNotifications = useMemo(() => {
    return notifications.filter(n => {
      if (filter === "all") return true;
      if (filter === "unread") return !n.isRead;
      return n.type === filter;
    });
  }, [notifications, filter]);

  return (
    <div className="max-w-[1000px] mx-auto pb-10">
      
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <div className="flex items-center gap-2.5">
            <h1 className="text-3xl font-black text-slate-800 tracking-tight">Notifications</h1>
            {counts.unread > 0 && (
              <span className="px-2.5 py-0.5 rounded-full text-xs font-bold bg-teal-50 text-teal-700 border border-teal-200">
                {counts.unread} unread
              </span>
            )}
          </div>
          <p className="text-sm font-medium text-slate-500 mt-0.5">
            Stay updated with alerts, order updates, and support activities in real time.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button 
            onClick={loadNotifications}
            className="p-2.5 bg-white text-slate-500 hover:text-teal-600 border border-slate-200 rounded-xl transition-colors shadow-sm"
            title="Refresh"
          >
            <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          </button>
          
          <button 
            onClick={markAllAsRead}
            disabled={counts.unread === 0}
            className="flex items-center px-4 py-2 bg-white text-slate-700 border border-slate-200 rounded-xl text-sm font-bold hover:bg-slate-50 disabled:opacity-50 transition-colors shadow-sm"
          >
            <CheckCircle className="w-4 h-4 mr-2 text-teal-600" />
            Mark all as read
          </button>
        </div>
      </div>

      {/* Filters */}
      <div className="flex overflow-x-auto space-x-2 mb-6 pb-2 custom-scrollbar">
        {[
          { id: 'all', label: 'All', count: counts.all },
          { id: 'unread', label: 'Unread', count: counts.unread },
          { id: 'order', label: 'Orders', count: counts.order },
          { id: 'delivery', label: 'Delivery', count: counts.delivery },
          { id: 'support', label: 'Support', count: counts.support },
          { id: 'system', label: 'System', count: counts.system },
        ].map((f) => (
          <button
            key={f.id}
            onClick={() => setFilter(f.id)}
            className={`px-4 py-2 rounded-xl text-sm font-bold whitespace-nowrap transition-all flex items-center gap-2 ${
              filter === f.id 
                ? 'bg-slate-900 text-white shadow-sm' 
                : 'bg-white text-slate-600 hover:bg-slate-50 border border-slate-200'
            }`}
          >
            <span>{f.label}</span>
            <span className={`text-[10px] px-1.5 py-0.2 rounded-full font-bold ${
              filter === f.id ? 'bg-slate-700 text-white' : 'bg-slate-100 text-slate-500'
            }`}>
              {f.count}
            </span>
          </button>
        ))}
      </div>

      {/* List */}
      <div className="bg-white rounded-3xl border border-slate-200 shadow-sm overflow-hidden">
        {loading ? (
          <div className="py-20 text-center flex flex-col items-center">
            <div className="w-8 h-8 border-3 border-teal-500 border-t-transparent rounded-full animate-spin mb-3"></div>
            <p className="text-sm font-medium text-slate-400">Loading notifications...</p>
          </div>
        ) : filteredNotifications.length === 0 ? (
          <div className="py-20 text-center flex flex-col items-center">
            <Bell className="w-12 h-12 text-slate-200 mb-4" />
            <p className="text-sm font-bold text-slate-700">No notifications found.</p>
            <p className="text-xs text-slate-400 mt-1">You are all caught up in this category.</p>
          </div>
        ) : (
          <div className="divide-y divide-slate-100">
            {filteredNotifications.map((notification) => {
              const config = getTypeConfig(notification.type);
              const Icon = config.icon;
              const isUnread = !notification.isRead;

              return (
                <div 
                  key={notification._id} 
                  onClick={() => handleNotificationClick(notification)}
                  className={`p-4 sm:p-5 flex items-start space-x-4 transition-colors hover:bg-slate-50/80 cursor-pointer group ${
                    isUnread ? 'bg-teal-50/20' : 'bg-white'
                  }`}
                >
                  <div className={`w-11 h-11 rounded-2xl flex items-center justify-center shrink-0 border ${config.bg} ${config.text} ${config.border}`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  <div className="flex-1 min-w-0 pt-0.5">
                    <div className="flex justify-between items-start mb-1">
                      <div className="flex items-center gap-2">
                        <h3 className={`text-sm font-bold truncate ${isUnread ? 'text-slate-900' : 'text-slate-700'}`}>
                          {notification.title}
                        </h3>
                        <span className={`text-[10px] font-bold px-2 py-0.2 rounded-full border ${config.bg} ${config.text} ${config.border}`}>
                          {config.label}
                        </span>
                      </div>
                      <span className="text-[11px] font-medium text-slate-400 whitespace-nowrap ml-4">
                        {formatTimeAgo(notification.createdAt)}
                      </span>
                    </div>
                    <p className={`text-sm ${isUnread ? 'text-slate-700 font-medium' : 'text-slate-500'}`}>
                      {notification.message}
                    </p>
                  </div>
                  <div className="flex items-center space-x-2 shrink-0 self-center">
                    {isUnread && (
                      <div className="w-2.5 h-2.5 rounded-full bg-teal-500"></div>
                    )}
                    {notification.link && (
                      <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-teal-600 transition-colors" />
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>

    </div>
  );
}
