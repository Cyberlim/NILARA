const mongoose = require('mongoose');

const bulkOrderSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false // Allow guest bulk orders for now if user app doesn't enforce auth
  },
  productName: {
    type: String,
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    min: 1
  },
  totalPrice: {
    type: Number,
    required: true,
    min: 0
  },
  deliveryDate: {
    type: String,
    required: true
  },
  timeSlot: {
    type: String,
    required: true
  },
  address: {
    type: Object,
    required: false
  },
  paymentMethod: {
    type: String,
    required: true,
    default: 'UPI'
  },
  status: {
    type: String,
    enum: ['Pending', 'Confirmed', 'Processing', 'Delivered', 'Cancelled'],
    default: 'Pending'
  },
  specialInstructions: {
    type: String,
    required: false
  },
  advancePayment: {
    type: Number,
    default: 0
  },
  remainingPayment: {
    type: Number,
    default: 0
  },
  adminMessage: {
    type: String,
    required: false
  },
  advancePaid: {
    type: Boolean,
    default: false
  },
  customDesign: {
    type: Object,
    required: false
  }
}, { timestamps: true });

// Add index for fast querying by status
bulkOrderSchema.index({ status: 1 });
// Add index for fast querying by user
bulkOrderSchema.index({ user: 1 });

module.exports = mongoose.model('BulkOrder', bulkOrderSchema);
