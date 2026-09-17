const Order = require('../models/Order');
const Transaction = require('../models/Transaction');
const User = require('../models/User');
const { evaluateIncentivesForPartner } = require('./incentiveController');

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

      // Check and credit any completed incentives automatically
      await evaluateIncentivesForPartner(partnerId, req.app.get('io'));
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
    const { 
      aadharNumber, 
      drivingLicenseNumber, 
      vehicleType, 
      vehicleNumber,
      accountHolderName,
      bankName,
      accountNumber,
      ifscCode,
      accountType,
      upiId
    } = req.body;
    
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

    let rcImageUrl = null;
    if (req.files && req.files['rcImage']) {
      const result = await cloudinary.uploader.upload(req.files['rcImage'][0].path, { folder: 'kyc' });
      rcImageUrl = result.secure_url;
      fs.unlinkSync(req.files['rcImage'][0].path);
    }

    const User = require('../models/User');
    const user = await User.findById(req.auth.userId);
    
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    if (profileImageUrl) {
      user.photoUrl = profileImageUrl;
    }
    
    const existingBankDetails = user.deliveryDetails?.bankDetails || {};
    const bankDetails = (accountNumber || ifscCode || bankName || upiId) ? {
      accountHolderName: accountHolderName || user.displayName || '',
      bankName: bankName || '',
      accountNumber: accountNumber || '',
      ifscCode: ifscCode ? ifscCode.trim().toUpperCase() : '',
      accountType: accountType || 'Savings Account',
      upiId: upiId ? upiId.trim().toLowerCase() : '',
      payoutFrequency: 'Daily',
      payoutMode: 'Bank Transfer'
    } : existingBankDetails;

    user.deliveryDetails = {
      ...(user.deliveryDetails || {}),
      aadharNumber,
      aadharImage: aadharImageUrl,
      drivingLicenseNumber: drivingLicenseNumber ? drivingLicenseNumber.trim().toUpperCase() : drivingLicenseNumber,
      drivingLicenseImage: drivingLicenseImageUrl,
      vehicleType,
      vehicleNumber: vehicleNumber ? vehicleNumber.trim().toUpperCase() : vehicleNumber,
      vehicleFrontImage: vehicleFrontImageUrl,
      vehicleBackImage: vehicleBackImageUrl,
      rcImage: rcImageUrl || user.deliveryDetails?.rcImage,
      bankDetails
    };
    user.markModified('deliveryDetails');
    user.onboardingComplete = true;
    
    await user.save();
    
    res.status(200).json({ success: true, message: 'Onboarding completed successfully' });
  } catch (error) {
    next(error);
  }
};
const updateProfile = async (req, res, next) => {
  try {
    const { displayName, email, dob, address, emergencyContact, vehicleType, vehicleNumber, drivingLicenseNumber, bankDetails, preferences } = req.body;
    const userId = req.auth?.userId || req.user?.id;
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    if (displayName !== undefined) user.displayName = displayName;
    if (email !== undefined) user.email = email;
    if (dob !== undefined) user.dob = dob;
    if (address !== undefined) user.address = address;
    if (emergencyContact !== undefined) user.emergencyContact = emergencyContact;
    if (vehicleType !== undefined || vehicleNumber !== undefined || drivingLicenseNumber !== undefined) {
      if (!user.deliveryDetails) user.deliveryDetails = {};
      if (vehicleType !== undefined) user.deliveryDetails.vehicleType = vehicleType;
      if (vehicleNumber !== undefined) user.deliveryDetails.vehicleNumber = vehicleNumber.trim().toUpperCase();
      if (drivingLicenseNumber !== undefined) user.deliveryDetails.drivingLicenseNumber = drivingLicenseNumber.trim().toUpperCase();
      if (user.deliveryDetails.model) delete user.deliveryDetails.model;
      if (user.deliveryDetails.vehicleModel) delete user.deliveryDetails.vehicleModel;
      user.markModified('deliveryDetails');
    }
    if (bankDetails !== undefined) {
      if (!user.deliveryDetails) user.deliveryDetails = {};
      user.deliveryDetails.bankDetails = {
        ...(user.deliveryDetails.bankDetails || {}),
        ...bankDetails
      };
      user.markModified('deliveryDetails');
    }
    if (preferences !== undefined) {
      if (!user.deliveryDetails) user.deliveryDetails = {};
      user.deliveryDetails.preferences = {
        ...(user.deliveryDetails.preferences || {}),
        ...preferences
      };
      user.markModified('deliveryDetails');
    }
    
    await user.save();
    
    res.status(200).json({ success: true, message: 'Profile updated successfully', data: user });
  } catch (error) {
    next(error);
  }
};

const uploadRC = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: 'No RC image file provided' });
    }

    const result = await cloudinary.uploader.upload(req.file.path, { folder: 'kyc' });
    const rcImageUrl = result.secure_url;
    if (fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }

    const userId = req.auth?.userId || req.user?.id;
    const User = require('../models/User');
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (!user.deliveryDetails) user.deliveryDetails = {};
    user.deliveryDetails.rcImage = rcImageUrl;
    user.markModified('deliveryDetails');
    await user.save();

    res.status(200).json({
      success: true,
      message: 'RC document uploaded successfully',
      data: { rcImage: rcImageUrl }
    });
  } catch (error) {
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    next(error);
  }
};

const getPreferences = async (req, res, next) => {
  try {
    const userId = req.auth?.userId || req.user?.id;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const defaultPrefs = {
      navigationApp: 'OpenStreetMap',
      autoCenterMap: true,
      voiceRoutePrompts: true,
      highContrastMap: false,
      offlineMapCaching: true,
      language: 'English',
      alertTone: 'Loud Ring',
      soundVolume: 85,
      vibrateOnAlert: true
    };

    const currentPrefs = user.deliveryDetails?.preferences;
    const preferences = {
      ...defaultPrefs,
      ...(currentPrefs && typeof currentPrefs.toObject === 'function' ? currentPrefs.toObject() : currentPrefs || {})
    };

    res.status(200).json({
      success: true,
      data: preferences
    });
  } catch (error) {
    next(error);
  }
};

const updatePreferences = async (req, res, next) => {
  try {
    const userId = req.auth?.userId || req.user?.id;
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (!user.deliveryDetails) user.deliveryDetails = {};
    const existingPrefs = user.deliveryDetails.preferences && typeof user.deliveryDetails.preferences.toObject === 'function'
      ? user.deliveryDetails.preferences.toObject()
      : (user.deliveryDetails.preferences || {});

    user.deliveryDetails.preferences = {
      ...existingPrefs,
      ...req.body
    };
    user.markModified('deliveryDetails');
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Preferences updated successfully',
      data: user.deliveryDetails.preferences
    });
  } catch (error) {
    next(error);
  }
};

const getMyOrders = async (req, res, next) => {
  try {
    const partnerId = req.auth.userId;
    const filter = { deliveryPartner: partnerId };
    if (req.query.status) {
      if (req.query.status === 'delivered') {
        filter.status = 'delivered';
      } else if (req.query.status === 'cancelled') {
        filter.status = 'cancelled';
      } else if (req.query.status === 'active') {
        filter.status = { $in: ['confirmed', 'preparing', 'ready_for_pickup', 'out_for_delivery'] };
      }
    }
    const orders = await Order.find(filter)
      .sort({ updatedAt: -1 })
      .lean();
    res.status(200).json({ success: true, data: orders });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  updateProfile,
  completeOnboarding,
  uploadRC,
  getAvailableOrders,
  acceptOrder,
  updateDeliveryStatus,
  getPreferences,
  updatePreferences,
  getMyOrders
};
