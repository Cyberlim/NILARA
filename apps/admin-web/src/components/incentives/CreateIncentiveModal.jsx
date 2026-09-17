"use client";

import { useState } from "react";
import { X, Trophy, Target, Calendar, Clock, Sparkles, Loader2 } from "lucide-react";
import { fetchWithAuth } from "@/lib/api";

const CATEGORIES = [
  {
    id: "Order Target",
    label: "Order Target",
    desc: "Target orders milestone with progress bar (e.g. Complete 10 orders)",
    badge: "Milestone",
    color: "amber"
  },
  {
    id: "Daily Goal",
    label: "Daily Goal",
    desc: "Single-day milestone target (e.g. 15 orders today)",
    badge: "Daily",
    color: "emerald"
  },
  {
    id: "Peak Hour",
    label: "Peak Hour",
    desc: "Specific time-window bonus with Live Now indicator (e.g. 5 PM - 9 PM)",
    badge: "Surge",
    color: "orange"
  },
  {
    id: "Weekend Rush",
    label: "Weekend Rush",
    desc: "Saturday & Sunday high volume challenge (e.g. Sat - Sun bonus)",
    badge: "Weekend",
    color: "blue"
  }
];

export default function CreateIncentiveModal({ isOpen, onClose, onCreated }) {
  const [category, setCategory] = useState("Order Target");
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [targetOrders, setTargetOrders] = useState(10);
  const [rewardAmount, setRewardAmount] = useState(200);
  const [startDate, setStartDate] = useState(new Date().toISOString().split("T")[0]);
  const [endDate, setEndDate] = useState(
    new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString().split("T")[0]
  );
  const [startTime, setStartTime] = useState("17:00");
  const [endTime, setEndTime] = useState("21:00");
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState("");

  if (!isOpen) return null;

  const handleCategoryChange = (catId) => {
    setCategory(catId);
    if (catId === "Order Target" && !title) {
      setTitle("Complete 10 orders");
      setDescription("Earn ₹200 extra");
    } else if (catId === "Daily Goal") {
      setTitle("Daily Goal: 15 Orders");
      setDescription("Earn ₹150 extra today");
      setTargetOrders(15);
      setRewardAmount(150);
    } else if (catId === "Peak Hour") {
      setTitle("Peak Hour Bonus");
      setDescription("Earn extra ₹15 per order");
      setStartTime("17:00");
      setEndTime("21:00");
    } else if (catId === "Weekend Rush") {
      setTitle("Weekend Bonus");
      setDescription("Earn extra ₹100 on 10 orders");
      setTargetOrders(10);
      setRewardAmount(100);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");

    if (!title.trim()) {
      setError("Please enter a campaign title");
      return;
    }
    if (!targetOrders || targetOrders <= 0) {
      setError("Target orders must be at least 1");
      return;
    }
    if (!rewardAmount || rewardAmount <= 0) {
      setError("Reward amount must be at least ₹1");
      return;
    }
    if (!endDate) {
      setError("Please select an end date");
      return;
    }

    try {
      setSubmitting(true);
      const payload = {
        title: title.trim(),
        description: description.trim() || `Earn ₹${rewardAmount} extra on ${targetOrders} orders`,
        category,
        targetOrders: Number(targetOrders),
        rewardAmount: Number(rewardAmount),
        startDate,
        endDate,
        startTime: category === "Peak Hour" ? startTime : "",
        endTime: category === "Peak Hour" ? endTime : "",
        status: "Active"
      };

      await fetchWithAuth("/admin/incentives", {
        method: "POST",
        body: JSON.stringify(payload)
      });

      if (onCreated) onCreated();
      onClose();
    } catch (err) {
      setError(err.message || "Failed to create incentive campaign");
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6">
      <div className="absolute inset-0 bg-slate-900/40 backdrop-blur-sm" onClick={onClose} />
      
      <div className="relative w-full max-w-2xl bg-white rounded-3xl shadow-2xl flex flex-col max-h-[92vh] overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        
        {/* Modal Header */}
        <div className="flex items-center justify-between p-6 border-b border-slate-100 bg-slate-50/50">
          <div>
            <h2 className="text-xl font-black text-slate-800 flex items-center gap-2">
              <Sparkles className="w-5 h-5 text-teal-600" />
              New Incentive Campaign
            </h2>
            <p className="text-xs font-medium text-slate-500 mt-1">
              Define delivery bonuses with real wallet reward payout.
            </p>
          </div>
          <button 
            onClick={onClose}
            className="w-10 h-10 flex items-center justify-center rounded-full bg-white text-slate-500 hover:text-slate-800 hover:bg-slate-100 shadow-sm transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Modal Form */}
        <form onSubmit={handleSubmit} className="p-6 overflow-y-auto custom-scrollbar space-y-5">
          {error && (
            <div className="p-3.5 bg-red-50 border border-red-200 rounded-xl text-xs font-bold text-red-700">
              {error}
            </div>
          )}

          {/* 1. Category Selection */}
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-2">
              Incentive Category (Delivery App Format)
            </label>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              {CATEGORIES.map((cat) => (
                <div
                  key={cat.id}
                  onClick={() => handleCategoryChange(cat.id)}
                  className={`cursor-pointer p-3.5 rounded-2xl border transition-all ${
                    category === cat.id
                      ? "border-teal-600 bg-teal-50/40 ring-2 ring-teal-600/20"
                      : "border-slate-200 hover:border-slate-300 bg-white"
                  }`}
                >
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-sm font-bold text-slate-800">{cat.label}</span>
                    <span className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-slate-100 text-slate-600">
                      {cat.badge}
                    </span>
                  </div>
                  <p className="text-[11px] text-slate-500 leading-snug">{cat.desc}</p>
                </div>
              ))}
            </div>
          </div>

          {/* 2. Title & Subtitle */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5">
                Campaign Title *
              </label>
              <input
                type="text"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="e.g. Complete 10 orders"
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 outline-none"
                required
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5">
                Description / Subtitle
              </label>
              <input
                type="text"
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="e.g. Earn ₹200 extra"
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 outline-none"
              />
            </div>
          </div>

          {/* 3. Target Orders & Reward Amount */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5 flex items-center gap-1.5">
                <Target className="w-3.5 h-3.5 text-slate-400" />
                Target Delivered Orders *
              </label>
              <input
                type="number"
                min="1"
                value={targetOrders}
                onChange={(e) => setTargetOrders(e.target.value)}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 outline-none"
                required
              />
              <p className="text-[11px] text-slate-400 mt-1">Orders rider must deliver to unlock bonus</p>
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5 flex items-center gap-1.5">
                <Trophy className="w-3.5 h-3.5 text-amber-500" />
                Reward Amount (₹) *
              </label>
              <input
                type="number"
                min="1"
                value={rewardAmount}
                onChange={(e) => setRewardAmount(e.target.value)}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-bold text-teal-600 focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 outline-none"
                required
              />
              <p className="text-[11px] text-slate-400 mt-1">Credited directly to delivery wallet balance</p>
            </div>
          </div>

          {/* 4. Dates */}
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5 flex items-center gap-1.5">
                <Calendar className="w-3.5 h-3.5 text-slate-400" />
                Start Date *
              </label>
              <input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 outline-none"
                required
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-slate-500 mb-1.5 flex items-center gap-1.5">
                <Calendar className="w-3.5 h-3.5 text-slate-400" />
                End Date *
              </label>
              <input
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-sm font-medium focus:ring-2 focus:ring-teal-500/20 focus:border-teal-500 outline-none"
                required
              />
            </div>
          </div>

          {/* 5. Peak Hour Time Window (if selected) */}
          {category === "Peak Hour" && (
            <div className="p-4 bg-orange-50/60 border border-orange-100 rounded-2xl">
              <label className="block text-xs font-bold uppercase tracking-wider text-orange-800 mb-2 flex items-center gap-1.5">
                <Clock className="w-3.5 h-3.5 text-orange-600" />
                Peak Hour Window
              </label>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="text-[10px] font-bold text-slate-500 mb-1 block">Start Time</label>
                  <input
                    type="time"
                    value={startTime}
                    onChange={(e) => setStartTime(e.target.value)}
                    className="w-full px-3 py-2 bg-white border border-orange-200 rounded-xl text-sm font-bold"
                  />
                </div>
                <div>
                  <label className="text-[10px] font-bold text-slate-500 mb-1 block">End Time</label>
                  <input
                    type="time"
                    value={endTime}
                    onChange={(e) => setEndTime(e.target.value)}
                    className="w-full px-3 py-2 bg-white border border-orange-200 rounded-xl text-sm font-bold"
                  />
                </div>
              </div>
            </div>
          )}

          {/* Modal Actions */}
          <div className="pt-4 border-t border-slate-100 flex justify-end gap-3">
            <button
              type="button"
              onClick={onClose}
              className="px-5 py-2.5 bg-white border border-slate-200 text-slate-700 rounded-xl text-sm font-bold hover:bg-slate-50 transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={submitting}
              className="flex items-center px-6 py-2.5 bg-teal-600 hover:bg-teal-700 text-white rounded-xl text-sm font-bold transition-colors shadow-sm disabled:opacity-50"
            >
              {submitting ? (
                <>
                  <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  Creating...
                </>
              ) : (
                "Publish Incentive"
              )}
            </button>
          </div>

        </form>
      </div>
    </div>
  );
}
