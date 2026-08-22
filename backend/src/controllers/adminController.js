const express = require('express');
const Order = require('../models/Order');
const Product = require('../models/Product');
const { recordAudit } = require('../models/AuditLog');

const getAllOrders = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 20;
    const skip = (page - 1) * limit;
    
    // Optionally filter by status
    const filter = {};
    if (req.query.status) {
      filter.status = req.query.status;
    }
    
    const orders = await Order.find(filter)
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('user', 'displayName email phone')
      .populate('deliveryPartner', 'displayName phone')
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

const updateOrderStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    
    const order = await Order.findById(req.params.id);
    if (!order) {
      const err = new Error('Order not found');
      err.statusCode = 404;
      err.code = 'NOT_FOUND';
      throw err;
    }
    
    const oldStatus = order.status;
    order.status = status;
    
    if (status === 'cancelled') {
      order.cancelledAt = new Date();
      // NOTE: We do not auto-refund stock here. Admins must handle stock manually or we add a complex rollback logic.
    }
    
    await order.save();
    
    await recordAudit('ADMIN_ORDER_UPDATE', req.auth.userId, {
      orderId: order._id,
      oldStatus,
      newStatus: status
    });
    
    // Trigger Socket.IO event
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

const User = require('../models/User');

const getAllCustomers = async (req, res, next) => {
  try {
    const customers = await User.find({ role: 'customer' })
      .select('displayName email phone isActive photoUrl createdAt')
      .sort({ createdAt: -1 });

    const formattedCustomers = customers.map(c => ({
      id: c._id.toString(),
      name: c.displayName || 'Unknown User',
      email: c.email || 'N/A',
      phone: c.phone || 'N/A',
      avatar: c.photoUrl,
      status: c.isActive ? 'Active' : 'Suspended',
      statusColor: c.isActive ? 'teal' : 'red',
      joinDate: c.createdAt.toISOString().split('T')[0],
      totalOrders: 0,
      walletBalance: 0,
      isPremium: false,
      lastActive: 'Just now'
    }));

    res.status(200).json({ success: true, data: formattedCustomers });
  } catch (error) { next(error); }
};

const toggleCustomerSuspension = async (req, res, next) => {
  try {
    const customer = await User.findById(req.params.id);
    if (!customer) {
      return res.status(404).json({ success: false, error: { message: 'Customer not found' } });
    }
    
    customer.isActive = !customer.isActive;
    await customer.save();
    
    res.status(200).json({ success: true, isActive: customer.isActive });
  } catch (error) { next(error); }
};

const getDashboardStats = async (req, res, next) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    // KPI: Today's Orders & Revenue
    const todaysOrders = await Order.find({ createdAt: { $gte: today } });
    const yesterdaysOrders = await Order.find({ createdAt: { $gte: yesterday, $lt: today } });

    const todayRevenuePaise = todaysOrders.reduce((sum, o) => sum + o.totalPaise, 0);
    const yesterdayRevenuePaise = yesterdaysOrders.reduce((sum, o) => sum + o.totalPaise, 0);

    const todayRevenue = todayRevenuePaise / 100;
    const yesterdayRevenue = yesterdayRevenuePaise / 100;
    
    // Revenue trend
    let revenueTrend = 0;
    if (yesterdayRevenue > 0) {
      revenueTrend = ((todayRevenue - yesterdayRevenue) / yesterdayRevenue) * 100;
    } else if (todayRevenue > 0) {
      revenueTrend = 100; // infinite growth from 0
    }

    // Orders trend
    let ordersTrend = 0;
    if (yesterdaysOrders.length > 0) {
      ordersTrend = ((todaysOrders.length - yesterdaysOrders.length) / yesterdaysOrders.length) * 100;
    } else if (todaysOrders.length > 0) {
      ordersTrend = 100;
    }

    // KPI: Low Stock
    const lowStockProductsCount = await Product.countDocuments({ stock: { $lt: 10 } });

    // Recent Orders
    const recentOrders = await Order.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .populate('user', 'displayName email phone');

    // Chart logic
    const last7Days = new Date(today);
    last7Days.setDate(last7Days.getDate() - 6);

    const ordersLast7Days = await Order.find({ createdAt: { $gte: last7Days } });

    const chartData = {};
    for (let i = 6; i >= 0; i--) {
      const d = new Date(today);
      d.setDate(d.getDate() - i);
      const dateStr = d.toLocaleDateString('en-GB', { day: '2-digit', month: 'short' });
      chartData[dateStr] = { revenue: 0, orders: 0 };
    }

    ordersLast7Days.forEach(o => {
      const dateStr = new Date(o.createdAt).toLocaleDateString('en-GB', { day: '2-digit', month: 'short' });
      if (chartData[dateStr]) {
        chartData[dateStr].revenue += o.totalPaise / 100;
        chartData[dateStr].orders += 1;
      }
    });

    const revenueChart = {
      labels: Object.keys(chartData),
      data: Object.values(chartData).map(d => d.revenue)
    };

    const ordersChart = {
      labels: Object.keys(chartData),
      data: Object.values(chartData).map(d => d.orders)
    };

    res.json({
      success: true,
      data: {
        kpi: {
          todayRevenue: todayRevenue,
          revenueTrend: revenueTrend.toFixed(1),
          todayOrders: todaysOrders.length,
          ordersTrend: ordersTrend.toFixed(1),
          activeSubscriptions: 0,
          subscriptionsTrend: 0,
          activeDeliveries: 0,
          deliveriesTrend: 0,
          onlineRiders: 0,
          ridersTrend: 0,
          lowStockProducts: lowStockProductsCount,
          lowStockTrend: 0
        },
        charts: {
          revenue: revenueChart,
          orders: ordersChart
        },
        recentOrders: recentOrders,
        topProducts: [] 
      }
    });
  } catch (error) { next(error); }
};

const getInventory = async (req, res, next) => {
  try {
    const products = await Product.find()
      .populate('category', 'name')
      .lean();

    const items = products.map(p => {
      const v = p.variants[0] || {};
      const stock = v.stockQuantity || 0;
      const stockStatus = stock === 0 ? 'Out of Stock' : stock < 10 ? 'Low Stock' : 'In Stock';
      const statusColor = stock === 0 ? 'red' : stock < 10 ? 'orange' : 'green';
      return {
        id: p._id,
        name: p.name,
        variant: `${v.weightOrVolume || ''} ${v.unit || ''}`.trim(),
        sku: v.sku || 'N/A',
        category: p.category?.name || 'Uncategorized',
        stock,
        stockStatus,
        statusColor,
        image: p.images?.[0] || '',
        price: (v.discountPricePaise || v.pricePaise || 0) / 100,
        updatedAt: p.updatedAt,
      };
    });

    const total = items.length;
    const inStock = items.filter(i => i.stockStatus === 'In Stock').length;
    const lowStock = items.filter(i => i.stockStatus === 'Low Stock').length;
    const outOfStock = items.filter(i => i.stockStatus === 'Out of Stock').length;

    res.json({
      success: true,
      data: { kpi: { total, inStock, lowStock, outOfStock }, items }
    });
  } catch (err) { next(err); }
};

const getPayments = async (req, res, next) => {
  try {
    const orders = await Order.find()
      .sort({ createdAt: -1 })
      .populate('user', 'displayName email phone')
      .lean();

    const items = orders.map(o => ({
      id: o._id,
      orderNumber: o.orderNumber,
      customer: o.user?.displayName || 'Guest',
      phone: o.user?.phone || '',
      amount: o.totalPaise / 100,
      method: o.paymentMethod?.toUpperCase() || 'COD',
      status: o.paymentStatus,
      statusColor: o.paymentStatus === 'paid' ? 'green' : o.paymentStatus === 'failed' ? 'red' : 'amber',
      date: o.createdAt,
    }));

    const totalRevenue = orders
      .filter(o => o.paymentStatus === 'paid')
      .reduce((s, o) => s + o.totalPaise / 100, 0);
    const pending = items.filter(i => i.status === 'pending').length;
    const paid = items.filter(i => i.status === 'paid').length;
    const failed = items.filter(i => i.status === 'failed').length;

    res.json({
      success: true,
      data: { kpi: { totalRevenue, pending, paid, failed }, items }
    });
  } catch (err) { next(err); }
};

module.exports = {
  getDashboardStats,
  getAllOrders,
  updateOrderStatus,
  getAllCustomers,
  toggleCustomerSuspension,
  getInventory,
  getPayments
};
