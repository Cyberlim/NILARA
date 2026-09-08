import re

with open("backend/src/models/User.js", "r", encoding="utf-8") as f:
    content = f.read()

old_schema = """  isActive: {
    type: Boolean,
    default: true
  },"""

new_schema = """  isActive: {
    type: Boolean,
    default: true
  },
  dob: {
    type: String,
    default: ""
  },
  address: {
    type: String,
    default: ""
  },
  emergencyContact: {
    type: String,
    default: ""
  },"""

content = content.replace(old_schema, new_schema)

with open("backend/src/models/User.js", "w", encoding="utf-8") as f:
    f.write(content)
