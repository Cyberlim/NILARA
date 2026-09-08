require('dotenv').config();
const mongoose = require('mongoose');
const Order = require('./src/models/Order');

async function test() {
  await mongoose.connect(process.env.MONGO_URI);
  const orders = await Order.find().lean();
  let invalidOrders = [];
  
  for (const o of orders) {
    if (!o.createdAt || !o.status || typeof o.totalPaise !== 'number' || !o.items) {
      invalidOrders.push(o._id);
    } else {
      for (const item of o.items) {
        if (!item.name || !item.quantity || typeof item.unitPricePaise !== 'number') {
          invalidOrders.push(o._id);
          break;
        }
      }
    }
  }
  
  console.log('Invalid orders count:', invalidOrders.length);
  if (invalidOrders.length > 0) {
    console.log('Sample invalid order:', await Order.findById(invalidOrders[0]).lean());
  }

  mongoose.connection.close();
}
test();
