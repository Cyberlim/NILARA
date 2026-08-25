require('dotenv').config({ path: __dirname + '/.env' });
const mongoose = require('mongoose');
const Category = require('./src/models/Category');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/nilara';

const categoryUpdates = [
  {
    name: "Water",
    bannerTitle: "Nilara Pure Water",
    iconName: "water_drop_outlined",
    subcategories: ["250 ml", "500 ml", "1 Litre", "2 Litre", "5 L Jar", "20 L Can"]
  },
  {
    name: "Oil",
    bannerTitle: "Nilara Cooking Oils",
    iconName: "opacity_outlined",
    subcategories: ["Mustard Oil 1L", "Sunflower Oil 1L", "Mustard Oil 5L", "Groundnut Oil 5L"]
  },
  {
    name: "Dairy",
    bannerTitle: "Fresh Dairy Every Day",
    iconName: "egg_alt_outlined",
    subcategories: ["Fresh Milk", "Paneer & Curd", "Butter & Spread", "Cheese"]
  },
  {
    name: "Grocery",
    bannerTitle: "Daily Essentials",
    iconName: "shopping_basket_outlined",
    subcategories: ["Basmati Rice", "Chakki Atta", "Dals & Pulses", "Sugar & Salt"]
  }
];

async function run() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log("Connected to MongoDB.");

    for (const update of categoryUpdates) {
      const cat = await Category.findOne({ name: update.name });
      if (cat) {
        cat.bannerTitle = update.bannerTitle;
        cat.iconName = update.iconName;
        cat.subcategories = update.subcategories;
        await cat.save();
        console.log(`Updated ${update.name}`);
      } else {
        console.log(`Category ${update.name} not found!`);
      }
    }

    console.log("Migration complete!");
    process.exit(0);
  } catch (err) {
    console.error("Migration error:", err);
    process.exit(1);
  }
}

run();
