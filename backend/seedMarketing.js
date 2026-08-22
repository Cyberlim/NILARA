require('dotenv').config();
const mongoose = require('mongoose');
const Coupon = require('./src/models/Coupon');
const Gift = require('./src/models/Gift');

async function seedMarketing() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to DB');

    // Create Coupons
    await Coupon.deleteMany({});
    await Coupon.create([
      {
        code: 'WELCOME50',
        description: 'Get ₹50 off your first order',
        discountPercent: 0,
        maxDiscountAmount: 50,
        minOrderValue: 200,
        isActive: true
      },
      {
        code: 'SAVE10',
        description: 'Get 10% off on all orders',
        discountPercent: 10,
        maxDiscountAmount: 150,
        minOrderValue: 500,
        isActive: true
      }
    ]);
    console.log('Coupons seeded');

    // Create Gifts
    await Gift.deleteMany({});
    await Gift.create([
      {
        name: 'Free Coke Can',
        image: 'assets/images/qb4.jpg', // Using generic image available in repo
        minOrderValue: 300,
        isActive: true
      },
      {
        name: 'Free Premium Milk',
        image: 'assets/images/milk.png',
        minOrderValue: 800,
        isActive: true
      }
    ]);
    console.log('Gifts seeded');

    process.exit(0);
  } catch (error) {
    console.error('Error seeding marketing data:', error);
    process.exit(1);
  }
}

seedMarketing();
