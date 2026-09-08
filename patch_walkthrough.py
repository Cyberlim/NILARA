with open("C:/Users/kdev7/.gemini/antigravity-ide/brain/1ad22423-4c19-48b7-8302-03019ea44fbd/walkthrough.md", "r", encoding="utf-8") as f:
    content = f.read()

content = content.replace("Vehicle Type (Bike, Scooter, Cycle)\n     - Vehicle Number", "Vehicle Type (Bike, Scooter, Cycle)\n     - Vehicle Number (Input Field)\n     - Vehicle Front Image\n     - Vehicle Back Image")

with open("C:/Users/kdev7/.gemini/antigravity-ide/brain/1ad22423-4c19-48b7-8302-03019ea44fbd/walkthrough.md", "w", encoding="utf-8") as f:
    f.write(content)
