const { z } = require('zod');

const updateProfileSchema = z.object({
  displayName: z.string().trim().min(1).max(100).optional(),
  phone: z.string().trim().min(5).max(20).optional(),
}).strict();

const createDeliveryPartnerSchema = z.object({
  name: z.string().trim().min(2, "Name must be at least 2 characters").max(100),
  email: z.string().email("Invalid email format"),
  phone: z.string().trim().min(5, "Phone must be at least 5 characters").max(20),
  password: z.string().min(6, "Password must be at least 6 characters"),
  assignedStore: z.string().trim().optional(),
  assignedHub: z.string().trim().optional(),
  darkStore: z.string().trim().optional()
});

const updatePreferencesSchema = z.object({
  navigationApp: z.string().trim().optional(),
  autoCenterMap: z.boolean().optional(),
  voiceRoutePrompts: z.boolean().optional(),
  highContrastMap: z.boolean().optional(),
  offlineMapCaching: z.boolean().optional(),
  language: z.string().trim().optional(),
  alertTone: z.string().trim().optional(),
  soundVolume: z.number().min(0).max(100).optional(),
  vibrateOnAlert: z.boolean().optional(),
}).strict();

module.exports = { updateProfileSchema, createDeliveryPartnerSchema, updatePreferencesSchema };
