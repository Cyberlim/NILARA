const Ticket = require('../models/Ticket');
const Message = require('../models/Message');
const User = require('../models/User');

exports.createTicket = async (req, res, next) => {
  try {
    const { subject, initialMessage } = req.body;
    const userId = req.auth.userId;

    if (!subject) {
      return res.status(400).json({ success: false, message: 'Subject is required' });
    }

    const ticket = new Ticket({
      userId,
      subject,
      status: 'open'
    });
    await ticket.save();

    if (initialMessage) {
      const message = new Message({
        senderId: userId,
        receiverId: 'admin',
        text: initialMessage,
        ticketId: ticket._id
      });
      await message.save();
    }

    res.status(201).json({ success: true, ticket });
  } catch (error) {
    next(error);
  }
};

exports.getTickets = async (req, res, next) => {
  try {
    const role = req.auth.role;
    const userId = req.auth.userId;

    let tickets = [];
    if (role === 'admin') {
      // Admin sees all tickets
      tickets = await Ticket.find().sort({ createdAt: -1 });
    } else {
      // User sees their own tickets
      tickets = await Ticket.find({ userId }).sort({ createdAt: -1 });
    }

    // Populate user info and last message
    const populatedTickets = await Promise.all(
      tickets.map(async (ticket) => {
        const user = await User.findById(ticket.userId).select('displayName email phone photoUrl role');
        const lastMessage = await Message.findOne({ ticketId: ticket._id }).sort({ createdAt: -1 });
        return {
          ...ticket.toObject(),
          user,
          lastMessage
        };
      })
    );

    res.status(200).json({ success: true, tickets: populatedTickets });
  } catch (error) {
    next(error);
  }
};

exports.getTicketMessages = async (req, res, next) => {
  try {
    const { ticketId } = req.params;
    const role = req.auth.role;
    const currentUserId = req.auth.userId;

    const ticket = await Ticket.findById(ticketId);
    if (!ticket) {
      return res.status(404).json({ success: false, message: 'Ticket not found' });
    }

    // Check permissions
    if (role !== 'admin' && ticket.userId.toString() !== currentUserId) {
      return res.status(403).json({ success: false, message: 'Not authorized to view these messages' });
    }

    // Mark unread messages intended for the current viewer as read
    const unreadFilter = role === 'admin'
      ? { ticketId, senderId: { $ne: 'admin' }, isRead: false }
      : { ticketId, senderId: 'admin', isRead: false };

    const updateRes = await Message.updateMany(unreadFilter, { $set: { isRead: true } });

    if (updateRes.modifiedCount > 0) {
      const io = req.app.get('io');
      if (io) {
        io.to(`ticket_${ticketId.toString()}`).emit('messages_read', {
          ticketId: ticketId.toString(),
          readerRole: role
        });

        if (role === 'admin') {
          io.to(`user_${ticket.userId.toString()}`).emit('messages_read', {
            ticketId: ticketId.toString(),
            readerRole: 'admin'
          });
        } else {
          io.to('admin_room').emit('messages_read', {
            ticketId: ticketId.toString(),
            readerRole: role
          });
        }
      }
    }

    const messages = await Message.find({ ticketId }).sort({ createdAt: 1 }); // Oldest first

    res.status(200).json({ success: true, messages });
  } catch (error) {
    next(error);
  }
};

exports.closeTicket = async (req, res, next) => {
  try {
    const { ticketId } = req.params;
    const role = req.auth.role;

    if (role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Only admins can close tickets' });
    }

    const ticket = await Ticket.findByIdAndUpdate(ticketId, { status: 'closed' }, { new: true });
    if (!ticket) {
      return res.status(404).json({ success: false, message: 'Ticket not found' });
    }

    res.status(200).json({ success: true, ticket });
  } catch (error) {
    next(error);
  }
};

exports.updateTicketStatus = async (req, res, next) => {
  try {
    const { ticketId } = req.params;
    const { status } = req.body;
    const role = req.auth.role;

    if (role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Only admins can update ticket status' });
    }

    if (!['open', 'closed'].includes(status)) {
      return res.status(400).json({ success: false, message: 'Invalid status' });
    }

    const ticket = await Ticket.findByIdAndUpdate(ticketId, { status }, { new: true });
    if (!ticket) {
      return res.status(404).json({ success: false, message: 'Ticket not found' });
    }

    res.status(200).json({ success: true, ticket });
  } catch (error) {
    next(error);
  }
};

