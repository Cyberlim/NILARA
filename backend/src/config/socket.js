const firebaseAdmin = require('./firebase');
const User = require('../models/User');

const initSocket = (io) => {
  // Middleware for authentication
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
      
      if (!token) {
        return next(new Error('Authentication error: Token missing'));
      }
      
      const cleanToken = token.replace('Bearer ', '');
      const decodedToken = await firebaseAdmin.auth().verifyIdToken(cleanToken);
      
      const user = await User.findOne({ firebaseUid: decodedToken.uid }).lean();
      
      if (!user) {
        return next(new Error('Authentication error: User not found in DB'));
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

    socket.on('disconnect', () => {
      // Cleanup happens automatically, but we can log if needed
    });
  });
};

module.exports = initSocket;
