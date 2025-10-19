import React, { useRef, useEffect, useState } from 'react'
import { Bell, Key, LogOut } from 'lucide-react'
import avatarImg from '@assets/react.svg'
import logoImg from '@assets/logo_tlu.png'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '@features/auth/useAuth'

export default function Topbar() {
  const [menuOpen, setMenuOpen] = useState(false)
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false)
  const ref = useRef<HTMLDivElement | null>(null)
  const navigate = useNavigate()
  const { user, logout } = useAuth()

  useEffect(() => {
    function onDoc(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setMenuOpen(false)
    }
    document.addEventListener('mousedown', onDoc)
    return () => document.removeEventListener('mousedown', onDoc)
  }, [])

  function doLogout() {
    logout()
  }

  return (
    <>
      <header className="relative h-20 bg-white border-b shadow-sm flex items-center justify-between px-4 sm:px-6 rounded-b-md">
        <div className="flex items-center gap-3">
          <img src={logoImg} alt="TLU" className="h-14 w-14 object-contain ml-2" />
        </div>

        <div className="flex-1 flex items-center justify-left pointer-events-none">
          <div className="pointer-events-auto text-center">
            <div className="font-medium text-[18px] uppercase">Trường đại học thủy lợi</div>
            <div className="text-xs uppercase text-slate-500">Khoa công nghệ thông tin</div>
          </div>
        </div>

        <div className="relative flex items-center gap-4">
          <div className="relative">
            <button className="p-2 rounded-md hover:bg-slate-100" aria-label="Thông báo">
              <Bell size={20} />
            </button>
            <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] rounded-full h-4 w-4 grid place-items-center">9</span>
          </div>

          <div className="relative" ref={ref}>
            <button onClick={() => setMenuOpen(s => !s)} className="flex items-center gap-3 p-2 rounded hover:bg-slate-100">
              <img src={avatarImg} alt="avatar" className="h-9 w-9 rounded-full object-cover" />
              <span className="text-sm font-medium">{user?.fullName ?? 'Họ và tên'}</span>
            </button>

            {menuOpen && (
              <div className="absolute right-0 mt-2 w-56 bg-white shadow rounded-md z-50">
                <div className="p-4 border-b">
                  <div className="flex items-center gap-3">
                    <img src={avatarImg} alt="avatar-lg" className="h-16 w-16 rounded-full object-cover" />
                    <div>
                      <div className="font-medium">{user?.fullName ?? 'Họ và tên'}</div>
                      <div className="text-xs text-slate-500">{user?.email ?? ''}</div>
                    </div>
                  </div>
                </div>
                <div className="p-2">
                  <button className="w-full flex items-center gap-3 px-3 py-2 rounded hover:bg-slate-50 text-sm text-slate-700" onClick={() => { navigate('/profile'); setMenuOpen(false) }}>
                    <Key size={16} />
                    <span>Đổi Mật Khẩu</span>
                  </button>
                  <button className="w-full mt-1 flex items-center gap-3 px-3 py-2 rounded hover:bg-slate-50 text-sm text-red-600" onClick={() => { setShowLogoutConfirm(true); setMenuOpen(false) }}>
                    <LogOut size={16} />
                    <span>Đăng Xuất</span>
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </header>

      {showLogoutConfirm && (
        <div className="fixed inset-0 z-[9999] grid place-items-center bg-black/40">
          <div className="relative z-[10000] bg-white rounded-md shadow-lg w-[420px] p-6 transform -translate-y-6 translate-x-6">
            <div className="text-lg font-semibold mb-2">Xác nhận đăng xuất</div>
            <div className="text-sm text-slate-600 mb-4">Bạn có chắc chắn muốn đăng xuất khỏi hệ thống không?</div>
            <div className="flex justify-end gap-3">
              <button className="px-4 py-2 border rounded" onClick={() => setShowLogoutConfirm(false)}>Hủy</button>
              <button className="px-4 py-2 bg-red-600 text-white rounded" onClick={() => { setShowLogoutConfirm(false); doLogout(); }}>Đăng xuất</button>
            </div>
          </div>
        </div>
      )}
    </>
  )
}
