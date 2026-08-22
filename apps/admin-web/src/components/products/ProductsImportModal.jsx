"use client";

import { useState, useEffect, useRef } from "react";
import { X, Upload, FileSpreadsheet, Download, AlertCircle, CheckCircle2 } from "lucide-react";

export default function ProductsImportModal({ isOpen, onClose }) {
  const [dragActive, setDragActive] = useState(false);
  const [selectedFile, setSelectedFile] = useState(null);
  const [isImporting, setIsImporting] = useState(false);
  const inputRef = useRef(null);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
      setSelectedFile(null);
      setIsImporting(false);
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  const handleDrag = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (e.type === "dragenter" || e.type === "dragover") {
      setDragActive(true);
    } else if (e.type === "dragleave") {
      setDragActive(false);
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setDragActive(false);
    if (e.dataTransfer.files && e.dataTransfer.files[0]) {
      handleFileSelect(e.dataTransfer.files[0]);
    }
  };

  const handleChange = (e) => {
    e.preventDefault();
    if (e.target.files && e.target.files[0]) {
      handleFileSelect(e.target.files[0]);
    }
  };

  const handleFileSelect = (file) => {
    // Only accept csv or excel
    if (file.name.endsWith('.csv') || file.name.endsWith('.xlsx')) {
      setSelectedFile(file);
    } else {
      alert("Please upload a .csv or .xlsx file");
    }
  };

  const handleImport = () => {
    if (!selectedFile) return;
    setIsImporting(true);
    // Simulate network delay for import processing
    setTimeout(() => {
      setIsImporting(false);
      alert(`Successfully imported ${selectedFile.name}.\n24 new products added, 0 errors.`);
      onClose();
    }, 2000);
  };

  const handleDownloadTemplate = () => {
    const headers = ["Name,Variant,SKU,Category,Price,MRP,Stock,Status"];
    const exampleRow = ['"Nilara 20L Jar","Pack of 2 | Combo","NIL-20L-2PK","Combos",230,240,78,"Active"'];
    const csv = [headers, exampleRow].join("\n");
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'products_import_template.csv';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
      {/* Backdrop */}
      <div 
        className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity"
        onClick={onClose}
      ></div>

      {/* Modal Container */}
      <div className="relative w-full max-w-lg bg-white/90 backdrop-blur-xl rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <div>
            <h2 className="text-lg font-black text-slate-800 tracking-tight">Bulk Import Products</h2>
            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mt-0.5">Upload CSV or Excel</p>
          </div>
          <button 
            onClick={onClose}
            className="w-8 h-8 flex items-center justify-center rounded-full bg-slate-100 hover:bg-slate-200 text-slate-500 transition-colors"
          >
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 overflow-y-auto custom-scrollbar space-y-6">
          
          {/* Instructions */}
          <div className="bg-teal-50 border border-teal-100 rounded-2xl p-4 flex items-start gap-3">
            <AlertCircle className="w-5 h-5 text-teal-600 flex-shrink-0 mt-0.5" />
            <div>
              <p className="text-sm font-bold text-teal-800">Before you upload</p>
              <p className="text-xs text-teal-600 mt-1">Please ensure your file matches our required format. You can download our template to get started.</p>
              <button 
                onClick={handleDownloadTemplate}
                className="mt-3 inline-flex items-center text-xs font-bold text-teal-700 bg-white px-3 py-1.5 rounded-lg border border-teal-200 hover:bg-teal-50 transition-colors shadow-sm"
              >
                <Download className="w-3.5 h-3.5 mr-1.5" />
                Download Template
              </button>
            </div>
          </div>

          {/* Drag & Drop Zone */}
          <div>
            <h3 className="text-xs font-bold text-slate-700 uppercase tracking-widest mb-3">Upload File</h3>
            <div 
              className={`border-2 border-dashed rounded-2xl p-8 flex flex-col items-center justify-center text-center transition-colors ${
                dragActive ? "border-teal-400 bg-teal-50/50" : selectedFile ? "border-teal-200 bg-teal-50/30" : "border-slate-200 bg-slate-50 hover:bg-slate-100/50 hover:border-slate-300"
              }`}
              onDragEnter={handleDrag}
              onDragLeave={handleDrag}
              onDragOver={handleDrag}
              onDrop={handleDrop}
            >
              {selectedFile ? (
                <>
                  <div className="w-12 h-12 rounded-xl bg-teal-100 flex items-center justify-center text-teal-600 mb-3">
                    <FileSpreadsheet className="w-6 h-6" />
                  </div>
                  <p className="text-sm font-bold text-slate-800">{selectedFile.name}</p>
                  <p className="text-xs text-slate-500 mt-1">{(selectedFile.size / 1024).toFixed(1)} KB</p>
                  <button 
                    onClick={() => setSelectedFile(null)}
                    className="mt-4 text-xs font-bold text-red-500 hover:text-red-600"
                  >
                    Remove File
                  </button>
                </>
              ) : (
                <>
                  <div className="w-12 h-12 rounded-xl bg-white shadow-sm border border-slate-100 flex items-center justify-center text-slate-400 mb-3">
                    <Upload className="w-6 h-6" />
                  </div>
                  <p className="text-sm font-bold text-slate-800">Drag & drop your file here</p>
                  <p className="text-xs text-slate-500 mt-1 mb-4">or click to browse from your computer</p>
                  <input
                    ref={inputRef}
                    type="file"
                    accept=".csv,.xlsx"
                    className="hidden"
                    onChange={handleChange}
                  />
                  <button 
                    onClick={() => inputRef.current.click()}
                    className="px-4 py-2 bg-white border border-slate-200 rounded-xl text-xs font-bold text-slate-700 hover:bg-slate-50 transition-colors shadow-sm"
                  >
                    Select File
                  </button>
                </>
              )}
            </div>
          </div>

        </div>

        {/* Footer Actions */}
        <div className="px-6 py-4 border-t border-slate-100 bg-slate-50/50 flex justify-end gap-3">
          <button 
            onClick={onClose}
            className="px-5 py-2.5 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-200 bg-slate-100 transition-colors"
          >
            Cancel
          </button>
          <button 
            onClick={handleImport}
            disabled={!selectedFile || isImporting}
            className="px-5 py-2.5 rounded-xl text-sm font-bold text-white bg-teal-600 hover:bg-teal-700 transition-colors shadow-sm flex items-center disabled:opacity-70 disabled:cursor-not-allowed"
          >
            {isImporting ? (
              <span className="flex items-center">
                <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Importing...
              </span>
            ) : (
              <>
                <CheckCircle2 className="w-4 h-4 mr-2" />
                Upload & Import
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
