const mongoose = require('mongoose');

const orderItemSnapshotSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  variantId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  name: {
    type: String,
    required: true
  },
  imageUrl: {
    type: String,
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    min: 1,
    validate: { validator: Number.isInteger, message: 'quantity must be an integer' }
  },
  unitPricePaise: {
    type: Number,
    required: true,
    min: 0,
    validate: { validator: Number.isInteger, message: 'unitPricePaise must be an integer' }
  },
  totalPricePaise: {
    type: Number,
    required: true,
    min: 0,
    validate: { validator: Number.isInteger, message: 'totalPricePaise must be an integer' }
  }
}, { _id: false });

const orderSchema = new mongoose.Schema({
  orderNumber: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  deliveryPartner: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    index: true
  },
  items: {
    type: [orderItemSnapshotSchema],
    required: true,
    validate: { validator: (v) => v.length > 0, message: 'Order must have at least one item' }
  },

  subtotalPaise:     { type: Number, required: true, min: 0, validate: { validator: Number.isInteger, message: 'must be integer' } },
  discountPaise:     { type: Number, default: 0,    min: 0, validate: { validator: Number.isInteger, message: 'must be integer' } },
  deliveryFeePaise:  { type: Number, default: 0,    min: 0, validate: { validator: Number.isInteger, message: 'must be integer' } },
  taxPaise:          { type: Number, default: 0,    min: 0, validate: { validator: Number.isInteger, message: 'must be integer' } },
  totalPaise:        { type: Number, required: true, min: 0, validate: { validator: Number.isInteger, message: 'must be integer' } },

  paymentMethod: { type: String, enum: ['cod', 'online'], required: true },
  paymentStatus: { type: String, enum: ['pending', 'paid', 'failed'], default: 'pending' },

  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'ready_for_pickup', 'out_for_delivery', 'delivered', 'cancelled'],
    default: 'pending'
  },

  deliveryAddressSnapshot: {
    recipientName: String,
    phone: String,
    addressLine1: String,
    addressLine2: String,
    landmark: String,
    city: String,
    state: String,
    postalCode: String,
    location: {
      type: { type: String, enum: ['Point'] },
      coordinates: [Number]
    }
  },

  customerNotes: { type: String, trim: true },
  cancellationReason: { type: String, trim: true },

  placedAt: { type: Date },
  acceptedAt: { type: Date },
  outForDeliveryAt: { type: Date },
  deliveredAt: { type: Date },
  cancelledAt: { type: Date },
}, {
  timestamps: true
});

orderSchema.index({ user: 1, createdAt: -1 });
orderSchema.index({ deliveryPartner: 1, status: 1 });
orderSchema.index({ status: 1, createdAt: -1 });

module.exports = mongoose.model('Order', orderSchema);
