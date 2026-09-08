import re

with open("src/controllers/orderController.js", "r", encoding="utf-8") as f:
    content = f.read()

# Update getMyOrders filter to remove isHiddenByUser if we want, or leave it. 
# We'll revert the filter since orders will be hard deleted anyway.
old_get_my_orders = """      const query = { user: req.auth.userId, isHiddenByUser: { $ne: true } };
      const orders = await Order.find(query)"""
new_get_my_orders = """      const query = { user: req.auth.userId };
      const orders = await Order.find(query)"""
content = content.replace(old_get_my_orders, new_get_my_orders)

# Update hideOrder to deleteOrder
old_hide = """const hideOrder = async (req, res, next) => {
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
};"""

new_hide = """const deleteOrder = async (req, res, next) => {
  try {
    const orderId = req.params.id;
    const order = await Order.findOne({ _id: orderId, user: req.auth.userId });
    
    if (!order) {
      const err = new Error('Order not found or unauthorized');
      err.statusCode = 404;
      throw err;
    }
    
    await Order.findByIdAndDelete(orderId);
    
    res.status(200).json({ success: true, message: 'Order completely deleted from database' });
  } catch (err) {
    next(err);
  }
};"""
content = content.replace(old_hide, new_hide)

content = content.replace("  hideOrder", "  deleteOrder")

with open("src/controllers/orderController.js", "w", encoding="utf-8") as f:
    f.write(content)

with open("src/routes/orderRoutes.js", "r", encoding="utf-8") as f:
    routes = f.read()

routes = routes.replace("hideOrder } = require('../controllers/orderController');", "deleteOrder } = require('../controllers/orderController');")
routes = routes.replace("router.delete('/me/:id', validate({ params: objectIdParamSchema }), hideOrder);", "router.delete('/me/:id', validate({ params: objectIdParamSchema }), deleteOrder);")

with open("src/routes/orderRoutes.js", "w", encoding="utf-8") as f:
    f.write(routes)
