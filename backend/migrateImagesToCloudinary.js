require('dotenv').config({ path: __dirname + '/.env' });
const mongoose = require('mongoose');
const cloudinary = require('./src/config/cloudinary');
const Product = require('./src/models/Product');
const Category = require('./src/models/Category');
const fs = require('fs');
const path = require('path');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/nilara';
const userAppAssetsDir = path.join(__dirname, '../apps/user-app');

async function uploadToCloudinary(filePath) {
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload(filePath, { folder: 'nilara' }, (error, result) => {
      if (error) {
        reject(error);
      } else {
        resolve(result.secure_url);
      }
    });
  });
}

async function migrate() {
  try {
    await mongoose.connect(MONGO_URI);
    console.log('Connected to DB');

    // Migrate Categories
    const categories = await Category.find({});
    for (const cat of categories) {
      if (cat.imageUrl && cat.imageUrl.startsWith('assets/')) {
        const fullPath = path.join(userAppAssetsDir, cat.imageUrl);
        if (fs.existsSync(fullPath)) {
          console.log(`Uploading category image for ${cat.name}...`);
          try {
            const url = await uploadToCloudinary(fullPath);
            cat.imageUrl = url;
            await cat.save();
            console.log(`Updated category ${cat.name} with URL: ${url}`);
          } catch (err) {
            console.error(`Failed to upload for category ${cat.name}:`, err);
          }
        }
      }
    }

    // Migrate Products
    const products = await Product.find({});
    for (const prod of products) {
      let updated = false;
      const newImages = [];
      for (const img of prod.images) {
        if (img && img.startsWith('assets/')) {
          const fullPath = path.join(userAppAssetsDir, img);
          if (fs.existsSync(fullPath)) {
            console.log(`Uploading product image for ${prod.name}...`);
            try {
              const url = await uploadToCloudinary(fullPath);
              newImages.push(url);
              updated = true;
              console.log(`Uploaded image for ${prod.name} -> ${url}`);
            } catch (err) {
              console.error(`Failed to upload for product ${prod.name}:`, err);
              newImages.push(img); // keep old on fail
            }
          } else {
            console.log(`File not found: ${fullPath}`);
            newImages.push(img);
          }
        } else {
          newImages.push(img);
        }
      }
      if (updated) {
        prod.images = newImages;
        await prod.save();
        console.log(`Updated product ${prod.name} in DB`);
      }
    }

    console.log('Migration complete!');
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
}

migrate();
