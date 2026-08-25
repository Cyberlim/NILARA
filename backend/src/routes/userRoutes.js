const express = require('express');
const router = express.Router();

const { getMe, updateMe, uploadAvatar, addFcmToken, getWishlist, toggleWishlist } = require('../controllers/userController');
const upload = require('../middlewares/uploadMiddleware');
const { requireAuth } = require('../middlewares/authMiddleware');
const { validate } = require('../middlewares/validateMiddleware');
const { updateProfileSchema } = require('../validators/userValidators');
const { CUSTOMER_STANDARD } = require('../middlewares/rateLimiter');

router.use(requireAuth);
router.use(CUSTOMER_STANDARD);

router.get('/me', getMe);
router.patch('/me', validate({ body: updateProfileSchema }), updateMe);
router.post('/me/avatar', upload.single('avatar'), uploadAvatar);
router.patch('/me/fcm-token', addFcmToken);

router.get('/me/wishlist', getWishlist);
router.post('/me/wishlist/:productId', toggleWishlist);
module.exports = router;

