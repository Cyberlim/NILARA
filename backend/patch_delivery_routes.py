import re

with open("src/routes/deliveryRoutes.js", "r", encoding="utf-8") as f:
    content = f.read()

import_str = "const { completeOnboarding, getAvailableOrders, acceptOrder, updateDeliveryStatus } = require('../controllers/deliveryController');\nconst { getWalletData, requestPayout } = require('../controllers/walletController');"
content = content.replace("const { completeOnboarding, getAvailableOrders, acceptOrder, updateDeliveryStatus } = require('../controllers/deliveryController');", import_str)

routes_str = """router.get('/orders/available', requireOnboarding, validate({ query: paginationQuerySchema }), getAvailableOrders);
router.patch('/orders/:id/accept', requireOnboarding, validate({ params: objectIdParamSchema }), acceptOrder);
router.patch('/orders/:id/status', requireOnboarding, validate({ params: objectIdParamSchema, body: updateOrderStatusSchema }), updateDeliveryStatus);

// Wallet
router.get('/wallet', requireOnboarding, getWalletData);
router.post('/wallet/payout', requireOnboarding, requestPayout);"""

content = content.replace("""router.get('/orders/available', requireOnboarding, validate({ query: paginationQuerySchema }), getAvailableOrders);
router.patch('/orders/:id/accept', requireOnboarding, validate({ params: objectIdParamSchema }), acceptOrder);
router.patch('/orders/:id/status', requireOnboarding, validate({ params: objectIdParamSchema, body: updateOrderStatusSchema }), updateDeliveryStatus);""", routes_str)

with open("src/routes/deliveryRoutes.js", "w", encoding="utf-8") as f:
    f.write(content)
