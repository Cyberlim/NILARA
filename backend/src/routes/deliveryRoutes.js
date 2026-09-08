const express = require('express');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

const router = express.Router();

const { completeOnboarding, getAvailableOrders, acceptOrder, updateDeliveryStatus } = require('../controllers/deliveryController');
const { getWalletData, requestPayout } = require('../controllers/walletController');
const { requireAuth, requireOnboarding } = require('../middlewares/authMiddleware');
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
router.post('/onboarding', upload.fields([{ name: 'profileImage', maxCount: 1 }, { name: 'aadharImage', maxCount: 1 }, { name: 'drivingLicenseImage', maxCount: 1 }, { name: 'vehicleFrontImage', maxCount: 1 }, { name: 'vehicleBackImage', maxCount: 1 }]), completeOnboarding);
router.get('/orders/available', requireOnboarding, validate({ query: paginationQuerySchema }), getAvailableOrders);
router.patch('/orders/:id/accept', requireOnboarding, validate({ params: objectIdParamSchema }), acceptOrder);
router.patch('/orders/:id/status', requireOnboarding, validate({ params: objectIdParamSchema, body: updateOrderStatusSchema }), updateDeliveryStatus);

// Wallet
router.get('/wallet', requireOnboarding, getWalletData);
router.post('/wallet/payout', requireOnboarding, requestPayout);

module.exports = router;
