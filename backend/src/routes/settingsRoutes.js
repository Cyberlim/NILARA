const express = require('express');
const { getSettings, updateSettings, getDeliverySupport } = require('../controllers/settingsController');
// const { protect, authorize } = require('../middleware/auth'); // Optional if admin auth is enabled

const router = express.Router();

router
  .route('/')
  .get(getSettings)
  .put(updateSettings); // Assuming no auth middleware needed for local dev right now

router
  .route('/delivery-support')
  .get(getDeliverySupport);

module.exports = router;
