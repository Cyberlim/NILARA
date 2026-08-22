const express = require('express');
const router = express.Router();

const { createAddress, listAddresses, updateAddress, deleteAddress } = require('../controllers/addressController');
const { requireAuth } = require('../middlewares/authMiddleware');
const { validate } = require('../middlewares/validateMiddleware');
const { createAddressSchema, updateAddressSchema } = require('../validators/addressValidators');
const { objectIdParamSchema } = require('../validators/commonValidators');
const { CUSTOMER_STANDARD } = require('../middlewares/rateLimiter');

router.use(requireAuth);
router.use(CUSTOMER_STANDARD);

router.post('/', validate({ body: createAddressSchema }), createAddress);
router.get('/', listAddresses);

// Validate that the :id param is a valid ObjectId
router.use('/:id', validate({ params: objectIdParamSchema }));

router.patch('/:id', validate({ body: updateAddressSchema }), updateAddress);
router.delete('/:id', deleteAddress);

module.exports = router;
