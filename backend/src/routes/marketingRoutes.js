const express = require('express');
const router = express.Router();
const { getActiveCoupons, getActiveGifts } = require('../controllers/marketingController');
const { requireAuth } = require('../middlewares/authMiddleware');
const { CUSTOMER_STANDARD } = require('../middlewares/rateLimiter');

router.use(requireAuth);
router.use(CUSTOMER_STANDARD);

router.get('/coupons/active', getActiveCoupons);
router.get('/gifts/active', getActiveGifts);

module.exports = router;
