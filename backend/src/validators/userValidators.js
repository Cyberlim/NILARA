const { z } = require('zod');

const updateProfileSchema = z.object({
  displayName: z.string().trim().min(1).max(100).optional(),
  phone: z.string().trim().min(5).max(20).optional(),
}).strict();

module.exports = { updateProfileSchema };
