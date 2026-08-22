const { z } = require('zod');
const mongoose = require('mongoose');

const checkoutItemSchema = z.object({
  productId: z.string().refine((val) => mongoose.Types.ObjectId.isValid(val), {
    message: 'Invalid productId format'
  }),
  variantId: z.string().refine((val) => mongoose.Types.ObjectId.isValid(val), {
    message: 'Invalid variantId format'
  }),
  quantity: z.number().int().positive()
});

const checkoutSchema = z.object({
  items: z.array(checkoutItemSchema).min(1, 'Cart cannot be empty'),
  deliveryAddressId: z.string().refine((val) => mongoose.Types.ObjectId.isValid(val), {
    message: 'Invalid deliveryAddressId format'
  }),
  paymentMethod: z.enum(['cod', 'online']),
  customerNotes: z.string().trim().max(500).optional()
}).strict();

const updateOrderStatusSchema = z.object({
  status: z.enum(['pending', 'confirmed', 'preparing', 'ready_for_pickup', 'out_for_delivery', 'delivered', 'cancelled'])
}).strict();

module.exports = {
  checkoutSchema,
  updateOrderStatusSchema
};
