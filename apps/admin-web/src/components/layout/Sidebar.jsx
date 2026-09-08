"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { 
  Home, ShoppingBag, Grid, PackageSearch, Receipt, Users, Bike,
  Calendar, CreditCard, Droplets, MapPin, BadgeDollarSign, HeartHandshake,
  Megaphone, Tag, Image as ImageIcon, Wallet, Banknote, FileText, BadgeCheck, X,
  Mail, Bell, User, Settings, Layers, LogOut, MessageSquare, Star
} from "lucide-react";
import { useSidebar } from "@/context/SidebarContext";
import { useAuth } from "@/context/AuthContext";
import ImageModal from "@/components/common/ImageModal";
import { useState } from "react";

const SIDEBAR_GROUPS = [
  {
    items: [
      { title: "Dashboard", path: "/", icon: Home }
    ]
  },
  {
    label: "COMMERCE",
    items: [
      { title: "Orders", path: "/orders", icon: Receipt },
      { title: "Bulk Orders", path: "/bulk-orders", icon: Layers },
      { title: "Products", path: "/products", icon: ShoppingBag },
      { title: "Categories", path: "/categories", icon: Grid },
      { title: "Inventory", path: "/inventory", icon: PackageSearch },
      { title: "Reviews", path: "/reviews", icon: Star },
    ]
  },
  {
    label: "SUBSCRIBERS",
    items: [
      { title: "Subscribers", path: "/subscriptions", icon: Calendar },
      { title: "Delivery Calendar", path: "/delivery-calendar", icon: MapPin },
      { title: "Plans", path: "/plans", icon: FileText },
    ]
  },
  {
    label: "CUSTOMERS",
    items: [
      { title: "Customers", path: "/customers", icon: Users },
      { title: "Wallets", path: "/wallets", icon: Wallet },
      { title: "Live Chat", path: "/chat", icon: MessageSquare },
    ]
  },
  {
    label: "DELIVERY",
    items: [
      { title: "Live Deliveries", path: "/live-deliveries", icon: Bike },
      { title: "Delivery Partners", path: "/delivery-partners", icon: Users },
      { title: "Assignments", path: "/assignments", icon: FileText },
      { title: "Earnings", path: "/earnings", icon: BadgeDollarSign },
      { title: "Withdrawals", path: "/withdrawals", icon: Banknote },
      { title: "Incentives", path: "/incentives", icon: HeartHandshake },
    ]
  },
  {
    label: "GROWTH",
    items: [
      { title: "Banners", path: "/banners", icon: ImageIcon },
      { title: "Offers & Coupons", path: "/offers", icon: Tag },
      { title: "Marketing", path: "/marketing", icon: Megaphone },
    ]
  },
  {
    label: "FINANCE",
    items: [
      { title: "Payments", path: "/payments", icon: CreditCard },
      { title: "Refunds", path: "/refunds", icon: Banknote },
    ]
  },
  {
    label: "ANALYTICS",
    items: [
      { title: "Reports", path: "/reports", icon: FileText },
      { title: "Staff", path: "/staff", icon: BadgeCheck },
    ]
  },
  {
    label: "SYSTEM & ACCOUNT",
    items: [
      { title: "Messages", path: "/messages", icon: Mail },
      { title: "Notifications", path: "/notifications", icon: Bell },
      { title: "My Profile", path: "/profile", icon: User },
      { title: "Settings", path: "/settings", icon: Settings },
    ]
  }
];

export default function Sidebar() {
  const pathname = usePathname();
  const { isOpen, setIsOpen } = useSidebar();
  const { logout } = useAuth();
  const [isLogoModalOpen, setIsLogoModalOpen] = useState(false);

  return (
    <>
      {/* Mobile Backdrop */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-40 md:hidden transition-opacity duration-300"
          onClick={() => setIsOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`w-64 bg-white border-r border-slate-200 h-screen flex flex-col fixed md:sticky top-0 left-0 z-50 transition-transform duration-300 ease-in-out ${isOpen ? "translate-x-0 shadow-2xl" : "-translate-x-full md:translate-x-0"}`}>
        <div className="h-16 min-h-16 flex items-center justify-between px-5 border-b border-slate-100 flex-shrink-0">
          <div 
            className="flex items-center cursor-pointer hover:opacity-80 transition-opacity"
            onClick={() => setIsLogoModalOpen(true)}
          >
            <div className="w-8 h-10 flex items-center justify-center mr-3 relative">
              <div className="absolute inset-0 bg-gradient-to-br from-cyan-400 to-blue-500 rounded-full" style={{ borderRadius: '50% 50% 0 50%', transform: 'rotate(-45deg)'}}></div>
              <Droplets className="w-4 h-4 text-white relative z-10" />
            </div>
            <div>
              <h1 className="text-xl font-black tracking-tight text-slate-800 leading-tight">Nilara</h1>
              <p className="text-[10px] font-bold text-slate-500 tracking-wide uppercase">Pure life. Delivered.</p>
            </div>
          </div>
          
          <button 
            className="md:hidden w-8 h-8 flex items-center justify-center rounded-full bg-slate-50 text-slate-500 hover:text-slate-800"
            onClick={() => setIsOpen(false)}
          >
            <X className="w-4 h-4" />
          </button>
        </div>

      <nav className="flex-1 overflow-y-auto py-4 px-4 hide-scrollbar">
        {SIDEBAR_GROUPS.map((group, gIdx) => (
          <div key={gIdx} className="mb-6">
            {group.label && (
              <h3 className="text-[10px] font-bold text-slate-400 tracking-widest uppercase mb-2 px-3">
                {group.label}
              </h3>
            )}
            <ul className="space-y-1">
              {group.items.map((item, iIdx) => {
                const isActive = pathname === item.path || (item.path !== "/" && pathname.startsWith(item.path));
                return (
                  <li key={iIdx}>
                    <Link 
                      href={item.path}
                      className={`flex items-center px-3 py-2.5 rounded-xl transition-all duration-200 group ${
                        isActive 
                          ? "bg-teal-50/80 text-teal-700 font-bold border border-teal-100/50 shadow-sm" 
                          : "text-slate-600 hover:bg-slate-50 hover:text-teal-600 font-medium border border-transparent"
                      }`}
                    >
                      <item.icon 
                        className={`w-4 h-4 mr-3 transition-transform duration-200 ${
                          isActive ? "text-teal-600" : "text-slate-400 group-hover:scale-110 group-hover:text-teal-500"
                        }`} 
                      />
                      <span className="text-sm truncate">{item.title}</span>
                    </Link>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </nav>
      <div className="p-4 border-t border-slate-100 flex items-center justify-between">
        <p className="text-xs text-slate-400 font-medium">Nilara Admin v2.0.0</p>
        <button 
          onClick={logout}
          className="p-2 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-lg transition-colors group"
          title="Log Out"
        >
          <LogOut className="w-4 h-4 transition-transform group-hover:scale-110" />
        </button>
      </div>
    </aside>

    <ImageModal 
      isOpen={isLogoModalOpen}
      onClose={() => setIsLogoModalOpen(false)}
    >
      <div className="flex items-center p-8 bg-slate-50/50 rounded-3xl">
        <div className="w-16 h-20 flex items-center justify-center mr-6 relative">
          <div className="absolute inset-0 bg-gradient-to-br from-cyan-400 to-blue-500 rounded-full shadow-lg" style={{ borderRadius: '50% 50% 0 50%', transform: 'rotate(-45deg)'}}></div>
          <Droplets className="w-8 h-8 text-white relative z-10" />
        </div>
        <div>
          <h1 className="text-5xl font-black tracking-tight text-slate-800 leading-tight mb-2">Nilara</h1>
          <p className="text-sm font-bold text-slate-500 tracking-widest uppercase">Pure life. Delivered.</p>
        </div>
      </div>
    </ImageModal>
    </>
  );
}
