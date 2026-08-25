const express = require('express');
const router = express.Router();

const { getAllOrders, updateOrderStatus, getAllCustomers, toggleCustomerSuspension, getDashboardStats, getInventory, getPayments, getDeliverySchedule, markDeliveryDelivered } = require('../controllers/adminController');
const { requireAuth } = require('../middlewares/authMiddleware');
const { requireRole } = require('../middlewares/rbacMiddleware');
const { validate } = require('../middlewares/validateMiddleware');
const { updateOrderStatusSchema } = require('../validators/orderValidators');
const { objectIdParamSchema, paginationQuerySchema } = require('../validators/commonValidators');
const { ADMIN_STRICT } = require('../middlewares/rateLimiter');

// All routes here require Admin role
router.use(requireAuth);
router.use(requireRole('admin'));
router.use(ADMIN_STRICT);

// Dashboard
router.get('/dashboard', getDashboardStats);

// Delivery Calendar & Live Deliveries
router.get('/delivery-schedule', getDeliverySchedule);
router.post('/live-deliveries/mark-delivered', markDeliveryDelivered);

// Orders
router.get('/orders', validate({ query: paginationQuerySchema }), getAllOrders);
router.get('/customers', getAllCustomers);
router.patch('/customers/:id/suspend', validate({ params: objectIdParamSchema }), toggleCustomerSuspension);
router.patch('/orders/:id/status', validate({ params: objectIdParamSchema, body: updateOrderStatusSchema }), updateOrderStatus);

// Inventory (derived from Products)
router.get('/inventory', getInventory);

// Payments (derived from Orders)
router.get('/payments', getPayments);

module.exports = router;

