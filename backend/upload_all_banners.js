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

const filesToUpload = [
  'milk.png',
  'pcard3.webp',
  'pcard1.jpg',
  'bread.png',
  'tomato.png',
  'apple.png'
];

async function run() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log('Connected to DB');

  const uploadedUrls = {};

  for (const file of filesToUpload) {
    const fullPath = path.resolve(__dirname, `../apps/user-app/assets/images/${file}`);
    console.log(`Uploading ${file}...`);
    try {
      const result = await cloudinary.uploader.upload(fullPath, { folder: 'nilara', resource_type: 'image' });
      uploadedUrls[file] = result.secure_url;
      console.log(`Uploaded: ${result.secure_url}`);
    } catch (e) {
      console.error(`Error uploading ${file}:`, e.message);
    }
  }

  const settings = await Settings.findOne();
  if (settings) {
    const newBanners = [
      // Oils (using unsplash)
      { img: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?q=80&w=400&auto=format&fit=crop', actionType: 'category', searchQuery: 'mustard', tabName: 'Oils' },
      { img: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=400&auto=format&fit=crop', actionType: 'category', searchQuery: 'sunflower', tabName: 'Oils' },
      { img: 'https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1?q=80&w=400&auto=format&fit=crop', actionType: 'category', searchQuery: 'soybean', tabName: 'Oils' },
      { img: 'https://images.unsplash.com/photo-1589927986076-2558976b34f6?q=80&w=400&auto=format&fit=crop', actionType: 'category', searchQuery: 'groundnut', tabName: 'Oils' },
      
      // Dairy
      { img: uploadedUrls['milk.png'], actionType: 'category', searchQuery: 'milk', tabName: 'Dairy' },
      { img: uploadedUrls['pcard3.webp'], actionType: 'category', searchQuery: 'paneer', tabName: 'Dairy' },
      { img: uploadedUrls['pcard3.webp'], actionType: 'category', searchQuery: 'curd', tabName: 'Dairy' },
      { img: uploadedUrls['pcard1.jpg'], actionType: 'category', searchQuery: 'butter', tabName: 'Dairy' },
      
      // Grocery
      { img: uploadedUrls['bread.png'], actionType: 'category', searchQuery: 'rice', tabName: 'Grocery' },
      { img: uploadedUrls['pcard3.webp'], actionType: 'category', searchQuery: 'dals', tabName: 'Grocery' },
      { img: uploadedUrls['tomato.png'], actionType: 'category', searchQuery: 'spices', tabName: 'Grocery' },
      { img: uploadedUrls['apple.png'], actionType: 'category', searchQuery: 'dry fruits', tabName: 'Grocery' },
    ];
    
    // Add to existing water banners
    const waterBanners = settings.homeBanners.filter(b => b.tabName === 'Water');
    settings.homeBanners = [...waterBanners, ...newBanners];
    
    await settings.save();
    console.log('Settings updated!');
  }

  process.exit(0);
}

run().catch(console.error);
