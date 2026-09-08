const Order = require('../models/Order');
const Transaction = require('../models/Transaction');
const User = require('../models/User');

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
    if (status === 'delivered') {
      order.deliveredAt = new Date();
      
      // Calculate earnings in Rupees (fallback to Rs 20 if 0)
      const feeRupees = order.deliveryFeePaise > 0 ? (order.deliveryFeePaise / 100) : 20;
      
      const user = await User.findById(partnerId);
      if (user) {
        user.walletBalance = (user.walletBalance || 0) + feeRupees;
        await user.save();
        
        await Transaction.create({
          user: partnerId,
          type: 'credit',
          amount: feeRupees,
          order: orderId,
          description: `Earning for Order #${order.orderNumber}`
        });
      }
    }
    
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



const cloudinary = require('../config/cloudinary');
const fs = require('fs');

const completeOnboarding = async (req, res, next) => {
  try {
    const { aadharNumber, drivingLicenseNumber, vehicleType, vehicleNumber } = req.body;
    
    let aadharImageUrl = null;
    let profileImageUrl = null;
    let drivingLicenseImageUrl = null;
    let vehicleFrontImageUrl = null;
    let vehicleBackImageUrl = null;
    
    if (req.files && req.files['aadharImage']) {
      const result = await cloudinary.uploader.upload(req.files['aadharImage'][0].path, { folder: 'kyc' });
      aadharImageUrl = result.secure_url;
      fs.unlinkSync(req.files['aadharImage'][0].path);
    }
    
    if (req.files && req.files['profileImage']) {
      const result = await cloudinary.uploader.upload(req.files['profileImage'][0].path, { folder: 'kyc' });
      profileImageUrl = result.secure_url;
      fs.unlinkSync(req.files['profileImage'][0].path);
    }
    
    if (req.files && req.files['drivingLicenseImage']) {
      const result = await cloudinary.uploader.upload(req.files['drivingLicenseImage'][0].path, { folder: 'kyc' });
      drivingLicenseImageUrl = result.secure_url;
      fs.unlinkSync(req.files['drivingLicenseImage'][0].path);
    }
    
    if (req.files && req.files['vehicleFrontImage']) {
      const result = await cloudinary.uploader.upload(req.files['vehicleFrontImage'][0].path, { folder: 'kyc' });
      vehicleFrontImageUrl = result.secure_url;
      fs.unlinkSync(req.files['vehicleFrontImage'][0].path);
    }
    
    if (req.files && req.files['vehicleBackImage']) {
      const result = await cloudinary.uploader.upload(req.files['vehicleBackImage'][0].path, { folder: 'kyc' });
      vehicleBackImageUrl = result.secure_url;
      fs.unlinkSync(req.files['vehicleBackImage'][0].path);
    }

    const User = require('../models/User');
    const user = await User.findById(req.auth.userId);
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    if (profileImageUrl) {
      user.photoUrl = profileImageUrl;
    }
    
    user.deliveryDetails = {
      aadharNumber,
      aadharImage: aadharImageUrl,
      drivingLicenseNumber,
      drivingLicenseImage: drivingLicenseImageUrl,
      vehicleType,
      vehicleNumber,
      vehicleFrontImage: vehicleFrontImageUrl,
      vehicleBackImage: vehicleBackImageUrl
    };
    user.onboardingComplete = true;
    
    await user.save();
    
    res.status(200).json({ success: true, message: 'Onboarding completed successfully' });
  } catch (error) {
    next(error);
  }
};
module.exports = {
  completeOnboarding,
  getAvailableOrders,
  acceptOrder,
  updateDeliveryStatus
};
