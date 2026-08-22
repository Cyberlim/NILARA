const { z } = require('zod');
const { objectIdSchema } = require('./commonValidators');

const variantSchema = z.object({
  sku: z.string().trim().min(1).max(50),
  pricePaise: z.number().int().min(0),
  discountPricePaise: z.number().int().min(0).optional(),
  stockQuantity: z.number().int().min(0),
  unit: z.enum(['piece', 'ml', 'l', 'g', 'kg', 'pack']),
  weightOrVolume: z.number().min(0),
  isActive: z.boolean().optional(),
}).strict().refine(
  (data) => data.discountPricePaise == null || data.discountPricePaise <= data.pricePaise,
  { message: 'discountPricePaise cannot exceed pricePaise', path: ['discountPricePaise'] }
);

const createProductSchema = z.object({
  name: z.string().trim().min(1).max(200),
  description: z.string().trim().max(2000).optional(),
  category: objectIdSchema,
  images: z.array(z.string().trim().url()).min(1).max(10),
  variants: z.array(variantSchema).min(1).max(20),
}).strict();

const updateProductSchema = z.object({
  name: z.string().trim().min(1).max(200).optional(),
  description: z.string().trim().max(2000).optional(),
  category: objectIdSchema.optional(),
  images: z.array(z.string().trim().url()).min(1).max(10).optional(),
  variants: z.array(variantSchema).min(1).max(20).optional(),
  isActive: z.boolean().optional(),
}).strict();

module.exports = { createProductSchema, updateProductSchema };
