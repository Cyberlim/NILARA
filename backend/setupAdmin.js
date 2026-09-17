require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');

async function setupAdmin() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB.');

    const emails = [
      'admin@nilara.com',
      'kdev7830@gmail.com',
      'kapildev781885@gmail.com',
      'cyberlimcare@gmail.com'
    ];
    const password = 'admin123';
    const bcrypt = require('bcryptjs');

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    for (const email of emails) {
      await User.findOneAndUpdate(
        { email },
        {
          $set: {
            email,
            password: hashedPassword,
            role: 'admin',
            isActive: true,
            permissions: ['all']
          },
          $setOnInsert: {
            displayName: email === 'admin@nilara.com' ? 'Super Admin' : 'Admin User'
          }
        },
        { returnDocument: 'after', upsert: true }
      );
      console.log(`Configured admin: ${email}`);
    }

    console.log('\nAdmin users successfully configured in MongoDB!');
    console.log('You can log in with any of these:');
    emails.forEach(e => console.log(` - ${e} (password: ${password})`));
    
  } catch (error) {
    console.error('Error setting up admin:', error);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
}

setupAdmin();
