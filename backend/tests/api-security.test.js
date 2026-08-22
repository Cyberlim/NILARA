// ── Mock firebase-admin ──────────────────────────────────────────────
jest.mock('firebase-admin', () => ({
  auth: () => ({
    verifyIdToken: jest.fn().mockImplementation((token) => {
      if (token === 'valid_customer_a') return Promise.resolve({ uid: 'fb_cust_a', email: 'a@test.com' });
      if (token === 'valid_customer_b') return Promise.resolve({ uid: 'fb_cust_b', email: 'b@test.com' });
      if (token === 'valid_admin') return Promise.resolve({ uid: 'fb_admin', email: 'admin@test.com' });
      return Promise.reject(new Error('Firebase: Invalid token'));
    })
  }),
  credential: { cert: jest.fn() },
  initializeApp: jest.fn()
}));

// ── Mock Mongoose Models ─────────────────────────────────────────────
jest.mock('../src/models/User', () => ({
  findOne: jest.fn(({ firebaseUid }) => {
    if (firebaseUid === 'fb_cust_a') return Promise.resolve({ _id: { toString: () => 'mongo_cust_a' }, firebaseUid, role: 'customer', isActive: true });
    if (firebaseUid === 'fb_cust_b') return Promise.resolve({ _id: { toString: () => 'mongo_cust_b' }, firebaseUid, role: 'customer', isActive: true });
    if (firebaseUid === 'fb_admin') return Promise.resolve({ _id: { toString: () => 'mongo_admin' }, firebaseUid, role: 'admin', isActive: true });
    return Promise.resolve(null);
  }),
  findById: jest.fn(),
  findByIdAndUpdate: jest.fn()
}));

jest.mock('../src/models/Address', () => {
  const mockAddressData = {
    '64a2b9f3e4b0a1c2d3e4f5a1': { _id: { toString: () => '64a2b9f3e4b0a1c2d3e4f5a1' }, user: 'mongo_cust_a', city: 'A' },
    '64a2b9f3e4b0a1c2d3e4f5a2': { _id: { toString: () => '64a2b9f3e4b0a1c2d3e4f5a2' }, user: 'mongo_cust_b', city: 'B' }
  };
  return {
    findOne: jest.fn(),
    find: jest.fn(() => ({ sort: jest.fn().mockResolvedValue(Object.values(mockAddressData)) })),
    findOneAndUpdate: jest.fn((query) => {
      // Simulate IDOR protection
      const addr = mockAddressData[query._id];
      if (addr && addr.user === query.user) return Promise.resolve(addr);
      return Promise.resolve(null);
    }),
    findOneAndDelete: jest.fn((query) => {
      const addr = mockAddressData[query._id];
      if (addr && addr.user === query.user) return Promise.resolve(addr);
      return Promise.resolve(null);
    }),
    create: jest.fn(),
    updateMany: jest.fn().mockResolvedValue({})
  };
});

jest.mock('../src/models/Category', () => ({
  find: jest.fn(() => ({ sort: jest.fn(() => ({ select: jest.fn().mockResolvedValue([]) })) })),
  findOne: jest.fn(() => ({ select: jest.fn(() => ({ lean: jest.fn().mockResolvedValue(null) })) })),
  findByIdAndUpdate: jest.fn(),
  create: jest.fn()
}));

jest.mock('../src/models/Product', () => ({
  find: jest.fn(() => ({ populate: jest.fn(() => ({ sort: jest.fn(() => ({ skip: jest.fn(() => ({ limit: jest.fn(() => ({ select: jest.fn().mockResolvedValue([]) })) })) })) })) })),
  countDocuments: jest.fn().mockResolvedValue(0),
  findOne: jest.fn(),
  findByIdAndUpdate: jest.fn(),
  create: jest.fn()
}));

jest.mock('../src/models/AuditLog', () => ({
  recordAudit: jest.fn().mockResolvedValue()
}));

const request = require('supertest');
const app = require('../src/server'); // We need to export app from server.js

// ═══════════════════════════════════════════════════════════════════════
// API SECURITY TESTS
// ═══════════════════════════════════════════════════════════════════════

describe('Address API IDOR Protection', () => {

  test('Customer A cannot update Customer B address', async () => {
    const res = await request(app)
      .patch('/api/v1/addresses/64a2b9f3e4b0a1c2d3e4f5a2')
      .set('Authorization', 'Bearer valid_customer_a')
      .send({ city: 'Hacked City' });
      
    // Should return 404 because the ownership query yields nothing
    expect(res.status).toBe(404);
  });

  test('Customer A can update own address', async () => {
    const res = await request(app)
      .patch('/api/v1/addresses/64a2b9f3e4b0a1c2d3e4f5a1')
      .set('Authorization', 'Bearer valid_customer_a')
      .send({ city: 'New City' });
      
    expect(res.status).toBe(200);
  });

  test('Customer A cannot delete Customer B address', async () => {
    const res = await request(app)
      .delete('/api/v1/addresses/64a2b9f3e4b0a1c2d3e4f5a2')
      .set('Authorization', 'Bearer valid_customer_a');
      
    expect(res.status).toBe(404);
  });
});

describe('Category & Product API RBAC', () => {

  test('Public can read categories', async () => {
    const res = await request(app).get('/api/v1/categories');
    expect(res.status).toBe(200);
  });

  test('Public can read products', async () => {
    const res = await request(app).get('/api/v1/products');
    expect(res.status).toBe(200);
  });

  test('Customer cannot create category (403)', async () => {
    const res = await request(app)
      .post('/api/v1/categories')
      .set('Authorization', 'Bearer valid_customer_a')
      .send({ name: 'Test', imageUrl: 'http://test.com/img.jpg' });
    expect(res.status).toBe(403);
  });

  test('Admin can create category (201)', async () => {
    // Mock generateUniqueSlug which requires db hit
    require('../src/models/Category').findOne.mockReturnValueOnce({ select: jest.fn(() => ({ lean: jest.fn().mockResolvedValue(null) })) });
    require('../src/models/Category').create.mockResolvedValueOnce({ _id: '64a2b9f3e4b0a1c2d3e4f5a3', name: 'Test', slug: 'test' });
    
    const res = await request(app)
      .post('/api/v1/categories')
      .set('Authorization', 'Bearer valid_admin')
      .send({ name: 'Test', imageUrl: 'http://test.com/img.jpg' });
    expect(res.status).toBe(201);
  });

  test('Customer cannot update product (403)', async () => {
    const res = await request(app)
      .patch('/api/v1/products/64a2b9f3e4b0a1c2d3e4f5a4')
      .set('Authorization', 'Bearer valid_customer_a')
      .send({ name: 'Hacked' });
    expect(res.status).toBe(403);
  });
});

describe('Profile Mass Assignment', () => {
  
  test('Customer patching role is rejected by Zod', async () => {
    const res = await request(app)
      .patch('/api/v1/users/me')
      .set('Authorization', 'Bearer valid_customer_a')
      .send({ displayName: 'Test', role: 'admin' });
      
    expect(res.status).toBe(400);
    expect(res.body.error.code).toBe('VALIDATION_ERROR');
  });
});
