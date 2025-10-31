import React from 'react'
import usePhanBienViewModel from '../viewmodels/PhanBienViewmodels'
import { useAuth } from '@features/auth/useAuth'

export default function PhanBienPage() {
  const vm = usePhanBienViewModel()
  const { user } = useAuth()

  // determine a reasonable display name from the logged in user
  const currentName = (user?.fullName ?? user?.name ?? user?.hoTen ?? user?.username ?? '').toString()

  // only show proposals where the current user is among the reviewers (giangVienPhanBien)
  const visibleItems = (vm.items || []).filter((it: any) => {
    const gv = (it.giangVienPhanBien ?? '')
    if (!gv) return false
    // giangVienPhanBien may be a comma-separated string or single name
    return gv.toString().includes(currentName)
  })

  function renderStatusBadge(raw: any) {
    const s = raw == null ? '' : String(raw)
    const key = s.toUpperCase().normalize('NFKD').replace(/\s+|_|-|\./g, '')

    if (!s) {
      return <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-700">Chưa phản biện</span>
    }

    if (key.includes('DADUYET') || key === 'DA' || key.includes('DA_DUYET') || key === 'TRUE') {
      return <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-emerald-100 text-emerald-800">Đã duyệt</span>
    }

    if (key.includes('CHOXET') || key.includes('CHODUYET') || key === 'CHO') {
      return <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-amber-100 text-amber-800">Chờ duyệt</span>
    }

    if (key.includes('TUCHOI') || key.includes('TUCHỐI') || key.includes('TU_CHOI') || key.includes('TUCHOI') || key === 'FALSE') {
      return <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-rose-100 text-rose-800">Từ chối</span>
    }

    // fallback: show raw as neutral badge
    return <span className="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-slate-100 text-slate-700">{s}</span>
  }

  return (
    <div className="min-h-[calc(100vh-80px)]">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-semibold">Phản biện</h1>
        <div className="text-sm text-slate-500">Quản lý giảng viên phản biện và phiếu phản biện</div>
      </div>

      <div className="bg-white shadow rounded p-6">
        {vm.isLoading ? (
          <div className="p-6 text-center">Đang tải...</div>
        ) : !(vm.items && vm.items.length) ? (
          <div className="p-6 text-center text-slate-500">Chưa có nhiệm vụ phản biện</div>
        ) : (
          <table className="min-w-full text-sm">
            <thead>
              <tr className="bg-slate-50">
                <th className="px-3 py-2 text-left">Mã SV</th>
                <th className="px-3 py-2 text-left">Họ và tên</th>
                <th className="px-3 py-2 text-left">Đề tài</th>
                <th className="px-3 py-2 text-left">GV phản biện</th>
                <th className="px-3 py-2 text-left">Trạng thái</th>
                <th className="px-3 py-2 text-left">Hành động</th>
              </tr>
            </thead>
            <tbody>
              {visibleItems.map((it: any) => (
                <tr key={it.id} className="border-b hover:bg-slate-50">
                  <td className="px-3 py-2">{it.maSinhVien}</td>
                  <td className="px-3 py-2">{it.hoTenSinhVien}</td>
                  <td className="px-3 py-2">{it.tenDeTai}</td>
                  <td className="px-3 py-2">{it.giangVienPhanBien}</td>
                  <td className="px-3 py-2">{renderStatusBadge(it.gvPhanBienDuyet)}</td>
                  <td className="px-3 py-2">
                    <div className="flex gap-2">
                      <button className="px-3 py-1 rounded bg-sky-600 text-white text-sm">Chi tiết</button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  )
}
