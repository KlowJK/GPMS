// src/features/admin/routes/AdminApp.tsx
import React, { useState } from 'react';
import { Outlet } from 'react-router-dom';
import Topbar from '@features/admin/components/Topbar';
import AdminSidebar from '@features/admin/components/Sidebar';
import { ToastProvider } from '@features/admin/components/ToastProvider';

export default function AdminApp() {
  const [showSidebar, setShowSidebar] = useState(false);

  return (
    <ToastProvider>
    <div className="h-screen w-full bg-[#F5F7FB] text-slate-800">
      <Topbar onOpenSidebar={() => setShowSidebar(true)} />

      <div className="flex h-[calc(100%-80px)]"> {/* 80px ~ h-20 */}
        {/* Desktop */}
        <div className="hidden lg:block">
          <AdminSidebar />
        </div>

        {/* Mobile overlay */}
        {showSidebar && (
          <AdminSidebar overlay onClose={() => setShowSidebar(false)} />
        )}

        <main className="flex-1 overflow-y-auto px-12 sm:px-16 py-8">
          <Outlet />
        </main>
      </div>
    </div>
    </ToastProvider>
  );
}
