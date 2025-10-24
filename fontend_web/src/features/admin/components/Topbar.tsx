import React, { useEffect, useRef, useState } from 'react';
import { Bell, Key, LogOut, Menu } from 'lucide-react';
import { useAuth } from '@features/auth/useAuth';

type Props = {
  onOpenSidebar?: () => void;
};

export default function Topbar({ onOpenSidebar }: Props) {
  const { user, logout } = useAuth();
  const userName = user?.fullName ?? 'Họ và tên';
  const userEmail = user?.email ?? '';

  const [openMenu, setOpenMenu] = useState(false);
  const menuRef = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    const close = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        setOpenMenu(false);
      }
    };
    document.addEventListener('mousedown', close);
    return () => document.removeEventListener('mousedown', close);
  }, []);

  return (
    <header className="relative h-20 w-full bg-white border-b shadow-sm flex items-center justify-between px-4 sm:px-6 rounded-b-xl">
      {/* Left: menu button (mobile) + logo + school name */}
      <div className="flex items-center gap-3">
        <button
          onClick={onOpenSidebar}
          className="lg:hidden p-2 rounded-md hover:bg-slate-100"
          aria-label="Open sidebar"
        >
          <Menu size={20} />
        </button>

        <img src="/assets/logo_tlu.png" alt="TLU" className="h-12 w-12 object-contain" />
        <div className="hidden sm:block">
          <h1 className="text-lg font-semibold uppercase">Trường Đại học Thủy Lợi</h1>
          <p className="text-xs text-gray-500 uppercase">Khoa Công Nghệ Thông Tin</p>
        </div>
      </div>

      {/* Spacer */}
      <div className="flex-1" />

      {/* Right: notifications + user menu */}
      <div className="flex items-center gap-3 sm:gap-4">
        <div className="relative">
          <button className="p-2 rounded-md hover:bg-slate-100" aria-label="Thông báo">
            <Bell size={20} />
          </button>
          <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] rounded-full h-4 w-4 grid place-items-center">
            9
          </span>
        </div>

        <div className="relative" ref={menuRef}>
          <button
            onClick={() => setOpenMenu((s) => !s)}
            className="flex items-center gap-2 p-1.5 rounded-lg hover:bg-slate-100"
          >
            <img src="https://placehold.co/36x36" className="rounded-full h-9 w-9" alt="avatar" />
            <span className="hidden sm:inline text-sm font-medium">{userName}</span>
          </button>

          {openMenu && (
            <div className="absolute right-0 mt-2 w-60 bg-white rounded-xl shadow-md overflow-hidden z-50">
              <div className="p-4 border-b">
                <div className="flex items-center gap-3">
                  <img src="https://placehold.co/48x48" className="h-12 w-12 rounded-full" alt="avatar-lg" />
                  <div>
                    <div className="font-medium">{userName}</div>
                    {userEmail && <div className="text-xs text-slate-500">{userEmail}</div>}
                  </div>
                </div>
              </div>
              <div className="p-2">
                <button
                  className="w-full flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-slate-50 text-sm text-slate-700"
                  onClick={() => setOpenMenu(false)}
                >
                  <Key size={16} />
                  <span>Đổi mật khẩu</span>
                </button>
                <button
                  className="w-full mt-1 flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-slate-50 text-sm text-red-600"
                  onClick={() => {
                    setOpenMenu(false);
                    logout();
                  }}
                >
                  <LogOut size={16} />
                  <span>Đăng xuất</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
