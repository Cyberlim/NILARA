"use client";

import { useEffect, useState } from "react";
import { X, ExternalLink, ArrowLeft, Calendar, Package, CreditCard, Clock, User, MapPin } from "lucide-react";
import BulkOrdersModal from "./BulkOrdersModal";
import { fetchWithAuth } from "@/lib/api";

export default function BulkOrdersListModal({ 
  isOpen, 
  onClose, 
  filterType, 
  ordersData = [],
  onRefresh
}) {
  const [selectedOrder, setSelectedOrder] = useState(null);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  const getTitle = () => {
    switch(filterType) {
      case "Pending": return "Pending Requests";
      case "Confirmed": return "Confirmed Orders";
      case "Delivered": return "Delivered Orders";
      case "Cancelled": return "Cancelled Orders";
      default: return "All Bulk Orders";
    }
  };

  const getStatusColor = (status) => {
    switch (status) {
      case "Delivered": return "green";
      case "Confirmed": return "blue";
      case "Processing": return "yellow";
      case "Cancelled": return "red";
      default: return "slate";
    }
  };

  const filteredOrders = ordersData.filter(order => {
    if (filterType === "Total") return true;
    return order.status === filterType;
  });

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      ></div>

      {/* Modal Container */}
      <div className="relative w-full max-w-3xl max-h-[85vh] bg-white/90 backdrop-blur-xl rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <div>
            <h2 className="text-xl font-black text-slate-800 tracking-tight">
              {getTitle()}
            </h2>
            <p className="text-xs font-bold text-slate-500 mt-1">
              {filteredOrders.length} {filteredOrders.length === 1 ? 'order' : 'orders'} found
            </p>
          </div>
          <button 
            onClick={onClose}
            className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-100 hover:bg-slate-200 text-slate-500 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content Area */}
        <div className="flex-1 overflow-y-auto p-2 sm:p-4 custom-scrollbar">
          {filteredOrders.length === 0 ? (
            <div className="py-12 text-center flex flex-col items-center justify-center">
              <div className="w-16 h-16 rounded-full bg-slate-50 flex items-center justify-center mb-4">
                <X className="w-8 h-8 text-slate-300" />
              </div>
              <p className="text-sm font-bold text-slate-600">No orders found.</p>
              <p className="text-xs text-slate-400 mt-1">There are no orders matching this status.</p>
            </div>
          ) : (
            <div className="space-y-2">
              {filteredOrders.map((order, idx) => (
                <div 
                  key={order._id || idx} 
                  onClick={() => setSelectedOrder(order)}
                  className="cursor-pointer bg-white rounded-2xl p-4 border border-slate-100 shadow-sm hover:shadow-md transition-all flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 group hover:-translate-y-0.5"
                >
                  {/* Left: ID & Customer */}
                  <div className="flex items-center space-x-4">
                    <div className="w-10 h-10 rounded-full border border-slate-200 bg-slate-50 flex items-center justify-center text-slate-400">
                      <User className="w-5 h-5" />
                    </div>
                    <div>
                      <h4 className="text-sm font-black text-slate-800">
                        #{order._id ? order._id.substring(order._id.length - 6).toUpperCase() : 'N/A'}
                      </h4>
                      <p className="text-xs font-medium text-slate-500 mt-0.5">
                        {order.user?.displayName || "Guest"}
                      </p>
                    </div>
                  </div>

                  {/* Middle: Items & Status */}
                  <div className="flex items-center space-x-6">
                    <div className="hidden sm:block text-right">
                      <p className="text-xs font-bold text-slate-700">{order.quantity} units</p>
                      <p className="text-[10px] font-medium text-slate-400 mt-0.5">{order.productName}</p>
                    </div>
                    <span className={`inline-flex px-3 py-1 rounded-full text-[10px] font-bold bg-${getStatusColor(order.status)}-50 text-${getStatusColor(order.status)}-700 border border-${getStatusColor(order.status)}-100/50`}>
                      {order.status}
                    </span>
                  </div>

                  {/* Right: Amount & Action */}
                  <div className="flex items-center justify-between w-full sm:w-auto sm:space-x-6 pt-3 sm:pt-0 border-t border-slate-50 sm:border-0 mt-2 sm:mt-0">
                    <div className="text-right">
                      <p className="text-xs font-bold text-slate-500 mb-0.5">Total</p>
                      <p className="text-sm font-black text-slate-800">₹{order.totalPrice?.toFixed(2) || '0.00'}</p>
                    </div>
                    <button className="w-8 h-8 flex items-center justify-center rounded-xl bg-blue-50 text-blue-600 group-hover:bg-blue-600 group-hover:text-white transition-colors">
                      <ExternalLink className="w-4 h-4" />
                    </button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
      {/* Update Status function */}
      {selectedOrder && (
        <BulkOrdersModal 
          order={selectedOrder} 
          onClose={() => setSelectedOrder(null)} 
          onUpdateStatus={async (status) => {
            try {
              const response = await fetchWithAuth(`/bulk-orders/${selectedOrder._id}/status`, {
                method: "PATCH",
                body: JSON.stringify({ status })
              });
              if (response.success) {
                if (onRefresh) onRefresh();
                setSelectedOrder(null);
              }
            } catch (err) {
              console.error("Failed to update status", err);
            }
          }}
        />
      )}
    </div>
  );
}
