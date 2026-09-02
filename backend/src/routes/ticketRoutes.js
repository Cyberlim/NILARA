const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middlewares/authMiddleware');
const ticketController = require('../controllers/ticketController');

// All ticket routes require authentication
router.use(requireAuth);

router.post('/', ticketController.createTicket);
router.get('/', ticketController.getTickets);
router.get('/:ticketId/messages', ticketController.getTicketMessages);
router.patch('/:ticketId/close', ticketController.closeTicket);

module.exports = router;
