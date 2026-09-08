const express = require('express');
const router = express.Router();
const { requireAuth } = require('../middlewares/authMiddleware');
const reviewController = require('../controllers/reviewController');

// Public route to get reviews for a product
router.get('/product/:productId', reviewController.getProductReviews);

// All other routes require auth
router.use(requireAuth);

router.post('/', reviewController.createReview);
router.get('/eligibility/order/:orderId', reviewController.getReviewEligibility);

module.exports = router;
