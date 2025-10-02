import { useState } from "react";
import { Outlet, NavLink } from "react-router-dom";
import { Bell, Menu, Home, FileText, CalendarCheck, ClipboardCheck, Building, X } from "lucide-react";


function Topbar({ onOpenSidebar }: { onOpenSidebar: () => void }) {
  return (
    <header className="h-16 bg-white border-b shadow-sm flex items-center justify-between px-4 sm:px-6">
      <div className="flex items-center gap-3">
        <button
          className="lg:hidden p-2 rounded-md hover:bg-slate-100"
          aria-label="Mở sidebar"
          onClick={onOpenSidebar}
        >
          <Menu size={22} />
        </button>
        <img src="/logo_tlu.png" alt="TLU" className="h-10 w-10 object-contain" />
        <div className="leading-tight">
          <div className="font-bold text-[13px] sm:text-sm">TRƯỜNG ĐẠI HỌC THỦY LỢI</div>
          <div className="text-[11px] sm:text-xs text-slate-500">KHOA CÔNG NGHỆ THÔNG TIN</div>
        </div>
      </div>

      <div className="relative">
        <button className="p-2 rounded-md hover:bg-slate-100" aria-label="Thông báo">
          <Bell size={20} />
        </button>
        <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[10px] rounded-full h-4 w-4 grid place-items-center">
          3
        </span>
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
  const items = [
    { to: "/lecturers", icon: Home, label: "Trang chủ" },
    { to: "/lecturers/do-an", icon: FileText, label: "Đồ án" },
    { to: "/lecturers/nhat-ky", icon: CalendarCheck, label: "Nhật ký tiến độ" },
    { to: "/lecturers/bao-cao", icon: ClipboardCheck, label: "Báo cáo" },
    { to: "/lecturers/hoi-dong", icon: Building, label: "Hội đồng" },
  ];

  const body = (
    <aside className="h-full w-[260px] bg-[#2F7CD3] text-white flex flex-col">
      <div className="h-16 flex items-center justify-between px-4 lg:hidden">
        <span className="font-semibold">Menu</span>
        <button className="p-2 rounded-md hover:bg-white/10" onClick={onClose} aria-label="Đóng sidebar">
          <X />
        </button>
      </div>
      <nav className="px-2 py-3 space-y-1">
        {items.map(({ to, icon: Icon, label }) => (
          <NavLink
            key={to}
            to={to}
            onClick={overlay ? onClose : undefined}
            end={to === "/lecturers"} // active đúng với trang chủ
            className={({ isActive }) =>
              `flex items-center gap-3 px-3 py-2 rounded-lg transition-colors hover:bg-white/15 ${
                isActive ? "bg-white/10 border-l-4 border-white" : ""
              }`
            }
          >
            <Icon size={18} />
            <span className="text-sm font-medium">{label}</span>
          </NavLink>
        ))}
      </nav>
    </aside>
  );

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

        <main className="flex-1 overflow-y-auto px-6 sm:px-8 py-6">
          {/* Nội dung trang con */}
          <Outlet />
        </main>
      </div>
    </div>
  );
}
