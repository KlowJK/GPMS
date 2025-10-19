import React, { useEffect, useState } from 'react'
import { NavLink, useLocation } from 'react-router-dom'
import { Home, FileText, CalendarCheck, ClipboardCheck, Building } from 'lucide-react'

export default function Sidebar({ onClose, overlay = false }: { onClose: () => void; overlay?: boolean }) {
  const location = useLocation()
  const [selected, setSelected] = useState<string | null>(() => window.location.pathname || null)

  useEffect(() => {
    setSelected(location.pathname)
  }, [location.pathname])

  const items = [
    { to: '/lecturers', icon: Home, label: 'Trang chủ' },
    { to: '/lecturers/do-an', icon: FileText, label: 'Đồ án' },
    { to: '/lecturers/nhat-ky', icon: CalendarCheck, label: 'Nhật ký tiến độ' },
    { to: '/lecturers/bao-cao', icon: ClipboardCheck, label: 'Báo cáo' },
    { to: '/lecturers/hoi-dong', icon: Building, label: 'Hội đồng' },
  ]

  const body = (
    <aside className="h-full w-[259px] bg-[#2F7CD3] text-white flex flex-col shadow-md rounded-br-xl relative px-5 py-6">
      <div className="mb-4">
        <NavLink to="/lecturers" end onClick={() => { if (overlay) onClose(); setSelected('/lecturers') }} className="block w-[219px]">
          {() => {
            const isSelected = selected === '/lecturers'
            return (
              <div className={`${isSelected ? 'bg-white rounded-[12px]' : ''}`}>
                <div className={`flex items-center gap-3 px-4 py-3 ${isSelected ? 'text-slate-800' : 'text-white/90'}`}>
                  <span className="text-sm font-medium">Trang chủ</span>
                </div>
              </div>
            )
          }}
        </NavLink>
      </div>

      <nav className="space-y-2">
        {items.slice(1).map(({ to, icon: Icon, label }) => {
          if (to === '/lecturers/do-an') {
            return <DoAnItem key={to} to={to} Icon={Icon} overlay={overlay} onClose={onClose} />
          }

          return (
            <NavLink key={to} to={to} end={to === '/lecturers'} onClick={() => { if (overlay) onClose(); setSelected(to) }} className="block w-[219px]">
              {() => {
                const isSelected = selected === to
                return (
                  <div className={`${isSelected ? 'bg-white rounded-[12px]' : ''}`}>
                    <div className={`flex items-center gap-3 px-4 py-3 ${isSelected ? 'text-slate-800' : 'text-white/80'} cursor-pointer`}>
                      <Icon size={18} />
                      <span className="text-sm font-medium">{label}</span>
                      <div className="ml-auto" />
                      {isSelected ? (
                        <div className="ml-3 w-4 h-4 rounded-sm bg-slate-200" />
                      ) : (
                        <div className="ml-3 w-4 h-4" />
                      )}
                    </div>
                  </div>
                )
              }}
            </NavLink>
          )
        })}
      </nav>
    </aside>
  )

  function DoAnItem({ to, Icon, overlay, onClose }: { to: string; Icon: any; overlay: boolean; onClose: () => void }) {
    const location = useLocation()
    const [open, setOpen] = useState(() => location.pathname.startsWith('/lecturers/do-an'))

    useEffect(() => setOpen(location.pathname.startsWith('/lecturers/do-an')), [location.pathname])

    return (
      <div className="w-[219px]">
        <div className="flex items-center gap-3 px-4 py-3 text-white/80 cursor-pointer" onClick={() => setOpen(s => !s)}>
          <Icon size={18} />
          <span className="text-sm font-medium">Đồ án</span>
          <div className="ml-auto text-xs">{open ? '▾' : '▸'}</div>
        </div>

        {open && (
          <div className="mt-2 space-y-2 pl-8">
            {(() => {
              const path1 = '/lecturers/do-an/list'
              const path2 = '/lecturers/do-an/duyet'
              const sel1 = selected === path1
              const sel2 = selected === path2
              return (
                <>
                  <NavLink to={path1} className={`block text-sm ${sel1 ? 'bg-white text-slate-800 rounded-[8px] px-3 py-2' : 'text-white/90'}`} onClick={() => { if (overlay) onClose(); setSelected(path1) }}>
                    Danh sách sinh viên hướng dẫn
                  </NavLink>
                  <NavLink to={path2} className={`block text-sm ${sel2 ? 'bg-white text-slate-800 rounded-[8px] px-3 py-2' : 'text-white/90'}`} onClick={() => { if (overlay) onClose(); setSelected(path2) }}>
                    Duyệt đề tài
                  </NavLink>
                </>
              )
            })()}
          </div>
        )}
      </div>
    )
  }

  if (!overlay) return body

  return (
    <div className="fixed inset-0 z-40 lg:hidden" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="absolute inset-y-0 left-0">{body}</div>
    </div>
  )
}
