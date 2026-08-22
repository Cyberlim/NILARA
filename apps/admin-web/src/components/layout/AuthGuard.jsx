"use client";

import React, { useEffect, useState } from "react";
import { useAuth } from "@/context/AuthContext";
import { usePathname, useRouter } from "next/navigation";
import Sidebar from "@/components/layout/Sidebar";
import Topbar from "@/components/layout/Topbar";

export default function AuthGuard({ children }) {
  const { isAuthenticated } = useAuth();
  const pathname = usePathname();
  const router = useRouter();
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  const isLoginPage = pathname === "/login";

  useEffect(() => {
    if (mounted && !isAuthenticated && !isLoginPage) {
      router.push("/login");
    }
  }, [mounted, isAuthenticated, isLoginPage, router]);

  // Prevent hydration mismatch or early redirect flashes
  if (!mounted) return null;

  if (isLoginPage) {
    return <>{children}</>;
  }

  if (!isAuthenticated) {
    return null; // Will redirect via useEffect
  }

  return (
    <div className="flex w-full flex-1 h-screen overflow-hidden">
      <Sidebar />
      <div className="flex-1 flex flex-col overflow-y-auto overflow-x-hidden min-w-0">
        <Topbar />
        <main className="flex-1 p-6 pt-10 md:p-8 md:pt-12">
          {children}
        </main>
      </div>
    </div>
  );
}
