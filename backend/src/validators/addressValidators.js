const { z } = require('zod');

const coordinateSchema = z.tuple([
  z.number().min(-180).max(180), // longitude
  z.number().min(-90).max(90),   // latitude
]);

const createAddressSchema = z.object({
  label: z.string().trim().max(50).optional(),
  recipientName: z.string().trim().min(1).max(100),
  phone: z.string().trim().min(5).max(20),
  addressLine1: z.string().trim().min(1).max(200),
  addressLine2: z.string().trim().max(200).optional(),
  landmark: z.string().trim().max(200).optional(),
  city: z.string().trim().min(1).max(100),
  state: z.string().trim().min(1).max(100),
  postalCode: z.string().trim().min(4).max(10),
  coordinates: coordinateSchema,
  isDefault: z.boolean().optional(),
}).strict();

const updateAddressSchema = z.object({
  label: z.string().trim().max(50).optional(),
  recipientName: z.string().trim().min(1).max(100).optional(),
  phone: z.string().trim().min(5).max(20).optional(),
  addressLine1: z.string().trim().min(1).max(200).optional(),
  addressLine2: z.string().trim().max(200).optional(),
  landmark: z.string().trim().max(200).optional(),
  city: z.string().trim().min(1).max(100).optional(),
  state: z.string().trim().min(1).max(100).optional(),
  postalCode: z.string().trim().min(4).max(10).optional(),
  coordinates: coordinateSchema.optional(),
  isDefault: z.boolean().optional(),
}).strict();

module.exports = { createAddressSchema, updateAddressSchema };
