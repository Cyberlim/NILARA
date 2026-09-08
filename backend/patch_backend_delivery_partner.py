import re
import os

# 1. Update userValidators.js
with open("src/validators/userValidators.js", "r", encoding="utf-8") as f:
    uv = f.read()

new_schema = """const createDeliveryPartnerSchema = z.object({
  name: z.string().trim().min(2, "Name must be at least 2 characters").max(100),
  email: z.string().email("Invalid email format"),
  phone: z.string().trim().min(5, "Phone must be at least 5 characters").max(20),
  password: z.string().min(6, "Password must be at least 6 characters")
}).strict();"""

uv = uv.replace("module.exports = { updateProfileSchema };", f"{new_schema}\n\nmodule.exports = {{ updateProfileSchema, createDeliveryPartnerSchema }};")

with open("src/validators/userValidators.js", "w", encoding="utf-8") as f:
    f.write(uv)


# 2. Update adminController.js
with open("src/controllers/adminController.js", "r", encoding="utf-8") as f:
    ac = f.read()

ac_imports = """const Order = require('../models/Order');
const User = require('../models/User');
const { auth } = require('../config/firebase');"""

ac = ac.replace("const Order = require('../models/Order');", ac_imports)

add_partner = """
const addDeliveryPartner = async (req, res, next) => {
  try {
    const { name, email, phone, password } = req.body;

    // Check if user exists in MongoDB first
    const existingUser = await User.findOne({ email });
    if (existingUser) {
      const err = new Error('User already exists in database');
      err.statusCode = 400;
      throw err;
    }

    if (!auth) {
      const err = new Error('Firebase Admin Auth is not initialized');
      err.statusCode = 500;
      throw err;
    }

    // Create user in Firebase Auth
    const firebaseUser = await auth.createUser({
      email,
      emailVerified: false,
      password,
      displayName: name,
      disabled: false,
    });

    // Create user in MongoDB
    const newUser = await User.create({
      firebaseUid: firebaseUser.uid,
      email,
      phone,
      displayName: name,
      role: 'delivery',
      isActive: true,
    });

    res.status(201).json({
      success: true,
      data: {
        id: newUser._id,
        name: newUser.displayName,
        email: newUser.email,
        role: newUser.role
      },
      message: 'Delivery partner created successfully'
    });
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      error.statusCode = 400;
      error.message = 'The email address is already in use by another account.';
    }
    next(error);
  }
};
"""

# Inject before module.exports
ac = ac.replace("module.exports = {", add_partner + "\nmodule.exports = {")
ac = ac.replace("module.exports = {", "module.exports = {\n  addDeliveryPartner,")

with open("src/controllers/adminController.js", "w", encoding="utf-8") as f:
    f.write(ac)


# 3. Update adminRoutes.js
with open("src/routes/adminRoutes.js", "r", encoding="utf-8") as f:
    ar = f.read()

ar = ar.replace("markDeliveryDelivered } = require('../controllers/adminController');", "markDeliveryDelivered, addDeliveryPartner } = require('../controllers/adminController');")
ar = ar.replace("const { updateOrderStatusSchema } = require('../validators/orderValidators');", "const { updateOrderStatusSchema } = require('../validators/orderValidators');\nconst { createDeliveryPartnerSchema } = require('../validators/userValidators');")

add_route = """// Delivery Partners
router.post('/delivery-partners', validate({ body: createDeliveryPartnerSchema }), addDeliveryPartner);"""

ar = ar.replace("module.exports = router;", add_route + "\n\nmodule.exports = router;")

with open("src/routes/adminRoutes.js", "w", encoding="utf-8") as f:
    f.write(ar)

