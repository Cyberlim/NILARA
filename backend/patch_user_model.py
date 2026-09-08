with open("src/models/User.js", "r", encoding="utf-8") as f:
    content = f.read()

onboarding_fields = """  onboardingComplete: {
    type: Boolean,
    default: false
  },
  deliveryDetails: {
    aadharNumber: { type: String },
    aadharImage: { type: String },
    drivingLicenseNumber: { type: String },
    drivingLicenseImage: { type: String },
    vehicleType: { type: String },
    vehicleNumber: { type: String }
  },"""

content = content.replace("  fcmTokens: [{", onboarding_fields + "\n  fcmTokens: [{")

with open("src/models/User.js", "w", encoding="utf-8") as f:
    f.write(content)
