const express = require('express');
const router = express.Router();

const { createCategory, listCategories, getCategoryBySlug, updateCategory, archiveCategory } = require('../controllers/categoryController');
const { requireAuth } = require('../middlewares/authMiddleware');
const { requireRole } = require('../middlewares/rbacMiddleware');
const { validate } = require('../middlewares/validateMiddleware');
const { createCategorySchema, updateCategorySchema } = require('../validators/categoryValidators');
const { objectIdParamSchema } = require('../validators/commonValidators');
const { PUBLIC_STANDARD, ADMIN_STRICT } = require('../middlewares/rateLimiter');

// Public reads
router.get('/', PUBLIC_STANDARD, listCategories);
router.get('/:slug', PUBLIC_STANDARD, getCategoryBySlug);

// Admin mutations
router.use(requireAuth);
router.use(requireRole('admin'));
router.use(ADMIN_STRICT);

router.post('/', validate({ body: createCategorySchema }), createCategory);

router.use('/:id', validate({ params: objectIdParamSchema }));
router.patch('/:id', validate({ body: updateCategorySchema }), updateCategory);
router.put('/:id', validate({ body: updateCategorySchema }), updateCategory);
router.delete('/:id', archiveCategory);

module.exports = router;
