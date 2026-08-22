import { Outfit } from "next/font/google";
import "./globals.css";
import { SidebarProvider } from "@/context/SidebarContext";
import { AuthProvider } from "@/context/AuthContext";
import AuthGuard from "@/components/layout/AuthGuard";

const outfit = Outfit({
  variable: "--font-outfit",
  subsets: ["latin"],
});

export const metadata = {
  title: "Nilara Admin Panel",
  description: "Admin panel for Nilara ecosystem",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={`${outfit.variable} h-full antialiased`} suppressHydrationWarning>
      <body className="min-h-full flex bg-slate-50/50 font-sans text-slate-800 relative overflow-x-hidden">
        <AuthProvider>
          <SidebarProvider>
            <div className="fixed inset-0 bg-[radial-gradient(ellipse_at_top_right,_var(--tw-gradient-stops))] from-teal-200/50 via-cyan-100/20 to-transparent -z-10 pointer-events-none" />
            <div className="fixed inset-0 bg-[radial-gradient(ellipse_at_bottom_left,_var(--tw-gradient-stops))] from-blue-200/50 via-purple-100/20 to-transparent -z-10 pointer-events-none" />
            
            <AuthGuard>
              {children}
            </AuthGuard>
            
          </SidebarProvider>
        </AuthProvider>
      </body>
    </html>
  );
}
