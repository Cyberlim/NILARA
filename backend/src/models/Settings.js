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
}, {
  timestamps: true,
});

module.exports = mongoose.model('Settings', settingsSchema);
