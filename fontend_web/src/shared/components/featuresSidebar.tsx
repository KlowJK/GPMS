import React, { useEffect, useState } from 'react'
import { NavLink, useLocation } from 'react-router-dom'
import { useAuth } from '@shared/hooks/useAuth'
import { Home, FileText, CalendarCheck, ClipboardCheck, Building, MessageSquare } from 'lucide-react'

export default function Sidebar({ onClose, overlay = false }: { onClose: () => void; overlay?: boolean }) {
  const location = useLocation()
  const [selected, setSelected] = useState<string | null>(() => window.location.pathname || null)

  useEffect(() => {
    setSelected(location.pathname)
  }, [location.pathname])

  const baseItems = [
    { to: '/lecturers', icon: Home, label: 'Trang chủ' },
    { to: '/lecturers/do-an', icon: FileText, label: 'Đồ án' },
    { to: '/lecturers/nhat-ky', icon: CalendarCheck, label: 'Nhật ký tiến độ' },
    { to: '/lecturers/bao-cao', icon: ClipboardCheck, label: 'Báo cáo' },
    { to: '/lecturers/phan-bien', icon: MessageSquare, label: 'Phản biện' },
    { to: '/lecturers/hoi-dong', icon: Building, label: 'Hội đồng' },
  ]
  const items = baseItems

  const { roles } = useAuth()
  const isHead = Array.isArray(roles) && roles.includes('TRUONG_BO_MON')

  const body = (
    <aside className="h-full w-[259px] bg-[#2F7CD3] text-white flex flex-col shadow-md rounded-br-xl relative px-5 py-6">
      <div className="mb-4">
        <NavLink to="/lecturers" end onClick={() => { if (overlay) onClose(); setSelected('/lecturers') }} className="block w-[219px]">
          {() => {
            const isSelected = selected === '/lecturers'
            return (
              <div className={`${isSelected ? 'bg-white rounded-[12px]' : ''}`}>
                <div className={`flex items-center gap-3 px-4 py-3 ${isSelected ? 'text-slate-800' : 'text-white/90'}`}>
                  <Home size={18} />
                  <span className="text-sm font-medium">Trang chủ</span>
                  <div className="ml-auto" />
                  {/* removed right-side decorative indicator */}
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
                      {/* removed right-side decorative indicator */}
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
  // Keep Đồ án submenu open when route is under '/lecturers/do-an' or
  // when user navigates to TBM-specific routes under '/lecturers/truong-bo-mon'.
  const isDoAnPath = (p: string) => p.startsWith('/lecturers/do-an') || p.startsWith('/lecturers/truong-bo-mon')
  const [open, setOpen] = useState(() => isDoAnPath(location.pathname))

  useEffect(() => setOpen(isDoAnPath(location.pathname)), [location.pathname])

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
              const path3 = '/lecturers/truong-bo-mon/duyet-de-cuong-cuoi'
              const path4 = '/lecturers/truong-bo-mon/phan-cong-giang-vien'
              const path5 = '/lecturers/truong-bo-mon/danh-sach-giang-vien'
              // also treat the reviewer assignment route as the same TBM "Phân công giảng viên" item
              const path4Reviewer = '/lecturers/truong-bo-mon/phan-cong-phan-bien'
              const sel1 = selected === path1
              const sel2 = selected === path2
              const sel3 = selected === path3
              const sel4 = selected === path4 || selected === path4Reviewer
              const sel5 = selected === path5
              return (
                <>
                  <NavLink to={path1} className={`block text-sm ${sel1 ? 'bg-white text-slate-800 rounded-[8px] px-3 py-2' : 'text-white/90'}`} onClick={() => { if (overlay) onClose(); setSelected(path1) }}>
                    Danh sách sinh viên hướng dẫn
                  </NavLink>
                  <NavLink to={path2} className={`block text-sm ${sel2 ? 'bg-white text-slate-800 rounded-[8px] px-3 py-2' : 'text-white/90'}`} onClick={() => { if (overlay) onClose(); setSelected(path2) }}>
                    Duyệt Đăng ký đề tài
                  </NavLink>
                  {isHead && (
                    <>
                      <NavLink to={path3} className={`block text-sm ${sel3 ? 'bg-white text-slate-800 rounded-[8px] px-3 py-2' : 'text-white/90'}`} onClick={() => { if (overlay) onClose(); setSelected(path3) }}>
                        Duyệt đề cương cuối (TBM)
                      </NavLink>
                      <NavLink to={path4} className={`block text-sm ${sel4 ? 'bg-white text-slate-800 rounded-[8px] px-3 py-2' : 'text-white/90'}`} onClick={() => { if (overlay) onClose(); setSelected(path4) }}>
                        Phân công giảng viên (TBM) 
                      </NavLink>
                      <NavLink to={path5} className={`block text-sm ${sel5 ? 'bg-white text-slate-800 rounded-[8px] px-3 py-2' : 'text-white/90'}`} onClick={() => { if (overlay) onClose(); setSelected(path5) }}>
                        Danh sách giảng viên (TBM)
                      </NavLink>
                    </>
                  )}
                </>
              )
            })()}
          </div>
        )}
      </div>
    )
  }

  // Note: Trưởng bộ môn section removed; TBM tasks (duyet-de-cuong-cuoi, phan-cong-giang-vien)
  // are moved into the Đồ án submenu inside DoAnItem.

  if (!overlay) return body

  return (
    <div className="fixed inset-0 z-40 lg:hidden" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="absolute inset-y-0 left-0">{body}</div>
    </div>
  )
}
