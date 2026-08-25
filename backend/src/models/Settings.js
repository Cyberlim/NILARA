const mongoose = require('mongoose');

const settingsSchema = new mongoose.Schema({
  handlingCharge: {
    type: Number,
    required: true,
    default: 2,
  },
  deliveryFee: {
    type: Number,
    required: true,
    default: 25,
  },
  freeDeliveryMinAmount: {
    type: Number,
    required: true,
    default: 500, // E.g., free delivery over 500
  },
  customDesignMinOrder: {
    type: Number,
    required: true,
    default: 100, // Default min 100
  },
  customDesignSurcharge: {
    type: Number,
    required: true,
    default: 10, // Default 10 currency units extra per item/total
  },
  subscriptionPlans: [{
    name: { type: String, required: true },
    frequency: { type: String, enum: ['Daily', 'Alternate Days', 'Weekly', 'Monthly'], required: true },
    price: { type: Number, required: true },
    discountPercentage: { type: Number, default: 0 },
    durationMonths: { type: Number, default: 1 },
    description: { type: String },
    isActive: { type: Boolean, default: true },
    includedProducts: [{ type: String }],
    features: [{ type: String }]
  }],
  deliveryTimeSlots: {
    type: [String],
    default: [
      'Early Morning (6 AM - 8 AM)',
      'Morning (8 AM - 10 AM)',
      'Noon (10 AM - 1 PM)',
      'Afternoon (1 PM - 5 PM)',
      'Evening (5 PM - 8 PM)'
    ]
  },
  contactSupport: {
    email: { type: String, default: 'support@nilara.com' },
    chatResponseTime: { type: String, default: 'Usually replies within 5 minutes' }
  },
  faqs: [{
    question: { type: String, required: true },
    answer: { type: String, required: true }
  }]
}, {
  timestamps: true,
});

module.exports = mongoose.model('Settings', settingsSchema);
