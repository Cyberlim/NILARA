const Review = require('../models/Review');
const Order = require('../models/Order');
const Product = require('../models/Product');

exports.createReview = async (req, res, next) => {
  try {
    const userId = req.auth.userId;
    const { productId, orderId, rating, comment } = req.body;

    if (!productId || !orderId || !rating) {
      return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    // Check if review already exists for this user and product
    const existingReview = await Review.findOne({ user: userId, product: productId });
    if (existingReview) {
      return res.status(400).json({ success: false, message: 'You have already reviewed this product' });
    }

    // Check if the order belongs to the user and is delivered
    const order = await Order.findOne({ _id: orderId, user: userId });
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }
    if (order.status !== 'delivered') {
      return res.status(400).json({ success: false, message: 'You can only review products after delivery' });
    }

    // Check if the product was actually in this order
    const hasProduct = order.items.some(item => item.productId.toString() === productId);
    if (!hasProduct) {
      return res.status(400).json({ success: false, message: 'Product not found in this order' });
    }

    const review = new Review({
      user: userId,
      product: productId,
      order: orderId,
      rating,
      comment
    });

    await review.save();

    res.status(201).json({ success: true, message: 'Review submitted and is pending approval', review });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({ success: false, message: 'You have already reviewed this product' });
    }
    next(error);
  }
};

exports.getProductReviews = async (req, res, next) => {
  try {
    const { productId } = req.params;
    const reviews = await Review.find({ product: productId, status: 'approved' })
      .populate('user', 'displayName photoUrl')
      .sort({ createdAt: -1 });

    res.status(200).json({ success: true, reviews });
  } catch (error) {
    next(error);
  }
};

exports.getAdminReviews = async (req, res, next) => {
  try {
    if (req.auth.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }
    const { status } = req.query; // pending, approved, rejected
    const query = status ? { status } : {};

    const reviews = await Review.find(query)
      .populate('user', 'displayName email')
      .populate('product', 'name images')
      .sort({ createdAt: -1 });

    res.status(200).json({ success: true, reviews });
  } catch (error) {
    next(error);
  }
};

exports.updateReviewStatus = async (req, res, next) => {
  try {
    if (req.auth.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    const { id } = req.params;
    const { status } = req.body;

    if (!['pending', 'approved', 'rejected'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const review = await Review.findByIdAndUpdate(id, { status }, { new: true });
    if (!review) {
      return res.status(404).json({ success: false, message: 'Review not found' });
    }

    // Recalculate average rating for the product if approved
    // If it was already approved and is now rejected, we also need to recalculate
    const allApprovedReviews = await Review.find({ product: review.product, status: 'approved' });
    let averageRating = 0;
    let totalReviews = allApprovedReviews.length;

    if (totalReviews > 0) {
      const sum = allApprovedReviews.reduce((acc, curr) => acc + curr.rating, 0);
      averageRating = sum / totalReviews;
    }

    await Product.findByIdAndUpdate(review.product, {
      averageRating: parseFloat(averageRating.toFixed(1)),
      totalReviews
    });

    res.status(200).json({ success: true, review });
  } catch (error) {
    next(error);
  }
};

// Check if user can review order items
exports.getReviewEligibility = async (req, res, next) => {
  try {
    const userId = req.auth.userId;
    const { orderId } = req.params;

    const order = await Order.findOne({ _id: orderId, user: userId });
    if (!order || order.status !== 'delivered') {
      return res.status(200).json({ success: true, eligibility: {} });
    }

    const productIds = order.items.map(item => item.productId);
    const existingReviews = await Review.find({ user: userId, product: { $in: productIds } });
    
    const reviewedProductIds = existingReviews.map(r => r.product.toString());

    // Build a map of productId -> canReview (true/false)
    const eligibility = {};
    order.items.forEach(item => {
      eligibility[item.productId.toString()] = !reviewedProductIds.includes(item.productId.toString());
    });

    res.status(200).json({ success: true, eligibility });
  } catch (error) {
    next(error);
  }
};
