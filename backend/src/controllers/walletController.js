const Transaction = require('../models/Transaction');
const User = require('../models/User');
const Order = require('../models/Order');

const getWalletData = async (req, res, next) => {
  try {
    const userId = req.auth.userId;
    
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }
    
    // Fetch last 50 transactions
    const transactions = await Transaction.find({ user: userId })
      .sort({ createdAt: -1 })
      .limit(50)
      .lean();
      
    // Calculate today's earnings & delivered orders
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const todaysTransactions = await Transaction.find({
      user: userId,
      type: 'credit',
      createdAt: { $gte: today }
    });
    
    const todaysEarnings = todaysTransactions.reduce((sum, tx) => sum + (tx.amount || 0), 0);

    // Calculate weekly earnings (last 7 days)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    sevenDaysAgo.setHours(0, 0, 0, 0);

    const weeklyTransactions = await Transaction.find({
      user: userId,
      type: 'credit',
      createdAt: { $gte: sevenDaysAgo }
    });
    const weeklyEarnings = weeklyTransactions.reduce((sum, tx) => sum + (tx.amount || 0), 0);

    // Count today's delivered orders for this delivery partner
    const todayDeliveredOrders = await Order.countDocuments({
      deliveryPartner: userId,
      status: 'delivered',
      deliveredAt: { $gte: today }
    });

    // Count total delivered orders for this delivery partner
    const totalDeliveredOrders = await Order.countDocuments({
      deliveryPartner: userId,
      status: 'delivered'
    });

    res.status(200).json({
      success: true,
      data: {
        balance: user.walletBalance || 0,
        todaysEarnings,
        weeklyEarnings,
        todayDeliveredOrders,
        totalDeliveredOrders,
        transactions
      }
    });
  } catch (error) {
    next(error);
  }
};

const requestPayout = async (req, res, next) => {
  try {
    const userId = req.auth.userId;
    const { amount, bankName } = req.body;
    
    if (!amount || amount < 100) {
      return res.status(400).json({ success: false, message: 'Minimum payout is Rs 100' });
    }
    
    const user = await User.findById(userId);
    if (!user || user.walletBalance < amount) {
      return res.status(400).json({ success: false, message: 'Insufficient balance' });
    }
    
    // Deduct balance and create pending transaction
    user.walletBalance -= amount;
    await user.save();
    
    const payoutDest = bankName ? ` (${bankName})` : '';
    const transaction = await Transaction.create({
      user: userId,
      type: 'debit',
      amount: amount,
      description: `Payout Request${payoutDest}`,
      status: 'pending_payout'
    });
    
    res.status(200).json({
      success: true,
      data: {
        balance: user.walletBalance,
        transaction
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getWalletData,
  requestPayout
};
