require('dotenv').config({ path: '.env' });
const mongoose = require('mongoose');
const cloudinary = require('./src/config/cloudinary');
const Settings = require('./src/models/Settings');
const fs = require('fs');

const seedBanner = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB Connected');

    const imagePath = 'C:\\Users\\kdev7\\.gemini\\antigravity-ide\\brain\\1ad22423-4c19-48b7-8302-03019ea44fbd\\.user_uploaded\\media_1787660120452.png';
    if (!fs.existsSync(imagePath)) {
      console.log('Image not found at path');
      return;
    }

    // Upload to Cloudinary
    console.log('Uploading image to Cloudinary...');
    const result = await cloudinary.uploader.upload(imagePath, {
      folder: 'nilara',
    });
    console.log('Upload successful! URL:', result.secure_url);

    // Get settings
    let settings = await Settings.findOne();
    if (!settings) {
      settings = new Settings();
    }

    // Find the MILKLAB banner in homeBanners (tabName Dairy, searchQuery milk, newly added)
    const bannerIndex = settings.homeBanners.findIndex(b => b.tabName === 'Dairy' && b.img === result.secure_url);
    
    if (bannerIndex !== -1) {
       // Remove it from homeBanners
       settings.homeBanners.splice(bannerIndex, 1);
       console.log('Removed from homeBanners');
    }

    // Add to carouselBanners
    settings.carouselBanners.push({
      img: result.secure_url,
      actionType: 'category',
      searchQuery: 'milk',
      tabName: 'Dairy'
    });

    await settings.save();
    console.log('Banner successfully migrated to carouselBanners for Dairy tab!');
    
    process.exit(0);
  } catch (error) {
    console.error('Error seeding banner:', error);
    process.exit(1);
  }
};

seedBanner();
