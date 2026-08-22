const Category = require('../models/Category');
const { recordAudit } = require('../models/AuditLog');
const { generateUniqueSlug } = require('../utils/slugify');

const createCategory = async (req, res, next) => {
  try {
    const { name, imageUrl, sortOrder } = req.body;

    const slug = await generateUniqueSlug(name, Category);

    const category = await Category.create({
      name,
      slug,
      imageUrl,
      sortOrder: sortOrder || 0,
      isActive: true
    });

    await recordAudit({
      actorUserId: req.auth.userId,
      actorRole: req.auth.role,
      action: 'ADMIN_CATEGORY_CREATE',
      resourceType: 'Category',
      resourceId: category._id,
      requestId: req.requestId,
      newState: { name, slug, isActive: true }
    });

    res.status(201).json({ success: true, data: category, requestId: req.requestId });
  } catch (err) { next(err); }
};

const listCategories = async (req, res, next) => {
  try {
    const categories = await Category.find({ isActive: true })
      .sort({ sortOrder: 1, name: 1 })
      .select('-__v');
    res.json({ success: true, data: categories, requestId: req.requestId });
  } catch (err) { next(err); }
};

const getCategoryBySlug = async (req, res, next) => {
  try {
    const category = await Category.findOne({ slug: req.params.slug, isActive: true }).select('-__v');
    if (!category) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Category not found' },
        requestId: req.requestId
      });
    }
    res.json({ success: true, data: category, requestId: req.requestId });
  } catch (err) { next(err); }
};

const updateCategory = async (req, res, next) => {
  try {
    const { name, imageUrl, sortOrder, isActive } = req.body;
    
    const updateFields = {};
    if (name !== undefined) {
      updateFields.name = name;
      updateFields.slug = await generateUniqueSlug(name, Category, req.params.id);
    }
    if (imageUrl !== undefined) updateFields.imageUrl = imageUrl;
    if (sortOrder !== undefined) updateFields.sortOrder = sortOrder;
    if (isActive !== undefined) updateFields.isActive = isActive;

    const category = await Category.findByIdAndUpdate(
      req.params.id,
      { $set: updateFields },
      { new: true, runValidators: true }
    ).select('-__v');

    if (!category) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Category not found' },
        requestId: req.requestId
      });
    }

    await recordAudit({
      actorUserId: req.auth.userId,
      actorRole: req.auth.role,
      action: 'ADMIN_CATEGORY_UPDATE',
      resourceType: 'Category',
      resourceId: category._id,
      requestId: req.requestId,
      newState: updateFields
    });

    res.json({ success: true, data: category, requestId: req.requestId });
  } catch (err) { next(err); }
};

const archiveCategory = async (req, res, next) => {
  try {
    const category = await Category.findByIdAndUpdate(
      req.params.id,
      { $set: { isActive: false } },
      { new: true }
    );

    if (!category) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Category not found' },
        requestId: req.requestId
      });
    }

    await recordAudit({
      actorUserId: req.auth.userId,
      actorRole: req.auth.role,
      action: 'ADMIN_CATEGORY_ARCHIVE',
      resourceType: 'Category',
      resourceId: category._id,
      requestId: req.requestId,
      newState: { isActive: false }
    });

    res.json({ success: true, message: 'Category archived successfully', requestId: req.requestId });
  } catch (err) { next(err); }
};

module.exports = { createCategory, listCategories, getCategoryBySlug, updateCategory, archiveCategory };
