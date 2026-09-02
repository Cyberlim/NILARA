const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middlewares/authMiddleware');
const chatController = require('../controllers/chatController');

// All chat routes require authentication
router.use(requireAuth);

// Get chat history for a specific user (admin can fetch anyone's, user can only fetch their own)
router.get('/history/:userId', chatController.getHistory);

// Get all recent chats (admin only)
router.get('/recent', chatController.getRecentChats);

module.exports = router;
