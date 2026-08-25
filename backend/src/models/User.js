const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  firebaseUid: {
    type: String,
    required: true,
    unique: true,
    index: true
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

