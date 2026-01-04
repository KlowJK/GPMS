import React, { useEffect, useState } from 'react'
import { NavLink, useLocation } from 'react-router-dom'
import { Home, FileText, UserCheck } from 'lucide-react'

export default function StudentSidebar({ onClose, overlay = false }: { onClose: () => void; overlay?: boolean }) {
  const location = useLocation()
  const [selected, setSelected] = useState<string | null>(() => window.location.pathname || null)

  useEffect(() => {
    setSelected(location.pathname)
  }, [location.pathname])

  return (
    <aside className="h-full w-[259px] bg-[#1F2937] text-white flex flex-col shadow-md rounded-br-xl relative px-5 py-6">
      <div className="mb-4">
        <NavLink to="/students" end onClick={() => { if (overlay) onClose(); setSelected('/students') }} className="block w-[219px]">
          {() => {
            const isSelected = selected === '/students'
            return (
              <div className={`${isSelected ? 'bg-white rounded-[12px]' : ''}`}>
                <div className={`flex items-center gap-3 px-4 py-3 ${isSelected ? 'text-slate-800' : 'text-white/90'}`}>
                  <span className="text-sm font-medium">Trang sinh viên</span>
                </div>
              </div>
            )
          }}
        </NavLink>
      </div>

      <nav className="space-y-2">
        <NavLink to="/students/proposals" className={`block w-[219px]`} onClick={() => { if (overlay) onClose(); setSelected('/students/proposals') }}>
          {() => {
            const isSelected = selected === '/students/proposals'
            return (
              <div className={`${isSelected ? 'bg-white rounded-[12px]' : ''}`}>
                <div className={`flex items-center gap-3 px-4 py-3 ${isSelected ? 'text-slate-800' : 'text-white/80'} cursor-pointer`}>
                  <FileText size={18} />
                  <span className="text-sm font-medium">Đề tài</span>
                </div>
              </div>
            )
          }}
        </NavLink>

        <NavLink to="/students/profile" className={`block w-[219px]`} onClick={() => { if (overlay) onClose(); setSelected('/students/profile') }}>
          {() => {
            const isSelected = selected === '/students/profile'
            return (
              <div className={`${isSelected ? 'bg-white rounded-[12px]' : ''}`}>
                <div className={`flex items-center gap-3 px-4 py-3 ${isSelected ? 'text-slate-800' : 'text-white/80'} cursor-pointer`}>
                  <UserCheck size={18} />
                  <span className="text-sm font-medium">Hồ sơ</span>
                </div>
              </div>
            )
          }}
        </NavLink>
      </nav>
    </aside>
  )
}
