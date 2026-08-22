"use client";

import { Bell, Search, Mail, Menu, X, Receipt, Users, Package, Bike } from "lucide-react";
import { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { useSidebar } from "@/context/SidebarContext";
import ImageModal from "@/components/common/ImageModal";

export default function Topbar() {
  const [searchQuery, setSearchQuery] = useState("");
  const [isMobileSearchOpen, setIsMobileSearchOpen] = useState(false);
  const [searchResults, setSearchResults] = useState([]);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [activeDropdown, setActiveDropdown] = useState(null);
  const [isAvatarModalOpen, setIsAvatarModalOpen] = useState(false);
  const dropdownRef = useRef(null);
  const rightIconsRef = useRef(null);
  const router = useRouter();
  const { setIsOpen } = useSidebar();

  // Handle click outside to close dropdown
  useEffect(() => {
    function handleClickOutside(event) {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target)) {
        setIsDropdownOpen(false);
      }
      if (rightIconsRef.current && !rightIconsRef.current.contains(event.target)) {
        setActiveDropdown(null);
      }
    }
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  // Search Logic
  useEffect(() => {
    if (!searchQuery.trim()) {
      setSearchResults([]);
      return;
    }

    const query = searchQuery.toLowerCase();
    const results = [];


    setSearchResults(results.slice(0, 8)); // Limit to 8 results
    setIsDropdownOpen(true);
  }, [searchQuery]);

  const handleResultClick = (result) => {
    setSearchQuery("");
    setIsDropdownOpen(false);
    setIsMobileSearchOpen(false);
    // Push with a timestamp so it forces a re-render/useEffect trigger if clicking the same order
    router.push(`/orders?viewOrder=${result.id}&t=${Date.now()}`);
  };

  return (
    <>
      {/* Global Blur Overlay when search or dropdowns are active */}
      {(isDropdownOpen || isMobileSearchOpen || activeDropdown) && (
        <div 
          className="fixed inset-0 bg-slate-900/20 backdrop-blur-sm z-40 transition-opacity duration-200"
          onClick={() => {
            setIsDropdownOpen(false);
            setIsMobileSearchOpen(false);
            setActiveDropdown(null);
          }}
        />
      )}

      <header className="h-16 min-h-16 bg-white border-b border-slate-100 flex items-center justify-between px-4 sm:px-8 sticky top-0 z-50">
      
      {/* Left side with hamburger and Search */}
      <div className="flex items-center space-x-4 sm:space-x-6 flex-1">
        <button 
          className="w-10 h-10 flex items-center justify-center text-slate-500 hover:text-teal-600 hover:bg-slate-50 rounded-full transition-colors md:hidden"
          onClick={() => setIsOpen(true)}
        >
          <Menu className="w-6 h-6" />
        </button>
        
        {/* Mobile Search Toggle Icon */}
        <button 
          className="w-10 h-10 flex items-center justify-center sm:hidden text-slate-500 hover:text-teal-600 hover:bg-slate-50 rounded-full transition-colors ml-auto mr-0 sm:mr-4"
          onClick={() => {
            setIsMobileSearchOpen(!isMobileSearchOpen);
            if (isMobileSearchOpen) setSearchQuery("");
          }}
        >
          {isMobileSearchOpen ? <X className="w-6 h-6 text-teal-600" /> : <Search className="w-6 h-6" />}
        </button>

        {/* Search Bar Container */}
        <div 
          ref={dropdownRef}
          className={`
            ${isMobileSearchOpen ? 'absolute top-full left-0 right-0 bg-white border-b border-slate-100 p-4 shadow-sm flex animate-in slide-in-from-top-2' : 'hidden sm:flex'}
            sm:relative sm:inset-auto sm:bg-transparent sm:p-0 sm:border-none sm:shadow-none sm:items-center sm:w-full sm:max-w-xl group z-50
          `}
        >
          <div className="relative w-full">
            <Search className="w-4 h-4 text-slate-400 absolute left-4 top-1/2 -translate-y-1/2 group-focus-within:text-teal-500 transition-colors" />
            <input 
              type="text" 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onFocus={() => { if(searchQuery) setIsDropdownOpen(true); }}
              placeholder="Search orders, customers, products, riders..." 
              className="w-full h-10 pl-11 pr-4 bg-slate-50/50 border border-slate-200/80 rounded-xl focus:outline-none focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 focus:bg-white transition-all text-sm font-medium placeholder-slate-400"
              autoFocus={isMobileSearchOpen}
            />

            {/* Global Search Dropdown */}
            {isDropdownOpen && searchQuery.trim() !== "" && (
              <div className="absolute top-full left-0 right-0 mt-2 bg-white rounded-2xl shadow-[0_10px_40px_rgb(0,0,0,0.1)] border border-slate-100 overflow-hidden z-50 animate-in fade-in slide-in-from-top-2">
                {searchResults.length === 0 ? (
                  <div className="p-6 text-center">
                    <Search className="w-8 h-8 text-slate-200 mx-auto mb-2" />
                    <p className="text-sm font-bold text-slate-600">No results found</p>
                    <p className="text-xs font-medium text-slate-400 mt-1">Try searching for something else</p>
                  </div>
                ) : (
                  <div className="py-2 max-h-[400px] overflow-y-auto hide-scrollbar">
                    {searchResults.map((result, idx) => (
                      <button
                        key={idx}
                        onClick={() => handleResultClick(result)}
                        className="w-full text-left px-4 py-3 hover:bg-slate-50 transition-colors flex items-start space-x-3 group/item border-b border-slate-50 last:border-0"
                      >
                        <div className={`w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ${
                          result.type === 'Order' ? 'bg-blue-50 text-blue-600' :
                          result.type === 'Customer' ? 'bg-purple-50 text-purple-600' :
                          result.type === 'Rider' ? 'bg-orange-50 text-orange-600' :
                          'bg-emerald-50 text-emerald-600'
                        }`}>
                          <result.icon className="w-4 h-4" />
                        </div>
                        <div className="flex flex-col overflow-hidden">
                          <span className="text-sm font-bold text-slate-700 truncate group-hover/item:text-teal-600 transition-colors">{result.title}</span>
                          <span className="text-xs font-medium text-slate-400 truncate mt-0.5">{result.subtitle}</span>
                        </div>
                        <span className="ml-auto text-[9px] font-black uppercase tracking-wider text-slate-300 mt-1">{result.type}</span>
                      </button>
                    ))}
                  </div>
                )}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Right side icons and profile */}
      <div ref={rightIconsRef} className="flex items-center space-x-3 sm:space-x-6 relative z-50">
        
        {/* Notifications */}
        <div>
          <button 
            onClick={() => setActiveDropdown(activeDropdown === 'notifications' ? null : 'notifications')}
            className={`w-10 h-10 flex items-center justify-center rounded-full relative transition-colors ${activeDropdown === 'notifications' ? 'bg-teal-50 text-teal-600' : 'text-slate-600 hover:bg-slate-50 hover:text-teal-600'}`}
          >
            <Bell className="w-6 h-6" />
            <span className="absolute top-2 right-2 w-2.5 h-2.5 bg-teal-500 border-2 border-white rounded-full"></span>
          </button>
          {activeDropdown === 'notifications' && (
            <div className="fixed sm:absolute top-[85px] sm:top-full left-4 right-4 sm:left-auto sm:right-24 sm:mt-4 sm:w-80 bg-white rounded-2xl shadow-[0_10px_40px_rgb(0,0,0,0.1)] border border-slate-100 overflow-hidden animate-in fade-in slide-in-from-top-2 origin-top sm:origin-top-right">
              <div className="p-4 border-b border-slate-100 flex justify-between items-center bg-slate-50">
                <h4 className="font-bold text-slate-800 text-sm">Notifications</h4>
                <span className="text-xs font-bold text-teal-600 cursor-pointer hover:text-teal-700">Mark all read</span>
              </div>
              <div className="p-2 max-h-[300px] overflow-y-auto hide-scrollbar">
                <div className="p-3 hover:bg-slate-50 rounded-xl cursor-pointer transition-colors border-b border-slate-50">
                  <p className="text-sm font-bold text-slate-800">New order #ORD-2025-1251</p>
                  <p className="text-xs text-slate-500 mt-0.5">Aman Kumar placed a new order.</p>
                  <p className="text-[10px] text-slate-400 mt-1 font-semibold uppercase tracking-wider">2 mins ago</p>
                </div>
                <div className="p-3 hover:bg-slate-50 rounded-xl cursor-pointer transition-colors">
                  <p className="text-sm font-bold text-slate-800">Rider delayed</p>
                  <p className="text-xs text-slate-500 mt-0.5">Rahul Singh is delayed by 10 mins.</p>
                  <p className="text-[10px] text-slate-400 mt-1 font-semibold uppercase tracking-wider">15 mins ago</p>
                </div>
              </div>
              <div className="p-3 border-t border-slate-100 text-center cursor-pointer hover:bg-slate-50 transition-colors">
                <span className="text-xs font-bold text-teal-600">View all notifications</span>
              </div>
            </div>
          )}
        </div>

        {/* Messages */}
        <div>
          <button 
            onClick={() => setActiveDropdown(activeDropdown === 'messages' ? null : 'messages')}
            className={`w-10 h-10 flex items-center justify-center rounded-full transition-colors ${activeDropdown === 'messages' ? 'bg-teal-50 text-teal-600' : 'text-slate-600 hover:bg-slate-50 hover:text-teal-600'}`}
          >
            <Mail className="w-6 h-6" />
          </button>
          {activeDropdown === 'messages' && (
            <div className="fixed sm:absolute top-[85px] sm:top-full left-4 right-4 sm:left-auto sm:right-12 sm:mt-4 sm:w-80 bg-white rounded-2xl shadow-[0_10px_40px_rgb(0,0,0,0.1)] border border-slate-100 overflow-hidden animate-in fade-in slide-in-from-top-2 origin-top sm:origin-top-right">
              <div className="p-4 border-b border-slate-100 bg-slate-50">
                <h4 className="font-bold text-slate-800 text-sm">Messages</h4>
              </div>
              <div className="p-8 text-center">
                <Mail className="w-8 h-8 text-slate-200 mx-auto mb-3" />
                <p className="text-sm font-bold text-slate-600">No new messages</p>
                <p className="text-xs font-medium text-slate-400 mt-1">You're all caught up for today!</p>
              </div>
            </div>
          )}
        </div>
        
        <div className="h-8 w-px bg-slate-200 mx-1 sm:mx-2"></div>
        
        {/* Profile */}
        <div>
          <button 
            onClick={() => setActiveDropdown(activeDropdown === 'profile' ? null : 'profile')}
            className="flex items-center space-x-3 hover:opacity-80 transition-opacity ml-1 sm:ml-0"
          >
            <img 
              src="https://api.dicebear.com/7.x/notionists/svg?seed=Admin&backgroundColor=e2e8f0" 
              alt="Admin" 
              className="w-9 h-9 rounded-full bg-slate-100 border border-slate-200"
            />
            <div className="text-left hidden sm:block">
              <p className="text-sm font-bold text-slate-800 leading-tight">Admin User</p>
              <p className="text-xs font-medium text-slate-500">Super Admin</p>
            </div>
          </button>
          {activeDropdown === 'profile' && (
            <div className="fixed sm:absolute top-[85px] sm:top-full left-4 right-4 sm:left-auto sm:right-0 sm:mt-4 sm:w-56 bg-white rounded-2xl shadow-[0_10px_40px_rgb(0,0,0,0.1)] border border-slate-100 overflow-hidden animate-in fade-in slide-in-from-top-2 origin-top sm:origin-top-right">
              <div className="p-4 border-b border-slate-100 bg-slate-50 sm:hidden">
                <p className="text-sm font-bold text-slate-800">Admin User</p>
                <p className="text-xs font-medium text-slate-500">Super Admin</p>
              </div>
              <div className="p-2">
                <div onClick={() => { setActiveDropdown(null); router.push('/profile'); }} className="px-4 py-2.5 hover:bg-slate-50 rounded-xl cursor-pointer text-sm font-semibold text-slate-700 transition-colors">My Profile</div>
                <div onClick={() => { setActiveDropdown(null); router.push('/settings'); }} className="px-4 py-2.5 hover:bg-slate-50 rounded-xl cursor-pointer text-sm font-semibold text-slate-700 transition-colors">Settings</div>
              </div>
              <div className="p-2 border-t border-slate-100">
                <div onClick={() => { setActiveDropdown(null); alert("Logged out!"); }} className="px-4 py-2.5 hover:bg-red-50 rounded-xl cursor-pointer text-sm font-semibold text-red-600 transition-colors">Log out</div>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>

    <ImageModal 
      isOpen={isAvatarModalOpen}
      onClose={() => setIsAvatarModalOpen(false)}
      imageSrc="https://api.dicebear.com/7.x/notionists/svg?seed=Admin&backgroundColor=e2e8f0"
      altText="Admin Avatar"
    />
    </>
  );
}
