const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  slug: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  imageUrl: {
    type: String,
    required: false,
    default: '',
    trim: true
  },
  bannerTitle: {
    type: String,
    trim: true
  },
  iconName: {
    type: String,
    trim: true
  },
  subcategories: [{
    type: String,
    trim: true
  }],
  isActive: {
    type: Boolean,
    default: true
  },
  sortOrder: {
    type: Number,
    default: 0
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Category', categorySchema);
