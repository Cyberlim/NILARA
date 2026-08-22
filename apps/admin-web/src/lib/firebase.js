import { initializeApp, getApps, getApp } from "firebase/app";
import { getAuth } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyAO-mha02w0KW71CeK-dui_LCvKN6JmMvc",
  appId: "1:460372603542:web:placeholder", // Fallback for web if needed
  messagingSenderId: "460372603542",
  projectId: "nilara-83b61",
  authDomain: "nilara-83b61.firebaseapp.com",
  storageBucket: "nilara-83b61.firebasestorage.app",
};

// Initialize Firebase only if it hasn't been initialized yet
const app = !getApps().length ? initializeApp(firebaseConfig) : getApp();
const auth = getAuth(app);

export { app, auth };
