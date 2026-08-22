const express = require('express');
const router = express.Router();

const { checkout, getMyOrders, getOrderById, mockPayOrder } = require('../controllers/orderController');
const { requireAuth } = require('../middlewares/authMiddleware');
const { validate } = require('../middlewares/validateMiddleware');
const { checkoutSchema } = require('../validators/orderValidators');
const { objectIdParamSchema, paginationQuerySchema } = require('../validators/commonValidators');
const { CUSTOMER_STANDARD } = require('../middlewares/rateLimiter');

// Customer operations require auth
router.use(requireAuth);
router.use(CUSTOMER_STANDARD);

// Orders / Checkout
router.post('/checkout', validate({ body: checkoutSchema }), checkout);
router.get('/me', validate({ query: paginationQuerySchema }), getMyOrders);
router.get('/me/:id', validate({ params: objectIdParamSchema }), getOrderById);
router.post('/:id/mock-pay', validate({ params: objectIdParamSchema }), mockPayOrder);

module.exports = router;
