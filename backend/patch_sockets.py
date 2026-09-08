import re

with open("src/controllers/orderController.js", "r", encoding="utf-8") as f:
    oc = f.read()

oc = oc.replace("req.app.get('io').to(`admin_room`).emit('new_order', order[0]);", "req.app.get('io').to(`admin_room`).emit('new_order', order[0]);\n    req.app.get('io').to(`delivery_room`).emit('new_order_available', order[0]);")

with open("src/controllers/orderController.js", "w", encoding="utf-8") as f:
    f.write(oc)


with open("src/controllers/adminController.js", "r", encoding="utf-8") as f:
    ac = f.read()

ac = ac.replace("req.app.get('io').to(`admin_room`).emit('order_status_updated', { orderId: order._id, status });", "req.app.get('io').to(`admin_room`).emit('order_status_updated', { orderId: order._id, status });\n    req.app.get('io').to(`delivery_room`).emit('order_status_updated', { orderId: order._id, status });")

with open("src/controllers/adminController.js", "w", encoding="utf-8") as f:
    f.write(ac)
