"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { auth } from "@/lib/firebase";
import { onAuthStateChanged, signOut, getIdToken } from "firebase/auth";

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [isInitializing, setIsInitializing] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        // User is signed in
        const token = await getIdToken(firebaseUser);
        
        // Store token in localStorage for any API clients that might need it synchronously
        localStorage.setItem("admin_auth_token", token);
        
        setIsAuthenticated(true);
        setUser({
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          name: firebaseUser.displayName || "Admin User",
          token: token
        });
      } else {
        // User is signed out
        localStorage.removeItem("admin_auth_token");
        setIsAuthenticated(false);
        setUser(null);
      }
      setIsInitializing(false);
    });

    return () => unsubscribe();
  }, []);

  const logout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error("Error signing out:", error);
    }
  };

  // The actual login logic is handled by the LoginPage calling signInWithEmailAndPassword.
  // We keep a dummy login function here for backwards compatibility if needed, 
  // but it shouldn't be used directly anymore.
  const login = () => {
    console.warn("login() should be replaced with signInWithEmailAndPassword in LoginPage");
  };

  // Prevent flash of incorrect state during initial client-side hydration
  if (isInitializing) {
    return null;
  }

  return (
    <AuthContext.Provider value={{ isAuthenticated, user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
