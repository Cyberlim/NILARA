const express = require('express');
const router = express.Router();

const { uploadImages } = require('../controllers/uploadController');
const { requireAuth } = require('../middlewares/authMiddleware');
const { requireRole } = require('../middlewares/rbacMiddleware');
const { UPLOAD_STRICT } = require('../middlewares/rateLimiter');
const upload = require('../middlewares/uploadMiddleware');

// Admin mutations
router.use(requireAuth);
router.use(requireRole('admin'));
router.use(UPLOAD_STRICT);

// Handle multiple images uploads via 'images' field
router.post('/images', upload.array('images', 5), uploadImages);

module.exports = router;
