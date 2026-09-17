const mongoose = require('mongoose');

const incentiveClaimSchema = new mongoose.Schema({
  incentive: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Incentive',
    required: true,
    index: true
  },
  deliveryPartner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  ordersCompleted: {
    type: Number,
    required: true,
    default: 0
  },
  targetOrders: {
    type: Number,
    required: true
  },
  rewardAmount: {
    type: Number,
    required: true
  },
  status: {
    type: String,
    enum: ['claimed', 'credited'],
    default: 'claimed'
  },
  completedAt: {
    type: Date,
    default: Date.now
  },
  walletTransaction: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Transaction'
  }
}, { timestamps: true });

// Prevent duplicate claims for the same incentive by the same delivery partner
incentiveClaimSchema.index({ incentive: 1, deliveryPartner: 1 }, { unique: true });

module.exports = mongoose.model('IncentiveClaim', incentiveClaimSchema);
