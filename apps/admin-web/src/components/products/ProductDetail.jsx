import { useState } from "react";
import {
  Package, Tag, IndianRupee,
  BarChart2, Calendar, Pencil, Save
} from "lucide-react";

const STOCK_COLORS = { "In Stock": "green", "Low Stock": "orange", "Out of Stock": "red" };
const STATUS_COLORS = { "Active": "green", "Inactive": "red" };

export default function ProductDetail({ product, isEditing = false }) {
  const [editData, setEditData] = useState({ ...product });
  
  if (!product) return null;
  
  const stockColor = STOCK_COLORS[product.stockStatus] || "slate";
  const statusColor = STATUS_COLORS[product.status] || "slate";

  const Field = ({ label, value, editKey, type = "text" }) => (
    <div>
      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">{label}</p>
      {isEditing && editKey ? (
        <input
          type={type}
          value={editData[editKey] ?? ""}
          onChange={e => setEditData(prev => ({ ...prev, [editKey]: e.target.value }))}
          className="w-full text-sm font-semibold text-slate-800 bg-slate-50 border border-teal-300 rounded-lg px-3 py-1.5 focus:outline-none focus:ring-2 focus:ring-teal-500/20"
        />
      ) : (
        <p className="text-sm font-semibold text-slate-800">{value}</p>
      )}
    </div>
  );

  return (
    <div className="space-y-4 animate-in slide-in-from-right-4 duration-300">
      {/* Product Hero */}
      <div className="bg-gradient-to-br from-teal-50 to-cyan-50 rounded-2xl p-5 border border-teal-100/50 flex items-start gap-4">
        <div className="w-16 h-16 rounded-2xl bg-white border border-teal-100 shadow-sm flex items-center justify-center text-4xl flex-shrink-0">
          {product.image ? (
            <img src={product.image} alt={product.name} className="w-full h-full object-cover rounded-2xl" />
          ) : (
            <span className="text-4xl">📦</span>
          )}
        </div>
        <div className="flex-1 min-w-0">
          <h3 className="text-lg font-black text-slate-800 leading-tight">{product.name}</h3>
          <p className="text-sm text-slate-500 mt-0.5">{product.variant}</p>
          <div className="flex flex-wrap gap-2 mt-2">
            <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${statusColor}-50 text-${statusColor}-700 border border-${statusColor}-100`}>
              <span className={`w-1.5 h-1.5 rounded-full bg-${statusColor}-500 mr-1.5`}></span>
              {product.status}
            </span>
            <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${stockColor}-50 text-${stockColor}-700 border border-${stockColor}-100`}>
              <span className={`w-1.5 h-1.5 rounded-full bg-${stockColor}-500 mr-1.5`}></span>
              {product.stockStatus}
            </span>
          </div>
        </div>
      </div>

      {/* Core Info */}
      <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm">
        <h4 className="text-sm font-bold text-slate-700 mb-4 flex items-center">
          <Package className="w-4 h-4 mr-2 text-slate-400" /> Product Info
        </h4>
        <div className="grid grid-cols-2 gap-4">
          <Field label="SKU" value={product.sku} editKey="sku" />
          <Field label="Category" value={product.category} />
          <Field label="Price" value={`₹${product.price}`} editKey="price" type="number" />
          <Field label="MRP" value={product.mrp ? `₹${product.mrp}` : "—"} editKey="mrp" type="number" />
        </div>
      </div>

      {/* Stock & Sales */}
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-3 flex items-center">
            <Tag className="w-3 h-3 mr-1" /> Stock
          </p>
          {isEditing ? (
            <input
              type="number"
              value={editData.stock}
              onChange={e => setEditData(prev => ({ ...prev, stock: Number(e.target.value) }))}
              className="w-full text-2xl font-black text-slate-800 bg-slate-50 border border-teal-300 rounded-lg px-3 py-1.5 focus:outline-none focus:ring-2 focus:ring-teal-500/20"
            />
          ) : (
            <p className="text-2xl font-black text-slate-800">{product.stock?.toLocaleString()}</p>
          )}
          <p className={`text-xs font-bold text-${stockColor}-600 mt-1`}>{product.stockStatus}</p>
        </div>
        <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-3 flex items-center">
            <BarChart2 className="w-3 h-3 mr-1" /> Sales
          </p>
          <p className="text-2xl font-black text-slate-800">{product.sales?.toLocaleString()}</p>
          <p className="text-xs font-bold text-slate-400 mt-1">units sold</p>
        </div>
      </div>

      {/* Pricing breakdown */}
      <div className="bg-white rounded-2xl p-5 border border-slate-100 shadow-sm">
        <h4 className="text-sm font-bold text-slate-700 mb-4 flex items-center">
          <IndianRupee className="w-4 h-4 mr-2 text-slate-400" /> Pricing
        </h4>
        <div className="space-y-2">
          <div className="flex justify-between py-2 border-b border-slate-50">
            <span className="text-sm text-slate-500 font-medium">Selling Price</span>
            <span className="text-sm font-black text-teal-600">₹{product.price}</span>
          </div>
          {product.mrp && (
            <div className="flex justify-between py-2 border-b border-slate-50">
              <span className="text-sm text-slate-500 font-medium">MRP</span>
              <span className="text-sm font-semibold text-slate-400 line-through">₹{product.mrp}</span>
            </div>
          )}
          {product.mrp && (
            <div className="flex justify-between py-2">
              <span className="text-sm text-slate-500 font-medium">Discount</span>
              <span className="text-sm font-bold text-green-600">
                ₹{product.mrp - product.price} ({Math.round(((product.mrp - product.price) / product.mrp) * 100)}% off)
              </span>
            </div>
          )}
        </div>
      </div>

      {/* Last Updated */}
      <div className="bg-white rounded-2xl p-4 border border-slate-100 shadow-sm flex items-center gap-3">
        <div className="w-8 h-8 rounded-full bg-slate-50 flex items-center justify-center">
          <Calendar className="w-4 h-4 text-slate-400" />
        </div>
        <div>
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Last Updated</p>
          <p className="text-sm font-semibold text-slate-700 mt-0.5">{product.updatedDate} at {product.updatedTime}</p>
        </div>
      </div>
    </div>
  );
}
