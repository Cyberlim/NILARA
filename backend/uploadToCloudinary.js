require('dotenv').config();
const mongoose = require('mongoose');
const cloudinary = require('cloudinary').v2;
const fs = require('fs');
const path = require('path');

// Configure Cloudinary
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

const Product = require('./src/models/Product');

const uploadImages = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('MongoDB Connected');

    const products = await Product.find();
    let updatedCount = 0;

    for (const product of products) {
      if (product.images && product.images.length > 0) {
        const newImages = [];
        let needsUpdate = false;

        for (const imagePath of product.images) {
          if (imagePath.startsWith('assets/images/')) {
            const fileName = imagePath.replace('assets/images/', '');
            const absolutePath = path.join(__dirname, '../apps/user-app/assets/images', fileName);

            if (fs.existsSync(absolutePath)) {
              console.log(`Uploading ${fileName} for product ${product.name}...`);
              try {
                const result = await cloudinary.uploader.upload(absolutePath, {
                  folder: 'nilara',
                  resource_type: 'image'
                });
                newImages.push(result.secure_url);
                needsUpdate = true;
                console.log(` -> Uploaded successfully: ${result.secure_url}`);
              } catch (uploadErr) {
                console.error(`Failed to upload ${fileName}:`, uploadErr);
                newImages.push(imagePath); // Keep old path if upload fails
              }
            } else {
              console.log(`File not found: ${absolutePath}, skipping...`);
              newImages.push(imagePath);
            }
          } else {
            // Already uploaded or valid URL
            newImages.push(imagePath);
          }
        }

        if (needsUpdate) {
          product.images = newImages;
          await product.save();
          updatedCount++;
          console.log(`Updated product: ${product.name}`);
        }
      }
    }

    console.log(`Finished migrating images. Total products updated: ${updatedCount}`);
    process.exit(0);
  } catch (err) {
    console.error('Migration failed:', err);
    process.exit(1);
  }
};

uploadImages();
