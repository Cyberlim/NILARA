require('dotenv').config();
const mongoose = require('mongoose');
const { auth } = require('./src/config/firebase');
const User = require('./src/models/User');

async function setupAdmin() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB.');

    const email = 'admin@nilara.com';
    const password = 'admin123';
    const displayName = 'Super Admin';

    let firebaseUser;
    
    // Check if user already exists in Firebase
    try {
      firebaseUser = await auth.getUserByEmail(email);
      console.log('User already exists in Firebase Auth. Updating password...');
      await auth.updateUser(firebaseUser.uid, { password, displayName });
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        console.log('Creating new user in Firebase Auth...');
        firebaseUser = await auth.createUser({
          email,
          password,
          displayName,
          emailVerified: true
        });
      } else {
        throw error;
      }
    }

    console.log('Firebase User UID:', firebaseUser.uid);

    // Upsert user in MongoDB
    console.log('Updating MongoDB user record...');
    const dbUser = await User.findOneAndUpdate(
      { firebaseUid: firebaseUser.uid },
      {
        email,
        displayName,
        role: 'admin',
        isActive: true,
        permissions: ['all']
      },
      { new: true, upsert: true }
    );

    console.log('Admin user successfully configured!');
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
