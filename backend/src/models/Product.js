const mongoose = require('mongoose');

const productVariantSchema = new mongoose.Schema({
  sku: {
    type: String,
    required: true,
    unique: true,
    trim: true
  },
  pricePaise: {
    type: Number,
    required: true,
    min: 0,
    validate: {
      validator: Number.isInteger,
      message: 'pricePaise must be an integer'
    }
  },
  discountPricePaise: {
    type: Number,
    min: 0,
    validate: [
      {
        validator: Number.isInteger,
        message: 'discountPricePaise must be an integer'
      },
      {
        validator: function (val) {
          // discountPricePaise must not exceed pricePaise
          return val == null || val <= this.pricePaise;
        },
        message: 'discountPricePaise cannot exceed pricePaise'
      }
    ]
  },
  stockQuantity: {
    type: Number,
    required: true,
    min: 0,
    default: 0,
    validate: {
      validator: Number.isInteger,
      message: 'stockQuantity must be an integer'
    }
  },
  unit: {
    type: String,
    enum: ['piece', 'ml', 'l', 'g', 'kg', 'pack'],
    required: true
  },
  weightOrVolume: {
    type: Number,
    required: true,
    min: 0
  },
  isActive: {
    type: Boolean,
    default: true
  }
});

const productSchema = new mongoose.Schema({
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
  description: {
    type: String,
    trim: true
  },
  category: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Category',
    required: true,
    index: true
  },
  images: [{
    type: String, // Cloudinary URLs
    required: true
  }],
  variants: [productVariantSchema],
  isActive: {
    type: Boolean,
    default: true,
    index: true
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('Product', productSchema);
