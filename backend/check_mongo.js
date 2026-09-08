require('dotenv').config();
const mongoose = require('mongoose');
const BulkOrder = require('./src/models/BulkOrder');

async function test() {
  await mongoose.connect(process.env.MONGO_URI);
  const bulkOrders = await BulkOrder.find().sort({createdAt:-1}).lean();
  console.log('--- LATEST BULK ORDERS ---');
  console.log(JSON.stringify(bulkOrders.slice(0,3), null, 2));

  mongoose.connection.close();
}
test();
