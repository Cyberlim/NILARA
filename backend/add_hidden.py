import re

with open("src/models/Order.js", "r", encoding="utf-8") as f:
    content = f.read()

# I will add isHiddenByUser to the orderSchema right after deliveryTimePref
old_field = "  deliveryTimePref: { type: String, trim: true },"
new_field = "  deliveryTimePref: { type: String, trim: true },\n  isHiddenByUser: { type: Boolean, default: false },"
content = content.replace(old_field, new_field)

with open("src/models/Order.js", "w", encoding="utf-8") as f:
    f.write(content)
