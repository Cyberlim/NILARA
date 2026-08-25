require('dotenv').config({ path: '../.env' });
const mongoose = require('mongoose');
const Settings = require('../src/models/Settings');

async function seedSettings() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');

    let settings = await Settings.findOne();
    if (!settings) {
      settings = new Settings();
    }

    settings.subscriptionPlans = [
      {
        name: "Daily Essentials",
        frequency: "Daily",
        price: 799,
        discountPercentage: 10,
        minDurationDays: 30,
        description: "Fresh water delivered every morning.",
        includedProducts: ["Nilara 10L Water Jar", "Nilara 20L Water Jar"]
      },
      {
        name: "Premium",
        frequency: "Weekly",
        price: 499,
        discountPercentage: 5,
        minDurationDays: 14,
        description: "Weekly deliveries for regular use.",
        includedProducts: ["Nilara 20L Water Jar"]
      },
      {
        name: "Monthly Value",
        frequency: "Monthly",
        price: 1499,
        discountPercentage: 20,
        minDurationDays: 90,
        description: "Best value for long term needs.",
        includedProducts: ["Nilara 10L Water Jar", "Nilara 20L Water Jar"]
      }
    ];

    await settings.save();
    console.log('Successfully seeded default Subscription Plans into Settings!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding settings:', error);
    process.exit(1);
  }
}

seedSettings();
