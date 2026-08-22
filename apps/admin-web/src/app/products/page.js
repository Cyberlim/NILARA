"use client";

import { useState, useEffect } from "react";
import { Download, Upload, Plus } from "lucide-react";
import ProductsKPI from "@/components/products/ProductsKPI";
import ProductsTable from "@/components/products/ProductsTable";
import ProductsListModal from "@/components/products/ProductsListModal";
import ProductFormModal from "@/components/products/ProductFormModal";
import ProductsExportModal from "@/components/products/ProductsExportModal";
import ProductsImportModal from "@/components/products/ProductsImportModal";
import { fetchWithAuth } from "@/lib/api";

export default function ProductsPage() {
  const [modalFilter, setModalFilter] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [modalMode, setModalMode] = useState("detail");
  const [selectedProduct, setSelectedProduct] = useState(null);
  
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [productToEdit, setProductToEdit] = useState(null);
  
  const [isExportOpen, setIsExportOpen] = useState(false);
  const [isImportOpen, setIsImportOpen] = useState(false);

  const [products, setProducts] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const fetchProducts = async () => {
    try {
      setIsLoading(true);
      const res = await fetchWithAuth('/products');
      // Map backend products to the structure needed by the table
      const mapped = res.data.map(p => {
        const v = p.variants[0] || {};
        return {
          id: p._id,
          name: p.name,
          variant: `${v.weightOrVolume || ''} ${v.unit || ''}`,
          sku: v.sku || '',
          category: p.category?.name || 'Uncategorized',
          categoryColor: p.category?.name === 'Water' ? 'blue' : p.category?.name === 'Oil' ? 'orange' : 'teal',
          price: (v.discountPricePaise || v.pricePaise || 0) / 100,
          mrp: v.pricePaise / 100,
          stock: v.stockQuantity || 0,
          stockStatus: v.stockQuantity > 0 ? "In Stock" : "Out of Stock",
          status: p.isActive ? "Active" : "Inactive",
          sales: 0,
          updatedDate: new Date(p.updatedAt).toLocaleDateString(),
          updatedTime: new Date(p.updatedAt).toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'}),
          image: p.images[0] || "📦",
          images: p.images,
          tags: "",
          description: p.description
        };
      });
      setProducts(mapped);
    } catch (err) {
      console.error("Failed to load products", err);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchProducts();
  }, []);

  const openForm = (product = null) => {
    setProductToEdit(product);
    setIsFormOpen(true);
  };

  const handleRowClick = (product) => {
    setSelectedProduct(product);
    setModalMode("detail");
    setIsModalOpen(true);
  };

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Products</h1>
          <p className="text-sm font-medium text-slate-500">Manage and organize all your store products</p>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={() => setIsImportOpen(true)}
            className="flex items-center px-4 py-2.5 bg-white text-slate-600 border border-slate-200 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors shadow-sm"
          >
            <Upload className="w-4 h-4 mr-2" />
            Import
          </button>
          <button 
            onClick={() => setIsExportOpen(true)}
            className="flex items-center px-4 py-2.5 bg-teal-600 text-white border border-transparent rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm"
          >
            <Download className="w-4 h-4 mr-2" />
            Export
          </button>
          <button 
            onClick={() => openForm()}
            className="flex items-center px-4 py-2.5 bg-slate-800 text-white rounded-xl text-sm font-bold hover:bg-slate-900 transition-colors shadow-sm"
          >
            <Plus className="w-4 h-4 mr-2" />
            Add New Product
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <ProductsKPI
        products={products}
        modalFilter={modalFilter}
        setModalFilter={setModalFilter}
        setIsModalOpen={setIsModalOpen}
        setModalMode={setModalMode}
      />

      {/* Main Table */}
      {isLoading ? (
        <div className="py-20 text-center text-slate-500 font-medium">Loading products...</div>
      ) : (
        <ProductsTable
          products={products}
          onRowClick={handleRowClick}
          onEditClick={openForm}
          onRefresh={fetchProducts}
        />
      )}

      {/* List / Detail Modal */}
      <ProductsListModal
        products={products}
        isOpen={isModalOpen}
        onClose={() => { setIsModalOpen(false); setSelectedProduct(null); setModalFilter(null); }}
        filterType={modalFilter}
        selectedProduct={selectedProduct}
        setSelectedProduct={setSelectedProduct}
        modalMode={modalMode}
        setModalMode={setModalMode}
        onEditClick={openForm}
      />

      {/* Add / Edit Form Modal */}
      <ProductFormModal
        isOpen={isFormOpen}
        onClose={() => setIsFormOpen(false)}
        productToEdit={productToEdit}
        onSuccess={() => {
          setIsFormOpen(false);
          fetchProducts();
        }}
      />

      {/* Export Modal */}
      <ProductsExportModal
        isOpen={isExportOpen}
        onClose={() => setIsExportOpen(false)}
      />

      {/* Import Modal */}
      <ProductsImportModal
        isOpen={isImportOpen}
        onClose={() => setIsImportOpen(false)}
      />
    </div>
  );
}
