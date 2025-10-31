import { NavLink, useLocation } from 'react-router-dom';
import { useEffect, useMemo, useState } from 'react';

type Item = { to: string; label: string };

function Group({ label, items }: { label: string; items: Item[] }) {
  const location = useLocation();

  // Đang ở bất kỳ route con nào của nhóm?
  const active = useMemo(
    () => items.some(i => location.pathname.startsWith(i.to)),
    [location.pathname, items]
  );

  const [open, setOpen] = useState(active);
  // Tự mở nhóm khi điều hướng vào route con
  useEffect(() => { if (active) setOpen(true); }, [active]);

  return (
    <div className="mt-2">
      <button
        onClick={() => setOpen(s => !s)}
        aria-expanded={open}
        className={`w-full h-10 px-4 rounded-lg text-left transition text-white flex items-center justify-between
          ${active ? 'bg-white/10 font-semibold' : 'hover:bg-white/10'}`}
      >
        <span>{label}</span>
        <span className={`transition-transform ${open ? 'rotate-180' : ''}`}>▾</span>
      </button>

      {open && (
        <div className="mt-1 space-y-1">
          {items.map(i => (
            <NavLink
              key={i.to}
              to={i.to}
              className={({ isActive }) =>
                `block mx-2 h-10 leading-10 px-3 rounded-lg
                 ${isActive ? 'bg-white text-blue-600 font-semibold' : 'text-white hover:bg-white/10'}`
              }
            >
              {i.label}
            </NavLink>
          ))}
        </div>
      )}
    </div>
  );
}

export default function Sidebar() {
  return (
    <aside className="w-72 bg-[#2F7CD3] text-white p-3 h-screen sticky top-0 overflow-auto">
      {/* Trang chủ – luôn rõ, có trạng thái active */}
      <NavLink
        to="/assistant"
        end
        className={({ isActive }) =>
          `block h-10 leading-10 px-4 rounded-lg mb-1
           ${isActive ? 'bg-white text-blue-600 font-semibold' : 'text-white hover:bg-white/10'}`
        }
      >
        Trang chủ
      </NavLink>

      <Group
        label="Quản lý tài khoản"
        items={[{ to: '/assistant/staff', label: 'Giảng viên' }]}
      />

      <Group
        label="Quản lý tổ chức"
        items={[
          { to: '/assistant/subjects', label: 'Quản lý bộ môn' },
          { to: '/assistant/majors', label: 'Quản lý ngành' },
        ]}
      />

      {/* Đồ án */}
      <Group
        label="Đồ án"
        items={[
          { to: '/assistant/defense-rounds', label: 'Quản lý đợt bảo vệ' },
          { to: '/assistant/round-schedule', label: 'Thời gian thực hiện' },
        ]}
      />
    </aside>
  );
}
