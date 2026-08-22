"use client";

import { useState } from "react";
import { Plus } from "lucide-react";
import CategoriesKPI from "@/components/categories/CategoriesKPI";
import CategoriesTable from "@/components/categories/CategoriesTable";
import CategoriesListModal from "@/components/categories/CategoriesListModal";
import CategoryDetailModal from "@/components/categories/CategoryDetailModal";
import CategoryFormModal from "@/components/categories/CategoryFormModal";

export default function CategoriesPage() {
  const [modalFilter, setModalFilter] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const [initialView, setInitialView] = useState("overview");
  const [initialSub, setInitialSub] = useState(null);
  
  const [isFormModalOpen, setIsFormModalOpen] = useState(false);
  const [categoryToEdit, setCategoryToEdit] = useState(null);

  const handleRowClick = (category) => {
    setSelectedCategory(category);
    setInitialView("overview");
    setInitialSub(null);
    setIsDetailModalOpen(true);
  };

  const handleSubcategoryClick = (parentCategory, subcategory) => {
    setSelectedCategory(parentCategory);
    setInitialView("products");
    setInitialSub(subcategory);
    setIsDetailModalOpen(true);
  };

  const handleEditClick = (category) => {
    setCategoryToEdit(category);
    setIsFormModalOpen(true);
    setIsDetailModalOpen(false);
  };

  const handleAddClick = () => {
    setCategoryToEdit(null);
    setIsFormModalOpen(true);
  };

  return (
    <div className="max-w-[1600px] mx-auto pb-10">
      {/* Page Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between mb-8 gap-4">
        <div>
          <h1 className="text-3xl font-black text-slate-800 tracking-tight mb-1">Categories</h1>
          <p className="text-sm font-medium text-slate-500">Organize your products with categories and subcategories</p>
        </div>
        <div className="flex items-center gap-3">
          <button 
            onClick={handleAddClick}
            className="flex items-center px-4 py-2.5 bg-teal-600 text-white rounded-xl text-sm font-bold hover:bg-teal-700 transition-colors shadow-sm"
          >
            <Plus className="w-4 h-4 mr-2" />
            Add New Category
          </button>
        </div>
      </div>

      {/* KPI Cards */}
      <CategoriesKPI
        modalFilter={modalFilter}
        setModalFilter={setModalFilter}
        setIsModalOpen={setIsModalOpen}
      />

      {/* Main Table */}
      <CategoriesTable
        onRowClick={handleRowClick}
        onEditClick={handleEditClick}
      />

      {/* List Modal triggered by KPI Cards */}
      <CategoriesListModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        filter={modalFilter}
        onRowClick={handleRowClick}
        onSubcategoryClick={handleSubcategoryClick}
      />

      {/* Detail Modal triggered by Table Row Click */}
      <CategoryDetailModal
        isOpen={isDetailModalOpen}
        onClose={() => setIsDetailModalOpen(false)}
        category={selectedCategory}
        onEditClick={handleEditClick}
        initialView={initialView}
        initialSubcategory={initialSub}
      />

      {/* Form Modal for Add/Edit Category */}
      <CategoryFormModal
        isOpen={isFormModalOpen}
        onClose={() => setIsFormModalOpen(false)}
        categoryToEdit={categoryToEdit}
      />

    </div>
  );
}
