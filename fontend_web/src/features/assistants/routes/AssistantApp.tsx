import React from 'react';
import { Outlet } from 'react-router-dom';
import Topbar from '@shared/components/Topbar';
import Sidebar from '@/shared/components/AssistantSidebar';
import ToastProvider from '@features/admin/components/ToastProvider';

export default function AssistantApp() {
  return (
    <ToastProvider>
      <div className="h-screen w-full bg-[#F5F7FB] text-slate-800">
        <Topbar />

        <div className="flex h-[calc(100%-80px)]">
          {/* Sidebar desktop */}
          <div className="hidden lg:block">
            <Sidebar />
          </div>

          {/* Nội dung */}
          <main className="flex-1 overflow-y-auto px-12 sm:px-16 py-8">
            <Outlet />
          </main>
        </div>
      </div>
    </ToastProvider>
  );
}
