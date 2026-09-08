import re

with open("src/controllers/orderController.js", "r", encoding="utf-8") as f:
    content = f.read()

# 1. Update getMyOrders filter
old_get_my_orders = """      const orders = await Order.find({ user: req.auth.userId })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean();
        
      const total = await Order.countDocuments({ user: req.auth.userId });"""

new_get_my_orders = """      const query = { user: req.auth.userId, isHiddenByUser: { $ne: true } };
      const orders = await Order.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .lean();
        
      const total = await Order.countDocuments(query);"""
content = content.replace(old_get_my_orders, new_get_my_orders)

# 2. Add hideOrder method
hide_order_method = """const hideOrder = async (req, res, next) => {
  try {
    const orderId = req.params.id;
    const order = await Order.findOne({ _id: orderId, user: req.auth.userId });
    
    if (!order) {
      const err = new Error('Order not found or unauthorized');
      err.statusCode = 404;
      throw err;
    }
    
    order.isHiddenByUser = true;
    await order.save();
    
    res.status(200).json({ success: true, message: 'Order removed from history' });
  } catch (err) {
    next(err);
  }
};

module.exports = {"""
content = content.replace("module.exports = {", hide_order_method)

# 3. Export hideOrder
content = content.replace("  mockPayOrder\n};", "  mockPayOrder,\n  hideOrder\n};")

with open("src/controllers/orderController.js", "w", encoding="utf-8") as f:
    f.write(content)


with open("src/routes/orderRoutes.js", "r", encoding="utf-8") as f:
    routes = f.read()

# 1. Import hideOrder
routes = routes.replace("mockPayOrder } = require('../controllers/orderController');", "mockPayOrder, hideOrder } = require('../controllers/orderController');")

# 2. Register route
new_route = """router.post('/:id/mock-pay', validate({ params: objectIdParamSchema }), mockPayOrder);
router.delete('/me/:id', validate({ params: objectIdParamSchema }), hideOrder);"""
routes = routes.replace("router.post('/:id/mock-pay', validate({ params: objectIdParamSchema }), mockPayOrder);", new_route)

with open("src/routes/orderRoutes.js", "w", encoding="utf-8") as f:
    f.write(routes)
