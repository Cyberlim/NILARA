const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getMessaging } = require('firebase-admin/messaging');

let app;
try {
  const serviceAccount = require('../../firebase-service-account.json');
  app = initializeApp({
    credential: cert(serviceAccount)
  });
  console.log('Firebase Admin initialized successfully');
} catch (error) {
  console.error('Firebase Service Account not found or invalid.', error.message);
}

module.exports = {
  app,
  auth: app ? getAuth(app) : null,
  messaging: app ? getMessaging(app) : null
};
