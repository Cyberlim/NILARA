const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cartController');
const { requireAuth } = require('../middlewares/authMiddleware');

router.use(requireAuth);

router.route('/')
  .get(cartController.getCart)
  .post(cartController.addItem)
  .put(cartController.syncCart)
  .delete(cartController.clearCart);

router.route('/:productId/:variantId')
  .delete(cartController.removeItem);

module.exports = router;
