"use client";

import { useEffect } from "react";
import { X, ExternalLink, ArrowLeft, Package, Pencil, IndianRupee } from "lucide-react";

export default function ProductsListModal({ products = [], isOpen, onClose, filterType, selectedProduct, setSelectedProduct, modalMode, setModalMode, onEditClick }) {
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
      case "active": return "Active Products";
      case "outofstock": return "Out of Stock Products";
      case "lowstock": return "Low Stock Products";
      case "categories": return "Products by Category";
      case "inventory": return "Inventory Overview";
      default: return "All Products";
    }
  };

  const getStatusColor = (status) => {
    switch(status) {
      case "Active": return "green";
      case "Inactive": return "red";
      default: return "slate";
    }
  };

  const getStockColor = (stockStatus) => {
    switch(stockStatus) {
      case "In Stock": return "green";
      case "Low Stock": return "orange";
      case "Out of Stock": return "red";
      default: return "slate";
    }
  };

  const filteredProducts = products.filter(product => {
    if (filterType === "total" || filterType === "categories" || filterType === "inventory") return true;
    if (filterType === "active") return product.status === "Active";
    if (filterType === "outofstock") return product.stockStatus === "Out of Stock";
    if (filterType === "lowstock") return product.stockStatus === "Low Stock";
    return true;
  });

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity" onClick={onClose}></div>

      <div className="relative w-full max-w-3xl max-h-[85vh] bg-white/90 backdrop-blur-xl rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <div className="flex items-center space-x-3">
            {selectedProduct && modalMode === "detail" && (
              <button 
                onClick={() => { setSelectedProduct(null); setModalMode("list"); }}
                className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-500 hover:bg-slate-100 hover:text-slate-700 transition-colors mr-2"
              >
                <ArrowLeft className="w-4 h-4" />
              </button>
            )}
            <div>
              <h2 className="text-xl font-black text-slate-800 tracking-tight">
                {modalMode === "detail" ? "Product Details" : getTitle()}
              </h2>
              {modalMode === "list" && (
                <p className="text-xs font-bold text-teal-600 mt-0.5">{filteredProducts.length} products found</p>
              )}
            </div>
          </div>
          
          <div className="flex items-center gap-3">
            {modalMode === "detail" && (
              <button 
                onClick={() => { onClose(); onEditClick && onEditClick(selectedProduct); }}
                className="flex items-center px-4 py-2 bg-teal-50 text-teal-600 border border-teal-100 rounded-xl text-sm font-bold hover:bg-teal-100 hover:text-teal-700 transition-colors"
              >
                <Pencil className="w-4 h-4 mr-2" />
                Edit
              </button>
            )}
            <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto hide-scrollbar p-6 bg-slate-50/50">
          {modalMode === "list" ? (
            filteredProducts.length === 0 ? (
              <div className="text-center py-12">
                <Package className="w-12 h-12 text-slate-200 mx-auto mb-4" />
                <h3 className="text-lg font-bold text-slate-700">No products found</h3>
                <p className="text-sm text-slate-500 mt-1">Try adjusting your filters.</p>
              </div>
            ) : (
              <div className="space-y-3 animate-in slide-in-from-bottom-4 duration-300">
                {filteredProducts.map((product, idx) => (
                  <div key={idx} onClick={() => { setSelectedProduct(product); setModalMode("detail"); }}
                    className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm hover:shadow-md hover:border-teal-100 transition-all cursor-pointer flex flex-col sm:flex-row sm:items-center justify-between group"
                  >
                    <div className="flex items-center space-x-4 mb-4 sm:mb-0">
                      <div className="w-12 h-12 rounded-xl border border-slate-200 bg-slate-50 flex items-center justify-center text-2xl flex-shrink-0">
                        {product.image ? (
                          <img src={product.image} alt={product.name} className="w-full h-full object-cover rounded-xl" />
                        ) : (
                          <span className="text-2xl">📦</span>
                        )}
                      </div>
                      <div>
                        <h4 className="text-sm font-black text-slate-800 leading-tight">{product.name}</h4>
                        <p className="text-xs font-medium text-slate-500 mt-0.5">{product.variant}</p>
                        <p className="text-[10px] font-mono text-slate-400 mt-0.5">{product.sku}</p>
                      </div>
                    </div>

                    <div className="flex items-center space-x-6">
                      <div className="hidden sm:block text-right">
                        <p className="text-xs font-bold text-slate-700">{product.stock} items</p>
                        <p className={`text-[10px] font-medium text-${getStockColor(product.stockStatus)}-600 mt-0.5`}>{product.stockStatus}</p>
                      </div>
                      <span className={`inline-flex px-3 py-1 rounded-full text-[10px] font-bold bg-${getStatusColor(product.status)}-50 text-${getStatusColor(product.status)}-700 border border-${getStatusColor(product.status)}-100/50`}>
                        {product.status}
                      </span>
                    </div>

                    <div className="flex items-center justify-between w-full sm:w-auto sm:space-x-6 pt-3 sm:pt-0 border-t border-slate-50 sm:border-0 mt-2 sm:mt-0">
                      <div className="text-right">
                        <p className="text-xs font-bold text-slate-500 mb-0.5">Price</p>
                        <p className="text-sm font-black text-slate-800">₹{product.price}</p>
                      </div>
                      <button className="w-8 h-8 flex items-center justify-center rounded-xl bg-teal-50 text-teal-600 group-hover:bg-teal-600 group-hover:text-white transition-colors">
                        <ExternalLink className="w-4 h-4" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )
          ) : (
            <div className="space-y-4 animate-in slide-in-from-right-4 duration-300">
              <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm flex flex-col sm:flex-row gap-6 items-start">
                <div className="w-24 h-24 rounded-2xl border-2 border-slate-100 bg-slate-50 flex items-center justify-center text-5xl flex-shrink-0">
                  {selectedProduct.image ? (
                    <img src={selectedProduct.image} alt={selectedProduct.name} className="w-full h-full object-cover rounded-[1.25rem]" />
                  ) : (
                    <span className="text-4xl">📦</span>
                  )}
                </div>
                <div className="flex-1 w-full">
                  <div className="flex flex-col sm:flex-row sm:justify-between sm:items-start gap-4">
                    <div>
                      <h3 className="text-xl font-black text-slate-800">{selectedProduct.name}</h3>
                      <p className="text-sm font-medium text-slate-500 mt-1">{selectedProduct.variant}</p>
                      <div className="flex items-center mt-3 space-x-3">
                        <span className="text-xs font-mono font-bold bg-slate-100 text-slate-600 px-2 py-1 rounded-lg">
                          {selectedProduct.sku}
                        </span>
                        <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${getStatusColor(selectedProduct.status)}-50 text-${getStatusColor(selectedProduct.status)}-700 border border-${getStatusColor(selectedProduct.status)}-100/50`}>
                          <span className={`w-1.5 h-1.5 rounded-full bg-${getStatusColor(selectedProduct.status)}-500 mr-1`}></span>
                          {selectedProduct.status}
                        </span>
                      </div>
                    </div>
                    
                    <div className="bg-slate-50 rounded-xl p-4 border border-slate-100 min-w-[140px]">
                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Pricing</p>
                      <p className="text-2xl font-black text-slate-800">₹{selectedProduct.price}</p>
                      {selectedProduct.mrp && <p className="text-xs font-medium text-slate-400 line-through mt-0.5">MRP: ₹{selectedProduct.mrp}</p>}
                    </div>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm">
                  <h4 className="text-sm font-bold text-slate-800 mb-4 flex items-center">
                    <Package className="w-4 h-4 mr-2 text-slate-400" /> Inventory
                  </h4>
                  <div className="space-y-4">
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Current Stock</span>
                      <span className="text-sm font-black text-slate-800">{selectedProduct.stock} units</span>
                    </div>
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Stock Status</span>
                      <span className={`text-xs font-bold text-${getStockColor(selectedProduct.stockStatus)}-600`}>{selectedProduct.stockStatus}</span>
                    </div>
                    <div className="flex justify-between items-center">
                      <span className="text-xs font-semibold text-slate-500">Category</span>
                      <span className={`text-xs font-bold text-${selectedProduct.categoryColor}-700 flex items-center gap-1`}>
                         <span className={`w-1.5 h-1.5 rounded-full bg-${selectedProduct.categoryColor}-500`}></span>
                         {selectedProduct.category}
                      </span>
                    </div>
                  </div>
                </div>

                <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm">
                  <h4 className="text-sm font-bold text-slate-800 mb-4 flex items-center">
                    <IndianRupee className="w-4 h-4 mr-2 text-slate-400" /> Performance
                  </h4>
                  <div className="space-y-4">
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Total Sales</span>
                      <span className="text-sm font-black text-slate-800">{selectedProduct.sales} units</span>
                    </div>
                    <div className="flex justify-between items-center pb-3 border-b border-slate-50">
                      <span className="text-xs font-semibold text-slate-500">Last Updated</span>
                      <div className="text-right">
                        <p className="text-xs font-bold text-slate-800">{selectedProduct.updatedDate}</p>
                        <p className="text-[10px] text-slate-400">{selectedProduct.updatedTime}</p>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

            </div>
          )}
        </div>
        
        {/* Footer */}
        <div className="px-6 py-4 border-t border-slate-100 bg-white/50 flex justify-end">
          <button onClick={onClose} className="px-6 py-2.5 bg-slate-800 text-white rounded-xl text-sm font-bold hover:bg-slate-900 transition-colors shadow-sm">
            Close
          </button>
        </div>

      </div>
    </div>
  );
}
