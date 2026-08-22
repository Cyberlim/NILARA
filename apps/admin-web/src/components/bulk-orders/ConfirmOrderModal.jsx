import { useState, useEffect } from 'react';
import { X } from 'lucide-react';

export function ConfirmOrderModal({ isOpen, onClose, onConfirm, order }) {
  const [advanceAmount, setAdvanceAmount] = useState('');
  const [adminMessage, setAdminMessage] = useState('Your order is confirmed. Please pay the token advance money to proceed.');

  // Reset states when modal opens with a new order
  useEffect(() => {
    if (isOpen) {
      setAdvanceAmount('');
      setAdminMessage('Your order is confirmed. Please pay the token advance money to proceed.');
    }
  }, [isOpen, order]);

  if (!isOpen || !order) return null;

  const totalAmount = order.totalPrice || 0;
  const advance = parseFloat(advanceAmount) || 0;
  const remaining = Math.max(0, totalAmount - advance);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (advance < 0 || advance > totalAmount) {
      alert("Advance amount must be between 0 and total amount.");
      return;
    }
    
    onConfirm({
      advancePayment: advance,
      remainingPayment: remaining,
      adminMessage: adminMessage.trim()
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/50 backdrop-blur-sm">
      <div className="bg-white rounded-2xl w-full max-w-md shadow-xl overflow-hidden animate-in fade-in zoom-in-95 duration-200">
        <div className="flex items-center justify-between p-6 border-b border-slate-100">
          <h2 className="text-xl font-semibold text-slate-800">Confirm Order</h2>
          <button 
            onClick={onClose}
            className="p-2 text-slate-400 hover:text-slate-600 hover:bg-slate-100 rounded-full transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-6">
          <div className="bg-slate-50 p-4 rounded-xl border border-slate-100">
            <div className="flex justify-between items-center mb-2">
              <span className="text-sm font-medium text-slate-500">Order ID</span>
              <span className="font-semibold text-slate-800">#{order._id.substring(order._id.length - 6).toUpperCase()}</span>
            </div>
            <div className="flex justify-between items-center">
              <span className="text-sm font-medium text-slate-500">Total Price</span>
              <span className="font-semibold text-slate-800">₹{totalAmount.toFixed(2)}</span>
            </div>
          </div>

          <div className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Advance Payment (Token) <span className="text-red-500">*</span>
              </label>
              <div className="relative">
                <span className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-500">₹</span>
                <input
                  type="number"
                  required
                  min="0"
                  max={totalAmount}
                  step="0.01"
                  value={advanceAmount}
                  onChange={(e) => setAdvanceAmount(e.target.value)}
                  className="w-full pl-8 pr-4 py-2 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all"
                  placeholder="0.00"
                />
              </div>
              {advance > 0 && (
                <p className="mt-2 text-sm text-slate-500">
                  Remaining amount to pay on delivery: <span className="font-medium text-slate-800">₹{remaining.toFixed(2)}</span>
                </p>
              )}
            </div>

            <div>
              <label className="block text-sm font-medium text-slate-700 mb-1">
                Message to Customer
              </label>
              <textarea
                value={adminMessage}
                onChange={(e) => setAdminMessage(e.target.value)}
                rows={3}
                className="w-full px-4 py-2 bg-white border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-all resize-none"
                placeholder="Enter a message for the customer..."
              />
            </div>
          </div>

          <div className="flex items-center gap-3 pt-2">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-4 py-2.5 text-sm font-medium text-slate-600 bg-white border border-slate-200 rounded-xl hover:bg-slate-50 hover:text-slate-800 transition-all"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="flex-1 px-4 py-2.5 text-sm font-medium text-white bg-blue-600 rounded-xl hover:bg-blue-700 hover:shadow-lg hover:shadow-blue-600/20 transition-all"
            >
              Confirm Order
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
