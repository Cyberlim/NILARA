const { auth } = require('../config/firebase');
const User = require('../models/User');

const requireAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Missing or invalid authorization header'
        },
        requestId: req.requestId
      });
    }

    const idToken = authHeader.substring(7); // 'Bearer '.length === 7
    if (!idToken || idToken.trim().length === 0) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Missing or invalid authorization header'
        },
        requestId: req.requestId
      });
    }

    let decodedToken;
    try {
      decodedToken = await auth.verifyIdToken(idToken);
    } catch (firebaseError) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'INVALID_TOKEN',
          message: 'The provided token is expired or invalid'
        },
        requestId: req.requestId
      });
    }

    const firebaseUid = decodedToken.uid;

    // Attempt to find the user in DB
    const user = await User.findOne({ firebaseUid });

    if (!user) {
      // If no user exists yet, we still set req.auth but without a userId,
      // so the /api/v1/auth/sync endpoint can create it.
      req.auth = {
        firebaseUid,
        email: decodedToken.email,
        phone: decodedToken.phone_number,
        picture: decodedToken.picture,
        name: decodedToken.name
      };
      return next();
    }

    if (!user.isActive) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'ACCOUNT_SUSPENDED',
          message: 'Your account has been suspended or is inactive.'
        },
        requestId: req.requestId
      });
    }

    // Establish trusted backend auth context
    req.auth = {
      firebaseUid: user.firebaseUid,
      userId: user._id.toString(),
      role: user.role,
      isActive: user.isActive,
      permissions: user.permissions || []
    };

    next();
  } catch (error) {
    next(error);
  }
};

const optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return next();
    }

    const idToken = authHeader.substring(7);
    if (!idToken || idToken.trim().length === 0) {
      return next();
    }

    let decodedToken;
    try {
      decodedToken = await auth.verifyIdToken(idToken);
    } catch (firebaseError) {
      return next();
    }

    const firebaseUid = decodedToken.uid;
    const user = await User.findOne({ firebaseUid });

    if (user && user.isActive) {
      req.auth = {
        firebaseUid: user.firebaseUid,
        userId: user._id.toString(),
        role: user.role,
        isActive: user.isActive,
        permissions: user.permissions || []
      };
    } else if (!user) {
      req.auth = {
        firebaseUid,
        email: decodedToken.email,
        phone: decodedToken.phone_number,
        picture: decodedToken.picture,
        name: decodedToken.name
      };
    }
    next();
  } catch (error) {
    next();
  }
};

module.exports = { requireAuth, optionalAuth };
