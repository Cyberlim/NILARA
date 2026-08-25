"use client";

import React, { createContext, useContext, useState, useEffect } from "react";
import { useRouter } from "next/navigation";

const AuthContext = createContext();

export function AuthProvider({ children }) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [user, setUser] = useState(null);
  const [isInitializing, setIsInitializing] = useState(true);
  const router = useRouter();

  useEffect(() => {
    const token = localStorage.getItem("admin_auth_token");
    const userData = localStorage.getItem("admin_user_data");

    if (token && userData) {
      try {
        const parsedUser = JSON.parse(userData);
        setUser(parsedUser);
        setIsAuthenticated(true);
      } catch (e) {
        localStorage.removeItem("admin_auth_token");
        localStorage.removeItem("admin_user_data");
      }
    }
    
    setIsInitializing(false);
  }, []);

  const login = (userData, token) => {
    localStorage.setItem("admin_auth_token", token);
    localStorage.setItem("admin_user_data", JSON.stringify(userData));
    setUser(userData);
    setIsAuthenticated(true);
    router.push("/");
  };

  const logout = () => {
    localStorage.removeItem("admin_auth_token");
    localStorage.removeItem("admin_user_data");
    setIsAuthenticated(false);
    setUser(null);
    router.push("/login");
  };

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
