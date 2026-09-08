import re

with open("src/routes/deliveryRoutes.js", "r", encoding="utf-8") as f:
    content = f.read()

# Import requireOnboarding
content = content.replace("const { requireAuth } = require('../middlewares/authMiddleware');", "const { requireAuth, requireOnboarding } = require('../middlewares/authMiddleware');")

# Add requireOnboarding to specific routes
old_orders = """router.get('/orders/available', validate({ query: paginationQuerySchema }), getAvailableOrders);
router.patch('/orders/:id/accept', validate({ params: objectIdParamSchema }), acceptOrder);
router.patch('/orders/:id/status', validate({ params: objectIdParamSchema, body: updateOrderStatusSchema }), updateDeliveryStatus);"""

new_orders = """router.get('/orders/available', requireOnboarding, validate({ query: paginationQuerySchema }), getAvailableOrders);
router.patch('/orders/:id/accept', requireOnboarding, validate({ params: objectIdParamSchema }), acceptOrder);
router.patch('/orders/:id/status', requireOnboarding, validate({ params: objectIdParamSchema, body: updateOrderStatusSchema }), updateDeliveryStatus);"""

content = content.replace(old_orders, new_orders)

with open("src/routes/deliveryRoutes.js", "w", encoding="utf-8") as f:
    f.write(content)
