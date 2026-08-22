import { Plus, Tag, Bike, FileText } from "lucide-react";

export default function QuickActionGrid() {
  const actions = [
    { title: "Add Product", icon: Plus, color: "emerald" },
    { title: "Create Offer", icon: Tag, color: "blue" },
    { title: "Assign Rider", icon: Bike, color: "orange" },
    { title: "Generate Report", icon: FileText, color: "purple" },
  ];

  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-6">
      {actions.map((action, i) => {
        const Icon = action.icon;
        return (
          <button 
            key={i} 
            className="flex items-center justify-center space-x-3 p-4 bg-white/60 backdrop-blur-md border border-slate-200/50 rounded-2xl shadow-[0_4px_20px_rgb(0,0,0,0.02)] hover:-translate-y-1 hover:shadow-lg hover:border-transparent transition-all duration-300 group relative overflow-hidden"
          >
            <div className="absolute inset-0 bg-gradient-to-r from-emerald-500/0 via-emerald-500/0 to-emerald-500/0 group-hover:from-emerald-500/5 group-hover:to-emerald-500/10 transition-all duration-300"></div>
            <div className={`w-10 h-10 rounded-xl flex items-center justify-center bg-gradient-to-br from-${action.color}-400 to-${action.color}-600 text-white shadow-md shadow-${action.color}-500/20 group-hover:scale-110 transition-transform duration-300 relative z-10`}>
              <Icon className="w-5 h-5" />
            </div>
            <span className="font-bold text-sm text-slate-700 group-hover:text-emerald-700 relative z-10">{action.title}</span>
          </button>
        );
      })}
    </div>
  );
}
