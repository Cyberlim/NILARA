require('dotenv').config();
const cloudinary = require('cloudinary').v2;
const mongoose = require('mongoose');
const Settings = require('./src/models/Settings');
const path = require('path');

cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

const bannerFiles = [
  { file: '../apps/user-app/assets/images/banner/category_bottle.png.png', searchQuery: 'bottle', actionType: 'category' },
  { file: '../apps/user-app/assets/images/banner/category_bulk.png.png', actionType: 'bulk_order' },
  { file: '../apps/user-app/assets/images/banner/category_can.png.png', searchQuery: '20l|can', actionType: 'category' },
  { file: '../apps/user-app/assets/images/banner/category_carton.png.png', searchQuery: 'carton', actionType: 'category' }
];

async function run() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log('Connected to DB');

  const newBanners = [];

  for (const b of bannerFiles) {
    const fullPath = path.resolve(__dirname, b.file);
    console.log(`Uploading ${fullPath}...`);
    const result = await cloudinary.uploader.upload(fullPath, { folder: 'nilara', resource_type: 'image' });
    newBanners.push({
      img: result.secure_url,
      actionType: b.actionType,
      searchQuery: b.searchQuery,
      tabName: 'Water'
    });
    console.log(`Uploaded: ${result.secure_url}`);
  }

  const settings = await Settings.findOne();
  if (settings) {
    settings.homeBanners = newBanners;
    await settings.save();
    console.log('Settings updated!');
  }

  process.exit(0);
}

run().catch(console.error);
