const { auth } = require('./firebase');
const User = require('../models/User');

const initSocket = (io) => {
  // Middleware for authentication
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
      
      if (!token) {
        console.error("Socket auth error: Token missing");
        return next(new Error('Authentication error: Token missing'));
      }
      
      const cleanToken = token.replace('Bearer ', '');
      const jwt = require('jsonwebtoken');
      let user;

      // 1. Try Custom JWT first (Admin token)
      try {
        const decoded = jwt.verify(cleanToken, process.env.JWT_SECRET || 'fallback_secret_key_for_dev_only');
        user = await User.findById(decoded.userId).lean();
      } catch (jwtError) {
        // Not a valid custom JWT, fallback to Firebase
      }

      // 2. Try Firebase token (User token)
      if (!user) {
        let decodedToken;
        try {
          decodedToken = await auth.verifyIdToken(cleanToken);
        } catch (verifyError) {
          console.error("Socket auth error: Firebase verify failed -", verifyError.message);
          return next(new Error('Authentication error: Invalid token'));
        }
        
        user = await User.findOne({ firebaseUid: decodedToken.uid }).lean();
        
        // Auto-create user if missing
        if (!user) {
          const User = require('../models/User');
          const newUser = new User({
            firebaseUid: decodedToken.uid,
            displayName: decodedToken.name || decodedToken.phone_number || 'New User',
            email: decodedToken.email || `${decodedToken.uid}@example.com`,
            phone: decodedToken.phone_number || '',
            role: 'customer',
            isActive: true
          });
          await newUser.save();
          user = newUser.toObject();
        }
      }

      if (!user.isActive) {
        return next(new Error('Authentication error: Account suspended'));
      }
      
      // Store trusted auth context on the socket
      socket.user = {
        userId: user._id.toString(),
        role: user.role,
      };
      
      next();
    } catch (err) {
      console.error("Socket auth caught error:", err.message);
      next(new Error('Authentication error: Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    const { userId, role } = socket.user;
    
    // 1. Every user joins their own private room
    socket.join(`user_${userId}`);
    
    // 2. Admins join the admin room
    if (role === 'admin') {
      socket.join('admin_room');
    }
    
    // 3. Delivery partners join the delivery room
    if (role === 'delivery') {
      socket.join('delivery_room');
    }
    
    // Delivery partner can explicitly subscribe to a specific order tracking room
    socket.on('join_order_room', (orderId) => {
      if (role === 'delivery') {
        socket.join(`order_${orderId}`);
      }
    });

    // Handle real-time chat messages
    socket.on('send_message', async (data) => {
      const fs = require('fs');
      const appendLog = (msg) => fs.appendFileSync('socket-debug.log', new Date().toISOString() + ' - ' + msg + '\n');
      
      try {
        appendLog(`Received send_message from ${userId} (${role}): ${JSON.stringify(data)}`);
        
        const Message = require('../models/Message');
        const Ticket = require('../models/Ticket');
        const { receiverId, text, ticketId } = data;
        
        if (ticketId) {
          // Ensure ticket is open
          const ticket = await Ticket.findById(ticketId);
          if (ticket && ticket.status === 'closed') {
            socket.emit('chat_error', { message: 'This ticket is closed.' });
            return;
          }
        }

        // Save to DB
        const message = new Message({
          senderId: role === 'admin' ? 'admin' : userId, // Standardize admin sender ID
          receiverId: receiverId,
          text: text,
          ticketId: ticketId || undefined
        });
        await message.save();
        appendLog(`Message saved successfully with id: ${message._id}`);
        
        const messageObj = message.toJSON();

        // Broadcast to receiver
        if (receiverId === 'admin') {
          // Send to all admins
          io.to('admin_room').emit('receive_message', messageObj);
          appendLog(`Emitted to admin_room`);
        } else {
          // Send to specific user
          io.to(`user_${receiverId}`).emit('receive_message', messageObj);
          appendLog(`Emitted to user_${receiverId}`);
        }

        // Echo back to sender so they can update UI confidently
        socket.emit('receive_message', messageObj);
        appendLog(`Echoed back to sender`);
        
      } catch (error) {
        appendLog(`Socket send_message error: ${error.message} - ${error.stack}`);
        console.error('Socket send_message error:', error);
      }
    });

    // Mark messages as read
    socket.on('mark_as_read', async (data) => {
      try {
        const Message = require('../models/Message');
        const { senderId, ticketId } = data;
        // If admin is reading, receiver is 'admin'. If user is reading, receiver is their userId.
        const currentReceiverId = role === 'admin' ? 'admin' : userId;
        
        const query = { senderId: senderId, receiverId: currentReceiverId, isRead: false };
        if (ticketId) query.ticketId = ticketId;
        
        await Message.updateMany(query, { $set: { isRead: true } });
      } catch (error) {
        console.error('Socket mark_as_read error:', error);
      }
    });

    socket.on('disconnect', () => {
      // Cleanup happens automatically, but we can log if needed
    });
  });
};

module.exports = initSocket;
