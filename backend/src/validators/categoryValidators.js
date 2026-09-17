const { z } = require('zod');

const createCategorySchema = z.object({
  name: z.string().trim().min(1).max(100),
  imageUrl: z.string().trim().url().or(z.literal('')).optional().default(''),
  sortOrder: z.number().int().min(0).optional(),
  bannerTitle: z.string().trim().max(100).optional(),
  iconName: z.string().trim().max(50).optional(),
  subcategories: z.array(z.string().trim().min(1).max(100)).max(20).optional(),
}).strict();

const updateCategorySchema = z.object({
  name: z.string().trim().min(1).max(100).optional(),
  imageUrl: z.string().trim().url().or(z.literal('')).optional(),
  sortOrder: z.number().int().min(0).optional(),
  bannerTitle: z.string().trim().max(100).optional(),
  iconName: z.string().trim().max(50).optional(),
  subcategories: z.array(z.string().trim().min(1).max(100)).max(20).optional(),
  isActive: z.boolean().optional(),
}).strict();

module.exports = { createCategorySchema, updateCategorySchema };
