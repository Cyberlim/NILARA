const Incentive = require('../models/Incentive');
const IncentiveClaim = require('../models/IncentiveClaim');
const Order = require('../models/Order');
const User = require('../models/User');
const Transaction = require('../models/Transaction');
const Notification = require('../models/Notification');

// Helper to format days left
const calculateDaysLeft = (endDate) => {
  const now = new Date();
  const diffMs = new Date(endDate) - now;
  if (diffMs <= 0) return 'Expired';
  const diffDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
  if (diffDays === 1) return 'Ends today';
  return `${diffDays} days left`;
};

// Helper to check if current time is within peak hour window
const isPeakHourLive = (startTime, endTime) => {
  if (!startTime || !endTime) return false;
  try {
    const now = new Date();
    const currentMinutes = now.getHours() * 60 + now.getMinutes();

    const parseTimeToMinutes = (timeStr) => {
      // Handles formats like "17:00", "5 PM", "5:30 PM"
      const cleaned = timeStr.trim().toUpperCase();
      const isPM = cleaned.includes('PM');
      const isAM = cleaned.includes('AM');
      const timePart = cleaned.replace(/AM|PM/g, '').trim();
      const [hStr, mStr] = timePart.split(':');
      let hours = parseInt(hStr, 10) || 0;
      const minutes = parseInt(mStr, 10) || 0;
      if (isPM && hours < 12) hours += 12;
      if (isAM && hours === 12) hours = 0;
      return hours * 60 + minutes;
    };

    const startMins = parseTimeToMinutes(startTime);
    const endMins = parseTimeToMinutes(endTime);

    if (startMins <= endMins) {
      return currentMinutes >= startMins && currentMinutes <= endMins;
    } else {
      // Overnight window (e.g. 10 PM to 2 AM)
      return currentMinutes >= startMins || currentMinutes <= endMins;
    }
  } catch (e) {
    return false;
  }
};

// --- ADMIN CONTROLLERS ---

const createIncentive = async (req, res, next) => {
  try {
    const {
      title,
      description,
      category = 'Order Target',
      targetOrders,
      rewardAmount,
      startDate,
      endDate,
      startTime = '',
      endTime = '',
      status = 'Active'
    } = req.body;

    if (!title || !targetOrders || !rewardAmount || !endDate) {
      return res.status(400).json({
        success: false,
        message: 'Title, target orders, reward amount, and end date are required'
      });
    }

    const incentive = await Incentive.create({
      title,
      description: description || `Earn ₹${rewardAmount} extra on completing ${targetOrders} orders`,
      category,
      targetOrders: Number(targetOrders),
      rewardAmount: Number(rewardAmount),
      startDate: startDate ? new Date(startDate) : new Date(),
      endDate: new Date(endDate),
      startTime,
      endTime,
      status,
      createdBy: req.auth?.userId
    });

    return res.status(201).json({
      success: true,
      message: 'Incentive campaign created successfully',
      data: incentive
    });
  } catch (error) {
    next(error);
  }
};

const getAdminIncentives = async (req, res, next) => {
  try {
    const { status, search } = req.query;
    const query = {};

    if (status && status !== 'All') {
      query.status = status;
    }

    if (search) {
      query.title = { $regex: search, $options: 'i' };
    }

    const incentives = await Incentive.find(query).sort({ createdAt: -1 }).lean();

    // Aggregated KPI Stats
    const activeCount = await Incentive.countDocuments({ status: 'Active' });
    const allClaims = await IncentiveClaim.find({}).lean();
    const totalPaid = allClaims.reduce((sum, c) => sum + (c.rewardAmount || 0), 0);
    const totalClaims = allClaims.length;

    const uniquePartners = new Set(allClaims.map(c => c.deliveryPartner?.toString())).size;

    return res.status(200).json({
      success: true,
      data: {
        incentives: incentives.map(inc => ({
          id: inc._id.toString(),
          _id: inc._id.toString(),
          title: inc.title,
          description: inc.description,
          category: inc.category,
          type: inc.category,
          targetOrders: inc.targetOrders,
          target: `${inc.targetOrders} Orders`,
          rewardAmount: inc.rewardAmount,
          reward: `₹${inc.rewardAmount}`,
          startDate: new Date(inc.startDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
          endDate: new Date(inc.endDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }),
          rawStartDate: inc.startDate,
          rawEndDate: inc.endDate,
          startTime: inc.startTime,
          endTime: inc.endTime,
          status: inc.status,
          statusColor: inc.status === 'Active' ? 'emerald' : inc.status === 'Paused' ? 'amber' : 'slate'
        })),
        kpis: {
          activeCount,
          totalPaid,
          totalClaims,
          participatingPartners: uniquePartners
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

const updateIncentive = async (req, res, next) => {
  try {
    const { id } = req.params;
    const updateData = { ...req.body };

    if (updateData.startDate) updateData.startDate = new Date(updateData.startDate);
    if (updateData.endDate) updateData.endDate = new Date(updateData.endDate);

    const incentive = await Incentive.findByIdAndUpdate(id, updateData, { new: true, runValidators: true });
    if (!incentive) {
      return res.status(404).json({ success: false, message: 'Incentive campaign not found' });
    }

    return res.status(200).json({
      success: true,
      message: 'Incentive campaign updated successfully',
      data: incentive
    });
  } catch (error) {
    next(error);
  }
};

const deleteIncentive = async (req, res, next) => {
  try {
    const { id } = req.params;
    const deleted = await Incentive.findByIdAndDelete(id);
    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Incentive campaign not found' });
    }

    return res.status(200).json({
      success: true,
      message: 'Incentive campaign deleted successfully'
    });
  } catch (error) {
    next(error);
  }
};

// --- DELIVERY APP CONTROLLERS ---

const getDeliveryIncentives = async (req, res, next) => {
  try {
    const partnerId = req.auth.userId;
    const now = new Date();

    // Fetch all active campaigns
    const allIncentives = await Incentive.find({
      status: { $in: ['Active', 'Expired'] }
    }).sort({ createdAt: -1 }).lean();

    // Fetch this partner's claims
    const claims = await IncentiveClaim.find({ deliveryPartner: partnerId }).lean();
    const claimsMap = new Map();
    claims.forEach(c => claimsMap.set(c.incentive.toString(), c));

    const activeList = [];
    const expiredList = [];

    for (const inc of allIncentives) {
      const isClaimed = claimsMap.has(inc._id.toString());
      const claim = claimsMap.get(inc._id.toString());
      const isTimeExpired = new Date(inc.endDate) < now;

      // Count delivered orders in campaign date window
      const deliveredCount = await Order.countDocuments({
        deliveryPartner: partnerId,
        status: 'delivered',
        deliveredAt: { $gte: inc.startDate, $lte: inc.endDate }
      });

      const target = inc.targetOrders || 1;
      const progress = Math.min(1.0, Math.max(0.0, deliveredCount / target));
      const daysLeft = calculateDaysLeft(inc.endDate);
      const isLive = isPeakHourLive(inc.startTime, inc.endTime);

      const formatted = {
        id: inc._id.toString(),
        _id: inc._id.toString(),
        title: inc.title,
        subtitle: inc.description || `Earn ₹${inc.rewardAmount} extra`,
        description: inc.description,
        category: inc.category,
        type: inc.category,
        targetOrders: target,
        currentOrders: Math.min(deliveredCount, target),
        rewardAmount: inc.rewardAmount,
        progress: Number(progress.toFixed(2)),
        daysLeft,
        startDate: inc.startDate,
        endDate: inc.endDate,
        startTime: inc.startTime || '',
        endTime: inc.endTime || '',
        timeRange: (inc.startTime && inc.endTime) ? `${inc.startTime} - ${inc.endTime}` : (inc.category === 'Weekend Rush' ? 'Sat - Sun' : ''),
        isLive,
        isCompleted: deliveredCount >= target,
        isClaimed,
        claimedAt: claim ? claim.completedAt : null
      };

      if (!isTimeExpired && inc.status === 'Active') {
        activeList.push(formatted);
      } else {
        expiredList.push(formatted);
      }
    }

    return res.status(200).json({
      success: true,
      data: {
        active: activeList,
        expired: expiredList
      }
    });
  } catch (error) {
    next(error);
  }
};

// --- CORE EVALUATION ENGINE: CREDITING FUND TO WALLET ON COMPLETION ---

const evaluateIncentivesForPartner = async (partnerId, io) => {
  try {
    const now = new Date();

    // Query active campaigns within current window
    const activeIncentives = await Incentive.find({
      status: 'Active',
      startDate: { $lte: now },
      endDate: { $gte: now }
    });

    if (!activeIncentives || activeIncentives.length === 0) return;

    for (const inc of activeIncentives) {
      // 1. Check if already claimed
      const existingClaim = await IncentiveClaim.findOne({
        incentive: inc._id,
        deliveryPartner: partnerId
      });
      if (existingClaim) continue;

      // 2. Count delivered orders within campaign timeframe
      const deliveredCount = await Order.countDocuments({
        deliveryPartner: partnerId,
        status: 'delivered',
        deliveredAt: { $gte: inc.startDate, $lte: inc.endDate }
      });

      // 3. Milestone reached!
      if (deliveredCount >= inc.targetOrders) {
        const partner = await User.findById(partnerId);
        if (partner) {
          const reward = inc.rewardAmount;
          partner.walletBalance = (partner.walletBalance || 0) + reward;
          await partner.save();

          // Record Credit Transaction
          const txn = await Transaction.create({
            user: partnerId,
            type: 'credit',
            amount: reward,
            description: `Incentive Reward: ${inc.title}`,
            status: 'success'
          });

          // Record Claim
          await IncentiveClaim.create({
            incentive: inc._id,
            deliveryPartner: partnerId,
            ordersCompleted: deliveredCount,
            targetOrders: inc.targetOrders,
            rewardAmount: reward,
            status: 'claimed',
            completedAt: new Date(),
            walletTransaction: txn._id
          });

          // In-App Notification
          try {
            await Notification.create({
              user: partnerId,
              title: 'Incentive Unlocked! 🎉',
              message: `Congratulations! You completed '${inc.title}' and earned ₹${reward} extra in your wallet.`,
              type: 'delivery'
            });
          } catch (notifErr) {
            console.error('Notification create error:', notifErr.message);
          }

          // Real-time Socket Event
          if (io) {
            io.to(`delivery_${partnerId}`).emit('incentive_reward_credited', {
              incentiveId: inc._id,
              title: inc.title,
              rewardAmount: reward,
              newBalance: partner.walletBalance
            });
            io.to(`user_${partnerId}`).emit('wallet_updated', {
              newBalance: partner.walletBalance
            });
          }

          console.log(`[INCENTIVE CREDITED] Partner ${partnerId} achieved '${inc.title}'. Credited ₹${reward}. New Balance: ₹${partner.walletBalance}`);
        }
      }
    }
  } catch (error) {
    console.error('Error evaluating partner incentives:', error);
  }
};

module.exports = {
  createIncentive,
  getAdminIncentives,
  updateIncentive,
  deleteIncentive,
  getDeliveryIncentives,
  evaluateIncentivesForPartner
};
