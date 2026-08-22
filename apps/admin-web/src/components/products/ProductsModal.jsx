"use client";

import { useEffect, useState } from "react";
import {
  X, ArrowLeft, Pencil, Package, Tag, IndianRupee,
  BarChart2, Calendar, AlertTriangle, CheckCircle2, XCircle, Save
} from "lucide-react";

const STOCK_COLORS = { "In Stock": "green", "Low Stock": "orange", "Out of Stock": "red" };
const STATUS_COLORS = { "Active": "green", "Inactive": "red" };

function getFilteredProducts(filterType) {
  if (!filterType || filterType === "total") return [];
  if (filterType === "active") return [].filter(p => p.status === "Active");
  if (filterType === "outofstock") return [].filter(p => p.stockStatus === "Out of Stock");
  if (filterType === "lowstock") return [].filter(p => p.stockStatus === "Low Stock");
  if (filterType === "categories") return [];
  if (filterType === "inventory") return [];
  return [];
}

function getModalTitle(filterType) {
  switch (filterType) {
    case "active": return "Active Products";
    case "outofstock": return "Out of Stock Products";
    case "lowstock": return "Low Stock Products";
    case "categories": return "Products by Category";
    case "inventory": return "Inventory Overview";
    default: return "All Products";
  }
}

import ProductDetail from "@/components/products/ProductDetail";

// ─── Main Modal ───────────────────────────────────────────────────────────────
export default function ProductsModal({ isOpen, onClose, filterType }) {
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [isEditingProduct, setIsEditingProduct] = useState(false);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
    } else { 
      document.body.style.overflow = "unset"; 
      setSelectedProduct(null); 
      setIsEditingProduct(false);
    }
    return () => { document.body.style.overflow = "unset"; };
  }, [isOpen]);

  
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => {
      document.body.style.overflow = 'unset';
    };
  }, [isOpen]);

  if (!isOpen) return null;

  const products = getFilteredProducts(filterType);
  const title = getModalTitle(filterType);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
      {/* Backdrop */}
      <div
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      />

      {/* Modal */}
      <div className="relative w-full max-w-2xl max-h-[88vh] bg-white/90 backdrop-blur-xl rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">

        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50 flex-shrink-0">
          <div className="flex items-center space-x-3">
            {selectedProduct && (
              <button
                onClick={() => { setSelectedProduct(null); setIsEditingProduct(false); }}
                className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-100 hover:bg-slate-200 text-slate-600 transition-colors"
              >
                <ArrowLeft className="w-4 h-4" />
              </button>
            )}
            <div>
              <h2 className="text-xl font-black text-slate-800 tracking-tight">
                {selectedProduct ? selectedProduct.name : title}
              </h2>
              <p className="text-xs font-bold text-slate-500 mt-0.5">
                {selectedProduct
                  ? selectedProduct.sku
                  : `${products.length} product${products.length !== 1 ? "s" : ""} found`}
              </p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            {selectedProduct && (
              <button
                onClick={() => setIsEditingProduct(!isEditingProduct)}
                className={`w-8 h-8 flex items-center justify-center rounded-full transition-colors shadow-sm ${
                  isEditingProduct 
                    ? "bg-teal-50 text-teal-600 border border-teal-200 hover:bg-teal-100" 
                    : "bg-white text-slate-500 hover:bg-slate-100 hover:text-teal-600"
                }`}
              >
                {isEditingProduct ? <Save className="w-4 h-4" /> : <Pencil className="w-4 h-4" />}
              </button>
            )}
            <button
              onClick={onClose}
              className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-100 hover:bg-slate-200 text-slate-500 transition-colors"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto hide-scrollbar p-4">
          {!selectedProduct ? (
            /* ── LIST VIEW ── */
            products.length === 0 ? (
              <div className="py-16 text-center">
                <div className="w-16 h-16 rounded-full bg-slate-50 flex items-center justify-center mx-auto mb-4">
                  <Package className="w-8 h-8 text-slate-300" />
                </div>
                <p className="text-sm font-bold text-slate-600">No products found</p>
                <p className="text-xs text-slate-400 mt-1">No products match this filter.</p>
              </div>
            ) : (
              <div className="space-y-2">
                {products.map((p, idx) => {
                  const stockColor = STOCK_COLORS[p.stockStatus] || "slate";
                  const statusColor = STATUS_COLORS[p.status] || "slate";
                  return (
                    <div
                      key={idx}
                      onClick={() => setSelectedProduct(p)}
                      className="cursor-pointer bg-white rounded-2xl p-4 border border-slate-100 shadow-sm hover:shadow-md transition-all hover:-translate-y-0.5 flex items-center gap-4 group"
                    >
                      <div className="w-11 h-11 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-2xl flex-shrink-0">
                                                {p.image ? (
                          <img src={p.image} alt={p.name} className="w-full h-full object-cover rounded-xl" />
                        ) : (
                          <span className="text-2xl">📦</span>
                        )}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className="text-sm font-bold text-slate-800 truncate">{p.name}</p>
                        <p className="text-xs text-slate-400 mt-0.5">{p.variant} • <span className="font-mono">{p.sku}</span></p>
                      </div>
                      <div className="hidden sm:flex flex-col items-end gap-1 flex-shrink-0">
                        <span className="text-sm font-black text-slate-800">₹{p.price}</span>
                        <span className={`text-[10px] font-bold text-${stockColor}-600`}>{p.stockStatus} ({p.stock})</span>
                      </div>
                      <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${statusColor}-50 text-${statusColor}-700 border border-${statusColor}-100/50 flex-shrink-0`}>
                        <span className={`w-1.5 h-1.5 rounded-full bg-${statusColor}-500 mr-1`}></span>
                        {p.status}
                      </span>
                    </div>
                  );
                })}
              </div>
            )
          ) : (
            /* ── DETAIL VIEW ── */
            <ProductDetail
              product={selectedProduct}
              isEditing={isEditingProduct}
            />
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-slate-100 bg-white/50 flex justify-end flex-shrink-0">
          <button
            onClick={onClose}
            className="px-6 py-2 bg-slate-800 hover:bg-slate-900 text-white text-sm font-bold rounded-xl transition-colors shadow-sm"
          >
            Close
          </button>
        </div>
      </div>
    </div>
  );
}
