require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');

async function setupAdmin() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB.');

    const email = 'admin@nilara.com';
    const password = 'admin123';
    const displayName = 'Super Admin';
    const bcrypt = require('bcryptjs');

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    // Upsert user in MongoDB
    console.log('Updating MongoDB user record...');
    const dbUser = await User.findOneAndUpdate(
      { email },
      {
        email,
        password: hashedPassword,
        displayName,
        role: 'admin',
        isActive: true,
        permissions: ['all']
      },
      { new: true, upsert: true }
    );

    console.log('Admin user successfully configured in MongoDB!');
    console.log('You can now log in with:');
    console.log('Email:', email);
    console.log('Password:', password);
    
  } catch (error) {
    console.error('Error setting up admin:', error);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
}

setupAdmin();
