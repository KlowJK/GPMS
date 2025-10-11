import { useState, useRef, useEffect } from "react";
import { Outlet, NavLink, useLocation } from "react-router-dom";
import { Bell, Menu, Home, FileText, CalendarCheck, ClipboardCheck, Building, LogOut, Key } from "lucide-react";
import logoImg from '@assets/logo_tlu.png';
import avatarImg from '@assets/react.svg';


function Topbar({ onOpenSidebar }: { onOpenSidebar: () => void }) {
  const [menuOpen, setMenuOpen] = useState(false);
  const ref = useRef<HTMLDivElement | null>(null);

  useEffect(() => {
    function onDoc(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setMenuOpen(false);
    }
    document.addEventListener("mousedown", onDoc);
    return () => document.removeEventListener("mousedown", onDoc);
  }, []);

  return (
    <header className="relative h-20 bg-white border-b shadow-sm flex items-center justify-between px-4 sm:px-6 rounded-b-md">
      {/* left: logo */}
      <div className="flex items-center gap-3">
        <button
          className="lg:hidden p-2 rounded-md hover:bg-slate-100"
          aria-label="Mở sidebar"
          onClick={onOpenSidebar}
        >
          <Menu size={22} />
        </button>
        <img src={logoImg} alt="TLU" className="h-14 w-14 object-contain ml-2" />
      </div>

      {/* center: title */}
      <div className="flex-1 flex items-center justify-left pointer-events-none">
        <div className="pointer-events-auto text-center">
          <div className="font-medium text-[18px] uppercase">Trường đại học thủy lợi</div>
          <div className="text-xs uppercase text-slate-500">Khoa công nghệ thông tin</div>
        </div>
      </div>

      {/* right: notifications + avatar */}
      <div className="relative flex items-center gap-4">
        <div className="relative">
          <button className="p-2 rounded-md hover:bg-slate-100" aria-label="Thông báo">
            <Bell size={20} />
          </button>
          <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] rounded-full h-4 w-4 grid place-items-center">9</span>
        </div>

        <div className="relative flex items-center gap-3" ref={ref}>
          <img src={avatarImg} alt="avatar" className="h-14 w-14 rounded-sm object-cover" />
          <div className="flex flex-col">
            <span className="text-sm font-medium">Họ và tên</span>
          </div>

          {menuOpen && (
            <div className="absolute right-0 mt-2 w-48 bg-white shadow rounded-md z-50">
              <div className="p-2">
                <button className="w-full flex items-center gap-3 px-2 py-2 rounded hover:bg-slate-50 text-sm text-slate-700" onClick={() => { /* navigate to change password */ }}>
                  <Key size={16} />
                  <span>Đổi Mật Khẩu</span>
                </button>
                <button className="w-full flex items-center gap-3 px-2 py-2 rounded hover:bg-slate-50 text-sm text-slate-700" onClick={() => { /* perform logout */ }}>
                  <LogOut size={16} />
                  <span>Đăng Xuất</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}

function Sidebar({
  onClose,
  overlay = false,
}: {
  onClose: () => void;
  overlay?: boolean;
}) {
  const location = useLocation()
  const [selected, setSelected] = useState<string | null>(() => window.location.pathname || null)

  useEffect(() => {
    // keep selected in sync when route changes (deep-linking / back button)
    setSelected(location.pathname)
  }, [location.pathname])
  const items = [
    { to: "/lecturers", icon: Home, label: "Trang chủ" },
    { to: "/lecturers/do-an", icon: FileText, label: "Đồ án" },
    { to: "/lecturers/nhat-ky", icon: CalendarCheck, label: "Nhật ký tiến độ" },
    { to: "/lecturers/bao-cao", icon: ClipboardCheck, label: "Báo cáo" },
    { to: "/lecturers/hoi-dong", icon: Building, label: "Hội đồng" },
  ];

  const body = (
    <aside className="h-full w-[259px] bg-[#2F7CD3] text-white flex flex-col shadow-md rounded-br-xl relative px-5 py-6">
      {/* Top small nav (Trang chủ) */}
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
          // make 'Đồ án' a collapsible with submenu
          if (to === '/lecturers/do-an') {
            return (
              <DoAnItem key={to} to={to} Icon={Icon} overlay={overlay} onClose={onClose} />
            )
          }

            return (
            <NavLink key={to} to={to} end={to === "/lecturers"} onClick={() => { if (overlay) onClose(); setSelected(to) }} className="block w-[219px]">
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

      <div className="mt-auto">
        <div className="w-[219px] bg-[#2F7CD3] rounded-[12px] px-4 py-3 text-white font-medium">Phản biện</div>
        <div className="mt-3 p-2 text-xs text-white/80">© Khoa CNTT</div>
      </div>
    </aside>
  );

  function DoAnItem({ to, Icon, overlay, onClose }: { to: string; Icon: any; overlay: boolean; onClose: () => void }) {
    const location = useLocation();
    const [open, setOpen] = useState(() => location.pathname.startsWith('/lecturers/do-an'))

    // keep submenu open when the current route is under /lecturers/do-an
    useEffect(() => {
      setOpen(location.pathname.startsWith('/lecturers/do-an'))
    }, [location.pathname])

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

  if (!overlay) return body;

  return (
    <div className="fixed inset-0 z-40 lg:hidden" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="absolute inset-y-0 left-0">{body}</div>
    </div>
  );
}

export default function LecturerApp() {
  const [open, setOpen] = useState(false);

  return (
    <div className="h-screen w-full bg-[#F5F7FB] text-slate-800">
      <Topbar onOpenSidebar={() => setOpen(true)} />

      <div className="flex h-[calc(100%-64px)]">
        <div className="hidden lg:block">
          <Sidebar onClose={() => setOpen(false)} />
        </div>
        {open && <Sidebar overlay onClose={() => setOpen(false)} />}

        <main className="flex-1 overflow-y-auto px-12 sm:px-16 py-8">
          {/* Nội dung trang con */}
          <Outlet />
        </main>
      </div>
    </div>
  );
}
