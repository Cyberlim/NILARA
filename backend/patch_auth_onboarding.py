with open("src/controllers/authController.js", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace(
"""        data: {
          id: user._id,
          email: user.email,
          displayName: user.displayName,
          role: user.role
        }""",
"""        data: {
          id: user._id,
          email: user.email,
          displayName: user.displayName,
          role: user.role,
          onboardingComplete: user.onboardingComplete || false
        }"""
)

with open("src/controllers/authController.js", "w", encoding="utf-8") as f:
    f.write(content)
