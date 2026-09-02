const Message = require('../models/Message');
const User = require('../models/User');

exports.getHistory = async (req, res, next) => {
  try {
    let { userId } = req.params;
    const currentUserId = req.auth.userId;
    const role = req.auth.role;

    // If the frontend sends its Firebase UID instead of MongoDB _id, map it.
    if (userId === req.auth.firebaseUid) {
      userId = currentUserId;
    }

    // Check permissions
    if (role !== 'admin' && currentUserId !== userId) {
      return res.status(403).json({ success: false, message: 'Not authorized to view these messages' });
    }

    const messages = await Message.find({
      $or: [
        { senderId: userId, receiverId: 'admin' },
        { senderId: 'admin', receiverId: userId }
      ]
    }).sort({ createdAt: 1 }); // Oldest first

    res.status(200).json({ success: true, messages });
  } catch (error) {
    next(error);
  }
};

exports.getRecentChats = async (req, res, next) => {
  try {
    if (req.auth.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    // Get the most recent message per user
    const recentMessages = await Message.aggregate([
      {
        $match: {
          $or: [
            { receiverId: 'admin' },
            { senderId: 'admin' }
          ]
        }
      },
      {
        $addFields: {
          otherPartyId: {
            $cond: { if: { $eq: ["$senderId", "admin"] }, then: "$receiverId", else: "$senderId" }
          }
        }
      },
      {
        $sort: { createdAt: -1 }
      },
      {
        $group: {
          _id: "$otherPartyId",
          lastMessage: { $first: "$$ROOT" }
        }
      }
    ]);

    // Populate user info for each chat
    const populatedChats = await Promise.all(
      recentMessages.map(async (chat) => {
        const user = await User.findById(chat._id).select('displayName email phone photoUrl');
        return {
          userId: chat._id,
          user,
          lastMessage: chat.lastMessage
        };
      })
    );

    // Sort by most recent
    populatedChats.sort((a, b) => new Date(b.lastMessage.createdAt) - new Date(a.lastMessage.createdAt));

    res.status(200).json({ success: true, chats: populatedChats });
  } catch (error) {
    next(error);
  }
};
