import re

with open("src/middlewares/authMiddleware.js", "r", encoding="utf-8") as f:
    content = f.read()

new_middleware = """
const requireOnboarding = async (req, res, next) => {
  try {
    const User = require('../models/User');
    const user = await User.findById(req.auth.userId);
    
    if (!user || !user.onboardingComplete) {
      return res.status(403).json({
        success: false,
        error: { code: 'FORBIDDEN', message: 'You must complete the onboarding setup first.' },
        requestId: req.requestId
      });
    }
    next();
  } catch (error) {
    next(error);
  }
};

module.exports = { requireAuth, optionalAuth, requireOnboarding };
"""

content = content.replace("module.exports = { requireAuth, optionalAuth };", new_middleware)

with open("src/middlewares/authMiddleware.js", "w", encoding="utf-8") as f:
    f.write(content)
