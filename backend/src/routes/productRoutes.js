const express = require('express');
const router = express.Router();

const { createProduct, listProducts, getProductBySlug, updateProduct, archiveProduct } = require('../controllers/productController');
const { requireAuth } = require('../middlewares/authMiddleware');
const { requireRole } = require('../middlewares/rbacMiddleware');
const { validate } = require('../middlewares/validateMiddleware');
const { createProductSchema, updateProductSchema } = require('../validators/productValidators');
const { objectIdParamSchema, paginationQuerySchema } = require('../validators/commonValidators');
const { PUBLIC_STANDARD, ADMIN_STRICT } = require('../middlewares/rateLimiter');

// Public reads
router.get('/', validate({ query: paginationQuerySchema }), PUBLIC_STANDARD, listProducts);
router.get('/:slug', PUBLIC_STANDARD, getProductBySlug);

// Admin mutations
router.use(requireAuth);
router.use(requireRole('admin'));
router.use(ADMIN_STRICT);

router.post('/', validate({ body: createProductSchema }), createProduct);

router.use('/:id', validate({ params: objectIdParamSchema }));
router.patch('/:id', validate({ body: updateProductSchema }), updateProduct);
router.delete('/:id', archiveProduct);

module.exports = router;
