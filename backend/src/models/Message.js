const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  senderId: {
    type: String, // 'admin' or userId
    required: true,
  },
  receiverId: {
    type: String, // 'admin' or userId
    required: true,
  },
  text: {
    type: String,
    required: true,
  },
  isRead: {
    type: Boolean,
    default: false,
  },
  ticketId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Ticket',
    required: false, // Made optional temporarily for backward compatibility during migration
  }
}, { timestamps: true });

// Optional: create an index for faster querying by user
messageSchema.index({ senderId: 1, receiverId: 1 });
messageSchema.index({ ticketId: 1 }); // new index for tickets

module.exports = mongoose.model('Message', messageSchema);
