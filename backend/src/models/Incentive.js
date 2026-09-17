const mongoose = require('mongoose');

const incentiveSchema = new mongoose.Schema({
  title: {
    type: String,
    required: [true, 'Incentive title is required'],
    trim: true
  },
  description: {
    type: String,
    trim: true,
    default: ''
  },
  category: {
    type: String,
    enum: ['Order Target', 'Daily Goal', 'Peak Hour', 'Weekend Rush'],
    default: 'Order Target',
    required: true
  },
  targetOrders: {
    type: Number,
    required: true,
    default: 10,
    min: 1
  },
  rewardAmount: {
    type: Number,
    required: true,
    default: 100,
    min: 1
  },
  startDate: {
    type: Date,
    required: true,
    default: Date.now
  },
  endDate: {
    type: Date,
    required: true
  },
  startTime: {
    type: String, // e.g. "17:00" or "5 PM"
    default: ''
  },
  endTime: {
    type: String, // e.g. "21:00" or "9 PM"
    default: ''
  },
  status: {
    type: String,
    enum: ['Active', 'Paused', 'Expired'],
    default: 'Active'
  },
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  }
}, { timestamps: true });

// Index for fast query of active incentives within date range
incentiveSchema.index({ status: 1, startDate: 1, endDate: 1 });

module.exports = mongoose.model('Incentive', incentiveSchema);
