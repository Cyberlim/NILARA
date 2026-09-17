const express = require('express');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });

const router = express.Router();

const { updateProfile, completeOnboarding, uploadRC, getAvailableOrders, acceptOrder, updateDeliveryStatus, getPreferences, updatePreferences, getMyOrders } = require('../controllers/deliveryController');
const { getWalletData, requestPayout } = require('../controllers/walletController');
const { requireAuth, requireOnboarding } = require('../middlewares/authMiddleware');
const { requireRole } = require('../middlewares/rbacMiddleware');
const { validate } = require('../middlewares/validateMiddleware');
const { updateOrderStatusSchema } = require('../validators/orderValidators');
const { updatePreferencesSchema } = require('../validators/userValidators');
const { objectIdParamSchema, paginationQuerySchema } = require('../validators/commonValidators');
const { DELIVERY_STANDARD } = require('../middlewares/rateLimiter');

// Development test trigger for incoming order alert (unprotected)
router.post('/test-incoming-order', (req, res) => {
  const testOrder = {
    _id: '65f1234567890abcdef12345',
    totalPaise: 45000,
    deliveryAddress: { fullName: 'Test Customer', city: 'Delhi' },
    items: []
  };
  req.app.get('io').to('delivery_room').emit('new_order_available', testOrder);
  res.json({ success: true, message: 'Emitted new_order_available to delivery_room', order: testOrder });
});

// All routes here require Delivery role
router.use(requireAuth);
router.use(requireRole('delivery'));
router.use(DELIVERY_STANDARD);

// Profile & Preferences & Documents
router.put('/profile', updateProfile);
router.get('/preferences', getPreferences);
router.put('/preferences', validate({ body: updatePreferencesSchema }), updatePreferences);
router.post('/rc', upload.single('rcImage'), uploadRC);
router.post('/onboarding', upload.fields([
  { name: 'profileImage', maxCount: 1 },
  { name: 'aadharImage', maxCount: 1 },
  { name: 'drivingLicenseImage', maxCount: 1 },
  { name: 'vehicleFrontImage', maxCount: 1 },
  { name: 'vehicleBackImage', maxCount: 1 },
  { name: 'rcImage', maxCount: 1 }
]), completeOnboarding);

// Orders
router.get('/orders/available', requireOnboarding, validate({ query: paginationQuerySchema }), getAvailableOrders);
router.get('/orders/my-orders', requireOnboarding, getMyOrders);
router.patch('/orders/:id/accept', requireOnboarding, validate({ params: objectIdParamSchema }), acceptOrder);
router.patch('/orders/:id/status', requireOnboarding, validate({ params: objectIdParamSchema, body: updateOrderStatusSchema }), updateDeliveryStatus);

// Wallet & Payouts
router.get('/wallet', requireOnboarding, getWalletData);
router.post('/wallet/payout', requireOnboarding, requestPayout);

// Incentives & Schemes
const { getDeliveryIncentives } = require('../controllers/incentiveController');
router.get('/incentives', requireOnboarding, getDeliveryIncentives);

module.exports = router;
