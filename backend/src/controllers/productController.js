const Product = require('../models/Product');
const Category = require('../models/Category');
const { recordAudit } = require('../models/AuditLog');
const { generateUniqueSlug } = require('../utils/slugify');

const createProduct = async (req, res, next) => {
  try {
    const { name, description, category, images, variants } = req.body;

    // Verify category exists and is active
    const cat = await Category.findOne({ _id: category, isActive: true });
    if (!cat) {
      return res.status(400).json({
        success: false,
        error: { code: 'INVALID_CATEGORY', message: 'Category is invalid or inactive' },
        requestId: req.requestId
      });
    }

    const slug = await generateUniqueSlug(name, Product);

    const product = await Product.create({
      name,
      slug,
      description,
      category,
      images,
      variants,
      isActive: true
    });

    await recordAudit({
      actorUserId: req.auth.userId,
      actorRole: req.auth.role,
      action: 'ADMIN_PRODUCT_CREATE',
      resourceType: 'Product',
      resourceId: product._id,
      requestId: req.requestId,
      newState: { name, slug, variantsCount: variants.length }
    });

    res.status(201).json({ success: true, data: product, requestId: req.requestId });
  } catch (err) { 
    // Handle mongoose duplicate key on variant sku
    if (err.code === 11000 && err.message.includes('sku')) {
      return res.status(400).json({
        success: false,
        error: { code: 'DUPLICATE_SKU', message: 'One or more SKU values already exist' },
        requestId: req.requestId
      });
    }
    next(err); 
  }
};

const listProducts = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const query = { isActive: true };
    
    // Optional category filter by slug or ID
    if (req.query.category) {
      const cat = await Category.findOne({ $or: [{ slug: req.query.category }, { _id: req.query.category }] });
      if (cat) query.category = cat._id;
    }

    const products = await Product.find(query)
      .populate('category', 'name slug')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .select('-__v');

    const total = await Product.countDocuments(query);

    res.json({ 
      success: true, 
      data: products, 
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit)
      },
      requestId: req.requestId 
    });
  } catch (err) { next(err); }
};

const getProductBySlug = async (req, res, next) => {
  try {
    const product = await Product.findOne({ slug: req.params.slug, isActive: true })
      .populate('category', 'name slug')
      .select('-__v');
      
    if (!product) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Product not found' },
        requestId: req.requestId
      });
    }
    res.json({ success: true, data: product, requestId: req.requestId });
  } catch (err) { next(err); }
};

const updateProduct = async (req, res, next) => {
  try {
    const { name, description, category, images, variants, isActive } = req.body;
    
    const updateFields = {};
    if (name !== undefined) {
      updateFields.name = name;
      updateFields.slug = await generateUniqueSlug(name, Product, req.params.id);
    }
    if (description !== undefined) updateFields.description = description;
    if (category !== undefined) {
      const cat = await Category.findOne({ _id: category, isActive: true });
      if (!cat) {
        return res.status(400).json({
          success: false,
          error: { code: 'INVALID_CATEGORY', message: 'Category is invalid or inactive' },
          requestId: req.requestId
        });
      }
      updateFields.category = category;
    }
    if (images !== undefined) updateFields.images = images;
    if (variants !== undefined) updateFields.variants = variants;
    if (isActive !== undefined) updateFields.isActive = isActive;

    const product = await Product.findByIdAndUpdate(
      req.params.id,
      { $set: updateFields },
      { new: true, runValidators: true }
    ).select('-__v');

    if (!product) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Product not found' },
        requestId: req.requestId
      });
    }

    await recordAudit({
      actorUserId: req.auth.userId,
      actorRole: req.auth.role,
      action: 'ADMIN_PRODUCT_UPDATE',
      resourceType: 'Product',
      resourceId: product._id,
      requestId: req.requestId,
      newState: { name, category, isActive } // Keep log manageable
    });

    res.json({ success: true, data: product, requestId: req.requestId });
  } catch (err) {
    if (err.code === 11000 && err.message.includes('sku')) {
      return res.status(400).json({
        success: false,
        error: { code: 'DUPLICATE_SKU', message: 'One or more SKU values already exist' },
        requestId: req.requestId
      });
    }
    next(err);
  }
};

const archiveProduct = async (req, res, next) => {
  try {
    const product = await Product.findByIdAndUpdate(
      req.params.id,
      { $set: { isActive: false } },
      { new: true }
    );

    if (!product) {
      return res.status(404).json({
        success: false,
        error: { code: 'NOT_FOUND', message: 'Product not found' },
        requestId: req.requestId
      });
    }

    await recordAudit({
      actorUserId: req.auth.userId,
      actorRole: req.auth.role,
      action: 'ADMIN_PRODUCT_ARCHIVE',
      resourceType: 'Product',
      resourceId: product._id,
      requestId: req.requestId,
      newState: { isActive: false }
    });

    res.json({ success: true, message: 'Product archived successfully', requestId: req.requestId });
  } catch (err) { next(err); }
};

module.exports = { createProduct, listProducts, getProductBySlug, updateProduct, archiveProduct };
