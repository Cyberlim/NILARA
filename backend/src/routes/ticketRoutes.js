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
router.patch('/:ticketId/reopen', (req, res, next) => { req.body.status = 'open'; ticketController.updateTicketStatus(req, res, next); });
router.patch('/:ticketId/status', ticketController.updateTicketStatus);

module.exports = router;
