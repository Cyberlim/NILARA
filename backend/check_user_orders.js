require('dotenv').config();
const mongoose = require('mongoose');
const Order = require('./src/models/Order');

async function test() {
  await mongoose.connect(process.env.MONGO_URI);
  const userOrders = await Order.find().lean();
  console.log('Total orders:', userOrders.length);
  
  let deliveredCount = 0;
  for (const o of userOrders) {
    if (o.status === 'delivered') deliveredCount++;
  }
  console.log('Total delivered normal orders:', deliveredCount);

  const BulkOrder = require('./src/models/BulkOrder');
  const bulkOrders = await BulkOrder.find().lean();
  let deliveredBulkCount = 0;
  for (const o of bulkOrders) {
    if (o.status === 'Delivered') deliveredBulkCount++;
  }
  console.log('Total delivered bulk orders:', deliveredBulkCount);
  
  mongoose.connection.close();
}
test();
