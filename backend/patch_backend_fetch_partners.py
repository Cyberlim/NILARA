import re

# 1. Update adminController.js
with open("src/controllers/adminController.js", "r", encoding="utf-8") as f:
    ac = f.read()

get_all_partners = """
const getAllDeliveryPartners = async (req, res, next) => {
  try {
    const partners = await User.find({ role: 'delivery' })
      .select('displayName email phone isActive photoUrl createdAt')
      .sort({ createdAt: -1 });

    const formattedPartners = partners.map(p => ({
      id: p._id.toString(),
      name: p.displayName || 'Unknown Rider',
      email: p.email || 'N/A',
      phone: p.phone || 'N/A',
      avatar: p.photoUrl,
      status: p.isActive ? 'Active' : 'Suspended',
      statusColor: p.isActive ? 'teal' : 'red',
      joinDate: p.createdAt.toISOString().split('T')[0],
      totalOrders: 0,
      rating: 5.0,
      currentStatus: 'Offline'
    }));

    res.status(200).json({ success: true, data: formattedPartners });
  } catch (error) { next(error); }
};
"""

ac = ac.replace("module.exports = {", get_all_partners + "\nmodule.exports = {")
ac = ac.replace("module.exports = {", "module.exports = {\n  getAllDeliveryPartners,")

with open("src/controllers/adminController.js", "w", encoding="utf-8") as f:
    f.write(ac)

# 2. Update adminRoutes.js
with open("src/routes/adminRoutes.js", "r", encoding="utf-8") as f:
    ar = f.read()

ar = ar.replace("addDeliveryPartner } = require('../controllers/adminController');", "addDeliveryPartner, getAllDeliveryPartners } = require('../controllers/adminController');")
ar = ar.replace("router.post('/delivery-partners', validate({ body: createDeliveryPartnerSchema }), addDeliveryPartner);", "router.post('/delivery-partners', validate({ body: createDeliveryPartnerSchema }), addDeliveryPartner);\nrouter.get('/delivery-partners', getAllDeliveryPartners);")

with open("src/routes/adminRoutes.js", "w", encoding="utf-8") as f:
    f.write(ar)
