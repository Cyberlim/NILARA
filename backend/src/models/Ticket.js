const mongoose = require('mongoose');

const ticketSchema = new mongoose.Schema({
  userId: {
    type: String, // String to match existing schema conventions or mongoose.Schema.Types.ObjectId
    required: true,
  },
  subject: {
    type: String,
    required: true,
  },
  status: {
    type: String,
    enum: ['open', 'closed'],
    default: 'open',
  },
}, { timestamps: true });

ticketSchema.index({ userId: 1, status: 1 });

module.exports = mongoose.model('Ticket', ticketSchema);
