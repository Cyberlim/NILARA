with open("C:/Users/kdev7/.gemini/antigravity-ide/brain/1ad22423-4c19-48b7-8302-03019ea44fbd/walkthrough.md", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("     - Vehicle Type (Bike, Scooter, Cycle)", "     - Profile Photo (Delivery Man's Photo)\n     - Vehicle Type (Bike, Scooter, Cycle)")

with open("C:/Users/kdev7/.gemini/antigravity-ide/brain/1ad22423-4c19-48b7-8302-03019ea44fbd/walkthrough.md", "w", encoding="utf-8") as f:
    f.write(content)
