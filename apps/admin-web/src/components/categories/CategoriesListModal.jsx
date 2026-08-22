"use client";

import { useEffect, useState } from "react";
import { X, Search, Filter, ArrowLeft, Pencil, Save } from "lucide-react";
import ProductDetail from "@/components/products/ProductDetail";

export default function CategoriesListModal({ isOpen, onClose, filter, onRowClick, onSubcategoryClick }) {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [isEditingProduct, setIsEditingProduct] = useState(false);

  // Prevent background scroll
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
      setSelectedProduct(null);
      setIsEditingProduct(false);
    } else {
      document.body.style.overflow = "unset";
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

  // Filter based on KPI
  let filtered = [];
  let isSubcategoryView = filter === "subcategories";
  let isProductView = filter === "products";
  
  let subcategoriesData = [];
  if (isSubcategoryView) {
    [].forEach(c => {
      if (c.subcategoriesList) {
        c.subcategoriesList.forEach(sub => {
          subcategoriesData.push({ ...sub, parentCategory: c.name, parentIcon: c.image });
        });
      }
    });
  }

  let productsDataToShow = [];
  if (isProductView) {
    productsDataToShow = [];
  }

  if (!isSubcategoryView && !isProductView) {
    if (filter === "active") filtered = filtered.filter(c => c.status === "Active");
    if (filter === "inactive") filtered = filtered.filter(c => c.status === "Inactive");
    if (filter === "lowstock") filtered = filtered.filter(c => c.status === "Low Stock");
    if (filter === "value") {
      // Sort by value (remove commas and parse as int)
      filtered = [...filtered].sort((a, b) => {
        const valA = parseInt(a.value.replace(/,/g, ''), 10);
        const valB = parseInt(b.value.replace(/,/g, ''), 10);
        return valB - valA; // Descending
      });
    }
  }

  const getFilterTitle = () => {
    if (selectedProduct) return selectedProduct.name;
    if (isSubcategoryView) return "All Subcategories";
    if (isProductView) return "All Products in Categories";
    switch (filter) {
      case "active": return "Active Categories";
      case "inactive": return "Inactive Categories";
      case "lowstock": return "Low Stock Categories";
      case "value": return "Category Inventory Value";
      default: return "All Categories";
    }
  };

  const getFilterSubtitle = () => {
    if (selectedProduct) return selectedProduct.sku;
    const totalCount = isSubcategoryView ? subcategoriesData.length : (isProductView ? productsDataToShow.length : filtered.length);
    return `${totalCount} ${isSubcategoryView ? "subcategories" : (isProductView ? "products" : "categories")} found`;
  };

  const totalCount = isSubcategoryView ? subcategoriesData.length : (isProductView ? productsDataToShow.length : filtered.length);

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6 animate-in fade-in duration-200">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={onClose}></div>
      <div className="relative w-full max-w-4xl max-h-[90vh] bg-white/90 backdrop-blur-xl rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden zoom-in-95">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
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
              <h2 className="text-xl font-black text-slate-800 tracking-tight">{getFilterTitle()}</h2>
              <p className="text-xs font-bold text-slate-500 mt-1">{getFilterSubtitle()}</p>
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
            <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-100 hover:bg-slate-200 text-slate-500 transition-colors">
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* List / Detail */}
        <div className="flex-1 overflow-y-auto p-4 space-y-3 custom-scrollbar">
          {selectedProduct ? (
            <ProductDetail product={selectedProduct} isEditing={isEditingProduct} />
          ) : totalCount === 0 ? (
            <div className="text-center py-12 text-slate-500 font-medium text-sm">No items match your criteria</div>
          ) : isProductView ? (
            productsDataToShow.map((prod, idx) => (
              <div 
                key={idx}
                onClick={() => setSelectedProduct(prod)}
                className="cursor-pointer bg-white border border-slate-100 rounded-2xl p-4 flex items-center gap-4 hover:shadow-md hover:border-purple-100 transition-all group"
              >
                <div className="w-12 h-12 rounded-xl bg-purple-50 border border-purple-100 flex items-center justify-center text-2xl flex-shrink-0 group-hover:scale-110 transition-transform">
                  {prod.image}
                </div>
                <div className="flex-1 min-w-0">
                  <h4 className="text-sm font-bold text-slate-800 truncate">{prod.name}</h4>
                  <p className="text-[11px] font-bold text-slate-500 mt-1 truncate flex items-center gap-1">
                    <span className="w-1 h-1 rounded-full bg-slate-400"></span>
                    {prod.variant} • in {prod.category}
                  </p>
                </div>
                <div className="text-right hidden sm:block">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Price</p>
                  <p className="text-sm font-black text-slate-800 mt-0.5">₹{prod.price}</p>
                </div>
                <div className="text-right hidden sm:block">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Stock</p>
                  <p className="text-sm font-bold text-slate-800 mt-0.5">{prod.stock}</p>
                </div>
                <div className="text-right">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Status</p>
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold ${
                    prod.stockStatus === "In Stock" ? "bg-green-50 text-green-700 border border-green-100/50" : 
                    prod.stockStatus === "Low Stock" ? "bg-orange-50 text-orange-700 border border-orange-100/50" :
                    "bg-red-50 text-red-700 border border-red-100/50"
                  }`}>
                    <span className={`w-1 h-1 rounded-full ${
                      prod.stockStatus === "In Stock" ? "bg-green-500" : 
                      prod.stockStatus === "Low Stock" ? "bg-orange-500" :
                      "bg-red-500"
                    } mr-1`}></span>
                    {prod.stockStatus}
                  </span>
                </div>
              </div>
            ))
          ) : isSubcategoryView ? (
            subcategoriesData.map((sub, idx) => (
              <div 
                key={idx}
                onClick={() => {
                  if (onSubcategoryClick) {
                    const parentCat = [].find(cat => cat.name === sub.parentCategory);
                    onSubcategoryClick(parentCat, sub);
                    onClose();
                  }
                }}
                className="bg-white border border-slate-100 rounded-2xl p-4 flex items-center gap-4 hover:shadow-md hover:border-orange-100 transition-all cursor-pointer group"
              >
                <div className="w-12 h-12 rounded-xl bg-orange-50 border border-orange-100 flex items-center justify-center text-2xl flex-shrink-0 group-hover:scale-110 transition-transform">
                  {sub.parentIcon}
                </div>
                <div className="flex-1 min-w-0">
                  <h4 className="text-sm font-bold text-slate-800 truncate">{sub.name}</h4>
                  <p className="text-[11px] font-bold text-slate-500 mt-1 truncate flex items-center gap-1">
                    <span className="w-1 h-1 rounded-full bg-slate-400"></span>
                    in {sub.parentCategory}
                  </p>
                </div>
                <div className="text-right hidden sm:block">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Products</p>
                  <p className="text-sm font-bold text-slate-800 mt-0.5">{sub.products}</p>
                </div>
                <div className="text-right">
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold ${
                    sub.status === "Active" ? "bg-green-50 text-green-700 border border-green-100/50" : 
                    sub.status === "Low Stock" ? "bg-orange-50 text-orange-700 border border-orange-100/50" :
                    "bg-slate-100 text-slate-600 border border-slate-200"
                  }`}>
                    <span className={`w-1 h-1 rounded-full ${
                      sub.status === "Active" ? "bg-green-500" : 
                      sub.status === "Low Stock" ? "bg-orange-500" :
                      "bg-slate-400"
                    } mr-1`}></span>
                    {sub.status}
                  </span>
                </div>
              </div>
            ))
          ) : (
            filtered.map((c, idx) => (
              <div 
                key={idx}
                onClick={() => {
                  if (onRowClick) {
                    onRowClick(c);
                    onClose();
                  }
                }}
                className="bg-white border border-slate-100 rounded-2xl p-4 flex items-center gap-4 hover:shadow-md hover:border-teal-100 transition-all cursor-pointer group"
              >
                <div className="w-12 h-12 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-2xl flex-shrink-0 group-hover:scale-110 transition-transform">
                  {c.image}
                </div>
                <div className="flex-1 min-w-0">
                  <h4 className="text-sm font-bold text-slate-800 truncate">{c.name}</h4>
                  <p className="text-[11px] text-slate-500 mt-1 truncate">{c.description}</p>
                </div>
                <div className="text-right hidden sm:block">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Subcategories</p>
                  <p className="text-sm font-bold text-slate-800 mt-0.5">{c.subcategories}</p>
                </div>
                <div className="text-right hidden sm:block">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Products</p>
                  <p className="text-sm font-bold text-slate-800 mt-0.5">{c.products}</p>
                </div>
                {filter === "value" && (
                  <div className="text-right hidden sm:block">
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Inv. Value</p>
                    <p className="text-sm font-black text-green-600 mt-0.5">₹{c.value}</p>
                  </div>
                )}
                <div className="text-right">
                  <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-[10px] font-bold bg-${c.statusColor}-50 text-${c.statusColor}-700 border border-${c.statusColor}-100/50`}>
                    <span className={`w-1 h-1 rounded-full bg-${c.statusColor}-500 mr-1`}></span>
                    {c.status}
                  </span>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
