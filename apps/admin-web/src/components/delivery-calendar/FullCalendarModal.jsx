"use client";

import { useEffect, useState } from "react";
import { X, ChevronLeft, ChevronRight, Calendar as CalendarIcon } from "lucide-react";

export default function FullCalendarModal({ isOpen, onClose }) {
  const [currentDate, setCurrentDate] = useState(new Date());
  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = 'unset';
    }
    return () => { document.body.style.overflow = 'unset'; };
  }, [isOpen]);

  if (!isOpen) return null;

  // Calendar calculations
  const year = currentDate.getFullYear();
  const month = currentDate.getMonth();
  
  const daysInMonth = new Date(year, month + 1, 0).getDate();
  const startDayOfWeek = new Date(year, month, 1).getDay(); // 0 = Sun, 1 = Mon...
  
  const monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
  const currentMonthName = `${monthNames[month]} ${year}`;

  const nextMonth = () => setCurrentDate(new Date(year, month + 1, 1));
  const prevMonth = () => setCurrentDate(new Date(year, month - 1, 1));

  // Mock schedule data mapping
  const deliveriesByDate = {
    // Generate some random deliveries on random days
    5: 12,
    8: 4,
    12: 18,
    15: 22,
    18: 5,
    22: 30,
    25: 14,
    28: 8
  };

  const getDayClasses = (day) => {
    const deliveries = deliveriesByDate[day] || 0;
    if (deliveries === 0) return "bg-white hover:bg-slate-50 text-slate-700";
    if (deliveries < 10) return "bg-teal-50 hover:bg-teal-100 text-teal-800 border-teal-200 font-bold";
    if (deliveries < 20) return "bg-orange-50 hover:bg-orange-100 text-orange-800 border-orange-200 font-bold";
    return "bg-red-50 hover:bg-red-100 text-red-800 border-red-200 font-bold";
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity" onClick={onClose}></div>

      <div className="relative w-full max-w-3xl max-h-[95vh] bg-white rounded-3xl border border-white/60 shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Header */}
        <div className="px-4 sm:px-6 py-3 border-b border-slate-100 flex justify-between items-center bg-white/50">
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 rounded-xl bg-teal-50 border border-teal-100 flex items-center justify-center text-teal-600">
              <CalendarIcon className="w-5 h-5" />
            </div>
            <div>
              <h2 className="text-xl font-black text-slate-800 tracking-tight">Full Calendar</h2>
              <p className="text-xs font-bold text-slate-500 mt-0.5">Overview of deliveries this month</p>
            </div>
          </div>
          
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-xl bg-slate-50 text-slate-400 hover:bg-slate-100 hover:text-slate-600 transition-colors">
            <X className="w-4 h-4" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto hide-scrollbar p-4 sm:p-6 bg-slate-50/50">
          
          {/* Calendar Controls */}
          <div className="flex justify-between items-center mb-4 bg-white p-3 sm:p-4 rounded-2xl border border-slate-100 shadow-sm">
            <h3 className="text-lg font-black text-slate-800">{currentMonthName}</h3>
            <div className="flex gap-2">
              <button onClick={prevMonth} className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors">
                <ChevronLeft className="w-4 h-4" />
              </button>
              <button onClick={nextMonth} className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-600 hover:bg-slate-50 transition-colors">
                <ChevronRight className="w-4 h-4" />
              </button>
            </div>
          </div>

          {/* Calendar Grid */}
          <div className="bg-white rounded-2xl border border-slate-100 shadow-sm overflow-hidden">
            {/* Days of week header */}
            <div className="grid grid-cols-7 border-b border-slate-100 bg-slate-50/50">
              {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(day => (
                <div key={day} className="py-2 sm:py-3 text-center text-[10px] sm:text-xs font-bold text-slate-500 uppercase tracking-wider truncate">
                  <span className="hidden sm:inline">{day}</span>
                  <span className="sm:hidden">{day.charAt(0)}</span>
                </div>
              ))}
            </div>

            {/* Days grid */}
            <div className="grid grid-cols-7 bg-slate-100 gap-px">
              {/* Empty slots for start of month */}
              {[...Array(startDayOfWeek)].map((_, i) => (
                <div key={`empty-${i}`} className="bg-slate-50 min-h-[40px] sm:min-h-[50px] p-1" />
              ))}

              {/* Actual days */}
              {[...Array(daysInMonth)].map((_, i) => {
                const day = i + 1;
                const deliveries = deliveriesByDate[day] || 0;
                
                return (
                  <div key={day} className={`min-h-[40px] sm:min-h-[50px] p-1 flex flex-col transition-colors cursor-pointer border border-transparent min-w-0 ${getDayClasses(day)}`}>
                    <span className="text-xs sm:text-sm font-bold opacity-80 leading-none">{day}</span>
                    
                    {deliveries > 0 && (
                      <div className="mt-auto pt-1">
                        <span className="inline-block px-1 py-0.5 rounded text-[9px] sm:text-[10px] bg-white/50 w-full truncate text-center sm:text-left leading-none">
                          {deliveries} <span className="opacity-70">del.</span>
                        </span>
                      </div>
                    )}
                  </div>
                );
              })}

              {/* Empty slots for end of month */}
              {[...Array(42 - (daysInMonth + startDayOfWeek))].map((_, i) => (
                <div key={`empty-end-${i}`} className="bg-slate-50 min-h-[40px] sm:min-h-[50px] p-1" />
              ))}
            </div>
          </div>

          <div className="flex gap-4 mt-4 justify-center">
             <div className="flex items-center text-xs font-medium text-slate-500">
                <div className="w-3 h-3 rounded bg-teal-100 border border-teal-200 mr-2"></div> Light Load
             </div>
             <div className="flex items-center text-xs font-medium text-slate-500">
                <div className="w-3 h-3 rounded bg-orange-100 border border-orange-200 mr-2"></div> Medium Load
             </div>
             <div className="flex items-center text-xs font-medium text-slate-500">
                <div className="w-3 h-3 rounded bg-red-100 border border-red-200 mr-2"></div> Heavy Load
             </div>
          </div>

        </div>
        
        {/* Footer */}
        <div className="px-4 sm:px-6 py-3 border-t border-slate-100 bg-white/50 flex justify-end">
          <button onClick={onClose} className="px-6 py-2 bg-slate-800 text-white rounded-xl text-sm font-bold hover:bg-slate-900 transition-colors shadow-sm">
            Close
          </button>
        </div>

      </div>
    </div>
  );
}
