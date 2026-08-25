const rateLimit = require('express-rate-limit');

/**
 * Named rate-limit policies.
 * Each policy is exported individually so routes can apply the correct tier.
 * IP detection: standardHeaders uses RateLimit-* headers. 
 * WARNING: Do not set app.set('trust proxy', true) unless behind a known proxy.
 */

const AUTH_STRICT = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10,
  message: { success: false, error: { code: 'TOO_MANY_REQUESTS', message: 'Too many authentication attempts. Try again later.' } },
  standardHeaders: true,
  legacyHeaders: false,
});

const OTP_VERY_STRICT = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5,
  message: { success: false, error: { code: 'TOO_MANY_REQUESTS', message: 'Too many OTP requests. Try again later.' } },
  standardHeaders: true,
  legacyHeaders: false,
});

const PUBLIC_STANDARD = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000,
  message: { success: false, error: { code: 'TOO_MANY_REQUESTS', message: 'Too many requests. Try again later.' } },
  standardHeaders: true,
  legacyHeaders: false,
});

const CUSTOMER_STANDARD = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000,
  message: { success: false, error: { code: 'TOO_MANY_REQUESTS', message: 'Too many requests. Try again later.' } },
  standardHeaders: true,
  legacyHeaders: false,
});

const DELIVERY_STANDARD = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { success: false, error: { code: 'TOO_MANY_REQUESTS', message: 'Too many requests. Try again later.' } },
  standardHeaders: true,
  legacyHeaders: false,
});

const ADMIN_STRICT = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 1000,
  message: { success: false, error: { code: 'TOO_MANY_REQUESTS', message: 'Too many admin requests. Try again later.' } },
  standardHeaders: true,
  legacyHeaders: false,
});

const UPLOAD_STRICT = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 30,
  message: { success: false, error: { code: 'TOO_MANY_REQUESTS', message: 'Too many upload requests. Try again later.' } },
  standardHeaders: true,
  legacyHeaders: false,
});

const PAYMENT_STRICT = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { success: false, error: { code: 'TOO_MANY_REQUESTS', message: 'Too many payment requests. Try again later.' } },
  standardHeaders: true,
  legacyHeaders: false,
});

// Legacy aliases for backward compatibility with existing routes
const publicLimiter = PUBLIC_STANDARD;
const authLimiter = AUTH_STRICT;

module.exports = {
  AUTH_STRICT,
  OTP_VERY_STRICT,
  PUBLIC_STANDARD,
  CUSTOMER_STANDARD,
  DELIVERY_STANDARD,
  ADMIN_STRICT,
  UPLOAD_STRICT,
  PAYMENT_STRICT,
  publicLimiter,
  authLimiter,
};
