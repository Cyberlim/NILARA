const mongoose = require('mongoose');

const AUDIT_ACTIONS = [
  'USER_ROLE_CHANGE',
  'USER_SUSPEND',
  'USER_REACTIVATE',
  'ADMIN_PRODUCT_CREATE',
  'ADMIN_PRODUCT_UPDATE',
  'ADMIN_PRODUCT_ARCHIVE',
  'ADMIN_CATEGORY_CREATE',
  'ADMIN_CATEGORY_UPDATE',
  'ADMIN_CATEGORY_ARCHIVE',
  'ORDER_STATUS_CHANGE',
  'DELIVERY_PARTNER_ASSIGNED',
  'SECURITY_PERMISSION_CHANGE',
];

const auditLogSchema = new mongoose.Schema({
  actorUserId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  actorRole: {
    type: String,
    required: true
  },
  action: {
    type: String,
    enum: AUDIT_ACTIONS,
    required: true
  },
  resourceType: {
    type: String,
    required: true,
    trim: true
  },
  resourceId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true
  },
  requestId: {
    type: String,
    trim: true
  },
  previousState: {
    type: mongoose.Schema.Types.Mixed
  },
  newState: {
    type: mongoose.Schema.Types.Mixed
  },
  metadata: {
    type: mongoose.Schema.Types.Mixed
  }
}, {
  timestamps: true
});

auditLogSchema.index({ actorUserId: 1, createdAt: -1 });
auditLogSchema.index({ action: 1, createdAt: -1 });
auditLogSchema.index({ resourceType: 1, resourceId: 1 });

const AuditLog = mongoose.model('AuditLog', auditLogSchema);

/**
 * Record a security/business audit event.
 * Never log passwords, OTPs, Firebase tokens, Authorization headers,
 * refresh tokens, service credentials, or private keys.
 */
const recordAudit = async ({ actorUserId, actorRole, action, resourceType, resourceId, requestId, previousState, newState, metadata }) => {
  try {
    await AuditLog.create({
      actorUserId,
      actorRole,
      action,
      resourceType,
      resourceId,
      requestId,
      previousState,
      newState,
      metadata
    });
  } catch (err) {
    // Audit failures should never crash the application, but must be logged
    console.error(`[AUDIT_FAILURE] reqId: ${requestId} action: ${action} error: ${err.message}`);
  }
};

module.exports = { AuditLog, recordAudit, AUDIT_ACTIONS };
