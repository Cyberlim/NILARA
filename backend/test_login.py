import requests

API_KEY = "AIzaSyAO-mha02w0KW71CeK-dui_LCvKN6JmMvc"
EMAIL = "sahil@gmail.com"
PASSWORD = "Sahil@"

url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={API_KEY}"
payload = {
    "email": EMAIL,
    "password": PASSWORD,
    "returnSecureToken": True
}

response = requests.post(url, json=payload)
data = response.json()

if "idToken" in data:
    print("Login successful! ID Token acquired.")
    id_token = data["idToken"]
    
    # Now call backend sync
    sync_url = "http://localhost:5000/api/v1/auth/sync"
    sync_res = requests.post(sync_url, headers={"Authorization": f"Bearer {id_token}"})
    print("Sync response:", sync_res.status_code, sync_res.text)
else:
    print("Login failed:", data)
