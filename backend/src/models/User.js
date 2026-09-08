const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firebaseUid: {
    type: String,
    unique: true,
    sparse: true,
    index: true
  },
  password: {
    type: String
  },
  email: {
    type: String,
    lowercase: true,
    trim: true,
    sparse: true // sparse because phone login might not have email initially
  },
  phone: {
    type: String,
    trim: true,
    sparse: true
  },
  displayName: {
    type: String,
    trim: true
  },
  photoUrl: {
    type: String,
    trim: true
  },
  role: {
    type: String,
    enum: ['customer', 'delivery', 'admin'],
    default: 'customer'
  },
  permissions: [{
    type: String
  }],
  isActive: {
    type: Boolean,
    default: true
  },
  onboardingComplete: {
    type: Boolean,
    default: false
  },
  walletBalance: {
    type: Number,
    default: 0,
    min: 0
  },
  deliveryDetails: {
    aadharNumber: { type: String },
    aadharImage: { type: String },
    drivingLicenseNumber: { type: String },
    drivingLicenseImage: { type: String },
    vehicleType: { type: String },
    vehicleNumber: { type: String },
    vehicleFrontImage: { type: String },
    vehicleBackImage: { type: String }
  },
  fcmTokens: [{
    type: String,
    trim: true
  }],
  wishlist: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product'
  }]
}, {
  timestamps: true
});

module.exports = mongoose.model('User', userSchema);

