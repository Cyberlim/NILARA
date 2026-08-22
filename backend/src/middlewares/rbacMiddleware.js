const requireRole = (...allowedRoles) => {
  return (req, res, next) => {
    if (!req.auth || !req.auth.userId) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required'
        },
        requestId: req.requestId
      });
    }

    if (!allowedRoles.includes(req.auth.role)) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'You do not have the required role to perform this action'
        },
        requestId: req.requestId
      });
    }

    next();
  };
};

const requirePermission = (requiredPermission) => {
  return (req, res, next) => {
    if (!req.auth || !req.auth.userId) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'Authentication required'
        },
        requestId: req.requestId
      });
    }

    // Admins implicitly have all permissions in this setup, or we check explicit array
    if (req.auth.role === 'admin' || (req.auth.permissions && req.auth.permissions.includes(requiredPermission))) {
      return next();
    }

    return res.status(403).json({
      success: false,
      error: {
        code: 'FORBIDDEN',
        message: 'You do not have the required permission to perform this action'
      },
      requestId: req.requestId
    });
  };
};

module.exports = { requireRole, requirePermission };
