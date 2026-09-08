const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  type: {
    type: String,
    enum: ['credit', 'debit'],
    required: true
  },
  amount: {
    type: Number,
    required: true,
    min: 0
  },
  order: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Order'
  },
  description: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['success', 'pending_payout', 'completed_payout'],
    default: 'success'
  }
}, { timestamps: true });

module.exports = mongoose.model('Transaction', transactionSchema);
