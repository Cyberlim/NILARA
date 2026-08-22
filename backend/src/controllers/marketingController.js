const Coupon = require('../models/Coupon');
const Gift = require('../models/Gift');

exports.getActiveCoupons = async (req, res) => {
  try {
    const coupons = await Coupon.find({ isActive: true }).sort({ createdAt: -1 });
    res.json(coupons);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};

exports.getActiveGifts = async (req, res) => {
  try {
    const gifts = await Gift.find({ isActive: true }).sort({ minOrderValue: 1 });
    res.json(gifts);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error: error.message });
  }
};
