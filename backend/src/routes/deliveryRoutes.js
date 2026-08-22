const express = require('express');
const router = express.Router();

const { getAvailableOrders, acceptOrder, updateDeliveryStatus } = require('../controllers/deliveryController');
const { requireAuth } = require('../middlewares/authMiddleware');
const { requireRole } = require('../middlewares/rbacMiddleware');
const { validate } = require('../middlewares/validateMiddleware');
const { updateOrderStatusSchema } = require('../validators/orderValidators');
const { objectIdParamSchema, paginationQuerySchema } = require('../validators/commonValidators');
const { DELIVERY_STANDARD } = require('../middlewares/rateLimiter');

// All routes here require Delivery role
router.use(requireAuth);
router.use(requireRole('delivery'));
router.use(DELIVERY_STANDARD);

// Orders
router.get('/orders/available', validate({ query: paginationQuerySchema }), getAvailableOrders);
router.patch('/orders/:id/accept', validate({ params: objectIdParamSchema }), acceptOrder);
router.patch('/orders/:id/status', validate({ params: objectIdParamSchema, body: updateOrderStatusSchema }), updateDeliveryStatus);

module.exports = router;
