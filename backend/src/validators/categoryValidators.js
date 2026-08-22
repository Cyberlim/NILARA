const { z } = require('zod');

const createCategorySchema = z.object({
  name: z.string().trim().min(1).max(100),
  imageUrl: z.string().trim().url(),
  sortOrder: z.number().int().min(0).optional(),
}).strict();

const updateCategorySchema = z.object({
  name: z.string().trim().min(1).max(100).optional(),
  imageUrl: z.string().trim().url().optional(),
  sortOrder: z.number().int().min(0).optional(),
  isActive: z.boolean().optional(),
}).strict();

module.exports = { createCategorySchema, updateCategorySchema };
