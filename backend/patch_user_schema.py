import re

with open("src/models/User.js", "r", encoding="utf-8") as f:
    content = f.read()

# Add vehicleFrontImage and vehicleBackImage to deliveryDetails
old_details = """  deliveryDetails: {
    aadharNumber: { type: String },
    aadharImage: { type: String },
    drivingLicenseNumber: { type: String },
    drivingLicenseImage: { type: String },
    vehicleType: { type: String },
    vehicleNumber: { type: String }
  },"""

new_details = """  deliveryDetails: {
    aadharNumber: { type: String },
    aadharImage: { type: String },
    drivingLicenseNumber: { type: String },
    drivingLicenseImage: { type: String },
    vehicleType: { type: String },
    vehicleNumber: { type: String },
    vehicleFrontImage: { type: String },
    vehicleBackImage: { type: String }
  },"""

content = content.replace(old_details, new_details)

with open("src/models/User.js", "w", encoding="utf-8") as f:
    f.write(content)
