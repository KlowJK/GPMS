import { NavLink, useLocation } from 'react-router-dom';
import { useMemo } from 'react';

type Props = {
  /** Dùng cho mobile overlay */
  overlay?: boolean;
  /** Đóng overlay khi click item */
  onClose?: () => void;
};

export default function AdminSidebar({ overlay = false, onClose }: Props) {
  const { pathname } = useLocation();

  // Danh mục cho Quản trị viên (đã lược bỏ Bộ môn/Ngành/Lớp theo yêu cầu)
  const items = useMemo(
    () => [
      { to: '/admin', label: 'Trang chủ', exact: true },
      { to: '/admin/departments', label: 'Quản lý Khoa' },
      { to: '/admin/assistants', label: 'Quản lý Trợ lý khoa' },
      { to: '/admin/notifications', label: 'Quản lý Thông báo' },
    ],
    []
  );

  const body = (
    <aside className="w-64 h-full bg-blue-600 text-white rounded-br-[10px] flex flex-col py-4 shadow-md">
      <nav className="space-y-2">
        {items.map((link) => (
          <NavLink
            key={link.to}
            to={link.to}
            end={link.exact}
            className={({ isActive }) =>
              `mx-3 mb-2 block rounded-xl px-4 py-3 text-sm font-medium transition ${
                isActive || pathname === link.to
                  ? 'bg-white text-slate-700'
                  : 'hover:bg-blue-500 text-white'
              }`
            }
            onClick={() => {
              if (overlay) onClose?.();
            }}
          >
            {link.label}
          </NavLink>
        ))}
      </nav>
    </aside>
  );

  if (!overlay) return body;

  // Overlay cho mobile
  return (
    <div className="fixed inset-0 z-40 lg:hidden" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="absolute inset-y-0 left-0">{body}</div>
    </div>
  );
}
