with open("src/controllers/authController.js", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("res.status(200).json({", "console.log('Sending syncUser response for:', user.email, 'Role:', user.role);\n      res.status(200).json({")

with open("src/controllers/authController.js", "w", encoding="utf-8") as f:
    f.write(content)
