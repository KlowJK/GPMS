import React, { useEffect, useMemo, useState } from 'react';
import { NavLink, useLocation } from 'react-router-dom';

type LinkItem = { to: string; label: string };
type Group = { header: string; children: LinkItem[] };

export default function AdminSidebar({
  overlay = false,
  onClose,
}: {
  overlay?: boolean;
  onClose?: () => void;
}) {
  const location = useLocation();

  const groups: Group[] = useMemo(
    () => [
      {
        header: 'Quản lý tài khoản',
        children: [
          { to: '/admin/lectures', label: 'Giảng viên' }, // giữ đúng path router hiện tại
          { to: '/admin/students', label: 'Sinh viên' },
        ],
      },
      {
        header: 'Quản lý tổ chức',
        children: [
          { to: '/admin/departments', label: 'Quản lý khoa' },
          { to: '/admin/subjects', label: 'Quản lý bộ môn' },
          { to: '/admin/majors', label: 'Quản lý ngành' },
          { to: '/admin/classes', label: 'Quản lý lớp' },
        ],
      },
    ],
    []
  );

  // mở nhóm nếu route hiện tại khớp với bất kỳ child
  const initialOpen = useMemo<Record<string, boolean>>(() => {
    const map: Record<string, boolean> = {};
    for (const g of groups) {
      map[g.header] = g.children.some(
        (c) => location.pathname === c.to || location.pathname.startsWith(c.to + '/')
      );
    }
    return map;
  }, [groups, location.pathname]);

  const [open, setOpen] = useState<Record<string, boolean>>(initialOpen);
  useEffect(() => setOpen(initialOpen), [initialOpen]);

  const body = (
    <aside className="w-64 h-full bg-blue-600 text-white rounded-br-[10px] flex flex-col py-4 shadow-md">
      {groups.map((group) => (
        <div key={group.header} className="mt-2">
          <button
            type="button"
            onClick={() => setOpen((s) => ({ ...s, [group.header]: !s[group.header] }))}
            className="w-full px-4 py-2 text-[13px] font-medium opacity-90 flex items-center gap-2 hover:text-white"
          >
            <span>{group.header}</span>
            <span className="ml-auto text-xs">{open[group.header] ? '▾' : '▸'}</span>
          </button>

          {open[group.header] && (
            <div className="mt-1">
              {group.children.map((link) => (
                <NavLink
                  key={link.to}
                  to={link.to}
                  end
                  className={({ isActive }) =>
                    `mx-3 mb-2 block rounded-xl px-4 py-3 text-sm font-medium transition ${
                      isActive ? 'bg-white text-slate-700' : 'hover:bg-blue-500 text-white'
                    }`
                  }
                  onClick={() => {
                    if (overlay) onClose?.();
                  }}
                >
                  {link.label}
                </NavLink>
              ))}
            </div>
          )}
        </div>
      ))}
    </aside>
  );

  if (!overlay) return body;

  // Mobile overlay
  return (
    <div className="fixed inset-0 z-40 lg:hidden" role="dialog" aria-modal="true">
      <div className="absolute inset-0 bg-black/40" onClick={onClose} />
      <div className="absolute inset-y-0 left-0">{body}</div>
    </div>
  );
}
