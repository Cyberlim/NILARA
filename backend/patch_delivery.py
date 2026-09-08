import re

with open("src/controllers/deliveryController.js", "r", encoding="utf-8") as f:
    content = f.read()

import_str = "const Order = require('../models/Order');\nconst Transaction = require('../models/Transaction');\nconst User = require('../models/User');"
content = content.replace("const Order = require('../models/Order');", import_str)

old_status = """    order.status = status;
    if (status === 'out_for_delivery') order.outForDeliveryAt = new Date();
    if (status === 'delivered') order.deliveredAt = new Date();
    
    await order.save();"""

new_status = """    order.status = status;
    if (status === 'out_for_delivery') order.outForDeliveryAt = new Date();
    if (status === 'delivered') {
      order.deliveredAt = new Date();
      
      // Calculate earnings in Rupees (fallback to Rs 20 if 0)
      const feeRupees = order.deliveryFeePaise > 0 ? (order.deliveryFeePaise / 100) : 20;
      
      const user = await User.findById(partnerId);
      if (user) {
        user.walletBalance = (user.walletBalance || 0) + feeRupees;
        await user.save();
        
        await Transaction.create({
          user: partnerId,
          type: 'credit',
          amount: feeRupees,
          order: orderId,
          description: `Earning for Order #${order.orderNumber}`
        });
      }
    }
    
    await order.save();"""

content = content.replace(old_status, new_status)

with open("src/controllers/deliveryController.js", "w", encoding="utf-8") as f:
    f.write(content)
