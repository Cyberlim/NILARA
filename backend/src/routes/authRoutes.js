const express = require('express');
const router = express.Router();
const { syncUser } = require('../controllers/authController');
const { requireAuth } = require('../middlewares/authMiddleware');
const { authLimiter } = require('../middlewares/rateLimiter');

// Idempotent user sync route
router.post('/sync', authLimiter, requireAuth, syncUser);

module.exports = router;
