import re

with open("C:/Users/kdev7/.gemini/antigravity-ide/brain/1ad22423-4c19-48b7-8302-03019ea44fbd/task.md", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("- `[ ]`", "- `[x]`")

with open("C:/Users/kdev7/.gemini/antigravity-ide/brain/1ad22423-4c19-48b7-8302-03019ea44fbd/task.md", "w", encoding="utf-8") as f:
    f.write(content)
