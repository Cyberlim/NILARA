const Order = require('../models/Order');

const getAvailableOrders = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 20;
    const skip = (page - 1) * limit;
    
    // Delivery partners look for orders that are confirmed or preparing, and not yet assigned
    const filter = {
      status: { $in: ['confirmed', 'preparing', 'ready_for_pickup'] },
      deliveryPartner: { $exists: false }
    };
    
    const orders = await Order.find(filter)
      .sort({ createdAt: 1 }) // Oldest first
      .skip(skip)
      .limit(limit)
      .lean();
      
    const total = await Order.countDocuments(filter);
    
    res.status(200).json({
      success: true,
      data: orders,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      },
      requestId: req.requestId
    });
  } catch (err) {
    next(err);
  }
};

const acceptOrder = async (req, res, next) => {
  try {
    const orderId = req.params.id;
    const partnerId = req.auth.userId;
    
    // Find an order that isn't already assigned
    const order = await Order.findOneAndUpdate(
      { _id: orderId, deliveryPartner: { $exists: false }, status: { $in: ['confirmed', 'preparing', 'ready_for_pickup'] } },
      { deliveryPartner: partnerId },
      { new: true }
    );
    
    if (!order) {
      const err = new Error('Order is no longer available or not found');
      err.statusCode = 409;
      err.code = 'NOT_AVAILABLE';
      throw err;
    }
    
    req.app.get('io').to(`order_${orderId}`).emit('delivery_assigned', { partnerId });
    req.app.get('io').to(`user_${order.user}`).emit('delivery_assigned', { partnerId });
    
    res.status(200).json({
      success: true,
      data: order,
      requestId: req.requestId
    });
  } catch (err) {
    next(err);
  }
};

const updateDeliveryStatus = async (req, res, next) => {
  try {
    const orderId = req.params.id;
    const partnerId = req.auth.userId;
    const { status } = req.body;
    
    // IDOR protection: partner can only update their assigned order
    const order = await Order.findOne({ _id: orderId, deliveryPartner: partnerId });
    
    if (!order) {
      const err = new Error('Order not found or not assigned to you');
      err.statusCode = 404;
      err.code = 'NOT_FOUND';
      throw err;
    }
    
    if (!['out_for_delivery', 'delivered'].includes(status)) {
      const err = new Error('Invalid delivery status update');
      err.statusCode = 400;
      err.code = 'INVALID_STATUS';
      throw err;
    }
    
    order.status = status;
    if (status === 'out_for_delivery') order.outForDeliveryAt = new Date();
    if (status === 'delivered') order.deliveredAt = new Date();
    
    await order.save();
    
    req.app.get('io').to(`user_${order.user}`).emit('order_status_updated', { orderId: order._id, status });
    req.app.get('io').to(`admin_room`).emit('order_status_updated', { orderId: order._id, status });
    
    res.status(200).json({
      success: true,
      data: order,
      requestId: req.requestId
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getAvailableOrders,
  acceptOrder,
  updateDeliveryStatus
};
