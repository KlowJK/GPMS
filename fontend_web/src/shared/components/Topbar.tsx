// src/shared/components/Topbar.tsx
  import React, { useEffect, useRef, useState } from 'react';
  import { Bell, Key, LogOut, Menu, User } from 'lucide-react';
  import { useNavigate } from 'react-router-dom';
  import { useAuth } from '@features/auth/useAuth';
  import logoImg from '@assets/logo_tlu.png'

  type Props = {
    onOpenSidebar?: () => void;
  };

  export default function Topbar({ onOpenSidebar }: Props) {
    const { user, logout } = useAuth();
    const userName = user?.fullName ?? 'Quản trị viên';
    const userEmail = user?.email ?? '';
    const userAvatar = user?.duongDanAvt ?? 'https://placehold.co/36x36';

    const [openMenu, setOpenMenu] = useState(false);
    const menuRef = useRef<HTMLDivElement | null>(null);
    const navigate = useNavigate();

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

            <img src={logoImg} alt="TLU" className="h-12 w-12 object-contain" />
            <div className="hidden sm:block">
              <h2 className="text-lg font-semibold uppercase">Trường Đại học Thủy Lợi</h2>
              <p className="text-xs text-gray-500 uppercase">THUY LOI UNIVERSITY</p>
            </div>
          </div>

          {/* Spacer */}
          <div className="flex-1" />

          {/* Right: notifications + user menu */}
          <div className="flex items-center gap-3 sm:gap-4">


            <div className="relative" ref={menuRef}>
              <button
                  onClick={() => setOpenMenu((s) => !s)}
                  className="flex items-center gap-2 p-1.5 rounded-lg hover:bg-slate-100"
              >
                <img src={userAvatar} className="rounded-full h-9 w-9" alt="avatar" />
                <span className="hidden sm:inline text-sm font-medium">{userName}</span>
              </button>

              {openMenu && (
                  <div className="absolute right-0 mt-2 w-60 bg-white rounded-xl shadow-md overflow-hidden z-50">
                    <div className="p-4 border-b">
                      <div className="flex items-center gap-3">
                        <img src={userAvatar} className="h-12 w-12 rounded-full" alt="avatar-lg" />
                        <div>
                          <div className="font-medium">{userName}</div>
                          {userEmail && <div className="text-xs text-slate-500">{userEmail}</div>}
                        </div>
                      </div>
                    </div>
                    <div className="p-2">
                      <button
                          className="w-full flex items-center gap-3 px-3 py-2 rounded-lg hover:bg-slate-50 text-sm text-slate-700"
                          onClick={() => {
                            setOpenMenu(false);
                            navigate('/profile');
                          }}
                      >
                        <User size={16} />
                        <span>Hồ sơ</span>
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