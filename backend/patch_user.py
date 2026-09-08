import re

with open("src/models/User.js", "r", encoding="utf-8") as f:
    content = f.read()

new_wallet = """  onboardingComplete: {
    type: Boolean,
    default: false
  },
  walletBalance: {
    type: Number,
    default: 0,
    min: 0
  },"""

content = content.replace("  onboardingComplete: {\n    type: Boolean,\n    default: false\n  },", new_wallet)

with open("src/models/User.js", "w", encoding="utf-8") as f:
    f.write(content)
