// ── Mock firebase-admin BEFORE any imports that depend on it ──────────
jest.mock('firebase-admin', () => ({
  auth: () => ({
    verifyIdToken: jest.fn().mockImplementation((token) => {
      if (token === 'valid_customer') return Promise.resolve({ uid: 'fb_customer_1', email: 'cust@test.com' });
      if (token === 'valid_admin') return Promise.resolve({ uid: 'fb_admin_1', email: 'admin@test.com' });
      if (token === 'valid_delivery') return Promise.resolve({ uid: 'fb_delivery_1', email: 'delivery@test.com' });
      if (token === 'valid_new_user') return Promise.resolve({ uid: 'fb_new_1', email: 'new@test.com' });
      if (token === 'valid_inactive') return Promise.resolve({ uid: 'fb_inactive_1', email: 'inactive@test.com' });
      if (token === 'expired_token') return Promise.reject(new Error('Firebase: ID token has expired'));
      return Promise.reject(new Error('Firebase: Invalid token'));
    })
  }),
  credential: { cert: jest.fn() },
  initializeApp: jest.fn()
}));

// ── Mock Mongoose User model ─────────────────────────────────────────
jest.mock('../src/models/User', () => {
  const mockUsers = {
    'fb_customer_1': { _id: { toString: () => 'mongo_cust_1' }, firebaseUid: 'fb_customer_1', role: 'customer', isActive: true, permissions: [] },
    'fb_admin_1': { _id: { toString: () => 'mongo_admin_1' }, firebaseUid: 'fb_admin_1', role: 'admin', isActive: true, permissions: ['product.update'] },
    'fb_delivery_1': { _id: { toString: () => 'mongo_del_1' }, firebaseUid: 'fb_delivery_1', role: 'delivery', isActive: true, permissions: [] },
    'fb_inactive_1': { _id: { toString: () => 'mongo_inact_1' }, firebaseUid: 'fb_inactive_1', role: 'customer', isActive: false, permissions: [] },
  };
  return {
    findOne: jest.fn(({ firebaseUid }) => Promise.resolve(mockUsers[firebaseUid] || null)),
    findById: jest.fn((id) => {
      const user = Object.values(mockUsers).find(u => u._id.toString() === id);
      return Promise.resolve(user || null);
    }),
    findOneAndUpdate: jest.fn(({ firebaseUid }, update, opts) => {
      if (mockUsers[firebaseUid]) return Promise.resolve(mockUsers[firebaseUid]);
      // Simulate upsert for new user
      return Promise.resolve({
        _id: { toString: () => 'mongo_new_1' },
        firebaseUid,
        email: 'new@test.com',
        role: 'customer',
        isActive: true,
        permissions: [],
        createdAt: new Date()
      });
    })
  };
});

const request = require('supertest');
const express = require('express');

const { requireAuth } = require('../src/middlewares/authMiddleware');
const { requireRole, requirePermission } = require('../src/middlewares/rbacMiddleware');
const { validate } = require('../src/middlewares/validateMiddleware');
const errorHandler = require('../src/middlewares/errorHandler');
const { isValidObjectId } = require('../src/utils/validateObjectId');
const { z } = require('zod');

// ── Build test Express app ───────────────────────────────────────────
const app = express();
app.use(express.json());
app.use((req, res, next) => { req.requestId = 'test-req-id'; next(); });

// Protected route returning req.auth
app.get('/test/protected', requireAuth, (req, res) => res.json({ success: true, auth: req.auth }));
// Admin-only route
app.get('/test/admin-only', requireAuth, requireRole('admin'), (req, res) => res.json({ success: true }));
// Delivery-only route
app.get('/test/delivery-only', requireAuth, requireRole('delivery'), (req, res) => res.json({ success: true }));
// Permission-guarded route
app.get('/test/perm', requireAuth, requirePermission('product.update'), (req, res) => res.json({ success: true }));

// Zod-validated route with strict body schema
const strictSchema = z.object({ name: z.string().min(1) }).strict();
app.post('/test/validate', validate({ body: strictSchema }), (req, res) => res.json({ success: true, data: req.body }));

app.use(errorHandler);

// ═══════════════════════════════════════════════════════════════════════
// TEST SUITES
// ═══════════════════════════════════════════════════════════════════════

describe('Authentication Middleware Security', () => {

  test('missing Authorization header → 401 UNAUTHORIZED', async () => {
    const res = await request(app).get('/test/protected');
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  test('malformed Authorization header (no Bearer prefix) → 401', async () => {
    const res = await request(app).get('/test/protected').set('Authorization', 'Token abc');
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  test('Bearer without token → 401', async () => {
    const res = await request(app).get('/test/protected').set('Authorization', 'Bearer ');
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('UNAUTHORIZED');
  });

  test('invalid Firebase token → 401 INVALID_TOKEN', async () => {
    const res = await request(app).get('/test/protected').set('Authorization', 'Bearer garbage_token');
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('INVALID_TOKEN');
  });

  test('expired Firebase token → 401 INVALID_TOKEN', async () => {
    const res = await request(app).get('/test/protected').set('Authorization', 'Bearer expired_token');
    expect(res.status).toBe(401);
    expect(res.body.error.code).toBe('INVALID_TOKEN');
  });

  test('valid Firebase token, no MongoDB user → req.auth has firebaseUid but no userId', async () => {
    const res = await request(app).get('/test/protected').set('Authorization', 'Bearer valid_new_user');
    expect(res.status).toBe(200);
    expect(res.body.auth.firebaseUid).toBe('fb_new_1');
    expect(res.body.auth.userId).toBeUndefined();
  });

  test('inactive MongoDB user → 403 ACCOUNT_SUSPENDED', async () => {
    const res = await request(app).get('/test/protected').set('Authorization', 'Bearer valid_inactive');
    expect(res.status).toBe(403);
    expect(res.body.error.code).toBe('ACCOUNT_SUSPENDED');
  });

  test('valid active user → req.auth populated correctly from MongoDB', async () => {
    const res = await request(app).get('/test/protected').set('Authorization', 'Bearer valid_customer');
    expect(res.status).toBe(200);
    expect(res.body.auth).toEqual({
      firebaseUid: 'fb_customer_1',
      userId: 'mongo_cust_1',
      role: 'customer',
      isActive: true,
      permissions: []
    });
  });

  test('client cannot influence userId, role, or permissions in req.auth', async () => {
    // Even if the client sends a body with role: admin, req.auth comes from DB
    const res = await request(app)
      .get('/test/protected')
      .set('Authorization', 'Bearer valid_customer')
      .send({ role: 'admin', userId: 'hacker_id', permissions: ['*'] });
    expect(res.status).toBe(200);
    expect(res.body.auth.role).toBe('customer');
    expect(res.body.auth.userId).toBe('mongo_cust_1');
    expect(res.body.auth.permissions).toEqual([]);
  });
});


describe('RBAC Middleware Security', () => {

  test('customer → admin-only endpoint → 403 FORBIDDEN', async () => {
    const res = await request(app).get('/test/admin-only').set('Authorization', 'Bearer valid_customer');
    expect(res.status).toBe(403);
    expect(res.body.error.code).toBe('FORBIDDEN');
  });

  test('delivery → admin-only endpoint → 403 FORBIDDEN', async () => {
    const res = await request(app).get('/test/admin-only').set('Authorization', 'Bearer valid_delivery');
    expect(res.status).toBe(403);
    expect(res.body.error.code).toBe('FORBIDDEN');
  });

  test('admin → admin-only endpoint → 200 allowed', async () => {
    const res = await request(app).get('/test/admin-only').set('Authorization', 'Bearer valid_admin');
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  test('customer → delivery-only endpoint → 403 FORBIDDEN', async () => {
    const res = await request(app).get('/test/delivery-only').set('Authorization', 'Bearer valid_customer');
    expect(res.status).toBe(403);
  });

  test('delivery → delivery-only endpoint → 200 allowed', async () => {
    const res = await request(app).get('/test/delivery-only').set('Authorization', 'Bearer valid_delivery');
    expect(res.status).toBe(200);
  });

  test('unauthenticated request → requireRole returns 401', async () => {
    const isolatedApp = express();
    isolatedApp.get('/t', requireRole('admin'), (req, res) => res.json({ success: true }));
    const res = await request(isolatedApp).get('/t');
    expect(res.status).toBe(401);
  });
});


describe('Permission Middleware Security', () => {

  test('admin has implicit all permissions → 200', async () => {
    const res = await request(app).get('/test/perm').set('Authorization', 'Bearer valid_admin');
    expect(res.status).toBe(200);
  });

  test('customer without product.update permission → 403', async () => {
    const res = await request(app).get('/test/perm').set('Authorization', 'Bearer valid_customer');
    expect(res.status).toBe(403);
  });

  test('delivery without permission → 403', async () => {
    const res = await request(app).get('/test/perm').set('Authorization', 'Bearer valid_delivery');
    expect(res.status).toBe(403);
  });
});


describe('Zod Validation Security', () => {

  test('valid payload → accepted', async () => {
    const res = await request(app).post('/test/validate').send({ name: 'Test' });
    expect(res.status).toBe(200);
    expect(res.body.data.name).toBe('Test');
  });

  test('missing required field → 400 VALIDATION_ERROR', async () => {
    const res = await request(app).post('/test/validate').send({});
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  test('invalid type → 400 VALIDATION_ERROR', async () => {
    const res = await request(app).post('/test/validate').send({ name: 123 });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });

  test('unexpected privileged field on strict schema → 400 rejected', async () => {
    const res = await request(app).post('/test/validate').send({ name: 'Test', role: 'admin' });
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });
});


describe('ObjectId Validation', () => {

  test('valid ObjectId string → true', () => {
    expect(isValidObjectId('507f1f77bcf86cd799439011')).toBe(true);
  });

  test('malformed ObjectId → false', () => {
    expect(isValidObjectId('not-an-objectid')).toBe(false);
  });

  test('empty string → false', () => {
    expect(isValidObjectId('')).toBe(false);
  });

  test('null → false', () => {
    expect(isValidObjectId(null)).toBe(false);
  });
});


describe('Error Handler Security', () => {

  test('500 error does not expose stack trace', async () => {
    const errApp = express();
    errApp.use((req, res, next) => { req.requestId = 'err-req'; next(); });
    errApp.get('/crash', (req, res, next) => {
      next(new Error('Something broke with DB connection at mongodb+srv://secret'));
    });
    errApp.use(errorHandler);

    const res = await request(errApp).get('/crash');
    expect(res.status).toBe(500);
    expect(res.body.error.message).toBe('An unexpected error occurred');
    expect(JSON.stringify(res.body)).not.toContain('mongodb+srv');
    expect(JSON.stringify(res.body)).not.toContain('stack');
  });
});
