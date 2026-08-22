"use client";

import { useEffect, useState } from "react";
import { X, Pencil, Package, Tag, Box, Calendar, IndianRupee, ChevronLeft, ArrowRight, Save } from "lucide-react";

import ProductDetail from "@/components/products/ProductDetail";

export default function CategoryDetailModal({ isOpen, onClose, category, onEditClick, initialView = "overview", initialSubcategory = null }) {
  const [view, setView] = useState("overview"); // "overview" | "subcategories" | "products"
  const [activeSubcategory, setActiveSubcategory] = useState(null);
  const [selectedProduct, setSelectedProduct] = useState(null);
  const [isEditingProduct, setIsEditingProduct] = useState(false);

  // Prevent background scroll and reset view
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = "hidden";
      setView(initialView);
      setActiveSubcategory(initialSubcategory);
      setSelectedProduct(null);
      setIsEditingProduct(false);
    } else {
      document.body.style.overflow = "unset";
    }
    return () => { document.body.style.overflow = "unset"; };
  }, [isOpen, category, initialView, initialSubcategory]);

  if (!isOpen || !category) return null;

  // Mock product filtering for demonstration
  let displayProducts = [];
  if (activeSubcategory) {
    displayProducts = [].slice(0, 3); // Just show a subset for subcategory
  } else {
    displayProducts = [].slice(0, 5); // Just show a subset for category
  }

  const handleBack = () => {
    if (selectedProduct) {
      setSelectedProduct(null);
      setIsEditingProduct(false);
    } else if (view === "products" && activeSubcategory && initialView !== "products") {
      setView("subcategories");
      setActiveSubcategory(null);
    } else if (initialView === "products") {
      onClose(); // If it opened directly to products, going "back" closes the modal
    } else {
      setView("overview");
    }
  };

  const getTitle = () => {
    if (selectedProduct) return selectedProduct.name;
    if (view === "subcategories") return `${category.name} Subcategories`;
    if (view === "products" && activeSubcategory) return `${activeSubcategory.name} Products`;
    if (view === "products") return `${category.name} Products`;
    return category.name;
  };

  const getSubtitle = () => {
    if (selectedProduct) return selectedProduct.sku;
    if (view === "subcategories") return `Viewing ${category.subcategoriesList?.length || 0} subcategories.`;
    if (view === "products" && activeSubcategory) return `Viewing ${displayProducts.length} products. (Part of ${category.name} Category)`;
    if (view === "products") return `Viewing ${displayProducts.length} products.`;
    return category.description;
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6 animate-in fade-in duration-200">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={onClose}></div>
      <div className="relative w-full max-w-2xl bg-white/90 backdrop-blur-xl rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden zoom-in-95 max-h-[90vh]">
        
        {/* Header Actions */}
        <div className="absolute top-4 right-4 flex items-center gap-2 z-10">
          {selectedProduct ? (
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
          ) : (
            <button 
              onClick={() => {
                onClose();
                if (onEditClick) onEditClick(category);
              }}
              className="w-8 h-8 flex items-center justify-center rounded-full bg-white text-slate-500 hover:bg-slate-100 hover:text-teal-600 transition-colors shadow-sm"
            >
              <Pencil className="w-4 h-4" />
            </button>
          )}
          <button 
            onClick={onClose}
            className="w-8 h-8 flex items-center justify-center rounded-full bg-white text-slate-500 hover:bg-slate-100 transition-colors shadow-sm"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Header Content */}
        {!selectedProduct ? (
          <div className="px-8 pt-8 pb-6 border-b border-slate-100 bg-slate-50/50 flex items-start gap-5">
            {view !== "overview" && (
              <button 
                onClick={handleBack}
                className="absolute left-6 top-6 w-8 h-8 flex items-center justify-center rounded-full bg-white text-slate-500 hover:bg-slate-100 transition-colors shadow-sm z-10"
              >
                <ChevronLeft className="w-4 h-4" />
              </button>
            )}
            <div className="w-20 h-20 rounded-2xl bg-white shadow-sm border border-slate-100 flex items-center justify-center text-4xl flex-shrink-0 relative z-0">
              {category.image}
            </div>
            <div className="flex-1 pt-1 pl-2">
              <div className="flex items-center gap-3 mb-1">
                <h2 className="text-2xl font-black text-slate-800 tracking-tight">
                  {getTitle()}
                </h2>
                {view === "overview" && (
                  <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${category.statusColor}-50 text-${category.statusColor}-700 border border-${category.statusColor}-100/50`}>
                    <span className={`w-1.5 h-1.5 rounded-full bg-${category.statusColor}-500 mr-1.5`}></span>
                    {category.status}
                  </span>
                )}
              </div>
              <p className="text-sm font-medium text-slate-500 mt-1">
                {getSubtitle()}
              </p>
              {view === "overview" && (
                <p className="text-xs text-slate-400 mt-3 flex items-center font-mono bg-slate-100/50 inline-flex px-2 py-1 rounded-md border border-slate-100">
                  ID: {category.id}
                </p>
              )}
            </div>
          </div>
        ) : (
          <div className="px-6 py-4 border-b border-slate-100 flex items-center gap-3 bg-white/50">
            <button 
              onClick={handleBack}
              className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-100 hover:bg-slate-200 text-slate-600 transition-colors shadow-sm"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <div>
              <h2 className="text-xl font-black text-slate-800 tracking-tight">
                {getTitle()}
              </h2>
              <p className="text-xs font-medium text-slate-500 mt-0.5">
                {getSubtitle()}
              </p>
            </div>
          </div>
        )}

        {/* Content */}
        <div className="p-8 overflow-y-auto custom-scrollbar flex-1">
          {selectedProduct ? (
            <ProductDetail product={selectedProduct} isEditing={isEditingProduct} />
          ) : view === "overview" ? (
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div 
                onClick={() => setView("subcategories")}
                className="bg-white border border-slate-100 rounded-2xl p-4 flex items-center gap-4 cursor-pointer hover:border-orange-200 hover:shadow-md transition-all group"
              >
                <div className="w-10 h-10 rounded-xl bg-orange-50 flex items-center justify-center text-orange-600 group-hover:scale-110 transition-transform">
                  <Box className="w-5 h-5" />
                </div>
                <div className="flex-1">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Subcategories</p>
                  <p className="text-lg font-black text-slate-800 leading-tight">{category.subcategories}</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-orange-500 transition-colors" />
              </div>
              <div 
                onClick={() => setView("products")}
                className="bg-white border border-slate-100 rounded-2xl p-4 flex items-center gap-4 cursor-pointer hover:border-purple-200 hover:shadow-md transition-all group"
              >
                <div className="w-10 h-10 rounded-xl bg-purple-50 flex items-center justify-center text-purple-600 group-hover:scale-110 transition-transform">
                  <Package className="w-5 h-5" />
                </div>
                <div className="flex-1">
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Total Products</p>
                  <p className="text-lg font-black text-slate-800 leading-tight">{category.products}</p>
                </div>
                <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-purple-500 transition-colors" />
              </div>
              <div className="bg-white border border-slate-100 rounded-2xl p-4 flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-green-50 flex items-center justify-center text-green-600">
                  <IndianRupee className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Inventory Value</p>
                  <p className="text-lg font-black text-slate-800 leading-tight">₹{category.value}</p>
                </div>
              </div>
              <div className="bg-white border border-slate-100 rounded-2xl p-4 flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-slate-50 flex items-center justify-center text-slate-500">
                  <Calendar className="w-5 h-5" />
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Added On</p>
                  <p className="text-sm font-bold text-slate-800 leading-tight">{category.addedDate}</p>
                  <p className="text-xs text-slate-400">{category.addedTime}</p>
                </div>
              </div>
            </div>
          ) : view === "subcategories" ? (
            <div className="space-y-3">
              {category.subcategoriesList?.map((sub, idx) => (
                <div 
                  key={idx} 
                  onClick={() => {
                    setActiveSubcategory(sub);
                    setView("products");
                  }}
                  className="flex items-center justify-between p-4 bg-slate-50 border border-slate-100 rounded-xl hover:bg-slate-100/80 hover:border-slate-300 hover:shadow-sm transition-all cursor-pointer group"
                >
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-lg bg-white shadow-sm flex items-center justify-center text-slate-400 font-mono text-[10px] group-hover:scale-105 transition-transform">
                      {sub.id.split('-')[1]}
                    </div>
                    <div>
                      <h4 className="text-sm font-bold text-slate-800 group-hover:text-teal-700 transition-colors">{sub.name}</h4>
                      <p className="text-xs text-slate-500">{sub.products} Products</p>
                    </div>
                  </div>
                  <div className="flex items-center gap-3">
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
                    <ArrowRight className="w-4 h-4 text-slate-300 group-hover:text-slate-500 transition-colors" />
                  </div>
                </div>
              ))}
            </div>
          ) : view === "products" ? (
            <div className="space-y-3">
              {displayProducts.map((prod, idx) => (
                <div 
                  key={idx} 
                  onClick={() => setSelectedProduct(prod)}
                  className="cursor-pointer flex items-center justify-between p-4 bg-white border border-slate-100 rounded-xl hover:border-purple-200 hover:shadow-md transition-all group"
                >
                  <div className="flex items-center gap-4">
                    <div className="w-10 h-10 rounded-xl bg-slate-50 flex items-center justify-center text-xl flex-shrink-0 group-hover:scale-110 transition-transform">
                      {prod.image}
                    </div>
                    <div>
                      <h4 className="text-sm font-bold text-slate-800 group-hover:text-purple-700 transition-colors">{prod.name}</h4>
                      <p className="text-xs text-slate-500 mt-0.5">{prod.variant}</p>
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-sm font-black text-slate-800">₹{prod.price}</p>
                    <p className="text-[10px] font-bold text-green-600 mt-0.5">{prod.stockStatus}</p>
                  </div>
                </div>
              ))}
            </div>
          ) : null}
        </div>

      </div>
    </div>
  );
}
