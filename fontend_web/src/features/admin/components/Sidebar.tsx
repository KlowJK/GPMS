// src/features/admin/components/Sidebar.tsx
import { NavLink, useLocation } from 'react-router-dom'
import { useMemo } from 'react'

export default function AdminSidebar() {
  const location = useLocation()

  const items = useMemo(() => [
    {
      header: 'Quản lý tài khoản',
      children: [
        { to: '/admin/lecturers', label: 'Giảng viên' },
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
  ], [])

  return (
    <aside className="w-64 h-full bg-blue-600 text-white rounded-br-[10px] flex flex-col py-4 shadow-md">
      {items.map(group => (
        <div key={group.header} className="mt-2">
          <div className="px-4 text-[13px] font-medium opacity-90 mb-2">{group.header}</div>
          {group.children.map(link => (
            <NavLink
              key={link.to}
              to={link.to}
              className={({ isActive }) =>
                `mx-3 mb-2 block rounded-xl px-4 py-3 text-sm font-medium transition ${
                  isActive ? 'bg-white text-slate-700' : 'hover:bg-blue-500 text-white'
                }`
              }
            >
              {link.label}
            </NavLink>
          ))}
        </div>
      ))}
    </aside>
  )
}
