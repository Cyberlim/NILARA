const { z } = require('zod');
const mongoose = require('mongoose');

const objectIdSchema = z.string().refine(
  (val) => mongoose.Types.ObjectId.isValid(val),
  { message: 'Invalid identifier format' }
);

const objectIdParamSchema = z.object({
  id: objectIdSchema
});

const paginationQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(20),
}).passthrough(); // allow other query params to pass through

module.exports = { objectIdSchema, objectIdParamSchema, paginationQuerySchema };
