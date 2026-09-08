"use client";

import React, { useState, useEffect } from "react";
import { Star, CheckCircle, XCircle, Search, Filter } from "lucide-react";
import { fetchWithAuth } from "@/lib/api";

export default function ReviewsPage() {
  const [reviews, setReviews] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [filter, setFilter] = useState("pending");
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    loadReviews();
  }, [filter]);

  const loadReviews = async () => {
    setIsLoading(true);
    try {
      const data = await fetchWithAuth(`/admin/reviews?status=${filter}`);
      if (data.success) {
        setReviews(data.reviews);
      }
    } catch (error) {
      console.error("Failed to load reviews:", error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleUpdateStatus = async (reviewId, newStatus) => {
    try {
      const data = await fetchWithAuth(`/admin/reviews/${reviewId}/status`, {
        method: 'PATCH',
        body: JSON.stringify({ status: newStatus })
      });
      if (data.success) {
        // Remove from list if we are filtering by status, or just update it
        loadReviews();
      }
    } catch (error) {
      console.error("Failed to update status:", error);
    }
  };

  const filteredReviews = reviews.filter(r => 
    r.product?.name?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    r.user?.displayName?.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800">Product Reviews</h1>
          <p className="text-slate-500">Manage and moderate customer reviews.</p>
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
        <div className="p-4 border-b border-slate-200 flex flex-col sm:flex-row gap-4 items-center justify-between bg-slate-50/50">
          <div className="flex gap-2">
            {['pending', 'approved', 'rejected'].map(status => (
              <button
                key={status}
                onClick={() => setFilter(status)}
                className={`px-4 py-2 rounded-xl text-sm font-medium transition-colors capitalize ${
                  filter === status 
                    ? 'bg-white text-teal-600 shadow-sm border border-slate-200' 
                    : 'text-slate-500 hover:bg-white hover:text-slate-700'
                }`}
              >
                {status}
              </button>
            ))}
          </div>
          <div className="relative w-full sm:w-64">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-1/2 -translate-y-1/2" />
            <input 
              type="text" 
              placeholder="Search product or user..." 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-4 py-2 bg-white border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-teal-500/20 outline-none"
            />
          </div>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-slate-50 text-slate-500 font-medium border-b border-slate-200">
              <tr>
                <th className="px-6 py-4">Product</th>
                <th className="px-6 py-4">User</th>
                <th className="px-6 py-4">Rating & Comment</th>
                <th className="px-6 py-4">Date</th>
                <th className="px-6 py-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {isLoading ? (
                <tr>
                  <td colSpan="5" className="px-6 py-8 text-center text-slate-400">Loading reviews...</td>
                </tr>
              ) : filteredReviews.length === 0 ? (
                <tr>
                  <td colSpan="5" className="px-6 py-8 text-center text-slate-400">No {filter} reviews found.</td>
                </tr>
              ) : (
                filteredReviews.map((review) => (
                  <tr key={review._id} className="hover:bg-slate-50 transition-colors group">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        {review.product?.images?.[0] ? (
                          <img src={review.product.images[0]} alt={review.product.name} className="w-10 h-10 rounded-lg object-cover bg-slate-100" />
                        ) : (
                          <div className="w-10 h-10 rounded-lg bg-slate-100 flex items-center justify-center">
                            <Star className="w-4 h-4 text-slate-400" />
                          </div>
                        )}
                        <div>
                          <p className="font-bold text-slate-800">{review.product?.name || 'Unknown Product'}</p>
                          <p className="text-xs text-slate-500 truncate max-w-[150px]">{review.product?._id}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <p className="font-medium text-slate-700">{review.user?.displayName || 'Anonymous'}</p>
                      <p className="text-xs text-slate-500">{review.user?.email}</p>
                    </td>
                    <td className="px-6 py-4 max-w-md">
                      <div className="flex items-center gap-1 mb-1">
                        {[...Array(5)].map((_, i) => (
                          <Star key={i} className={`w-4 h-4 ${i < review.rating ? 'text-yellow-400 fill-yellow-400' : 'text-slate-200'}`} />
                        ))}
                      </div>
                      <p className="text-slate-600 line-clamp-2">{review.comment || <span className="italic text-slate-400">No comment</span>}</p>
                    </td>
                    <td className="px-6 py-4 text-slate-500">
                      {new Date(review.createdAt).toLocaleDateString()}
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                        {filter !== 'approved' && (
                          <button 
                            onClick={() => handleUpdateStatus(review._id, 'approved')}
                            className="p-2 text-green-600 hover:bg-green-50 rounded-lg transition-colors"
                            title="Approve"
                          >
                            <CheckCircle className="w-5 h-5" />
                          </button>
                        )}
                        {filter !== 'rejected' && (
                          <button 
                            onClick={() => handleUpdateStatus(review._id, 'rejected')}
                            className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                            title="Reject"
                          >
                            <XCircle className="w-5 h-5" />
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
