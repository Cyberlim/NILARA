require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/models/User');

const DB_URI = process.env.MONGO_URI;

async function seed() {
  await mongoose.connect(DB_URI);
  
  // Create a delivery partner if it doesn't exist.
  // We will assume the user registers via Firebase with email 'delivery@nilara.com'
  // When they login via Firebase, it returns a UID, which our backend /auth/sync will use.
  // But since the login sync route creates the user with role customer by default,
  // we can create the user here manually or update an existing one.
  
  const email = 'delivery@nilara.com';
  
  let user = await User.findOne({ email });
  if (user) {
    user.role = 'delivery';
    await user.save();
    console.log("Updated existing user to delivery partner.");
  } else {
    // If they haven't registered on Firebase yet, it's better to just tell the user to register
    // in the app as a normal user first, and then we change their role.
    console.log("User not found. Register in the app first using delivery@nilara.com, then run this script again.");
  }
  
  process.exit(0);
}
seed();
