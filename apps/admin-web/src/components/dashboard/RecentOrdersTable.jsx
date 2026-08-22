"use client";

export default function RecentOrdersTable({ orders }) {
  const displayOrders = orders || [];
  return (
    <div className="bg-white/80 backdrop-blur-xl rounded-3xl border border-white/60 shadow-[0_4px_20px_rgb(0,0,0,0.03)] p-6 h-full flex flex-col hover:shadow-lg transition-all duration-300">
      <div className="flex justify-between items-center mb-6">
        <h3 className="text-lg font-bold text-slate-800 tracking-tight">Recent Orders</h3>
        <button className="text-xs font-bold text-teal-600 hover:text-teal-700 transition-colors">
          View All
        </button>
      </div>

      <div className="flex-1 flex flex-col">
        
        {/* Desktop Table View */}
        <div className="overflow-x-auto hidden sm:block">
          <table className="w-full text-left border-collapse min-w-[400px]">
            <thead>
              <tr className="text-xs text-slate-500 font-bold border-b border-slate-100">
                <th className="pb-3 font-medium text-slate-400">Order ID</th>
                <th className="pb-3 font-medium text-slate-400">Customer</th>
                <th className="pb-3 font-medium text-slate-400">Amount</th>
                <th className="pb-3 font-medium text-slate-400">Status</th>
              </tr>
            </thead>
            <tbody>
              {displayOrders.map((order, idx) => {
                const statusColor = order.status === "Pending" ? "orange" : order.status === "Completed" ? "green" : order.status === "Cancelled" ? "red" : "blue";
                return (
                <tr key={idx} className="border-b border-slate-50 last:border-0 hover:bg-slate-50 transition-colors">
                  <td className="py-4 text-sm font-bold text-slate-700">{order.orderNumber || order._id}</td>
                  <td className="py-4 text-sm font-medium text-slate-600">{order.user?.displayName || "Guest"}</td>
                  <td className="py-4 text-sm font-bold text-slate-700">₹{(order.totalPaise / 100).toLocaleString()}</td>
                  <td className="py-4">
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-[10px] font-bold bg-${statusColor}-50 text-${statusColor}-700 border border-${statusColor}-100/50`}>
                      <span className={`w-1.5 h-1.5 rounded-full bg-${statusColor}-500 mr-1.5`}></span>
                      {order.status || "Unknown"}
                    </span>
                  </td>
                </tr>
              )})}
            </tbody>
          </table>
        </div>

        {/* Mobile Card View */}
        <div className="sm:hidden space-y-3">
          {displayOrders.map((order, idx) => {
            const statusColor = order.status === "Pending" ? "orange" : order.status === "Completed" ? "green" : order.status === "Cancelled" ? "red" : "blue";
            return (
            <div key={idx} className="bg-slate-50 rounded-2xl p-4 border border-slate-100 flex flex-col hover:shadow-md transition-shadow">
              <div className="flex justify-between items-center mb-3">
                <span className="text-sm font-bold text-slate-800">{order.orderNumber || order._id}</span>
                <span className={`inline-flex items-center px-2.5 py-1 rounded-full text-[10px] font-bold bg-${statusColor}-50 text-${statusColor}-700 border border-${statusColor}-100/50`}>
                  <span className={`w-1.5 h-1.5 rounded-full bg-${statusColor}-500 mr-1`}></span>
                  {order.status || "Unknown"}
                </span>
              </div>
              <div className="flex justify-between items-center">
                <div className="flex flex-col">
                  <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Customer</span>
                  <span className="text-xs font-semibold text-slate-600 mt-0.5">{order.user?.displayName || "Guest"}</span>
                </div>
                <div className="flex flex-col items-end">
                  <span className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Amount</span>
                  <span className="text-sm font-black text-slate-800 mt-0.5">₹{(order.totalPaise / 100).toLocaleString()}</span>
                </div>
              </div>
            </div>
          )})}
        </div>

      </div>
    </div>
  );
}
