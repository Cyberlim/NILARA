const BulkOrder = require('../models/BulkOrder');
const User = require('../models/User');
const { recordAudit } = require('../models/AuditLog');
const { messaging } = require('../config/firebase');

const createBulkOrder = async (req, res, next) => {
  try {
    const { productName, quantity, totalPrice, deliveryDate, timeSlot, paymentMethod, address, specialInstructions } = req.body;
    
    const bulkOrder = new BulkOrder({
      user: req.auth?.userId || null,
      productName,
      quantity,
      totalPrice,
      deliveryDate,
      timeSlot,
      paymentMethod,
      address,
      specialInstructions
    });

    await bulkOrder.save();

    res.status(201).json({
      success: true,
      data: bulkOrder,
      requestId: req.requestId
    });
  } catch (err) {
    next(err);
  }
};

const getBulkOrders = async (req, res, next) => {
  try {
    const { status, limit = 50, page = 1 } = req.query;
    const query = {};
    if (status) query.status = status;
    
    // Sort by newest first
    const bulkOrders = await BulkOrder.find(query)
      .sort({ createdAt: -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit))
      .populate('user', 'displayName phone email');

    res.json({
      success: true,
      data: bulkOrders,
      requestId: req.requestId
    });
  } catch (err) {
    next(err);
  }
};

const getMyBulkOrders = async (req, res, next) => {
  try {
    const userId = req.auth.userId;
    if (!userId) {
      return res.status(401).json({
        success: false,
        error: { message: "User not authenticated or missing ID" }
      });
    }

    const { status, limit = 50, page = 1 } = req.query;
    const query = { user: userId };
    if (status) query.status = status;

    const bulkOrders = await BulkOrder.find(query)
      .sort({ createdAt: -1 })
      .limit(Number(limit))
      .skip((Number(page) - 1) * Number(limit));

    res.json({
      success: true,
      data: bulkOrders,
      requestId: req.requestId
    });
  } catch (err) {
    next(err);
  }
};

const updateBulkOrderStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, advancePayment, remainingPayment, adminMessage } = req.body;

    if (!['Pending', 'Confirmed', 'Processing', 'Delivered', 'Cancelled'].includes(status)) {
      return res.status(400).json({
        success: false,
        error: { code: 'INVALID_STATUS', message: 'Invalid status provided' },
        requestId: req.requestId
      });
    }

    const updateFields = { status };
    if (status === 'Confirmed') {
      if (advancePayment !== undefined) updateFields.advancePayment = Number(advancePayment);
      if (remainingPayment !== undefined) updateFields.remainingPayment = Number(remainingPayment);
      if (adminMessage !== undefined) updateFields.adminMessage = adminMessage;
    }

    const bulkOrder = await BulkOrder.findByIdAndUpdate(
      id,
      { $set: updateFields },
      { new: true }
    );

    if (!bulkOrder) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Bulk order not found' },
        requestId: req.requestId
      });
    }

    // Send FCM notification if order is confirmed
    if (status === 'Confirmed' && bulkOrder.user && messaging) {
      const user = await User.findById(bulkOrder.user);
      if (user && user.fcmTokens && user.fcmTokens.length > 0) {
        const message = {
          notification: {
            title: 'Bulk Order Confirmed',
            body: adminMessage || 'Your bulk order has been confirmed by the admin.'
          },
          tokens: user.fcmTokens
        };
        try {
          await messaging.sendEachForMulticast(message);
        } catch (fcmError) {
          console.error("FCM push notification failed:", fcmError);
        }
      }
    }

    if (req.auth) {
      await recordAudit({
        actorUserId: req.auth.userId,
        actorRole: req.auth.role,
        action: 'ADMIN_BULK_ORDER_UPDATE',
        resourceType: 'BulkOrder',
        resourceId: bulkOrder._id,
        requestId: req.requestId,
        newState: { status }
      }).catch(err => console.error("Audit log failed:", err));
    }

    res.json({
      success: true,
      data: bulkOrder,
      requestId: req.requestId
    });
  } catch (err) {
    next(err);
  }
};

const payAdvanceToken = async (req, res, next) => {
  try {
    const { id } = req.params;

    const bulkOrder = await BulkOrder.findById(id);
    
    if (!bulkOrder) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Bulk order not found' },
        requestId: req.requestId
      });
    }

    if (bulkOrder.status !== 'Confirmed') {
      return res.status(400).json({
        success: false,
        error: { code: 'INVALID_STATUS', message: 'Order must be confirmed to pay advance token' },
        requestId: req.requestId
      });
    }

    if (bulkOrder.advancePaid) {
      return res.status(400).json({
        success: false,
        error: { code: 'ALREADY_PAID', message: 'Advance token already paid' },
        requestId: req.requestId
      });
    }

    bulkOrder.advancePaid = true;
    bulkOrder.status = 'Processing';
    await bulkOrder.save();

    if (req.auth) {
      await recordAudit({
        actorUserId: req.auth.userId,
        actorRole: req.auth.role,
        action: 'PAY_ADVANCE_TOKEN',
        resourceType: 'BulkOrder',
        resourceId: bulkOrder._id,
        requestId: req.requestId,
        newState: { advancePaid: true, status: 'Processing' }
      }).catch(err => console.error("Audit log failed:", err));
    }

    res.json({
      success: true,
      data: bulkOrder,
      requestId: req.requestId
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  createBulkOrder,
  getBulkOrders,
  getMyBulkOrders,
  updateBulkOrderStatus,
  payAdvanceToken
};
