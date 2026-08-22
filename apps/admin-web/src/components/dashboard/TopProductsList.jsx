"use client";

export default function TopProductsList({ products }) {
  const displayProducts = products || [];
  return (
    <div className="bg-white/80 backdrop-blur-xl rounded-3xl border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-6 h-full flex flex-col hover:shadow-lg transition-all duration-300">
      <div className="flex justify-between items-center mb-6">
        <h3 className="text-lg font-bold text-slate-800 tracking-tight">Top Products</h3>
        <button className="text-xs font-bold text-teal-600 hover:text-teal-700 transition-colors">
          View All
        </button>
      </div>

      <div className="flex-1 flex flex-col justify-between space-y-4 overflow-y-auto">
        {displayProducts.length > 0 ? displayProducts.map((product, idx) => (
          <div key={idx} className="flex items-center justify-between border-b border-slate-50 pb-4 last:border-0 last:pb-0 hover:bg-slate-50 transition-colors rounded-xl px-2 -mx-2">
            <div className="flex items-center space-x-4">
              <div className="w-10 h-14 rounded-lg bg-slate-100 flex items-center justify-center overflow-hidden">
                {product.image ? (
                  <img src={product.image} alt={product.name} className="w-full h-full object-cover" />
                ) : (
                  <span className="font-bold text-slate-300 text-[10px]">IMG</span>
                )}
              </div>
              <div>
                <h4 className="font-bold text-slate-700 text-sm mb-0.5">{product.name}</h4>
                <div className="flex items-center text-xs">
                  <span className="text-slate-500">{product.sales} sold</span>
                  <span className={`ml-3 font-bold ${product.trendUp ? 'text-teal-600' : 'text-red-500'}`}>{product.trend}%</span>
                </div>
              </div>
            </div>
          </div>
        )) : <div className="text-sm text-slate-400">No products data available.</div>}
      </div>
    </div>
  );
}
